#!/bin/bash

check_mode() {
    if [[ "$1" != "full" && "$1" != "f" && "$1" != "vim" && "$1" != "v" ]]; then
        return 0
    else
        return 1
    fi
}

CONFIGSDIR="configs"

# Ask sudo password
sudo echo "--> Full Linux config setup or just vim? [full (f),vim (v)]"

read mode

if check_mode "$mode"; then
    echo "--> Setup cancelled"
    exit -1
fi

if [[ "$mode" = "full" || "$mode" = "f" ]]; then
    echo "--> Setup Linux configuration"
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install -y curl git zsh vim golang python \
        python-dev build-essential cmake gdb valgrind

    echo "--> Install OhMyZsh"
    git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
    chsh -s $(grep /zsh$ /etc/shells | tail -1)
fi

echo "--> Setup Vim configuration"

if [ -x "/usr/bin/git" ]; then
    if [ -d "$HOME/$CONFIGSDIR" ]; then
        mv "$HOME/$CONFIGSDIR" "$HOME/configs.bak"
    fi
    git clone --quiet --recursive 'https://github.com/utay/configs' "$HOME/$CONFIGSDIR"
    cd "$HOME/$CONFIGSDIR"
    if [ -d "$HOME/.vim" ]; then
        mv "$HOME/.vim" "$HOME/.vim.bak"
    fi
    cp "$HOME/$CONFIGSDIR/vim" "$HOME/.vim"
else
    echo "Please install git" 1>&2
    exit -1
fi

if [ -f "$HOME/.vimrc" ]; then
    mv "$HOME/.vimrc" "$HOME/.vimrc.bak"
fi

cat > $HOME/.vimrc << EOF
"==== Vim Configuration ===="
:source $HOME/.vim/vimrc
EOF

echo "--> Configure YouCompleteMe"
python $HOME/.vim/bundle/YouCompleteMe/install.py --clang-completer \
    --gocode-completer

echo "--> Done :)"
