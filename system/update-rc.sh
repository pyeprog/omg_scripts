#! /bin/bash

set -e

GIST_VIMRC = 'https://gist.githubusercontent.com/pyeprog/30445faa4941b2ce94071b464bc6a766/raw/098f3ab902a191c65d9c3878ccea9d4167c76c33/.vimrc'
GIST_TMUXCONF = 'https://gist.githubusercontent.com/pyeprog/c7533126501933f14523e04d1cca1dd2/raw/38e7cd31266371d13210a188337db83f22856c45/.tmux.conf'
MY_BASHRC = ''

function updateVimrc() {
    curl $GIST_VIMRC > $HOME/.vimrc
}

function updateTmuxConf() {
    curl $GIST_TMUXCONF > $HOME/.tmux.conf
}
