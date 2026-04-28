#!/bin/bash
set -euo pipefail

apt-get update -y
apt-get upgrade -y
apt-get autoremove -y
