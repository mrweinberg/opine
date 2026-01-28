class CreateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :items, id: :uuid do |t|
      t.string :name, null: false
      t.string :category, null: false
      t.string :subcategory, null: false
      t.jsonb :metadata, default: {}
      t.text :ai_summary
      t.datetime :ai_last_updated_at
      t.decimal :average_score, precision: 3, scale: 2
      t.integer :reviews_count, default: 0
      t.boolean :metadata_edited_by_user, default: false
      t.references :created_by_user, foreign_key: { to_table: :users }, type: :uuid

      t.timestamps
    end

    add_index :items, [ :category, :subcategory ]
  end
end
