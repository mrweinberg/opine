class AddTvShowsSupport < ActiveRecord::Migration[8.1]
  def change
    add_column :items, :season, :string, as: "metadata ->> 'season'", stored: true
    add_index :items, :season

    # TV Shows: Unique by Name + Season
    execute <<~SQL
      CREATE UNIQUE INDEX index_items_unique_tv_shows
      ON items (name, season)#{' '}
      WHERE subcategory = 'TV Shows';
    SQL
  end
end
