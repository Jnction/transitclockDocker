#!/bin/sh -e
psql -h "$POSTGRES_PORT_5432_TCP_ADDR" -p "$POSTGRES_PORT_5432_TCP_PORT" -U postgres -d $AGENCYNAME -t -c "SELECT applicationkey from apikeys;"|xargs