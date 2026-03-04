FROM httpd:2.4

RUN apt-get update && apt-get install -y \
    perl \
    libjson-perl \
    libfile-slurp-perl \
    libcgi-pm-perl \
    cpanminus \
    && rm -rf /var/lib/apt/lists/*

RUN cpanm --notest JSON File::Slurp CGI

RUN sed -i \
    -e 's/#LoadModule cgid_module modules\/mod_cgid.so/LoadModule cgid_module modules\/mod_cgid.so/' \
    -e 's/#LoadModule cgi_module modules\/mod_cgi.so/LoadModule cgi_module modules\/mod_cgi.so/' \
    /usr/local/apache2/conf/httpd.conf

RUN printf '\nScriptAlias /cgi-bin/ /usr/local/apache2/cgi-bin/\n<Directory "/usr/local/apache2/cgi-bin">\n    AllowOverride None\n    Options +ExecCGI\n    AddHandler cgi-script .pl\n    Require all granted\n</Directory>\n' >> /usr/local/apache2/conf/httpd.conf

COPY ./index.html /usr/local/apache2/htdocs/
COPY ./swagger.html /usr/local/apache2/htdocs/
COPY ./cgi-bin/ /usr/local/apache2/cgi-bin/

RUN echo "[]" > /usr/local/apache2/cgi-bin/datos.json
RUN chmod -R 777 /usr/local/apache2/cgi-bin/
RUN chmod +x /usr/local/apache2/cgi-bin/api.pl
RUN chown -R www-data:www-data /usr/local/apache2/cgi-bin/

EXPOSE 80