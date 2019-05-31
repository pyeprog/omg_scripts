#!/bin/bash

set -e
sudo chmod 755 *
mkdir -p $HOME/bin
SCRIPTS=('pr_split')
python_header=#!$(which python3)

for SCRIPT in ${SCRIPTS[*]}
do
    rm -f $HOME/bin/$SCRIPT
    rm -f $HOME/bin/$SCRIPT.py
    cp $SCRIPT.py $HOME/bin/$SCRIPT
    sed -i "1s~^.*$~$python_header~" $HOME/bin/$SCRIPT
done

shell_rc="$HOME/.bashrc"
if [ -z "$(echo $SHELL | grep 'bash')" ]; then
    shell_rc="$HOME/.zshrc"
fi

if [ -z "$(echo $shell_rc | grep '$HOME/bin')" ]; then
    echo 'PATH=$PATH:$HOME/bin' >> $shell_rc
fi

echo 'Installation done'
