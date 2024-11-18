# Get the container ID
$CONTAINER = docker container ls | Where-Object { $_ -match "rclpy" } | ForEach-Object { $_.Split()[0] }
if($CONTAINER -eq $null) {
    Write-Host "No container found"
    exit
}

# Execute the entrypoint script inside the container
docker container exec -it $CONTAINER /entrypoint.sh tmux
