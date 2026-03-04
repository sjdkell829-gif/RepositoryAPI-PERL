FROM httpd:2.4

RUN apt-get update && apt-get install -y \
    perl \
    libjson-perl \
    libfile-slurp-perl \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/#LoadModule cgi_module modules\/mod_cgi.so/LoadModule cgi_module modules\/mod_cgi.so/' /usr/local/apache2/conf/httpd.conf

RUN echo 'ScriptAlias /cgi-bin/ /usr/local/apache2/cgi-bin/' >> /usr/local/apache2/conf/httpd.conf
RUN echo '<Directory "/usr/local/apache2/cgi-bin">' >> /usr/local/apache2/conf/httpd.conf
RUN echo '    AllowOverride None' >> /usr/local/apache2/conf/httpd.conf
RUN echo '    Options +ExecCGI' >> /usr/local/apache2/conf/httpd.conf
RUN echo '    AddHandler cgi-script .pl' >> /usr/local/apache2/conf/httpd.conf
RUN echo '    Require all granted' >> /usr/local/apache2/conf/httpd.conf
RUN echo '</Directory>' >> /usr/local/apache2/conf/httpd.conf
RUN echo 'SetEnvIf Request_URI "." HTTP_X_AUTH_TOKEN=%{HTTP:X-Auth-Token}e' >> /usr/local/apache2/conf/httpd.conf

COPY ./index.html /usr/local/apache2/htdocs/
COPY ./swagger.html /usr/local/apache2/htdocs/
COPY ./cgi-bin/ /usr/local/apache2/cgi-bin/

RUN echo "[]" > /usr/local/apache2/cgi-bin/datos.json
RUN chmod -R 777 /usr/local/apache2/cgi-bin/
RUN chmod +x /usr/local/apache2/cgi-bin/api.pl
RUN chown -R www-data:www-data /usr/local/apache2/cgi-bin/

EXPOSE 80