FROM iron/java:1.8

MAINTAINER Ivan Pedrazas (ipedrazas@gmail.com)

COPY run.sh /run.sh
COPY check-ssl-expire.sh /check-ssl-expire.sh

RUN chmod a+x /*.sh

CMD ["/run.sh"]

