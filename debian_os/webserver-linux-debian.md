Berikut langkah-langkah mengisntall webserver di OS linux versi Debian dan turunannya
Langkah - langkah dibawah ini meliputi instalasi webserver dalam hal ini apache, PHPv7 sebagai bahasa pemrograman sisi server 
dan juga database server (MySQL). Untuk mempermudah pengaturan host, akan dijelaskan juga konsep virtual host

# Install Webserver (Apache2)
```
sudo apt update
sudo apt-get install apache2 -y
```
>Sebagai aplikasi tambahan, jika dibutuhkan kita perlu juga menginstall aplikasi curl
```
sudo apt-get install curl
```
>Berikut daftar command yang sering digunakan dalam aplikasi apache
```
sudo systemctl status apache2
sudo systemctl start apache2
sudo systemctl restart apache2
sudo systemctl stop apache2
```
>Jika ada perubahan konfigurasi seperti mengedit file apache.conf, php.ini dll yang membutuhkan restart apache
maka cukup ketik perintah dibawah ini
```
sudo systemctl reload apache2
```

# Konfigurasi Apache2
Setelah aplikasi apache telah terinstall, maka kita bisa melakukan beberapa konfigurasi misal menyembunyikan informasi versi OS, versi apache, konfigurasi virtual host, konfigurasi port dll.
Berikut langkah melakukan konfigurasi apache untuk menyembunyikan informasi system tersebut.
>Buka file konfigurasi apache2, yang secara default terletak di /etc/apache2/apache2.conf atau ketik command berikut di terminal untuk melihat lokasi file konfigurasi apache dan membukanya dengan pico
```
sudo find /etc -name "apache2.conf"
sudo pico /etc/apache2/apache2.conf
```
>Tambahkan script berikut dibagian paling akhir untuk menyembunyikan versi apache dan OS
```
ServerSignature Off
ServerTokens Prod
```
>Simpan dan reload service apache2
```
sudo systemctl reload apache2
```

# Konfigurasi Virtual Host
Sebelum melakukan konfigurasi virtual host, pastikan anda membuat sebuah folder untuk lokasi virtual host tersebut.
```
# buat folder di /var/www dan buat hak aksesnya menjadi 755
sudo mkdir -p /var/www/hanifsite && chmod -R 755 /var/www/hanifsite
```
>Setelah folder lokasi virtual host dibuat, buatlah sebuat file di lokasi site-available apache
```
sudo touch /etc/apache2/sites-available/hanifsite.vhost.conf
sudo pico /etc/apache2/sites-available/hanifsite.vhost.conf
```
>Lalu copy paste script berikut kedalam file tersebut
```
<VirtualHost *:80>
    ServerAdmin hanifsite@softdev.com
    ServerName hanifsite.com
    ServerAlias www.hanifsite.com
    DocumentRoot "/var/www/hanifsite"
    <Directory "/var/www/hanifsite">
        Options Indexes FollowSymLinks
        AllowOverride All
        Order allow,deny
        Allow from all
        Require all granted
    </Directory>
    ErrorLog ${APACHE_LOG_DIR}/error.hanifsite.log
    CustomLog ${APACHE_LOG_DIR}/access.hanifsite.log combined
</VirtualHost>
```
>Simpan file tersebut, lalu aktifkan vhost dan modul rewrite (enable .htaccess).
Namun sebelumnya pastikan virtual host default apache(000-default.conf), harus dinonaktifkan terlebih dahulu
```
sudo a2dissite 000-default.conf
sudo a2ensite hanifsite.vhost.conf

# aktifkan modul rewrite
sudo a2enmod rewrite

# check syntax error
sudo apache2ctl configtest

# restart service apache
sudo systemctl reload apache2
```

# Trobleshoting Apache2 (Uninstall)
Jika suatu saat nanti terjadi crash atau ingin mengganti webserver apache dengan webserver yang lain, Anda bisa menghapus aplikasi apache dengan cara ini.
```
sudo service apache2 stop
sudo apt-get purge apache2*
sudo apt-get autoremove

# hapus berkas konfigurasi apache
sudo rm -rf /etc/apache2
# hapus berkas konfigurasi virtual host
sudo rm -rf /var/www/*
```
