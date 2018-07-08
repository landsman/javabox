#!/bin/bash

# be lazy
if [ ! -f ".env" ]; then
    echo "File .env not found, making copy from dist!"
    cp .env.dist .env
fi

# allow append to X11
xhost +

# make cache dir
mkdir ~/.javabox

# run docker on background
docker-compose up -d

echo "Intellij IDEA is opening ..."