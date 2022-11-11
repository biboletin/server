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
        # apt --assume-yes install $app &> /dev/null
        # apt --assume-yes install $app
    fi
    
    if [ "php7.4" == $app ] || [ "php8.0" == $app ] || [ "php8.1" == $app ]; then
        main_message "Installing ${app} extensions"
        for lib in ${PHP_EXTENSIONS[*]}; do
            load_spinner
            sub_message $app"-"$lib
            # apt --assume-yes install $app'-'$lib &> /dev/null
            apt --assume-yes install $app'-'$lib
        done
        task_done "Software installed"
    fi
done

echo "Install mod_security"
apt install libapache2-mod-security
echo "Install mod_evasive"
apt install libapache2-mod-evasive