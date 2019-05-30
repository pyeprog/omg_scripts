#!/bin/bash
set -e
sudo chmod 755 *
mkdir -p $HOME/bin
cp * $HOME/bin

if [ -z $(grep '$HOME/bin' $HOME/.bashrc) ]; then
    echo 'PATH=$PATH:$HOME/bin' >> $HOME/.bashrc
fi
