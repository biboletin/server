#!/bin/bash
set -euo pipefail

source helpers.sh
source ./config/env.sh

installing "Installing tools..."
install_packages  "${TOOLS[@]}"

installing "Installing web..."
install_packages  "${WEB[@]}"

installing "Installing databases..."
install_packages  "${DATABASES[@]}"

installing "Installing security..."
install_packages  "${SECURITY[@]}"

installing "Installing email..."
install_packages  "${EMAIL[@]}"

installing "Installing SSL..."
install_packages  "${SSL[@]}"

installing "Installing firewall..."
install_packages  "${FIREWALL[@]}"

installing "Installing extras..."
install_packages  "${EXTRAS[@]}"