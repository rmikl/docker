#!/bin/sh
# GIT_ASKPASS target: lets git push over HTTPS using GH_TOKEN without ever
# writing the token to a credential store file or the remote URL on disk.
# Git invokes this once for the username prompt, once for the password
# prompt (argv[1] identifies which); output goes straight to git, not a file.
case "$1" in
  Username*) echo "x-access-token" ;;
  Password*) echo "${GH_TOKEN:-}" ;;
esac
