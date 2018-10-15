#!/bin/bash

echo $(dirname $0)

# be lazy
if [ ! -f ".env" ]; then
    echo "File .env not found, making copy from dist!"
    cp .env.dist .env
fi

# allow append to X11
xhost +

# make cache dir
if [ ! -f "~/.javabox" ]; then
	mkdir ~/.javabox
fi

# run docker on background
docker-compose up -d

echo "Intellij IDEA is opening ..."

# create icon for future opening
if [ ! -f /usr/share/applications/intellij.desktop ]; then
    cp icon/debian/intellij.desktop /usr/share/applications/intellij.desktop
    chmod +x /usr/share/applications/ssh_home.desktop
fi