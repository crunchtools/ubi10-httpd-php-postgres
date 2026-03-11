#!/bin/bash
set -e

PGDATA="/var/lib/pgsql/data"

# If PGDATA is empty, initialize it
if [ ! -f "$PGDATA/PG_VERSION" ]; then
    echo "postgres-prep: Initializing PostgreSQL database..."
    postgresql-setup --initdb
    # Set trust auth for local connections
    cat > "$PGDATA/pg_hba.conf" <<'EOHBA'
local   all             all                                     trust
host    all             all             127.0.0.1/32            trust
host    all             all             ::1/128                 trust
EOHBA
    chown postgres:postgres "$PGDATA/pg_hba.conf"
fi

echo "postgres-prep: Done."
