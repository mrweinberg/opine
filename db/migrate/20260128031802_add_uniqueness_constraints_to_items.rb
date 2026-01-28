class AddUniquenessConstraintsToItems < ActiveRecord::Migration[8.1]
  def up
    # Places: Name + City must be unique
    execute <<~SQL
      CREATE UNIQUE INDEX index_items_unique_places#{' '}
      ON items (name, (metadata->>'city'))#{' '}
      WHERE subcategory IN ('Restaurants', 'Bars', 'Parks', 'Museums');
    SQL

    # Drinks: Name + Producer + Vintage must be unique
    execute <<~SQL
      CREATE UNIQUE INDEX index_items_unique_drinks#{' '}
      ON items (name, (metadata->>'producer'), (metadata->>'vintage'))#{' '}
      WHERE subcategory IN ('Wine', 'Beer', 'Liquor');
    SQL

    # Movies: Name + Release Year must be unique
    execute <<~SQL
      CREATE UNIQUE INDEX index_items_unique_movies#{' '}
      ON items (name, (metadata->>'release_year'))#{' '}
      WHERE subcategory = 'Movies';
    SQL
  end

  def down
    execute "DROP INDEX IF EXISTS index_items_unique_places;"
    execute "DROP INDEX IF EXISTS index_items_unique_drinks;"
    execute "DROP INDEX IF EXISTS index_items_unique_movies;"
  end
end
