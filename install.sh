#!/bin/bash
set -eou pipefail

source helpers.sh

if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root"
    exit 1
fi

banner

# Load environment configuration
if [ -f ./config/env.sh ]; then
  source ./config/env.sh
fi

mkdir -p ./logs
exec > >(tee -a "$LOG_FILE") 2>&1

info "Update and upgrade system packages before installation"
#update_packages

clear

banner

info "Starting installation at $(date)"

# Create home directories if they do not exist
for dir in "${DIRS[@]}"; do
	echo "Checking directory: $dir"
	if [ ! -d "${dir}" ]; then
		plus_sign "Create $dir"

		mkdir -p "${HOME_DIR}/$dir"
		chown -R ${USER}:${GROUP} "${HOME_DIR}/${dir}"
	else
		minus_sign "Directory $dir already exists"
	fi
done

# Run all modules
for script in ./modules/*.sh; do
  filename=$(basename "$script")

  # Check if the file is in the exclusion list
  if [[ " ${EXCLUDED_FILES[@]} " =~ " ${filename} " ]]; then
    warning "Skipping $filename"
    continue
  fi

  info "Running $filename"
  bash "$script"
done


success " Installation complete at $(date)"