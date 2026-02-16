# frozen_string_literal: true

class AiMetadataService
  MODEL = "gemini-3-flash-preview"
  MAX_RETRIES = 3
  INITIAL_BACKOFF = 1 # seconds

  class EnrichmentError < StandardError; end

  def initialize(api_key: nil)
    key = api_key || ENV["GEMINI_API_KEY"]
    raise EnrichmentError, "GEMINI_API_KEY not configured" if key.blank?

    @client = Google::Genai::Client.new(api_key: key)
  end

  # Returns { metadata: Hash, ai_summary: String, ai_estimated_score: Integer } or nil on failure.
  def enrich(item)
    prompt = build_prompt(item)
    raw = call_gemini(prompt)
    parse_response(raw, item)
  rescue EnrichmentError, JSON::ParserError => e
    Rails.logger.error("[AiMetadataService] Failed to enrich item #{item.id}: #{e.message}")
    nil
  end

  # Step 1: Suggest metadata fields based on name + known identifiers.
  # Returns a Hash of { "field_name" => "value" } or nil on failure.
  def suggest_metadata(name:, subcategory:, known_fields: {})
    fields = Item::ATTRIBUTE_DEFINITIONS[subcategory] || []
    return nil if fields.empty?

    missing_fields = fields.map(&:to_s) - known_fields.keys.map(&:to_s)
    return known_fields.stringify_keys if missing_fields.empty?

    prompt = build_suggest_prompt(name, subcategory, fields, known_fields)
    raw = call_gemini(prompt)
    data = parse_json(raw)

    return nil unless data.is_a?(Hash)

    sanitized = data.transform_values { |v| v.to_s.strip }.compact_blank
    expected = fields.map(&:to_s)
    sanitized.slice(*expected)
  rescue EnrichmentError, JSON::ParserError => e
    Rails.logger.error("[AiMetadataService] suggest_metadata failed: #{e.message}")
    nil
  end

  private

  def build_prompt(item)
    fields = Item::ATTRIBUTE_DEFINITIONS[item.subcategory] || []
    current_metadata = item.metadata || {}

    <<~PROMPT
      You are a data validation and enrichment assistant for a review platform called Opine.
      Opine uses a strict 6-point integer scale (1-6) where 1 is worst and 6 is best.

      The #{item.subcategory} named "#{item.name}" has the following metadata:
      #{current_metadata.map { |k, v| "- #{k}: #{v}" }.join("\n")}

      Expected fields: #{fields.map(&:to_s).join(", ")}

      Please:
      1. Validate and correct the metadata values above. Fix any typos, standardize casing, and fill in any missing fields if you can determine them from public knowledge. Return ALL expected fields.
      2. Write a public sentiment summary (what the general public thinks of this #{item.subcategory.downcase}). Keep it to 4 sentences or fewer.
      3. Estimate a rating on a 6-point scale (1 = terrible, 6 = outstanding) based on general public opinion.

      Respond with ONLY valid JSON in this exact format, no markdown fencing:
      {
        "metadata": { #{fields.map { |f| "\"#{f}\": \"value\"" }.join(", ")} },
        "ai_summary": "Your 1-4 sentence public sentiment summary.",
        "ai_estimated_score": 4
      }
    PROMPT
  end

  def call_gemini(prompt, retries: 0)
    response = @client.models.generate_content(
      model: MODEL,
      contents: prompt,
      config: { response_mime_type: "application/json" }
    )

    response.text
  rescue Faraday::TooManyRequestsError, Faraday::TimeoutError => e
    raise EnrichmentError, "Max retries exceeded: #{e.message}" if retries >= MAX_RETRIES

    backoff = INITIAL_BACKOFF * (2**retries)
    Rails.logger.warn("[AiMetadataService] #{e.class.name}, retrying in #{backoff}s (attempt #{retries + 1}/#{MAX_RETRIES})")
    sleep(backoff)
    call_gemini(prompt, retries: retries + 1)
  rescue StandardError => e
    raise EnrichmentError, "Gemini API error: #{e.message}"
  end

  def parse_response(raw_text, item, retry_attempted: false)
    # Strip markdown fencing if present (despite our prompt asking not to)
    cleaned = raw_text.gsub(/\A```(?:json)?\s*/, "").gsub(/\s*```\z/, "").strip
    data = JSON.parse(cleaned)

    metadata = data["metadata"]
    summary = data["ai_summary"]
    score = data["ai_estimated_score"]&.to_i

    unless metadata.is_a?(Hash) && summary.is_a?(String) && score.is_a?(Integer)
      raise JSON::ParserError, "Invalid response structure"
    end

    score = score.clamp(1, 6)

    {
      metadata: sanitize_metadata(metadata, item),
      ai_summary: summary.truncate(2000),
      ai_estimated_score: score
    }
  rescue JSON::ParserError => e
    if retry_attempted
      raise EnrichmentError, "Failed to parse AI response after retry: #{e.message}"
    end

    Rails.logger.warn("[AiMetadataService] JSON parse failed, retrying with stricter prompt")
    retry_prompt = "#{raw_text}\n\nThe above was not valid JSON. Please respond with ONLY valid JSON, no markdown fencing, no explanation."
    raw_retry = call_gemini(retry_prompt)
    parse_response(raw_retry, item, retry_attempted: true)
  end

  def build_suggest_prompt(name, subcategory, fields, known_fields)
    known_lines = known_fields.map { |k, v| "- #{k}: #{v}" }.join("\n")

    <<~PROMPT
      You are a data enrichment assistant. Given a #{subcategory} named "#{name}" with these known details:
      #{known_lines.presence || "(none)"}

      Please provide accurate values for ALL of these fields based on public knowledge:
      #{fields.map(&:to_s).join(", ")}

      Respond with ONLY valid JSON, no markdown fencing, in this exact format:
      { #{fields.map { |f| "\"#{f}\": \"value\"" }.join(", ")} }
    PROMPT
  end

  def parse_json(raw_text)
    cleaned = raw_text.gsub(/\A```(?:json)?\s*/, "").gsub(/\s*```\z/, "").strip
    JSON.parse(cleaned)
  end

  def sanitize_metadata(ai_metadata, item)
    expected_fields = (Item::ATTRIBUTE_DEFINITIONS[item.subcategory] || []).map(&:to_s)
    ai_metadata.slice(*expected_fields).transform_values { |v| v.to_s.strip }.compact_blank
  end
end
