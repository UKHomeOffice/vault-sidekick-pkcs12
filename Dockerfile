FROM java:8

MAINTAINER Ivan Pedrazas (ipedrazas@gmail.com)

COPY run.sh /run.sh
COPY check-ssl-expire.sh /check-ssl-expire.sh

RUN chmod a+x /*.sh

RUN apt-get update && \
  apt-get install -y jq host && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/jq

CMD ["/run.sh"]

# CMD[""]
