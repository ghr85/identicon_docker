#Default compose args
COMPOSE_ARGS=" -f jenkins.yml -p jenkins"

# Make sure all the old containers are gone, stop them and remove containers/volumes
sudo docker-compose $COMPOSE_ARGS stop
sudo docker-compose $COMPOSE_ARGS rm --force -v

# Now rebuild from scratch
sudo docker-compose $COMPOSE_ARGS build --no-cache
sudo docker-compose $COMPOSE_ARGS up -d

# Run Unit Tests
sudo docker-compose $COMPOSE_ARGS run --no-deps -rm -e ENV=UNIT identidock ERR=$?

# Run system test if unit tests passed, inspect container to obtain IP address, curl identidock service to determine if 200 response
if [ $ERR -eq 0 ]; then
	$IP=$(sudo docker inspect -f {{.NetworkSettings.IPAddress}} jenkins_identidock_1)
	$CODE=$(curl -sL -w "%{http_code}" $IP:9090/monster/bla -o /dev/null) || true
	if [ $CODE -ne 200 ]; then
		echo 'site returned' $CODE
    	ERR=1
	fi
fi
    
# Pull down the system once complete
sudo docker-compose $COMPOSE_ARGS stop
sudo docker-compose $COMPOSE_ARGS rm --force -v

return $ERR
