#!/bin/sh
# Fetch latest versions of config.guess and config.sub
set -ex
curl -L -o config.guess "https://git.savannah.gnu.org/cgit/config.git/plain/config.guess"
curl -L -o config.sub "https://git.savannah.gnu.org/cgit/config.git/plain/config.sub"
chmod 0755 config.guess config.sub
