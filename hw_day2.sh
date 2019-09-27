#!/usr/bin/bash
ls /etc/httpd/modules/mod_mpm*

# Set up worker module 
nano conf.modules.d/00-mpm.conf 
nano conf.modules.d/10-worker.conf 
# 10-worker.conf 
<IfModule mpm_worker_module>
ServerLimit         16
StartServers         2

MaxRequestWorkers   50
MinSpareThreads     25
MaxSpareThreads     50
ThreadsPerChild     25
</ifModule>

service httpd restart
httpd -V | grep -i 'version\|mpm'



# test server
ab -t 60 -n 10000 -c 1000 http://127.0.0.1/

# view processes and threads
pstree apache -p


# Set up prefork module
nano conf.modules.d/00-mpm.conf 
nano conf.modules.d/10-prefork.conf 

# 10-prefork.conf 
<IfModule mpm_prefork_module>
StartServers         8​
ServerLimit          25

MinSpareServers      5​
MaxSpareServers      20​​
MaxRequestWorkers    25​
MaxRequestsPerChild  4000​
</IfModule>

service httpd restart
httpd -V | grep -i 'version\|mpm'

# test server
ab -t 60 -n 10000 -c 1000 http://127.0.0.1/

# view processes and threads
pstree apache -p



# forward proxy

# /etc/httpd/conf.d/vhosts.conf
ProxyRequests On
ProxyVia On

<Proxy *>
    Order Deny,Allow
    Allow from all

    AuthType Basic
    AuthName "Password Required"
    AuthUserFile /etc/httpd/conf.d/password2.file
    Require valid-user
</Proxy>
service httpd restart


# reverse proxy
# /etc/httpd/conf.d/vhosts.conf
ProxyPreserveHost On
ProxyPass /sample http://10.6.144.127/ping.html
ProxyPassReverse /sample http://10.6.144.127/ping.html
service httpd restart
