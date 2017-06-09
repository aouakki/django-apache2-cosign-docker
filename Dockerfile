FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -y apt-utils vim curl apache2 apache2-utils
RUN apt-get -y install python3 libapache2-mod-wsgi-py3
RUN apt-get -y install postgresql postgresql-contrib pwgen

### install open ssl
RUN apt-get update \
	&& apt-get install -y wget gcc libssl-dev=$OPENSSL_VERSION make openssl


### Build Cosign ###
RUN wget "$COSIGN_URL" \
  && mkdir -p src/cosign \
  && tar -xvf cosign-3.2.0.tar.gz -C src/cosign --strip-components=1 \
  && rm cosign-3.2.0.tar.gz \
  && cd src/cosign \
  && ./configure --enable-apache2=/usr/local/apache2/bin/apxs \
  && sed -i 's/remote_ip/client_ip/g' ./filters/apache2/mod_cosign.c \
  && make \
  && make install \
  && cd ../../ \
  && rm -r src/cosign \
  && mkdir -p /var/cosign/filter \
  && chmod 777 /var/cosign/filter

### Start script incorporates config files and sends logs to stdout ###
COPY start.sh .
RUN chmod +x start.sh
CMD /usr/local/apache2/start.sh


RUN ln /usr/bin/python3 /usr/bin/python
RUN apt-get -y install python3-pip
RUN ln /usr/bin/pip3 /usr/bin/pip
RUN pip install --upgrade pip
RUN pip install django ptvsd
ADD ./demo_site.conf /etc/apache2/sites-available/000-default.conf
EXPOSE 80 3500
CMD ["apache2ctl", "-D", "FOREGROUND"]
