#!/bin/bash
set -euo pipefail

source helpers.sh

precheck "Checking OS version..."

if ! grep -q "Ubuntu" /etc/os-release; then
  error "This script only supports Ubuntu."
  exit 1
fi

precheck "Checking for internet connection..."

ping -c 1 1.1.1.1 >/dev/null || {
  error "No internet connection detected."
  exit 1
}
