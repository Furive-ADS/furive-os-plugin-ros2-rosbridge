# ROS 2 Humble Desktop 이미지를 베이스로 사용
FROM osrf/ros:humble-desktop

# 환경 변수 설정
ENV DEBIAN_FRONTEND=noninteractive
ENV ROS_DISTRO=humble
# Cyclone DDS 사용: RMW_IMPLEMENTATION을 Cyclone DDS로 지정
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

# /etc/apt/sources.list에서 Universe 저장소 주석 해제 후 필요한 패키지 설치
RUN sed -i 's/^# \(.*universe\)$/\1/g' /etc/apt/sources.list && \
    apt-get update && apt-get install -y \
      python3-pip \
      python3-gdal \
      gdal-bin \
      libgdal-dev \
      build-essential \
      python3-colcon-common-extensions \
      cmake \
      git \
      ros-humble-rosbridge-server \
      ros-humble-geographic-msgs \
      ros-humble-rmw-cyclonedds-cpp \
    && rm -rf /var/lib/apt/lists/*

# ROS 환경 설정 스크립트를 bashrc에 추가
RUN echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> /etc/bash.bashrc

# 작업 디렉토리 설정
WORKDIR /ros2_ws

# 소스 코드 및 설정 파일 복사
COPY . /ros2_ws
COPY cyclonedds_config.xml /ros2_ws/cyclonedds_config.xml

# entrypoint.sh 스크립트 복사 및 실행 권한 부여
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# entrypoint 설정
ENTRYPOINT ["/entrypoint.sh"]

# 기본 CMD 설정: ros2 rosbridge_server 실행
CMD ["ros2", "launch", "rosbridge_server", "rosbridge_websocket_launch.xml"]

