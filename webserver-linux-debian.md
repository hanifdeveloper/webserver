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
