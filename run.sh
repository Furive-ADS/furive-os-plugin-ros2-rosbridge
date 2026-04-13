#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
IMAGE_NAME="${FURIVE_DOCKER_IMAGE:-furive-os-plugin-ros2-rosbridge:latest}"
CONTAINER_NAME="${FURIVE_DOCKER_CONTAINER_NAME:-furive-os-plugin-ros2-rosbridge}"
SHARED_MSGS_DIR="${FURIVE_SHARED_MSGS_DIR:-$SCRIPT_DIR/../../shared/msgs}"
SHARED_INSTALL="$SHARED_MSGS_DIR/install"
if [ ! -d "$SHARED_INSTALL" ]; then
  SHARED_INSTALL="$SHARED_MSGS_DIR"
fi

# CycloneDDS 설정 (runtime_assets로 동기화된 경로)
CYCLONEDDS_CONFIG="/data/furive-os/ros2_rosbridge/cyclonedds_config.xml"

docker run -d \
  --name "$CONTAINER_NAME" \
  --restart unless-stopped \
  --network=host \
  --ipc=host \
  -v /etc/localtime:/etc/localtime:ro \
  -v /dev/shm:/dev/shm \
  -v "$SHARED_INSTALL:/opt/furive-os/msgs/install:ro" \
  -v "$CYCLONEDDS_CONFIG:/etc/cyclonedds/config.xml:ro" \
  -e FURIVE_NODE_TYPE="${FURIVE_NODE_TYPE:-agent}" \
  -e ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-79}" \
  -e ROS_LOCALHOST_ONLY="${ROS_LOCALHOST_ONLY:-0}" \
  -e RMW_IMPLEMENTATION="${RMW_IMPLEMENTATION:-rmw_cyclonedds_cpp}" \
  -e CYCLONEDDS_URI="file:///etc/cyclonedds/config.xml" \
  "$IMAGE_NAME"
