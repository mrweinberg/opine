class FixUniquenessIndexes < ActiveRecord::Migration[8.1]
  def up
    # Drop the flawed index involving vintage for all drinks
    execute "DROP INDEX IF EXISTS index_items_unique_drinks;"

    # Wine: Needs Vintage
    execute <<~SQL
      CREATE UNIQUE INDEX index_items_unique_wine#{' '}
      ON items (name, producer, vintage)#{' '}
      WHERE subcategory = 'Wine';
    SQL

    # Beer/Liquor: Unique by Name + Producer (Vintage usually NULL/irrelevant for identity matching)
    # Cleanup duplicates first (keep newest)

    # 1. Delete reviews associated with duplicate items
    execute <<~SQL
      DELETE FROM reviews#{' '}
      WHERE item_id IN (
        SELECT id FROM (
          SELECT id, ROW_NUMBER() OVER (
            PARTITION BY name, producer#{' '}
            ORDER BY created_at DESC
          ) as rnum#{' '}
          FROM items#{' '}
          WHERE subcategory IN ('Beer', 'Liquor')
        ) t#{' '}
        WHERE t.rnum > 1
      );
    SQL

    # 2. Delete the duplicate items themselves
    execute <<~SQL
      DELETE FROM items#{' '}
      WHERE id IN (
        SELECT id FROM (
          SELECT id, ROW_NUMBER() OVER (
            PARTITION BY name, producer#{' '}
            ORDER BY created_at DESC
          ) as rnum#{' '}
          FROM items#{' '}
          WHERE subcategory IN ('Beer', 'Liquor')
        ) t#{' '}
        WHERE t.rnum > 1
      );
    SQL

    execute <<~SQL
      CREATE UNIQUE INDEX index_items_unique_beer_liquor
      ON items (name, producer)#{' '}
      WHERE subcategory IN ('Beer', 'Liquor');
    SQL
  end

  def down
    execute "DROP INDEX IF EXISTS index_items_unique_wine;"
    execute "DROP INDEX IF EXISTS index_items_unique_beer_liquor;"
  end
end
