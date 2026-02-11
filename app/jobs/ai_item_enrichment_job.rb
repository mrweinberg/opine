# frozen_string_literal: true

class AiItemEnrichmentJob < ApplicationJob
  queue_as :default

  def perform(item_id)
    item = Item.find_by(id: item_id)
    return unless item

    result = AiMetadataService.new.enrich(item)
    return unless result

    # Only overwrite metadata if the user hasn't manually edited it
    unless item.metadata_edited_by_user?
      merged_metadata = (item.metadata || {}).merge(result[:metadata].stringify_keys)
      item.metadata = merged_metadata
    end

    item.ai_summary = result[:ai_summary]
    item.ai_estimated_score = result[:ai_estimated_score]
    item.ai_last_updated_at = Time.current
    item.save!(validate: false) # Skip validations — metadata may have been corrected

    # Broadcast Turbo Stream update to replace the AI summary section
    Turbo::StreamsChannel.broadcast_replace_to(
      item,
      target: "ai_summary_#{item.id}",
      partial: "items/ai_summary",
      locals: { item: item }
    )
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.warn("[AiItemEnrichmentJob] Item not found: #{e.message}")
  rescue StandardError => e
    Rails.logger.error("[AiItemEnrichmentJob] Failed for item #{item_id}: #{e.message}")
    Rails.logger.error(e.backtrace&.first(5)&.join("\n"))

    # Broadcast an "unavailable" state so the spinner disappears
    if item
      item.update_columns(ai_summary: "Unavailable", ai_last_updated_at: Time.current)
      Turbo::StreamsChannel.broadcast_replace_to(
        item,
        target: "ai_summary_#{item.id}",
        partial: "items/ai_summary",
        locals: { item: item.reload }
      )
    end
  end
end
