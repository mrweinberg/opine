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
end
