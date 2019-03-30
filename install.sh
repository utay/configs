#!/bin/bash

set -xe

is_full_mode() {
    mode="$1"
    [ "$mode" = "full" ] || [ "$mode" = "f" ]
}

is_mode_valid() {
    mode="$1"
    is_full_mode "$mode" || [ "$mode" = "vim" ] || [ "$mode" = "v" ]
}

CONFIG_DIR="$HOME/configs"

# Ask sudo password
sudo echo "--> Full Linux config setup or just vim? [full (f),vim (v)]"

read mode

if ! is_mode_valid "$mode"; then
    echo "--> Invalid mode"
    exit 1
fi

if [ ! -x "/usr/bin/git" ]; then
    sudo pacman -S git
fi

if [ -d "$CONFIG_DIR" ]; then
    mv "$CONFIG_DIR" "$HOME/configs.bak"
fi

git clone --quiet --recursive 'https://github.com/utay/configs' "$CONFIG_DIR"
cd "$CONFIG_DIR"

if is_full_mode "$mode"; then
    echo "--> Setup Linux configuration"

    # Make work directories
    mkdir "$HOME/go" "$HOME/Projects"

    # Install pacman packages
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm $(cat pkglist.txt)

    # Add current user to docker group
    sudo usermod -aG docker $USER

    # Install yaourt packages
    yaourt -S --noconfirm $(cat yaourtlist.txt)

    # Set zsh as default shell
    chsh -s $(grep /zsh$ /etc/shells | tail -1)

    # Install prezto
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
    zsh -c 'setopt EXTENDED_GLOB
    for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
      ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
    done'
    cp prezto/prompt_josh_setup "$HOME/.zprezto/modules/prompt/functions"

    # Backup existing dotfiles and symlink new dotfiles
    for dotfile in dotfiles/*; do
        dotfile_path="$HOME/.$(basename "$dotfile")"
        if [ -f "$dotfile_path" ]; then
            mv "$dotfile_path" "$dotfile_path.bak"
        fi
        ln -sf "$dotfile" "$dotfile_path"
    done

    # Install vscode extensions
    for ext in $(cat vscode.txt); do
        code --install-extension "$ext"
    done

    # Install go deps
    go get -u $(cat godeps.txt)

    # Install binaries

    # Install i3lock fancy
    cd "$HOME/Projects"
    git clone https://github.com/meskarune/i3lock-fancy.git
    cd i3lock-fancy
    sudo make install
    cd "$CONFIG_DIR"

    # kubectl
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    chmod +X kubectl
    sudo mv kubectl /usr/local/bin

    # kubectx, kubens
    sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
    sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
    sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

    # stern
    mkdir -p "$GOPATH/src/github.com/wercker"
    cd "$GOPATH/src/github.com/wercker"
    git clone https://github.com/wercker/stern.git && cd stern
    govendor sync
    go install
    cd "$CONFIG_DIR"

    # helm
    curl https://storage.googleapis.com/kubernetes-helm/helm-v2.10.0-linux-386.tar.gz | tar xz
    sudo mv linux-386/helm /usr/local/bin
    rm -rf linux-386

    # helmfile
    curl -LO https://github.com/roboll/helmfile/releases/download/v0.40.1/helmfile_linux_386
    chmod +x helmfile_linux_386
    sudo mv helmfile_linux_386 /usr/local/bin/helmfile

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

    # i3 config
    mkdir "$HOME/.config/i3"
    ln -sf i3/config "$HOME/.config/i3/config"

    # dunst config
    mkdir "$HOME/.config/dunst"
    ln -sf dunst/dunstrc "$HOME/.config/i3/dunstrc"

    # TODO: chrome default browser
fi

echo "--> Setup Vim configuration"

cd "$CONFIG_DIR"

if [ -d "$HOME/.vim" ]; then
    mv "$HOME/.vim" "$HOME/.vim.bak"
fi

cp -r "$CONFIG_DIR/vim" "$HOME/.vim"

if [ -f "$HOME/.vimrc" ]; then
    mv "$HOME/.vimrc" "$HOME/.vimrc.bak"
fi

cat > $HOME/.vimrc << EOF
"==== Vim Configuration ===="
:source $HOME/.vim/vimrc
EOF

python $HOME/.vim/bundle/youcompleteme/install.py \
    --clang-completer \
    --gocode-completer

echo "--> Done :)"
