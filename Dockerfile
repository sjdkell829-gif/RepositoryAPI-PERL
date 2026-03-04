FROM httpd:2.4

RUN apt-get update && apt-get install -y \
    perl \
    libjson-perl \
    libfile-slurp-perl \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i \
    -e 's/#LoadModule cgi_module/LoadModule cgi_module/' \
    -e 's/#LoadModule rewrite_module/LoadModule rewrite_module/' \
    /usr/local/apache2/conf/httpd.conf

RUN sed -i \
    -e 's|Options Indexes FollowSymLinks|Options Indexes FollowSymLinks ExecCGI|' \
    -e 's|AllowOverride None|AllowOverride All|' \
    /usr/local/apache2/conf/httpd.conf

RUN echo 'AddHandler cgi-script .pl' >> /usr/local/apache2/conf/httpd.conf
RUN echo 'ScriptAlias /cgi-bin/ /usr/local/apache2/cgi-bin/' >> /usr/local/apache2/conf/httpd.conf

COPY ./index.html /usr/local/apache2/htdocs/
COPY ./swagger.html /usr/local/apache2/htdocs/
COPY ./cgi-bin/ /usr/local/apache2/cgi-bin/

RUN echo "[]" > /usr/local/apache2/cgi-bin/datos.json
RUN chmod -R 777 /usr/local/apache2/cgi-bin/
RUN chmod +x /usr/local/apache2/cgi-bin/api.pl
RUN chown -R www-data:www-data /usr/local/apache2/cgi-bin/
RUN cat /usr/local/apache2/conf/httpd.conf | grep -i cgi
EXPOSE 80