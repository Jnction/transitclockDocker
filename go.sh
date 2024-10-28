#!/bin/sh -e
export PGPASSWORD=transitclock

for container in transitclock-db transitclock-server-instance; do
    if docker container inspect $container >/dev/null 2>&1; then        
        docker stop $container
        docker rm $container
    fi
done

if docker image inspect transitclock-server >/dev/null 2>&1; then 
    docker rmi transitclock-server
fi

docker build --no-cache -t transitclock-server \
--progress tty \
--build-arg TRANSITCLOCK_PROPERTIES="config/transitclock.properties" \
--build-arg AGENCYID="WDBC" \
--build-arg AGENCYNAME="morebus" \
--build-arg GTFS_URL="http://host.docker.internal/combined_gtfs.zip" \
--build-arg GTFSRTVEHICLEPOSITIONS="https://internal-proxy.servology.co.uk/dft/bus-data/gtfsrt/" .

docker run --name transitclock-db -p 5432:5432 -e POSTGRES_PASSWORD=$PGPASSWORD -d postgres:9.6.3

docker run --name transitclock-server-instance --rm --link transitclock-db:postgres -e PGPASSWORD=$PGPASSWORD -v ~/logs:/usr/local/transitclock/logs/ transitclock-server check_db_up.sh

docker run --name transitclock-server-instance --rm --link transitclock-db:postgres -e PGPASSWORD=$PGPASSWORD -v ~/logs:/usr/local/transitclock/logs/ transitclock-server create_tables.sh

docker run --name transitclock-server-instance --rm --link transitclock-db:postgres -e PGPASSWORD=$PGPASSWORD -v ~/logs:/usr/local/transitclock/logs/ transitclock-server import_gtfs.sh

docker run --name transitclock-server-instance --rm --link transitclock-db:postgres -e PGPASSWORD=$PGPASSWORD -v ~/logs:/usr/local/transitclock/logs/ transitclock-server create_api_key.sh

docker run --name transitclock-server-instance --rm --link transitclock-db:postgres -e PGPASSWORD=$PGPASSWORD -v ~/logs:/usr/local/transitclock/logs/ transitclock-server create_webagency.sh

#docker run --name transitclock-server-instance --rm --link transitclock-db:postgres -e PGPASSWORD=$PGPASSWORD transitclock-server ./import_avl.sh

#docker run --name transitclock-server-instance --rm --link transitclock-db:postgres -e PGPASSWORD=$PGPASSWORD transitclock-server ./process_avl.sh

docker run --name transitclock-server-instance --rm --link transitclock-db:postgres -e PGPASSWORD=$PGPASSWORD  -v ~/logs:/usr/local/transitclock/logs/ -v ~/ehcache:/usr/local/transitclock/cache/ -p 8080:8080 transitclock-server  start_transitclock.sh
