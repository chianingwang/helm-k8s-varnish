# Building from Ubuntu Precise
# image name - varnishswift
# include nginx reverse proxy + varnish 256m
# sudo docker build -t="varnishswift:1.1" .
FROM ubuntu:16.04

MAINTAINER johnny wang, johnny@swiftstack.com

RUN apt-get update -y
RUN apt-get upgrade -y

RUN apt-get -y install nginx varnish net-tools
#RUN apt-get -y install nginx varnish net-tools stunnel4
RUN mkdir -p /etc/nginx/ssl

ADD startscript/start.sh /start.sh

ADD nginx/default /etc/nginx/sites-available/default
ADD nginx/default.conf /etc/nginx/conf.d/default.conf
ADD varnish/varnish /etc/default/varnish
ADD varnish/default.vcl /etc/varnish/default.vcl

ADD ssl/star_xxx_org.pem /etc/nginx/ssl/star_xxx_org.pem
ADD ssl/star_xxx_org.key /etc/nginx/ssl/star_xxx_org.key
RUN chmod 600 /etc/nginx/ssl/star_xxx_org.pem
RUN chmod 600 /etc/nginx/ssl/star_xxx_org.pem

EXPOSE 443 80 8080

CMD ["/start.sh"]
