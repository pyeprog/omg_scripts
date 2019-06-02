#!/bin/bash

set -x  # debug
set -e

# Distro
distro=$(hostnamectl | sed 's/^ *//' | grep 'Operating System' | cut -d ' ' -f3)
if [ distro -ne 'CentOS' ]; then
    echo "Your distro is not centos"
    exit 1
fi

function showline() {
    echo "==========$@=========="
}

# User
function initUser() {
    name=pd
    if [[ $# > 0 ]]; then
        name=$1
    fi
    adduser $name
    if [[ -z $(grep $name /etc/sudoers) ]]; then
        echo "$name      ALL=(ALL)       ALL" >> /etc/sudoers
        sudo passwd $name
        echo "add $name to /etc/sudoers"
    fi
}

# System
function initSystem() {
    # sshd
    sudo sed -ie 's/#ClientAliveInterval.*$/ClientAliveInterval 3/' /etc/ssh/sshd_config
    sudo sed -ie 's/#ClientAliveCountMax.*$/ClientAliveCountMax 3600/' /etc/ssh/sshd_config
    sudo service sshd restart
}

# vim
function initVim() {
    pip3 install --upgrade pip
    sudo yum install vim -y
    pip3 install autopep8 yapf jedi --user

    if [[ -f $HOME/.vimrc ]]; then
        rm -f $HOME/.vimrc
    fi
    cp ../resource/.vimrc $HOME/.vimrc
    if [[ ! -d $HOME/.vim/bundle/Vundle.vim ]]; then
        git clone https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim
    fi
    vim +PluginInstall +qa
}

# Tools
function initTools() {
    showline init tools

    sudo yum install git -y
    sudo yum install python36 python36-pip -y
    sudo yum install golang -y
    sudo yum install docker -y
    sudo systemctl start docker
    initVim && echo "init vim done"

    showline init done
}

# Main
case $1 in
    user)
        if [[ $# > 1 ]]; then
            initUser $2
        else
            echo "specify user name"
        fi
        break
        ;;
    system)
        initSystem
        break
        ;;
    tool)
        initTools
        break
        ;;
    vim)
        initVim
        break
        ;;
    *)
        echo "available: user system tool vim"
esac
