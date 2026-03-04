FROM httpd:2.4

# Instalar Perl y librerías JSON
RUN apt-get update && apt-get install -y perl libjson-perl libfile-slurp-perl && rm -rf /var/lib/apt/lists/*

# Configurar Apache para que ejecute archivos .pl como CGI
RUN sed -i 's/#LoadModule cgi_module/LoadModule cgi_module/' /usr/local/apache2/conf/httpd.conf
RUN echo "AddHandler cgi-script .pl" >> /usr/local/apache2/conf/httpd.conf
RUN sed -i 's/Options Indexes FollowSymLinks/Options Indexes FollowSymLinks ExecCGI/' /usr/local/apache2/conf/httpd.conf

# COPIAR ARCHIVOS (Asegúrate de que estén en la raíz de tu GitHub)
COPY ./index.html /usr/local/apache2/htdocs/
COPY ./swagger.html /usr/local/apache2/htdocs/
COPY ./cgi-bin/ /usr/local/apache2/cgi-bin/

# PERMISOS DE ESCRITURA (Para que el botón Guardar funcione)
RUN echo "[]" > /usr/local/apache2/cgi-bin/datos.json
RUN chmod -R 777 /usr/local/apache2/cgi-bin/
RUN chown -R www-data:www-data /usr/local/apache2/cgi-bin/

EXPOSE 80