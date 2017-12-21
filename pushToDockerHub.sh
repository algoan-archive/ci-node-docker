export DOCKER_ID_USER="yelloan"
export DOCKER_IMAGE="node-docker"
export TAG="9.3.0-183.0.0"
docker build -t $DOCKER_IMAGE .
docker tag $DOCKER_IMAGE $DOCKER_ID_USER/$DOCKER_IMAGE:$TAG
docker push $DOCKER_ID_USER/$DOCKER_IMAGE