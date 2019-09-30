# server: 10.6.144.127

# Task 1 
# 1 Install httpd
yum install -y httpd

firewall-cmd --add-service=http --permanent
firewall-cmd --permanent --zone=public --add-port=80/tcp
firewall-cmd --reload

## start it
echo "
<h2>Hello from httpd</h2>
<hr/>
<p> Created by Andrei Shvedau </p>
" > /var/www/html/index.html


service httpd start
httpd -S

# *** done ***

# Install apache2
cd /usr/local/src/
wget http://ftp.byfly.by/pub/apache.org//httpd/httpd-2.4.41.tar.gz -P
gzip -d httpd-2.4.41.tar.gz
tar -xvf httpd-2.4.41.tar 

yum install -y gcc
yum -y install arp apr-devel apr-util apr-util-devel pcre pcre-devel 
./configure –prefix=/usr/local/apache2
make
make install

## start it
/usr/sbin/httpd -k stop
/usr/local/apache2/bin/apachectl start
rm /usr/local/apache2/htdocs/index.html
echo "
<h2> Hello from Apache2 </h2>
<hr/>
<p> Created by Andrei Shvedau </p>
" > /usr/local/apache2/htdocs/index.html


# Task 2

## 2. Run a webserver of choice, create VHOSTS configuration file vhosts.conf

# on host: edit /etc/hosts

mkdir /var/www/html/andrei.shvedau
echo "
h2>This is ping.html</h2>
<hr />
<p>Created by Andrei Shvedau</p>
" > /var/www/html/andrei.shvedau/ping.html

# cp default page for site
cp /var/www/html/index.html /var/www/html/andrei.shvedau/

echo "
<VirtualHost *:80>

 DocumentRoot /var/www/html/andrei.shvedau
 ServerName www.andrei.shvedau.local
 ServerAlias andrei.shvedau.local

</VirtualHost>
" > /etc/httpd/conf.d/vhosts.conf
service httpd restart

## 8. Configure mod rewrite for Virtual host with following rules:
### - All root requests are redirected to index.html // done
### - All requests to index.html are redirected to ping.htlm
### - All other requests must be “Forbidden” – return HTTP 403.
### Rules are chained, e.g. a request for non-existing page will be processed by each rule from top to bottom and finally will end up with 403 response code.
rm /etc/httpd/conf.d/vhosts.conf
echo '
<VirtualHost *:80>
 DocumentRoot /var/www/html/andrei.shvedau
 ServerName www.andrei.shvedau.local
 ServerAlias andrei.shvedau.local

 RewriteEngine On
 RewriteRule "/$" "/index.html" [R,L,NC]
 RewriteRule "^/index\.html$" "/ping.html" [R,L,NC]
 RewriteRule !^ping - [F,NC]
</VirtualHost>
' > /etc/httpd/conf.d/vhosts.conf


# Task 3

yum -y install epel-release
yum install -y cronolog

## added following lines to vhost.conf  
CustomLog "|/usr/sbin/cronolog /var/log/andrei.shvedau/acces.log.%Y-%m-%d" combined
ErrorLog "|/usr/sbin/cronolog /var/log/andrei.shvedau/error.log.%Y-%m-%d"

cat /var/log/andrei.shvedau/error.log.2019-09-26 
cat /var/log/andrei.shvedau/access.log.2019-09-26 

# Task 4
## added following lines to vhost.conf
LogFormat "%h %A %l %u %t \"%r\" %>s %p %b" my_log_format
CustomLog "|/usr/bin/logger -t httpd -p local1.info" my_log_format

cat /var/log/messages