#!/bin/bash
#Init Variable
APPLICATION="Sistem Informasi Kepegawaian Kota Pekalongan 2019"
# _GIT_URLS="bitbucket.org/kominfopklcity/web-application-simpeg.git"
# _GIT_USER="hanifdeveloper"
# _DB_HOST="localhost"
# _DB_USER="admin"
# _DB_PASS="_4dm1n-DB@Dev"
# _DB_NAME="dbweb_simpeg"
_RESULT=`mktemp`
_FILE_SQL=()

# Check OS
_OS=`uname -s`
echo 'Application started ...'
if [ $_OS == "Linux" ]; then
    _VHOST="/var/www/simpeg"
    _DIR_SQL="$_VHOST/upload/sql"
    _MYSQL_IMPORT=`which mysql | grep "/bin/mysql" | head -n 1`
    _MYSQL_EXPORT=`which mysqldump | grep "/bin/mysql" | head -n 1`
    sudo apt-get install dialog
else
    _VHOST="$HOME/Sites/simpeg"
    _DIR_SQL="$_VHOST/upload/sql"
    # _MYSQL_IMPORT=`locate mysql | grep "/bin/mysql" | head -n 1`
    # _MYSQL_EXPORT=`locate mysqldump | grep "/bin/mysql" | head -n 1`
    # brew install dialog
fi

webserver_linux(){
echo "Installing Webserver ..."
echo "========================"
# sudo apt-get update
sudo apt-get install apache2 -y
sudo apt-get install curl -y
}
php_linux(){
echo "Installing PHP ..."
echo "=================="
sudo apt-get install php7.0 -y
sudo apt-get install php-curl -y
sudo apt-get install php-mysql -y
sudo apt-get install php-gd -y
sudo systemctl reload apache2
}
mysql_linux(){
echo "Installing MySQL Server ..."
echo "==========================="
sudo apt-get install mysql-server mysql-client mysql-common -y
sudo mysql -u root -e "CREATE DATABASE $_DB_NAME CHARACTER SET utf8 COLLATE utf8_general_ci"
sudo mysql -u root -e "CREATE USER '$_DB_USER'@'$_DB_HOST' IDENTIFIED BY '$_DB_PASS'"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '$_DB_USER'@'$_DB_HOST'"
sudo mysql -u root -e "UPDATE mysql.user SET plugin='mysql_native_password' WHERE mysql.user.user='$_DB_USER'"
echo
}
create_vhost(){
echo "Creating Virtual Host"
echo "====================="
sudo mkdir -p $1
sudo chmod -R 755 $1
sudo touch /etc/apache2/sites-available/simpeg.vhost.conf
sudo chmod 777 /etc/apache2/sites-available/simpeg.vhost.conf
cat > /etc/apache2/sites-available/simpeg.vhost.conf << EOF
<VirtualHost *:80>
ServerAdmin hanif.softdev@pekalongankota.dev
ServerName simpeg.pekalongankota.com
ServerAlias www.simpeg.pekalongankota.com
DocumentRoot "$1"
<Directory "$1">
    Options Indexes FollowSymLinks
    AllowOverride All
    Order allow,deny
    Allow from all
    Require all granted
</Directory>
ErrorLog ${APACHE_LOG_DIR}/error.simpeg.log
CustomLog ${APACHE_LOG_DIR}/access.simpeg.log combined
</VirtualHost>
EOF
sudo a2dissite 000-default.conf
sudo a2ensite simpeg.vhost.conf
sudo a2enmod rewrite
sudo apache2ctl configtest
sudo systemctl reload apache2
echo
}
config_linux(){
echo "Configuring System ..."
echo "======================"
fileConfigApache='/etc/apache2/apache2.conf'
fileConfigPHP='/etc/php/7.0/apache2/php.ini'
fileConfigMySQL='/etc/mysql/my.cnf'
sudo grep -q 'ServerSignature Off' $fileConfigApache && sudo sed -i 's:ServerSignature Off:ServerSignature Off:' $fileConfigApache || echo 'ServerSignature Off' | sudo tee --append $fileConfigApache > /dev/null
sudo grep -q 'ServerTokens Prod' $fileConfigApache && sudo sed -i 's:ServerTokens Prod:ServerTokens Prod:' $fileConfigApache || echo 'ServerTokens Prod' | sudo tee --append $fileConfigApache > /dev/null
sudo sed -i 's:^upload_max_filesize.*:upload_max_filesize=20M:g' $fileConfigPHP
sudo sed -i 's:^post_max_size.*:post_max_size=20M:g' $fileConfigPHP
sudo sed -i 's:^;browscap.*:browscap=/var/www/simpeg/comp/php_browscap/php_browscap.ini:g' $fileConfigPHP
sudo sed -i 's:^innodb_buffer_pool_size.*:innodb_buffer_pool_size=384M:g' $fileConfigMySQL
sudo sed -i 's:^innodb_additional_mem_pool_size.*:innodb_additional_mem_pool_size=20M:g' $fileConfigMySQL
sudo sed -i 's:^innodb_log_file_size.*:innodb_log_file_size=10M:g' $fileConfigMySQL
sudo sed -i 's:^innodb_log_buffer_size.*:innodb_log_buffer_size=64M:g' $fileConfigMySQL
sudo sed -i 's:^innodb_flush_log_at_trx_commit.*:innodb_flush_log_at_trx_commit=1:g' $fileConfigMySQL
sudo sed -i 's:^innodb_lock_wait_timeout.*:innodb_lock_wait_timeout=180M:g' $fileConfigMySQL
sudo systemctl reload apache2
echo "Configuration OK"
}

