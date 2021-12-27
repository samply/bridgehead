echo "Stoping bridgehead"

source site.conf

cd ${project}

docker-compose --env-file ../site-config/${project}.env down

cd ..
