#!/bin/sh

# Laughing Biscuit Development Kit
#
#	Description: A scrappy idempotent script to setup my Development Environment
#	Requirements: Alpine Linux

#	Usage: ./lbdk.sh [sudo] [ui] 
#	Repo: https://github.com/laughingbiscuit/lbdk.git
#	Author: LaughingBiscuit
set -o xtrace
set -e
set -o pipefail 

# stub sudo if no argument is provided
if ! echo $@ | grep 'sudo' -q  ; then
	function sudo {
		"$@"
	}
fi

#####
# mkdirs
#####

mkdir -p ~/.vim/swapfiles
mkdir -p ~/.npm-global
mkdir -p ~/.vim/pack/git-plugins/start

#####
# apks
#####

sudo apk update
sudo apk upgrade
sudo apk add man
sudo apk add \
  curl \
  docker \
  git \
  jq  \
  lastpass-cli \
  libressl \
  lynx \
  nodejs \
  npm \
  tmux \
  vim

#####
# node packages
#####

# workaround thread stack size for musl
npm config set unsafe-perm true

npm config set prefix $HOME/.npm-global
npm install -g \
  apigeetool \
  eslint \
  http-server \
  js-beautify \
  jwt-cli

#####
# git
#####

REPOS=$(cat <<-END
  seymen/accelerator-ci-maven
  seymen/apickli-ff
  apickli/apickli
  laughingbiscuit/laughingbiscuit.github.io
  apigee/openbank
  apigee/docker-apigee-drupal-kickstart
  jlevy/the-art-of-command-line
END
)
for REPO in $REPOS; do
  DIR=$(echo $REPO | cut -d "/" -f 2)
	git clone --depth 1 https://github.com/$REPO ~/projects/$DIR || true
done

#####
# vim plugins
#####

PLUGINS=$(cat <<-END
  sbdchd/neoformat
  w0rp/ale
END
)

for REPO in $PLUGINS; do
  DIR=$(echo $REPO | cut -d "/" -f 2)
	git clone --depth 1 https://github.com/$REPO \
    ~/.vim/pack/git-plugins/start/$DIR || true
done

#####
# dotfiles
#####

if [ ! -d ~/.dotfiles ]; then
	[ -f ~/.bashrc ] && mv ~/.bashrc ~/.bashrc.old
	git clone --bare https://github.com/laughingbiscuit/dotfiles.git ~/.dotfiles
	git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout --force
else
	git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME pull || true
fi
