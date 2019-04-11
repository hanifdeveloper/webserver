Catatan Instalasi Web Server diberbagai mesin

## Install Apache2
```
sudo apt update
sudo apt-get install apache2 -y

-- Optional Install Curl
sudo apt-get install curl

-- Common Function
sudo systemctl status apache2
sudo systemctl start apache2
sudo systemctl restart apache2
sudo systemctl stop apache2

-- Jika ada perubahan konfigurasi, cukup reload service
sudo systemctl reload apache2
```
>Untuk mempermudah manajemen webserver, buat folder tempat file web di folder www (virtual host) dan buat hak akses folder vhosts menjadi 755
```
sudo mkdir -p /var/www/simpeg
sudo chmod -R 755 $_VHOST_SIMPEG
```
## Setting Apache.conf
>Buka file apache2.conf di folder instalasi Apache, untuk melihat lokasi pengaturan web server apache
```
sudo pico /etc/apache2/apache2.conf
```
>Tambahkan script berikut dibagian paling akhir untuk menyembunyikan versi apache dan OS
```
ServerSignature Off
ServerTokens Prod
```
>Simpan dan reload service apache
```
sudo systemctl reload apache2
```
>Buat sebuat file vhost baru di folder sites-available, dengan cara ini tidak perlu melakukan perubahan pada konfigurasi default apache
```
sudo touch /etc/apache2/sites-available/simpeg.vhost.conf
sudo pico /etc/apache2/sites-available/simpeg.vhost.conf
```
>Copy paste kedalam file vhost tersebut
```
<VirtualHost *:80>
    ServerAdmin hanif.softdev@pekalongankota.dev
    ServerName simpeg.pekalongankota.com
    ServerAlias www.simpeg.pekalongankota.com
    DocumentRoot "/var/www/simpeg"
    <Directory "/var/www/simpeg">
        Options Indexes FollowSymLinks
        AllowOverride All
        Order allow,deny
        Allow from all
        Require all granted
    </Directory>
    ErrorLog ${APACHE_LOG_DIR}/error.simpeg.log
    CustomLog ${APACHE_LOG_DIR}/access.simpeg.log combined
</VirtualHost>
```
>Disable vhost default apache, dan aktifkan vhost yang baru
```
sudo a2dissite 000-default.conf
sudo a2ensite simpeg.vhost.conf
```
>Aktifkan modul rewrite, lalu restart service apache
```
sudo a2enmod rewrite
sudo apache2ctl configtest
sudo systemctl reload apache2
```
## Trobleshoting Apache2 (Uninstall)
```
sudo service apache2 stop
sudo apt-get purge apache2*
sudo apt-get autoremove
sudo rm -rf /etc/apache2
sudo rm -rf /var/www/simpeg
```

## Install PHP 7.0
```
sudo apt update
sudo apt-get install php7.0 -y
-- Check version php
php -v
-- Check info php
php -i
```
## Install Lib PHP 7.0 (php-curl, php-mysql, php-gd)
>Install library pendukung php yang digunakan seperti php-curl, php-mysql dan php-gd
```
sudo apt-get install php-curl -y
sudo apt-get install php-mysql -y
sudo apt-get install php-gd -y
sudo systemctl reload apache2
```
## Setting php.ini

>Check location php.ini versi apache
>Example : /etc/php/7.0/apache2/php.ini
```
sudo find /etc/ -name php.ini | grep "apache2"
```
>Buka file php.ini sesuai lokasi penyimpan file konfigurasi php
```
sudo pico /etc/php/7.0/apache2/php.ini
```
>Cari dan ubah nilai variabel pada file php.ini
```
upload_max_filesize = 10M
post_max_size = 10M

-- Modul tambahan, untuk php_browser
browscap = /var/www/simpeg/comp/php_browscap/php_browscap.ini
```
>Restart service apache
```
sudo systemctl reload apache2
```
## Trobleshoting PHP 7.0 (Uninstall)
```
// Check Modul PHP yang terinstall
dpkg --list | grep php | awk '/^ii/{ print $2}'
x="$(dpkg --list | grep php | awk '/^ii/{ print $2}')"
sudo apt-get --purge remove $x
sudo apt-get purge php7.*
sudo apt-get autoremove phpmyadmin -y
sudo apt-get autoremove -y
sudo apt-get autoclean
```

