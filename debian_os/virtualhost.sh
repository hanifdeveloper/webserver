#!/bin/bash
_DNS_NAME="/etc/hosts"
_CONF_VHOST='/etc/apache2/sites-available'
APACHE_LOG_DIR='/var/log/apache2'
_BASE_DIR=`pwd`

create_vhost(){
# Buat Custom Vhosts
read -p "Virtual Hostname : " vhost
read -p "Custom Port : " port
_VHOST="$_BASE_DIR/$vhost"

sudo chmod -R 755 $_VHOST
sudo chown -R $USER:www-data $_VHOST
sudo touch "$_CONF_VHOST/$vhost.local.conf"
sudo chmod 777 "$_CONF_VHOST/$vhost.local.conf"
sudo cat > "$_CONF_VHOST/$vhost.local.conf" << EOF
<VirtualHost *:80>
ServerAdmin administrator@local.com
ServerName $vhost.local
ServerAlias www.$vhost.local
DocumentRoot "$_VHOST"
<Directory "$_VHOST">
    Options Indexes FollowSymLinks
    AllowOverride All
    Order allow,deny
    Allow from all
    Require all granted
</Directory>
ErrorLog ${APACHE_LOG_DIR}/error.$vhost.log
CustomLog ${APACHE_LOG_DIR}/access.$vhost.log combined
</VirtualHost>


# Custom Port to Access with localhost
Listen $port
<VirtualHost *:$port>
ServerAdmin administrator@local.com
ServerName $vhost.local
ServerAlias www.$vhost.local
DocumentRoot "$_VHOST"
<Directory "$_VHOST">
    Options Indexes FollowSymLinks
    AllowOverride All
    Order allow,deny
    Allow from all
    Require all granted
</Directory>
ErrorLog ${APACHE_LOG_DIR}/error.$vhost.log
CustomLog ${APACHE_LOG_DIR}/access.$vhost.log combined
</VirtualHost>
EOF
# Check Konfigurasi
sudo apache2ctl configtest
# Disable default vhost dan Enable New vhost
sudo a2dissite 000-default.conf
sudo a2ensite $vhost.local.conf
# Enable Modul Htaccess
sudo a2enmod rewrite
sudo apache2ctl configtest
sudo systemctl reload apache2
# # Menambahkan dnsname
sudo grep -q "127.0.0.1  $vhost.local" $_DNS_NAME && echo 'DNS READY' || echo "127.0.0.1  $vhost.local" | sudo tee -a $_DNS_NAME > /dev/null
}

# Main Program
clear
create_vhost
# Running Application Using Curl
# sh -c "$(curl -s https://raw.githubusercontent.com/hanifdeveloper/webserver/master/debian_os/virtualhost.sh)"
