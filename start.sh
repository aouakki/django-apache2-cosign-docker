#!/bin/sh

# link configuration files for apache and cosign
# from volume from preloaded secret.
ln -sf /usr/local/apache2/local/conf/httpd.conf /usr/local/apache2/conf/httpd.conf
ln -s /usr/local/apache2/local/conf/httpd-cosign.conf /usr/local/apache2/conf/extra/httpd-cosign.conf
ln -sf /usr/local/apache2/local/conf/httpd-ssl.conf /usr/local/apache2/conf/extra/httpd-ssl.conf

# copy certs from secret volume to a location that can be written to.
mkdir /usr/local/apache2/certs/
cp /usr/local/apache2/local/certs/* /usr/local/apache2/certs/

# Rehash command needs to be run before starting apache.
c_rehash /usr/local/apache2/certs

# Redirect logs to stdout and stderr for docker reasons.
ln -sf /dev/stdout /usr/local/apache2/logs/access_log
ln -sf /dev/stderr /usr/local/apache2/logs/error_log

/usr/local/apache2/bin/httpd -DFOREGROUND
