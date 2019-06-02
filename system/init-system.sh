#!/bin/bash

set -x  # debug
set -e

su - root

# Distro
distro=$(hostnamectl | sed 's/^ *//' | grep 'Operating System' | cut -d ' ' -f3)
if [ distro -ne 'CentOS' ]; then
    echo "Your distro is not centos"
    exit 1
fi

# User
function initUser() {
    adduser pd
    echo 'pd      ALL=(ALL)       ALL' >> /etc/sudoers
}

# Tools
function initTools() {
    
}
