# stunnel Server
# 
# VERSION 1.4 ( replace new cert and remove stunnel )
# VERSION 1.3 ( replace new cert )
# VERSION 1.2

# Building from Ubuntu Precise
FROM ubuntu:16.04

MAINTAINER johnny wang, johnny@swiftstack.com

RUN apt-get update -y
RUN apt-get upgrade -y

RUN apt-get -y install nginx varnish net-tools
#RUN apt-get -y install nginx varnish net-tools stunnel4
RUN mkdir -p /etc/nginx/ssl

ADD start.sh /start.sh

ADD default /etc/nginx/sites-available/default
ADD default.conf /etc/nginx/conf.d/default.conf
ADD varnish /etc/default/varnish
ADD default.vcl /etc/varnish/default.vcl
#ADD stunnel.conf /etc/stunnel/stunnel.conf

ADD star_xxx_org.pem /etc/nginx/ssl/star_xxx_org.pem
ADD star_xxx_org.key /etc/nginx/ssl/star_xxx_org.key
RUN chmod 600 /etc/nginx/ssl/star_xxx_org.pem
RUN chmod 600 /etc/nginx/ssl/star_xxx_org.pem

EXPOSE 443 80 8080

CMD ["/start.sh"]
