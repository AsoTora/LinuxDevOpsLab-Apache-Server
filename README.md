# Linux_DevOps_AS
Repo for scripts and stuff from EPAM devops lab.

# Day 1
## *For more details see hw_day1.sh file*

## Task 1 
### Installing httpd and apache2
httpd:  
![img 1](./imgs/httpd_s.png)
![img 2](./imgs/httpd.png)

apache2:  
![img 3](./imgs/apachectl_s.png)
![img 4](./imgs/apache2.png)

## Check
Graceful restart is a form of server restart, which when applied would advise server threads to exit when idle, and onl then reload the configuration.

## Task 2
### using vhosts and redirection

Redirect home:  
![img 5](./imgs/redirect_1.png)

Redirect /index.html:  
![img 6](./imgs/redirect_2.png)

Get forbiden on everything else
![img 7](./imgs/redirect_3.png)

## Task 3
### using cronolog
using cronolog logging:  
![img 8](./imgs/cronolog.png)

## Task4
### using syslog
sending curl request:  
![img 9](./imgs/curl.png)

vieving logs:  
![img 10](./imgs/syslog_files.png)


# Day 2
## *For more details see hw_day2.sh file*

## Task 1 
### Using worker mpm 
![img 1](./imgs2/ab_worker.png)
![img 2](./imgs2/worker.png)

### Using prefork mpm 
![img 3](./imgs2/ab_prefork.png)
![img 4](./imgs2/prefork.png)


## Task 2
### forward proxy:
![img 5](./imgs2/forward_proxy.png)

### rewerse proxy
![img 8](./imgs2/reverse_proxy.png)


# Day 3
## *For more details see hw_day3.sh file*

## Task 1 
### set up 3 VM with tomcat server
![img 1](./imgs3/tomcat.png)
![img 2](./imgs3/manager.png)

### file test.jsp:  
![img 0](./imgs3/test1.png)
![img 0](./imgs3/test2.png)
![img 0](./imgs3/test3.png)

### deployment of clusterjsp.war
![img 3](./imgs3/deploy2.png)
![img 4](./imgs3/deploy3.png)
  
cluster on vm1:  
![img 5](./imgs3/cluster1.png)

cluster on vm2:  
![img 6](./imgs3/cluster2.png)

cluster on vm3:  
![img 7](./imgs3/cluster3.png)

## Task 2
### cluster balancer:
![img 8](./imgs3/balancer.png)

config files:  
![img 9](./imgs3/vhosts.png)
![img 10](./imgs3/workers.png)


## Task 3
### Log4j2 on tomcat1
![img 11](./imgs3/logs.png)
