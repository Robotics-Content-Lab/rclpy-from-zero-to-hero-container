#!/bin/bash

usage(){
    echo -e "
    Usage: ./run_docker.sh -d <distribution> -p <profile> -t <type> [-g <graphics_platform>] [-h]

Options:
  -d <distribution>      Specify the distribution (e.g., jazzy, iron, humble)
  -p <profile>           Specify the profile (e.g., desktop, base)
  -t <type>              Specify the type (e.g., terminal, vnc)
  -g <graphics_platform> Specify the graphics platform (e.g., standard, nvidia, amd)
  -h                     Display this help message

Examples:
  ./run_docker.sh -d iron -p desktop -t terminal -g nvidia
  ./run_docker.sh -d humble -p base -t vnc
  "
}

BASE_DIR=$(git rev-parse --show-toplevel)
if [ $? -ne 0 ]; then
    echo "Error: Could not find base directory of repository."
    exit 1
fi

pushd ${BASE_DIR}/
SHARED_DIR=/home/ros_user/ros2_ws/src
HOST_DIR=$BASE_DIR/ros2_src

if [ ! -d $HOST_DIR ] && [ ! -f $HOST_DIR ] && [ -z $HOST_DIR ]; then
    echo "Error: Could not find ROS 2 workspace: $HOST_DIR. Creating new workspace."
    mkdir -p $BASE_DIR/ros2_src
fi

ROS_DISTRO="iron"
BASE="desktop"
UI="terminal"
WSL=false

# Check if running on WSL
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
    WSL=true
    echo "Running on WSL"
fi

if command -v lspci &> /dev/null; then
    echo "lspci found"
    if lspci | grep VGA | grep -i nvidia &> /dev/null; then
        GRAPHICS_PLATFORM="nvidia"
    elif lspci | grep VGA | grep -i amd &> /dev/null; then
        GRAPHICS_PLATFORM="amd"
    else
        GRAPHICS_PLATFORM="standard" # standard, nvidia, amd
    fi
elif $WSL; then
    # Check if nvidia-smi is available
    if command -v nvidia-smi &> /dev/null; then
        GRAPHICS_PLATFORM="nvidia"
    elif (command -v rocminfo &> /dev/null); then
        GRAPHICS_PLATFORM="amd"
    else
        GRAPHICS_PLATFORM="standard"
    fi
fi




while getopts d:p:t:g:h flag
do
    case "${flag}" in
        d) # CHECK IF ROS_DISTRO IS VALID [iron, humble]
            if [ ${OPTARG} == "jazzy" ] || [ ${OPTARG} == "iron" ] || [ ${OPTARG} == "humble" ]; then
                ROS_DISTRO=${OPTARG}
            else
                echo "Invalid ROS_DISTRO: ${OPTARG}"
                exit 1
            fi
            ;;
        p) # CHECK IF BASE IS VALID [desktop, base]
            if [ ${OPTARG} == "desktop" ] || [ ${OPTARG} == "base" ]; then
                BASE=${OPTARG}
            else
                echo "Invalid BASE: ${OPTARG}"
                exit 1
            fi
            ;;
        t) # CHECK IF UI IS VALID [terminal, vnc]
            if [ ${OPTARG} == "terminal" ] || [ ${OPTARG} == "vnc" ]; then
                UI=${OPTARG}
            else
                echo "Invalid UI: ${OPTARG}"
                exit 1
            fi
            ;;
        g) # CHECK IF GRAPHICS_PLATFORM IS VALID [standard, nvidia, amd]
            if [ ${OPTARG} == "standard" ] || [ ${OPTARG} == "nvidia" ] || [ ${OPTARG} == "amd" ]; then
                GRAPHICS_PLATFORM=${OPTARG}
            else
                echo "Invalid GRAPHICS_PLATFORM: ${OPTARG}"
                exit 1
            fi
            ;;
        h) # HELP
            usage
            exit 0
            ;;
        *) # DEFAULT
            usage
            exit 1
            ;;
    esac
done

echo -e "\e[32mMounting fodler:
    $HOST_DIR    to
    $SHARED_DIR\e[0m"


IMAGE="ghcr.io/robotics-content-lab/rclpy-from-zero-to-hero:${ROS_DISTRO}-${BASE}-${UI}-${GRAPHICS_PLATFORM}"

RUN_ARGS=(--rm \
    --volume="$HOST_DIR:$SHARED_DIR:rw" \
    --privileged \
    --env="QT_X11_NO_MITSHM=1" \
    --env="DISPLAY=$DISPLAY" )
if [ ${WSL} == true ]; then
    RUN_ARGS+=(--volume="/mnt/wslg/.X11-unix:/tmp/.X11-unix:rw" \
                --volume="/mnt/wslg:/mnt/wslg" \
                --env="VGL_DISPLAY=$DISPLAY" \
                --env="XDG_RUNTIME_DIR=/mnt/wslg/runtime-dir")
else
    RUN_ARGS+=(--volume=/tmp/.X11-unix:/tmp/.X11-unix)
fi

if [ ${UI} == "vnc" ]; then
    RUN_ARGS+=(--publish 0.0.0.0:6080:80 \
               --publish 0.0.0.0:6900:5901 \
               --publish 0.0.0.0:5902:5902)
fi

if [ ${GRAPHICS_PLATFORM} == "nvidia" ]; then
    RUN_ARGS+=(--gpus all)
elif [ ${GRAPHICS_PLATFORM} == "amd" ]; then
    RUN_ARGS+=(--device=/dev/dri:/dev/dri)
elif [ ${GRAPHICS_PLATFORM} == "standard" ]; then
    RUN_ARGS+=(--device=/dev/dri:/dev/dri --env=LIBGL_ALWAYS_SOFTWARE=1)
fi

if command -v xhost &> /dev/null; then
    xhost +
fi
set -xv
docker run -it \
    "${RUN_ARGS[@]}" \
    --name "rclpy-from-zero-to-hero" \
    $IMAGE
set +xv
    if command -v xhost &> /dev/null; then
        xhost - || true
    fi
popd