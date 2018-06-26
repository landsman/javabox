#!/bin/bash

# allow append to X11
xhost +

# make cache dir
mkdir ~/.javabox

# run docker on background
docker-compose up -d

echo "Intellij IDEA is opening ..."