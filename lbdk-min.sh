#!/bin/bash

# Laughing Biscuit Development Kit Lite

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
mkdir -p ~/.vim/pack/git-plugins/start

#####
# apts
#####

sudo apt-get update
sudo apt-get install -y \
  apt-transport-https \
  apache2-utils \
  bash-completion \
  cmake \
  ctags \
  curl \
  gnupg  \
  git  \
  jq  \
  lynx \
  maven \
  python-pip \
  ranger \
  unzip \
  urlscan \
  vim

#####
# npm
#####

sudo npm install -g \
  apigeetool \
  eslint \
  http-server \
  js-beautify
  
#####
# vim plugins
#####

PLUGINS=$(cat <<-END
  sbdchd/neoformat
  w0rp/ale
  gyim/vim-boxdraw

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
	git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout
else
	git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME pull || true
fi

#####
# Locale
#####

sudo sed -i 's/# en_GB.UTF-8/en_GB.UTF-8/g' /etc/locale.gen ||\ 
  sudo echo 'en_GB.UTF-8 UTF-8' > /etc/locale.gen &&\
  sudo apt-get install -y locales && sudo locale-gen || true
