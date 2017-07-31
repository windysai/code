#!/bin/bash

echo "It will install lamp"
sleep 1

##check last command is OK or not.
check_ok() {
if [ $? != 0 ]
then
    echo "Error, Check the error log."
    exit 1
fi
}
##get the archive of the system,i686 or x86_64.
ar=`arch`
##close seliux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
selinux_s=`getenforce`
if [ $selinux_s == "Enforcing"  -o $selinux_s == "enforcing" ]
then
    setenforce 0
fi
##close iptables
iptables-save > /etc/sysconfig/iptables_`date +%s`
iptables -F
service iptables save
##if the packge installed ,then omit.
myum() {
if ! rpm -qa|grep -q "^$1"
then
    yum install -y $1
    check_ok
else
    echo $1 already installed.
fi
}
## install some packges.
for p in gcc wget perl perl-devel libaio libaio-devel pcre-devel zlib-devel
do
    myum $p
done
##install epel.
if rpm -qa epel-release >/dev/null
then
    rpm -e epel-release
fi
if ls /etc/yum.repos.d/epel-6.repo* >/dev/null 2>&1
then
    rm -f /etc/yum.repos.d/epel-6.repo*
fi
wget -P /etc/yum.repos.d/ http://mirrors.aliyun.com/repo/epel-6.repo


##function of installing mysqld.
install_mysqld() {

          
        #install mysql5.6
            cd /usr/local/src
            [ -f mysql-5.6.35-linux-glibc2.5-$ar.tar.gz ] || wget http://mirrors.sohu.com/mysql/MySQL-5.6/mysql-5.6.35-linux-glibc2.5-$ar.tar.gz
            tar zxf mysql-5.6.35-linux-glibc2.5-$ar.tar.gz
            check_ok
            [ -d /usr/local/mysql ] && /bin/mv /usr/local/mysql /usr/local/mysql_bak
            mv mysql-5.6.35-linux-glibc2.5-$ar /usr/local/mysql
            if ! grep '^mysql:' /etc/passwd
            then
                useradd -M mysql -s /sbin/nologin
            fi
            myum compat-libstdc++-33
            [ -d /data/mysql ] && /bin/mv /data/mysql /data/mysql_bak
            mkdir -p /data/mysql
            chown -R mysql:mysql /data/mysql
            cd /usr/local/mysql
            ./scripts/mysql_install_db --user=mysql --datadir=/data/mysql
            check_ok
            /bin/cp support-files/my-default.cnf /etc/my.cnf
            check_ok
            sed -i '/^\[mysqld\]$/a\datadir = /data/mysql' /etc/my.cnf
            /bin/cp support-files/mysql.server /etc/init.d/mysqld
            sed -i 's#^datadir=#datadir=/data/mysql#' /etc/init.d/mysqld
            chmod 755 /etc/init.d/mysqld
            chkconfig --add mysqld
            chkconfig mysqld on
            service mysqld start
            check_ok
            break
         
}
##function of install httpd.
install_httpd() {
	echo "Install apache version 2.4.9"
	cd /usr/local/src    
	[ -f httpd-2.4.9.tar.gz ] || wget http://archive.apache.org/dist/httpd/httpd-2.4.9.tar.gz
	tar zxf  httpd-2.4.9.tar.gz && cd httpd-2.4.9
	check_ok
	./configure \
	--prefix=/usr/local/apache2 \
	--with-included-apr \
	--enable-so \
	--enable-deflate=shared \
	--enable-expires=shared \
	--enable-rewrite=shared \
	--with-pcre
	check_ok
	make && make install
	check_ok
}

##function of install lamp's php.
install_php() {
		echo -e "Install php version 5.6"
        5.6)
            cd /usr/local/src/
            [ -f php-5.6.6.tar.gz ] || wget http://mirrors.sohu.com/php/php-5.6.6.tar.gz
            tar zxf php-5.6.6.tar.gz &&   cd php-5.6.6
            for p in openssl-devel bzip2-devel \
            libxml2-devel curl-devel libpng-devel \
            libjpeg-devel freetype-devel libmcrypt-devel\
            libtool-ltdl-devel perl-devel
            do
                myum $p
            done
            ./configure \
            --prefix=/usr/local/php \
            --with-apxs2=/usr/local/apache2/bin/apxs \
            --with-config-file-path=/usr/local/php/etc  \
            --with-mysql=/usr/local/mysql \
            --with-libxml-dir \
            --with-gd \
            --with-jpeg-dir \
            --with-png-dir \
            --with-freetype-dir \
            --with-iconv-dir \
            --with-zlib-dir \
            --with-bz2 \
            --with-openssl \
            --with-mcrypt \
            --enable-soap \
            --enable-gd-native-ttf \
            --enable-mbstring \
            --enable-sockets \
            --enable-exif \
            --disable-ipv6
            check_ok
            make && make install
            check_ok
            [ -f /usr/local/php/etc/php.ini ] || /bin/cp php.ini-production  /usr/local/php/etc/php.ini
            break

}
##function of apache and php configue.
join_apa_php() {
sed -i '/AddType .*.gz .tgz$/a\AddType application\/x-httpd-php .php' /usr/local/apache2/conf/httpd.conf
check_ok
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html index.htm/' /usr/local/apache2/conf/httpd.conf
check_ok
cat > /usr/local/apache2/htdocs/index.php <<EOF
<?php
    phpinfo();
?>
EOF

if /usr/local/php/bin/php -i |grep -iq 'date.timezone =&gt; no value'
then
    sed -i '/;date.timezone =$/a\date.timezone = "Asia\/Chongqing"'  /usr/local/php/etc/php.ini
fi
/usr/local/apache2/bin/apachectl restart
check_ok
}


##function of install lamp
lamp() {
	check_service mysqld
	check_service httpd
	install_php
	join_apa_php
	echo "LAMP done，Please use 'http://your ip/index.php' to access."
}

echo "It will install lamp"
lamp
sleep 1
 

