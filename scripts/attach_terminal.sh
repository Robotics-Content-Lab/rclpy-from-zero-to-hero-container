#!/usr/bin/env bash

# Get the container ID
CONTAINER=$(docker container ls | grep -E "rclpy" | awk '{print $1}')
if [ -z $CONTAINER ]; then
    echo "No container found"
    exit 1
fi

# Define the environment variable
DISPLAY="${DISPLAY:-:0}"

# Execute the entrypoint script inside the container with the environment variable
docker container exec -e DISPLAY=$DISPLAY -it $CONTAINER /entrypoint.sh tmux