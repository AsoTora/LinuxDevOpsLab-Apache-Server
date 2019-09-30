# Task 1
yum install httpd-devel apr apr-devel apr-util apr-util-devel gcc make libtool autoconf

# download tomcat 
wget http://ftp.byfly.by/pub/apache.org/tomcat/tomcat-8/v8.5.46/bin/apache-tomcat-8.5.46.tar.gz
sudo tar -zxvf apache-tomcat-8.5.46.tar.gz -C /opt/tomcat --strip-components=1

cd /opt/tomcat
sudo chgrp -R tomcat conf
sudo chmod g+rwx conf
sudo chmod g+r conf/*
sudo chown -R tomcat logs/ temp/ webapps/ work/

sudo chgrp -R tomcat bin
sudo chgrp -R tomcat lib
sudo chmod g+rwx bin
sudo chmod g+r bin/*

echo "
[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/bin/kill -15 $MAINPID

User=tomcat
Group=tomcat

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/tomcat.service
start tomcat.service

# firewall
firewall-cmd --zone=public --permanent --add-port=8080/tcp
firewall-cmd --reload

# added to /opt/tomcat/conf/tomcat-users.xml
<user username="yourusername" password="yourpassword" roles="manager-gui,admin-gui"/>

# changed /opt/tomcat/latest/webapps/manager/META-INF/context.xml
<Context antiResourceLocking="false" privileged="true" >
<!--
  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1| my.ip.value" />
-->
</Context>

systemctl restart tomcat


#tomcat1 - create test.jsp page
cat << EOF > /opt/tomcat/webapps/ROOT/test.jsp
<%
session.setAttribute("a","a");
%>
<html>
<head>
<title>Test JSP</title>
</head>
<body>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr bgcolor="#CCCCCC">
<td width="13%">TomcatA Machine</td>
<td width="87%">&nbsp;</td>
</tr>
<tr>
<td>Session ID :</td>
<td><%=session.getId()%></td>
</tr>
</table>
</body>
</html>
EOF

#tomcat2 - create test.jsp page
cat << EOF > /opt/tomcat/webapps/ROOT/test.jsp
<%
session.setAttribute("a","a");
%>
<html>
<head>
<title>Test JSP</title>
</head>
<body>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr bgcolor="#CCCC00">
<td width="13%">TomcatB Machine</td>
<td width="87%">&nbsp;</td>
</tr>
<tr>
<td>Session ID :</td>
<td><%=session.getId()%></td>
</tr>
</table>
</body>
</html>
EOF

#tomcat3 - create test.jsp page
cat << EOF > /opt/tomcat/webapps/ROOT/test.jsp
<%
session.setAttribute("a","a");
%>
<html>
<head>
<title>Test JSP</title>
</head>
<body>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr bgcolor="#00CCCC">
<td width="13%">TomcatC Machine</td>
<td width="87%">&nbsp;</td>
</tr>
<tr>
<td>Session ID :</td>
<td><%=session.getId()%></td>
</tr>
</table>
</body>
</html>
EOF

#Autodeploy on surname-tomcat1x
scp clusterjsp.war root@10.6.144.127:/tmp
cp /tmp/clusterjsp.war /opt/tomcat/webapps/

#tomcat2 
scp clusterjsp.war root@10.6.144.144:/tmp

# tomcat3
scp clusterjsp.war root@10.6.144.145:/tmp


# Task 2
## download open_jdk 
mkdir -p /opt/mod_jk/
cd /opt/mod_jk
http://www.eu.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.46-src.tar.gz
tar -xvzf tomcat-connectors-1.2.46-src.tar.gz 

cd tomcat-connectors-1.2.46-src/native/
./configure --with-apxs=/usr/bin/apxs
make
libtool --finish /usr/lib64/httpd/modules
make install


## in /opt/tomcat/conf/server.xml files:
<Engine name="Catalina" defaultHost="localhost" jvmRoute="app1">
<Engine name="Catalina" defaultHost="localhost" jvmRoute="app2">
<Engine name="Catalina" defaultHost="localhost" jvmRoute="app3">

## + uncomment line:
<Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster"/>​

## set-up claster.lab
echo "
worker.list=balancer,app1,app2,app3
worker.balancer.type=lb
worker.balancer.balance_workers=app1,app2,app3
worker.balancer.sticky_session=1

# logs
workers.apache_log=/var/log/httpd

# tomcat 1
worker.app1.host=10.6.144.127
worker.app1.type=ajp13
worker.app1.port=8009
worker.app1.socket_timeout=10
worker.app1.lbfactor=1
# failover
#worker.app1.redirect=app2

# tomcat 2
worker.app2.type=ajp13
worker.app2.host=10.6.144.144
worker.app2.port=8009
worker.app2.socket_timeout=10
worker.app2.lbfactor=1
# failover
#worker.app2.redirect=app3

# tomcat 3
worker.app3.type=ajp13
worker.app3.host=10.6.144.145
worker.app3.port=8009
worker.app3.socket_timeout=10
worker.app3.lbfactor=1
# failover
#worker.app3.activation=disabled
" > /etc/httpd/conf/workers.properties

echo '
<VirtualHost *:80>
 DocumentRoot /var/www/html/andrei.shvedau
 ServerName www.andrei.shvedau.claster.lab
 ServerAlias andrei.shvedai.claster.lab

 LogFormat "%h %A %l %u %t \"%r\" %>s %p %b" shvedau.log
 CustomLog "|/usr/bin/logger -t httpd -p local1.info" shvedau.log
 ErrorLog "|/usr/sbin/cronolog /var/log/andrei.shvedau/error.log.%Y-%m-%d"

 JkMount /* balancer
 JkMountCopy On
</VirtualHost>

<VirtualHost *:80>
 ServerName www.andrei.shvedau-tomcat1.lab
 JkMount /* app1
 JkMountCopy On
</VirtualHost>

<VirtualHost *:80>
 ServerName www.andrei.shvedau-tomcat2.lab
 JkMount /* app2
 JkMountCopy On
</VirtualHost>

<VirtualHost *:80>
 ServerName www.andrei.shvedau-tomcat3.lab
 JkMount /* app3
 JkMountCopy On
</VirtualHost>
' >  /etc/httpd/conf.d/vhosts.conf 

echo 'LoadModule jk_module "/etc/httpd/modules/mod_jk.so"
JkWorkersFile /etc/httpd/conf/workers.properties

# Where to put jk shared memory
JkShmFile     /var/run/httpd/mod_jk.shm

# Where to put jk logs
JkLogFile     /var/log/httpd/mod_jk.log

# Set the jk log level [debug/error/info]
JkLogLevel    info

# Select the timestamp log format
JkLogStampFormat "[%a %b %d %H:%M:%S %Y] "
JkRequestLogFormat "%w %V %T"
JkEnvVar SSL_CLIENT_V_START worker1
' > /etc/httpd/conf.modules.d/10-jdk.conf 

## firewall on every machine
firewall-cmd --zone=public --permanent --add-port=8009/tcp


# Task 3
wget http://ftp.byfly.by/pub/apache.org/logging/log4j/2.12.1/apache-log4j-2.12.1-bin.tar.gz
tar -xzvf apache-log4j-2.12.1-bin.tar.gz
mv apache-log4j-2.12.1-bin/* /opt/tomcat/lib/

echo '
LOG4J_JARS="log4j-core-2.12.1.jar log4j-api-2.12.1.jar log4j-jul-2.12.1.jar"
# make log4j2.xml available
if [ ! -z "$CLASSPATH" ] ; then CLASSPATH="$CLASSPATH": ; fi
CLASSPATH="$CLASSPATH""$CATALINA_BASE"/lib
# Add log4j2 jar files to CLASSPATH
for jar in $LOG4J_JARS ; do
if [ -r "$CATALINA_HOME"/lib/"$jar" ] ; then
CLASSPATH="$CLASSPATH":"$CATALINA_HOME"/lib/"$jar"
else
echo "Cannot find $CATALINA_HOME/lib/$jar"
echo "This file is needed to properly configure log4j2 for this program"
exit 1
fi
done
# use the logging manager from log4j-jul
LOGGING_MANAGER="-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager"
LOGGING_CONFIG="-Dlog4j.configurationFile=${CATALINA_BASE}/conf/log4j2.xml"
' > setenv.sh

rm conf/logging.properties 

echo '
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="warn" name="catalina" packages="">

<Appenders>
<RollingRandomAccessFile name="catalina"
fileName="${sys:catalina.base}/logs/catalina.log"
filePattern="${sys:catalina.base}/logs/catalina/$${date:yyyy-MM}/catalina-%d{yyyy-MM-dd}-%i.log.zip">
<PatternLayout>
<Pattern>%d{MMM d, yyyy HH:mm:ss}: %5p (%F:%L) - %m%n</Pattern>
</PatternLayout>
<Policies>
<TimeBasedTriggeringPolicy />
<SizeBasedTriggeringPolicy size="250 MB" />
</Policies>
<DefaultRolloverStrategy max="100" />
</RollingRandomAccessFile>
</Appenders>
<Loggers>
<!-- default loglevel for emaxx code -->
<logger name="org.apache.catalina" level="info">
<appender-ref ref="catalina" />
</logger>
<Root level="info">
<appender-ref ref="catalina" />
</Root>
</Loggers>
</Configuration>
' > /conf/log4j2.xml

systemctl restart tomcat