## Install MySQL
```
sudo apt update
sudo apt-get install mysql-server mysql-client mysql-common -y
-- Buat database dbweb_simpeg
sudo mysql -u root -e "DROP DATABASE dbweb_simpeg;"
sudo mysql -u root -e "CREATE DATABASE dbweb_simpeg CHARACTER SET utf8 COLLATE utf8_general_ci"
sudo mysql -u root -e "CREATE USER 'admin'@'localhost' IDENTIFIED BY '_4dm1n-DB@Dev'"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost'"
sudo mysql -u root -e "UPDATE mysql.user SET plugin='mysql_native_password' WHERE mysql.user.user='admin'"

-- Check service MySQL
systemctl status mysql.service

--Check Process MySQL
ps aux | grep mysql

-- Terminated service
sudo pkill mysql

-- Install service
sudo mysqld --initialize

-- Reset Password root (masuk ke safemode)
sudo systemctl stop mysql.service
sudo mysqld_safe --skip-grant-tables --skip-networking &
mysql -u root
USE mysql;
SELECT user, host, password, plugin, authentication_string FROM user;
UPDATE user SET authentication_string=PASSWORD('root') WHERE User='root';
UPDATE user SET password=PASSWORD('root') WHERE User='root';
UPDATE user SET plugin = 'mysql_native_password' WHERE User='root';
FLUSH PRIVILEGES;

-- Menambah user admin untuk aplikasi
CREATE USER 'admin'@'localhost' IDENTIFIED BY '_4dm1n-DB@Dev';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost';
UPDATE user SET plugin='mysql_native_password' WHERE User='admin';
FLUSH PRIVILEGES;
quit

-- Check password root, jika masuk buat Database dbweb_simpeg
mysql -u root -p
root
CREATE DATABASE dbweb_simpeg;
quit
sudo systemctl status mysql.service
-- Jika error, saat menjalankan service mysql, reboot OS
sudo reboot

-- Jika error check prosess dan kill proccess mysql safe mode
ps aux | grep mysqld
sudo killall -9 mysqld mysqld_safe
-- Ulangi masuk ke safemode

-- Hapus history command mysql
sudo rm $HOME/.mysql_history
```
## Trobleshoting MySQL (Uninstall)
```
sudo apt-get remove --purge mysql-server mysql-client mysql-common -y
sudo apt-get autoremove -y
sudo apt-get autoclean
sudo rm -rf /etc/mysql
sudo find / -iname 'mysql*' -exec rm -rf {} \;
```
## Setting my.cnf
>Check location my.cnf
>Example : /etc/mysql/my.cnf
```
sudo find /etc -iname my.cnf | grep "mysql"
```
>Cari dan ubah nilai variabel pada file my.cnf
```
innodb_buffer_pool_size = 384M
innodb_additional_mem_pool_size = 20M
innodb_log_file_size = 10M
innodb_log_buffer_size = 64M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 180
```
## Setting Variabel Environment
>Setelah project berhasil diclone ke folder /var/www/simpeg, langkah selanjutnya, Buka file bashrc (sesuai dengan file konfigurasi masing2 terminal, misal .zshrc) untuk menambakan konfigurasi variable environment yang dibutuhkan aplikasi simpeg
```
sudo pico ~/.bashrc
```
>Tambahkan script berikut dibagian paling akhir
```
export _VHOST_SIMPEG=/var/www/simpeg
alias simpeg="php $_VHOST_SIMPEG/simpeg.php"
```
>Simpan, lalu reboot. Kemudian login kembali
```
sudo reboot
```

## Clone Source Code Project
>Untuk url dan password sesuaikan dengan url clone dari account masing-masing
```
cd $_VHOST_SIMPEG
git clone https://hanifdeveloper@bitbucket.org/kominfopklcity/web-application-simpeg.git .

-- Setelah project berhasil diclone, langkah selanjutnya tinggal mengupdate 
git pull origin master
```
>Buat owner folder vhost sesuai dengan user yang aktif dan group apache, hal ini dimaksudkan agar resource folder bisa diakses dari browser
```
sudo chown -R $USER:www-data $_VHOST_SIMPEG
```
## Instalasi script dan import database
>Setelah Anda login kembali, tahap selanjutnya adalah inisialisasi applikasi dan restoring database (pastikan dbweb_simpeg sudah dibuat)
```
simpeg -init
-- Tunggu hingga proses inisialisasi selesai

simpeg -options
-- Pilih menu Import Database, dan tunggu hingga proses restoring db selesai
```
## Setup Crontab
>Cron daemon merupakan sebuah service yang berjalan di semua distribusi Unix dan Linux. 
Service ini didesain khususnya untuk mengeksekusi suatu perintah diwaktu-waktu tertentu yang telah ditentukan. 
Tugas yang dikenal dengan istilah cronjobs ini merupakan hal mendasar yang harus dipahami setiap System 
Administrator. Cronjobs sangat berguna untuk mengotomatiskan suatu script sehingga mereka dapat dijalankan 
diwaktu-waktu tertentu.

