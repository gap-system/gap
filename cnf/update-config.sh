#!/bin/sh
# Fetch latest versions of config.guess and config.sub
set -ex
curl -o config.guess "https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess"
curl -o config.sub "https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub"
chmod 0755 config.guess config.sub
