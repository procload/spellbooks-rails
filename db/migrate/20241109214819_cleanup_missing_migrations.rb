class CleanupMissingMigrations < ActiveRecord::Migration[7.0]
  def up
    # Remove entries for missing migrations
    execute <<-SQL
      DELETE FROM schema_migrations 
      WHERE version IN ('20241109031728', '20241109211236', '20241109211237', '20241109211433');
    SQL
  end

  def down
    # This migration is not reversible
    raise ActiveRecord::IrreversibleMigration
  end
end 