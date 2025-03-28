#!/usr/bin/env bash
set -e

tags="$1"

if [ -z $tags ]; then
  tags="all"
fi

if [ -x "$(command -v ansible)" ]; then
    sudo dnf install ansible -y
fi