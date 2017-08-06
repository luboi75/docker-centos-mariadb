FROM centos

MAINTAINER Lubo Ivanovic <luboi75@googlemail.com>

RUN touch /etc/yum.repos.d/mariadb.repo; \
    echo -e "# MariaDB 10.2 CentOS repository list - created 2017-07-31 23:42 UTC \n\
# http://downloads.mariadb.org/mariadb/repositories/ \n\
[mariadb] \n\
name = MariaDB \n\
baseurl = http://yum.mariadb.org/10.2/centos7-amd64 \n\
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB \n\
gpgcheck=1" >> /etc/yum.repos.d/mariadb.repo; \
    yum install -y MariaDB-server MariaDB-client; \
    rm -Rf /var/lib/mysql/*

ADD entrypoint.sh /opt/
VOLUME /var/lib/mysql
EXPOSE 3306

ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["mysqld_safe"]
#CMD ["/bin/bash"]
