class AddGeneratedColumnsToItems < ActiveRecord::Migration[8.1]
  def change
    add_column :items, :city, :string, as: "metadata ->> 'city'", stored: true
    add_column :items, :producer, :string, as: "metadata ->> 'producer'", stored: true
    add_column :items, :vintage, :string, as: "metadata ->> 'vintage'", stored: true
    add_column :items, :release_year, :string, as: "metadata ->> 'release_year'", stored: true

    add_index :items, :city
    add_index :items, :producer
    add_index :items, :vintage
    add_index :items, :release_year
  end
end
