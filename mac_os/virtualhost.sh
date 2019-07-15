#!/bin/bash

# Buka file konfigurasi apache (httpd) => /etc/apache2/httpd.conf
# Uncoment konfigurasi default virtual host
# #Include etc/apache2/extra/httpd-vhosts.conf
# Tambahkan baris dibawahnya konfigurasi virtual host yang baru
# Include etc/apache2/vhosts/*.conf
# Buat folder vhosts di /etc/apache2 (kalau di linux, sudah tersedia folder sites-available)
# sudo mkdir -p /etc/apache2/vhosts
# Copy paste file konfigurasi default vhosts apache ke folder vhosts (Hal ini dimaksudkan untuk mengaktifkan localhost)
# sudo cp /etc/apache2/extra/httpd-vhosts.conf /etc/apache2/vhosts/000-default.conf

_DNS_NAME="/etc/hosts"
_CONF_VHOST='/etc/apache2/vhosts'
APACHE_LOG_DIR='/var/log/apache2'
_BASE_DIR=`pwd`

create_vhost(){
# Buat Custom Vhosts
read -p "Virtual Hostname : " vhost
read -p "Custom Port : " port
_VHOST="$_BASE_DIR/$vhost"

sudo chmod -R 755 $_VHOST
sudo chown -R $USER:staff $_VHOST
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
sudo apachectl configtest 2> /dev/null
# Restart service apache
sudo apachectl restart
# Menambahkan dnsname
sudo grep -q "127.0.0.1  $vhost.local" $_DNS_NAME && echo 'DNS READY' || echo "127.0.0.1  $vhost.local" | sudo tee -a $_DNS_NAME > /dev/null
# Aktifkan dnsname
dscacheutil -flushcache
sudo killall -HUP mDNSResponder
}

# Main Program
clear
create_vhost
# Running Application Using Curl
# sh -c "$(curl -s https://raw.githubusercontent.com/hanifdeveloper/webserver/master/mac_os/webserver.sh)"

