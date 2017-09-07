-- This file provides a method for applying incremental schema changes
-- to a PostgreSQL database.

-- Add your migrations at the end of the file, and run "psql -1f
-- migrations.sql yourdbname" to apply all pending migrations.

-- Most Rails (ie. ActiveRecord) migrations are run by a user with
-- full read-write access to both the schema and its contents, which
-- isn't ideal. You'd generally run this file as a database owner, and
-- the contained migrations would grant access to less-privileged
-- application-level users as appropriate.

--------------------------------------------------------------------------------
-- A function that will apply an individual migration
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION apply_migration (migration_name TEXT, ddl TEXT) RETURNS BOOLEAN
  AS $$
BEGIN
  CREATE TABLE IF NOT EXISTS schema_migrations (
      identifier TEXT NOT NULL PRIMARY KEY
    , ddl TEXT NOT NULL
    , applied_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
  );
  LOCK TABLE schema_migrations IN EXCLUSIVE MODE;
  IF NOT EXISTS (SELECT 1 FROM schema_migrations sm WHERE sm.identifier = migration_name)
  THEN
    EXECUTE ddl;
    INSERT INTO schema_migrations (identifier, ddl) VALUES (migration_name, ddl);
    RETURN TRUE;
  END IF;
  RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

--------------------------------------------------------------------------------
-- Example migrations follow
--------------------------------------------------------------------------------

-- Give each migration a unique name:
SELECT apply_migration('create_things_table', $$
  -- SQL to apply goes here
  CREATE TABLE things (
    name TEXT
  );
$$);

-- Add more migrations in the order you'd like them to be applied:
SELECT apply_migration('alter_things_table', $$
  -- You can place not just one statement
  ALTER TABLE things ADD number INTEGER;
  -- but multiple in here.
  ALTER TABLE things ALTER name SET NOT NULL;
  -- All will be run in a transaction.
$$);
