module ScoreHelper
  SCORE_COLORS = {
    1 => { bg: "bg-score-1", text: "text-score-1", border: "border-score-1" },
    2 => { bg: "bg-score-2", text: "text-score-2", border: "border-score-2" },
    3 => { bg: "bg-score-3", text: "text-score-3", border: "border-score-3" },
    4 => { bg: "bg-score-4", text: "text-score-4", border: "border-score-4" },
    5 => { bg: "bg-score-5", text: "text-score-5", border: "border-score-5" },
    6 => { bg: "bg-score-6", text: "text-score-6", border: "border-score-6" }
  }.freeze

  def score_bg_class(score)
    SCORE_COLORS.dig(score.to_i, :bg) || "bg-sand"
  end

  def score_text_class(score)
    SCORE_COLORS.dig(score.to_i, :text) || "text-walnut"
  end

  def score_border_class(score)
    SCORE_COLORS.dig(score.to_i, :border) || "border-sand"
  end

  # Returns the peer-checked classes for the radio button inputs.
  # We list them explicitly here so the Tailwind scanner detects the full class names.
  def score_input_classes(score)
    case score.to_i
    when 1 then "peer-checked:bg-score-1 peer-checked:border-score-1"
    when 2 then "peer-checked:bg-score-2 peer-checked:border-score-2"
    when 3 then "peer-checked:bg-score-3 peer-checked:border-score-3"
    when 4 then "peer-checked:bg-score-4 peer-checked:border-score-4"
    when 5 then "peer-checked:bg-score-5 peer-checked:border-score-5"
    when 6 then "peer-checked:bg-score-6 peer-checked:border-score-6"
    end
  end
end
