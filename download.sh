#!/bin/bash

#  Redis

main_message "Download redis"
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list


for app in ${SOFTWARE[*]}; do
    if ! command ${app} -v &> /dev/null
    then
        load_spinner
        sub_message "$app"
        apt --assume-yes install $app &> ${LOG_FILE}
    fi
    
    if [ "php8.0" == $app ] || [ "php8.1" == $app ] || [ "php8.2" == $app ]; then
        main_message "Installing ${app} extensions"
        for lib in ${PHP_EXTENSIONS[*]}; do
            load_spinner
            sub_message $app"-"$lib
            apt --assume-yes install $app'-'$lib &> ${LOG_FILE}
        done
        task_done "Software installed"
    fi
done

echo "Install mod_security"
yes | apt install libapache2-mod-security2
echo "Install mod_evasive"
yes | apt install libapache2-mod-evasive

