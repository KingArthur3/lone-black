#!/bin/sh
printf '\033c\033]0;%s\a' Lone Black
base_path="$(dirname "$(realpath "$0")")"
"$base_path/lone-black.x86_64" "$@"
