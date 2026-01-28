class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :item, null: false, foreign_key: true, type: :uuid
      t.integer :score, null: false
      t.text :body

      t.timestamps
    end

    add_index :reviews, [ :user_id, :item_id ], unique: true
  end
end
