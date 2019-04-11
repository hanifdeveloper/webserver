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
_CONF_VHOST='/etc/apache2/sites-available'
_BASE_VHOST='/var/www'
APACHE_LOG_DIR='/var/log/apache2'

create_vhost(){
# Buat Custom Vhosts
read -p "Virtual Hostname : " vhost
read -p "Source Code Url : " urls_git
# read -p "User Git : " user_git
# read -p -s "Password Git : " pass_git

_VHOST="$_BASE_VHOST/$vhost"

sudo mkdir -p $_VHOST
sudo chmod -R 755 $_VHOST
sudo chown -R $USER:staff $_VHOST
sudo touch "$_CONF_VHOST/$vhost.local.conf"
sudo chmod 777 "$_CONF_VHOST/$vhost.local.conf"
sudo cat > "$_CONF_VHOST/$vhost.local.conf" << EOF
<VirtualHost *:80>
ServerAdmin administrator@local.com
ServerName $vhost.local
ServerAlias www.$vhost.local
DocumentRoot "$_BASE_VHOST/$vhost"
<Directory "$_BASE_VHOST/$vhost">
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
# Seting User Git
# git config --global user.name "$user_git"
# git config --global user.password "$pass_git"

# Check Application
# Clone / Update Application
if [ -d $_VHOST/.git ]; then
    echo "Update Applicaton"
    echo "================="
    cd $_VHOST
    git pull origin master
else
    echo "Installing Applicaton"
    echo "====================="
    git clone $urls_git $_VHOST
fi
}

# Main Program
create_vhost
# Running Applocation Using Curl
# sh -c "$(curl -s https://raw.githubusercontent.com/hanifdeveloper/webserver/master/mac_os/webserver.sh)"

