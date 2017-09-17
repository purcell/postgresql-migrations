#!/bin/sh -e

export PGDATABASE=migration-test
THISDIR=$(dirname "$0")

reset() {
    dropdb --if-exists "$PGDATABASE"
    createdb "$PGDATABASE"
}

run_migrations() {
    psql -q -v ON_ERROR_STOP=1 -1f "$1"
}

assert() {
    temp=$(mktemp)
    cat <<'EOF' > "$temp"
DO
$body$
BEGIN
EOF
    cat >> "$temp"
    cat <<'EOF' >> "$temp"
END
$body$;
EOF
    psql -q -v ON_ERROR_STOP=1 -f "$temp"
}

fail() {
    echo "TEST FAILED" >&2
    exit 1;
}

announce() {
    echo
    echo "---------------------------------------------------"
    echo "$@"
    echo "---------------------------------------------------"
}

test_file=$(mktemp)
cat "$THISDIR/migrations.sql" > "$test_file"

reset
run_migrations "$test_file"

announce "Checking initial state"
assert <<'EOF'
ASSERT (EXISTS (SELECT FROM pg_catalog.pg_proc WHERE proname = 'apply_migration'));
ASSERT (NOT EXISTS (SELECT FROM pg_catalog.pg_tables WHERE tablename = 'applied_migrations' AND schemaname = 'public'));
EOF

announce "Migrating to create a simple table."
cat <<'EOF' >> $test_file
SELECT apply_migration('create_foo', $$
CREATE TABLE foo ();
$$);
EOF
run_migrations "$test_file"

announce "Checking migration ran and was recorded"
assert <<'EOF'
ASSERT (EXISTS (SELECT 1 FROM applied_migrations WHERE identifier = 'create_foo'));
ASSERT (EXISTS (SELECT FROM pg_catalog.pg_tables WHERE tablename = 'foo' AND schemaname = 'public'));
EOF

announce "Re-running to check idempotency"
run_migrations "$test_file"
assert <<'EOF'
ASSERT (1 = (SELECT COUNT(1) FROM applied_migrations));
EOF
