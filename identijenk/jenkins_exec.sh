#Default compose args
COMPOSE_ARGS=" -f jenkins.yml -p jenkins"

# Make sure all the old containers are gone, stop them and remove containers/volumes
sudo docker-compose $COMPOSE_ARGS stop
sudo docker-compose $COMPOSE_ARGS rm --force -v

# Now rebuild from scratch
sudo docker-compose $COMPOSE_ARGS build --no-cache
sudo docker-compose $COMPOSE_ARGS up -d

# Run Unit Tests
sudo docker-compose $COMPOSE_ARGS run --no-deps --rm -e ENV=UNIT identidock
ERR=$?

# Run system test if unit tests passed, inspect container to obtain IP address, curl identidock service to determine if 200 response
if [ $ERR -eq 0 ]; then
# Get the IP of the container
	IP=$(sudo docker inspect -f {{.NetworkSettings.IPAddress}} jenkins_identidock_1)
    # Ping the container and test for 200 status note variable set so as assingment works
	CODE=$(curl -sL -w "%{http_code}" $IP:9090/monster/bla -o /dev/null) || true
	if [ $CODE -eq 200 ]; then
        echo 'System test passed - now tagging image'
        # get the head of the latest commit
        HASH=$(git rev-parse --short HEAD)
        sudo docker tag -f jenkins_identidock ghruoa/identidock:$HASH
        sudo docker tag -f jenkins_identidock ghruoa/identidock:newest
        echo 'Pushing tagged image'
        sudo docker login -e $1 -u $2 -p $3
        sudo docker push ghruoa/identidock:$HASH
        sudo docker push ghruoa/identidock:newest
    else
		echo 'site returned' $CODE
    	ERR=1
	fi
fi
    
# Pull down the system once complete
sudo docker-compose $COMPOSE_ARGS stop
sudo docker-compose $COMPOSE_ARGS rm --force -v

return $ERR
