#!/bin/bash

# set -x  # debug
set -e

default_password='412351860'

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
    id "$name" > /dev/null 2>&1
    if [[ $? > 0 ]]; then
        adduser $name
    fi
    if [[ ! -d /etc/sudoers.d ]]; then
        sudo mkdir -p /etc/sudoers.d
    fi
    echo "$name      ALL=(ALL)       ALL" | sudo tee `/etc/sudoers.d/$name`
    echo -e "$default_password\n$default_password" | sudo passwd $name
    echo "add $name to /etc/sudoers"
}

# System
function initSystem() {
    # sshd
    sudo sed -ie 's/#ClientAliveInterval.*$/ClientAliveInterval 3/' /etc/ssh/sshd_config
    sudo sed -ie 's/#ClientAliveCountMax.*$/ClientAliveCountMax 3600/' /etc/ssh/sshd_config
    if [[ -z $(sudo grep 'DenyUsers root' /etc/ssh/sshd_config) ]]; then
        echo 'DenyUsers root' | sudo tee -a /etc/ssh/sshd_config
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

# add user jenkins to docker group
function jenkinsDockerConfig() {
    jenkins_user='jenkins'
    docker_group=`cat /etc/group | cut -d ':' -f1 | grep docker`
    sudo systemctl status docker > /dev/null
    docker_exist=$?
    sudo systemctl status jenkins > /dev/null
    jenkins_exist=$?
    if [[ $docker_exist == 0  && $jenkins_exist == 0 ]]; then
        sudo usermod -aG $jenkins_user $docker_group
    fi
}

# jenkins
function initJenkins() {
    sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
    sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
    sudo yum install java-11-openjdk -y
    sudo yum install jenkins -y
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
    jenkinsDockerConfig
    initUser jenkins
}

# docker
function initDocker() {
    sudo yum install docker -y
    sudo systemctl start docker
    jenkinsDockerConfig
}

# nginx
function initNginx() {
    sudo yum install nginx -y
    sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.back
    sudo mkdir -p /var/log/nginx/jenkins
    sudo cp ../resource/nginx.conf /etc/nginx
    mkdir -p /etc/nginx/conf.d/
    sudo cp ../resource/jenkins.nginx.conf /etc/nginx/conf.d/
    sudo systemctl start nginx
    sudo systemctl enable nginx
}

# Tools
function initTools() {
    showline init tools

    sudo yum install git -y
    sudo yum install python36 python36-pip -y
    sudo yum install golang -y
    initDocker && echo 'init docker done'
    initVim && echo 'init vim done'
    initJenkins && echo 'init jenkins done'
    initNginx && echo 'init nginx done'

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
    docker)
        initDocker
        ;;
    *)
        echo "available: user system tool vim jenkins docker nginx"
esac
