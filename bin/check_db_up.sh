#!/bin/bash -e
export PGPASSWORD=transitclock

echo 'THETRANSITCLOCK DOCKER: Check if database is runnng.'

while ! psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres -c "SELECT EXTRACT(DAY FROM TIMESTAMP '2001-02-16 20:38:40');"; do
    echo 'Database is not running.'
    sleep 10
done
echo 'THETRANSITCLOCK DOCKER: Database is now running.'
