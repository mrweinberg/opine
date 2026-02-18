class AddTagsToReviews < ActiveRecord::Migration[8.1]
  def change
    add_column :reviews, :tags, :text, array: true, default: []
    add_index :reviews, :tags, using: :gin
  end
end
