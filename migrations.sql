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


-- Example migrations follow

SELECT apply_migration('create_things_table', $$
    CREATE TABLE things (
      name TEXT
      );
$$);


SELECT apply_migration('alter_things_table', $$
    ALTER TABLE things ADD number INTEGER;
$$);
