class AddAiEstimatedScoreToItems < ActiveRecord::Migration[8.1]
  def change
    add_column :items, :ai_estimated_score, :integer
  end
end
