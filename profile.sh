#!/bin/sh

simulation=$1

for app in `seq 1 24`; do
    echo "Running docker for app " $app
    docker-compose run mlx /opt/ib/sim/utils/profile $simulation $app  & 
done