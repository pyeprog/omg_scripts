#!/bin/bash

# set -x  # debug
set -e

# Distro
distro=$(hostnamectl | sed 's/^ *//' | grep 'Operating System' | cut -d ' ' -f3)
if [[ distro -ne 'CentOS' ]]; then
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
    if [[ -z $(sudo grep 'DenyUsers root' /etc/ssh/sshd_config) ]]; then
        sudo echo 'DenyUsers root' | sudo tee -a /etc/ssh/sshd_config
	sudo sed -ie 's/PermitRootLogin.*$/PermitRootLogin no/' /etc/ssh/sshd_config
    fi
    sudo sed -ie 's/#Port 22/Port 4123/' /etc/ssh/sshd_config
    sudo semanage port -a -t ssh_port_t -p tcp 4123
    sudo service sshd restart

    # network config
    iptables -A INPUT -p tcp --dport 21 -j DROP
    iptables -A INPUT -p tcp --dport 22 -j DROP
    iptables-save
    echo 'Remeber to config aliyun port on its website'
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

# jenkins
function initJenkins() {
    sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
    sudo yum install java-11-openjdk -y
    sudo yum install jenkins -y
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
}

# nginx
function initNginx() {
    sudo yum install nginx -y
    sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.back
    sudo mkdir -p /var/log/nginx/jenkins
    sudo cp ../resource/nginx.conf /etc/nginx
    sudo systemctl start nginx
    sudo systemctl enable nginx
}

# Tools
function initTools() {
    showline init tools

    sudo yum install git -y
    sudo yum install python36 python36-pip -y
    sudo yum install golang -y
    sudo yum install docker -y
    sudo systemctl start docker
    initVim && echo 'init vim done'
    initJenkins && echo 'init jenkins'
    initNginx && echo 'init nginx'

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
        ;;
    system)
        initSystem
        ;;
    tool)
        initTools
        ;;
    vim)
        initVim
        ;;
    jenkins)
        initJenkins
        ;;
    nginx)
        initNginx
        ;;
    *)
        echo "available: user system tool vim jenkins"
esac
