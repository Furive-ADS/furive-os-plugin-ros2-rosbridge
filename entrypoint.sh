#!/usr/bin/env bash
set -e

source "/opt/ros/$ROS_DISTRO/setup.bash"

# 공유 msgs 워크스페이스가 마운트되어 있으면 source
if [ -f /opt/furive-os/msgs/install/setup.bash ]; then
    source /opt/furive-os/msgs/install/setup.bash
fi

exec "$@"
