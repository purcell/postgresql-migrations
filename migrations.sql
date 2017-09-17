-- This file provides a method for applying incremental schema changes
-- to a PostgreSQL database.

-- Add your migrations at the end of the file, and run "psql -v ON_ERROR_STOP=1 -1f
-- migrations.sql yourdbname" to apply all pending migrations. The
-- "-1" causes all the changes to be applied atomically

-- Most Rails (ie. ActiveRecord) migrations are run by a user with
-- full read-write access to both the schema and its contents, which
-- isn't ideal. You'd generally run this file as a database owner, and
-- the contained migrations would grant access to less-privileged
-- application-level users as appropriate.

-- Refer to https://github.com/purcell/postgresql-migrations for info and updates

--------------------------------------------------------------------------------
-- A function that will apply an individual migration
--------------------------------------------------------------------------------
DO
$body$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_proc WHERE proname = 'apply_migration') THEN
    CREATE FUNCTION apply_migration (migration_name TEXT, ddl TEXT) RETURNS BOOLEAN
      AS $$
    BEGIN
      CREATE TABLE IF NOT EXISTS applied_migrations (
          identifier TEXT NOT NULL PRIMARY KEY
        , ddl TEXT NOT NULL
        , applied_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
      );
      LOCK TABLE applied_migrations IN EXCLUSIVE MODE;
      IF NOT EXISTS (SELECT 1 FROM applied_migrations m WHERE m.identifier = migration_name)
      THEN
        EXECUTE ddl;
        INSERT INTO applied_migrations (identifier, ddl) VALUES (migration_name, ddl);
        RETURN TRUE;
      END IF;
      RETURN FALSE;
    END;
    $$ LANGUAGE plpgsql;
  END IF;
END
$body$;

--------------------------------------------------------------------------------
-- Example migrations follow, commented out
--------------------------------------------------------------------------------

-- -- Give each migration a unique name:
-- SELECT apply_migration('create_things_table',
-- $$
--   -- SQL to apply goes here
--   CREATE TABLE things (
--     name TEXT
--   );
-- $$);

-- -- Add more migrations in the order you'd like them to be applied:
-- SELECT apply_migration('alter_things_table',
-- $$
--   -- You can place not just one statement...
--   ALTER TABLE things ADD number INTEGER;
--   -- ...but multiple in here.
--   ALTER TABLE things ALTER name SET NOT NULL;
--   -- All statements will be run in a transaction.
-- $$);
