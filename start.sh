#!/bin/bash

# allow append to X11
xhost +

# run docker on background
docker-compose up -d

echo "Intellij IDEA is opening ..."