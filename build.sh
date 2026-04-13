#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="furive-os-plugin-ros2-rosbridge"
HASH_FILE="$SCRIPT_DIR/.build_hash"

CURRENT_HASH=$(find "$SCRIPT_DIR" -type f \
    ! -path '*/.git/*' \
    ! -path '*/__pycache__/*' \
    ! -name '*.pyc' \
    ! -name '*.log' \
    ! -name '.build_hash' \
    | sort | xargs md5sum 2>/dev/null | md5sum | awk '{print $1}')

if [ "${1:-}" = "--force" ]; then
    echo "$IMAGE_NAME 이미지 강제 빌드..."
    docker build -t "$IMAGE_NAME:latest" "$SCRIPT_DIR"
    echo "$CURRENT_HASH" > "$HASH_FILE"
    exit 0
fi

PREVIOUS_HASH=""
if [ -f "$HASH_FILE" ]; then
    PREVIOUS_HASH="$(cat "$HASH_FILE")"
fi

if ! docker image inspect "$IMAGE_NAME:latest" > /dev/null 2>&1; then
    echo "$IMAGE_NAME 이미지가 없습니다. 빌드 시작..."
    docker build -t "$IMAGE_NAME:latest" "$SCRIPT_DIR"
    echo "$CURRENT_HASH" > "$HASH_FILE"
elif [ "$CURRENT_HASH" != "$PREVIOUS_HASH" ]; then
    echo "$IMAGE_NAME 소스 변경 감지. 재빌드 시작..."
    docker build -t "$IMAGE_NAME:latest" "$SCRIPT_DIR"
    echo "$CURRENT_HASH" > "$HASH_FILE"
else
    echo "$IMAGE_NAME 변경 없음. 빌드 스킵. (강제 빌드: ./build.sh --force)"
fi
