# Web Server Configuration & Security Hardening Suite

A comprehensive collection of bash scripts designed to automate the deployment, configuration, and security hardening of web servers running LAMP stack (Linux, Apache, MySQL/MariaDB, PHP).

## Overview

This project provides a systematic approach to set up secure web server environments with minimal manual intervention. It includes scripts for installing essential software, configuring services, implementing security best practices, and applying protective measures against common threats.

## Key Features

- **Automated Installation**: One-command setup of web server software stack
- **Security Hardening**: Implementation of best practices for server security
- **Firewall Configuration**: Robust iptables rules to protect against network threats
- **Apache Optimization**: Performance and security enhancements for Apache
- **PHP Hardening**: Secure configuration of PHP with proper settings
- **ModSecurity Setup**: Web application firewall configuration
- **Brute Force Protection**: Measures to prevent unauthorized access attempts
- **DDoS Mitigation**: Defense mechanisms against denial-of-service attacks
- **CloudFlare Integration**: Support for CloudFlare IP allowlisting

## Components

- `install.sh`: Main installation script that orchestrates the entire setup process
- `apache.sh`: Apache web server configuration with security enhancements
- `iptables.sh`: Comprehensive firewall rules for network protection
- `variables.sh`: Centralized configuration variables for customization
- `download.sh`: Software acquisition and installation
- `configure.sh`: System configuration tasks
- `backup_files.sh`: Backup functionality for configuration files
- `helpers.sh`: Utility functions used across scripts
- `permissions.sh`: File permission hardening
- `/templates`: Directory containing configuration templates for various services

## Usage

1. Review and customize the variables in `variables.sh` to match your environment
2. Execute the installation script with root privileges:
   ```
   sudo ./install.sh
   ```
3. Follow any on-screen prompts to complete the installation

## Security Features

- **Network Hardening**: Protection against port scanning, spoofing, and invalid packets
- **HTTP/HTTPS Security**: Implementation of modern web security headers
- **PHP Security**: Restriction of dangerous functions and proper session handling
- **Brute Force Detection**: Automatic blocking of suspicious login attempts
- **System Hardening**: Kernel and service-level security improvements

## Requirements

- Debian-based Linux distribution (Ubuntu/Debian recommended)
- Root access
- Internet connection for downloading packages

## Customization

The script set is designed to be highly customizable through the `variables.sh` file, allowing adaptation to various hosting environments and security requirements.

## License

This project is open-source software.