>Perintah Dasar Crontab
```
crontab -e Mengubah atau membuat file crontab jika belum ada.
crontab -l Menampilkan isi file crontab.
crontab -r Menghapus file crontab.
crontab -v Menampilkan waktu terakhir mengubah isi file crontab. (Hanya tersedia dibeberapa sistem).
```

>Crontab Parameters
```
m - Minute (menit) - 0 to 59
h - Hour (jam) - 0 to 23
dom - Day of Month (tanggal) - 0 to 31
mon - Month (bulan) - 0 to 12
dow - Day of Week (nomor hari) - 0 to 7 (0 dan 7 adalah hari minggu)
```

>Penggunaan String Khusus
```
@reboot - Dijalankan sekali setiap kali sistem dihidupkan
@yearly - Dijalankan sekali setahun 0 0 1 1 *
@annually - Sama seperti @yearly
@monthly - Dijalankan sekali sebulan 0 0 1 * *
@weekly - Dijalankan sekali seminggu 0 0 * * 0
@daily - Dijalankan setiap hari 0 0 * * *
@midnight - Sama seperti @daily
@hourly - Dijalankan setiap jam 0 * * * *
```

>Contoh kombinasi parameter
```
#Setiap menit setiap hari
* * * * * /home/user/script.sh
0-59 0-23 0-31 0-12 0-7 /home/user/script.sh

#Setiap 10 menit setiap hari
\*/10 * * * * /home/user/script.sh
0-59/10 * * * * /home/user/script.sh
0,10,20,30,40,50 * * * * /home/user/script.sh

#Setiap 5 menit pada pukul 6 pagi dimulai pada 6:07
07-59/5 06 * * * /home/user/script.sh

#Setiap hari tengah malam
0 0 * * * /home/user/script.sh
0 0 * * 0-7 /home/user/script.sh

#Tiga kali sehari
0 */8 * * * /home/user/script.sh
0 0-23/8 * * * /home/user/script.sh
0 0,8,16 * * * /home/user/script.sh

#Setiap weekday (Senin - Jumat) jam 6 pagi
0 06 * * 1-5 /home/user/script.sh

#Setiap weekend (Sabtu - Minggu) jam 6 pagi
0 06 * * 6,7 /home/user/script.sh
0 06 * * 6-7 /home/user/script.sh

#Sebulan sekali setiap tanggal 20 jam 6 pagi
0 06 20 * * /home/user/script.sh

#Setiap 4 hari sekali jam 6 pagi
0 06 */4 * * /home/user/script.sh

#Setiap 4 bulan sekali tanggal 10 jam 6 pagi
0 06 10 */4 * /home/user/script.sh
```

>Berikut contoh script untuk menjalankan proses sinkronisasi database simpeg via cronjob
```
#@daily php simpeg -sync-all 2>&1 >> sync.logs
0 3 * * * php simpeg -sync-all 2>&1 >> sync.logs
```

## Script Instalasi dan Uninstall Application
>Buat sebuah file shell, dan copy paste script berikut untuk mempermudahkan proses instalasi dan uninstall aplikasi

>Install Server
```
$ touch install-server.sh && sudo chmod +x install-server.sh && pico install-server.sh
```
>copy paste script dibawah ini
[install-server.sh](assets/document/webserver/install-server.sh)

>dan untuk menjalakannya ketik :
```
$ ./install-server.sh
```

>Uninstall Server
```
$ touch uninstall-server.sh && sudo chmod +x uninstall-server.sh && pico uninstall-server.sh
```
>copy paste script dibawah ini
[uninstall-server.sh](assets/document/webserver/uninstall-server.sh)

>dan untuk menjalakannya ketik
```
$ ./uninstall-server.sh
```
