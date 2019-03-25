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

    # Make work directories
    mkdir ~/go ~/Projects

    # Install pacman packages
    sudo pacman -Syu
    sudo pacman -S $(cat pkglist.txt)

    # Add current user to docker group
    sudo usermod -aG docker $USER

    # Install yaourt packages
    yaourt -S $(cat yaourtlist.txt)

    # Set zsh as default shell
    chsh -s $(grep /zsh$ /etc/shells | tail -1)

    # Install prezto
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
    zsh -c 'setopt EXTENDED_GLOB
    for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
      ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
    done'

    # Install go deps
    go get -u $(cat godeps.txt)

    # Install binaries

    # Install i3lock fancy
    cd ~/Projects
    git clone https://github.com/meskarune/i3lock-fancy.git
    cd i3lock-fancy
    sudo make install

    # kubectl
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    chmod +X kubectl
    sudo mv kubectl /usr/local/bin

    # kubectx, kubens
    sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
    sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
    sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

    # stern
    mkdir -p $GOPATH/src/github.com/wercker
    cd $GOPATH/src/github.com/wercker
    git clone https://github.com/wercker/stern.git && cd stern
    govendor sync
    go install

    # terraform
    curl -LO https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
    unzip terraform_0.11.13_linux_amd64.zip
    sudo mv terraform /usr/local/bin
    rm -f terraform_0.11.13_linux_amd64.zip

    # aws cli
    pip3 install awscli --upgrade --user

    # aws-iam-authenticator
    curl -LO https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator
    chmod +x aws-iam-authenticator
    sudo mv aws-iam-authenticator /usr/local/bin

    # TODO: install git aliases, zsh aliases
    # TODO: symlink vimrc, .zshrc, .zprezto, josh theme, .gitconfig
    # TODO: chrome default browser
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
    cp -r "$HOME/$CONFIGSDIR/vim" "$HOME/.vim"
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
python $HOME/.vim/bundle/youcompleteme/install.py --clang-completer \
    --gocode-completer

echo "--> Done :)"