#Custom Function
init_app(){
dialog --clear --backtitle "$APPLICATION" \
--checklist "Tekan tombol spasi, untuk memilih modul yang akan diinstall" 20 60 15 \
"webserver" "Install Web Server Apache" off \
"php" "Install PHP" off \
"mysql" "Install MySQL Server" off \
"simpeg" "Install/Update Aplikasi Simpeg" on 2> $_RESULT
}
init_user_git(){
dialog --clear --backtitle "$APPLICATION" \
--inputbox "User Git" 15 50 "$_GIT_USER" 2> $_RESULT
}
init_pass_git(){
dialog --clear --backtitle "$APPLICATION" \
--insecure \
--passwordbox "Password Git" 15 50 2> $_RESULT
}
check_modul(){
type $1 &>/dev/null && $1 || echo "modul $1 not found" > /dev/null
}
install_modul(){
modul=$*
for m in $modul; do
    os=`echo $_OS | awk '{print tolower($0)}'`
    check_modul $m"_"$os
done
}
form_import_db(){
# List file sql
nomer=1
lists=()
cd $_DIR_SQL;
for file in *.sql; do
    _FILE_SQL+=("$file")
    lists+=("$nomer $file")
    let nomer=$nomer+1
done
dialog --clear --backtitle "$APPLICATION" --title 'Import Database' \
--menu 'Pilih database yang akan direstore' 15 55 5 ${lists[@]} 2> $_RESULT
}
action_import_db(){
files=$1
dialog --backtitle "$APPLICATION" --infobox "Tunggu sebentar, sedang mengimport $files ..." 5 100; sleep 3
import=`php $_VHOST/simpeg.php --restore $files`
show_results "File Import : $files"
}
action_export_db(){
fName="backup_simpeg_"`date +%d_%m_%Y_%H%M%S`".sql"
fBackup=$_DIR_SQL"/"$fName
dialog --backtitle "$APPLICATION" --infobox "Tunggu sebentar, sedang mengexport database ...." 10 100;
$_MYSQL_EXPORT --opt -h $_DB_HOST -u$_DB_USER -p$_DB_PASS $_DB_NAME 2>&1 > $fBackup
show_results "File Backup : $fName"
}
show_results(){
# Versi Apache
vAPACHE=`sudo apachectl -V | grep "Server version"`
# Versi PHP
vPHP="PHP version: `php -v|awk '{print $2}'|head -n 1`"
# Versi MySQL
vMYSQL="MySQL version: `$_MYSQL_IMPORT --version|awk '{ print $5 }'`"
result="\nSelamat Aplikasi simpeg 2019 telah terinstall\nBerikut detail sistem yang terinstall:\n$vAPACHE\n$vPHP\n$vMYSQL\n$1"
dialog --title "Instalation Complete" --backtitle "$APPLICATION" --msgbox "$result" 20 100;
clear
exit
}
exit_apps(){
echo $1; sleep 1; clear; exit;
}
show_form(){
$1 # Running Function
form_return=$? # Catch Error Code Dialog (0: success)
case $form_return in
    1) exit_apps "Application aborted";;
    255) exit_apps "Application terminated";;
esac
}

# Main Program
show_form init_app
list_modul=`cat $_RESULT`
show_form init_user_git
user_git=`cat $_RESULT`
show_form init_pass_git
pass_git=`cat $_RESULT`
install_modul $list_modul
# Check Application
if [ -d $_VHOST/.git ]; then
    echo "Update Applicaton"
    echo "================="
    cd $_VHOST
    git pull origin master
else
    create_vhost $_VHOST
    echo "Installing Applicaton"
    echo "====================="
    git clone https://$user_git:$pass_git@$_GIT_URLS $_VHOST
    sudo chown -R $USER:www-data $_VHOST
    sudo find $_VHOST/upload -type d -exec chmod 770 {} \;
    sudo find $_VHOST/upload -type d -exec chmod g+s {} \;
    sudo find $_VHOST/upload -type f -exec chmod 660 {} \; 2>&1 | grep -v "Operation not permitted"
    echo
    config_linux
    # # Update Message of the Day
    # php $_VHOST/simpeg.php --banner > motd.conf
    # sudo cp motd.conf /etc/motd
    # sudo rm -rf motd.conf
    
    # Restore DB
    show_form form_import_db
    input=`cat $_RESULT`
    action_import_db "${_FILE_SQL[$input-1]}"
fi

rm -f $_RESULT # Clear Result