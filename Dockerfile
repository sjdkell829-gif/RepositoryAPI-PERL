# 1. Usamos la imagen oficial de Apache (servidor web)
FROM httpd:2.4

# 2. Instalamos Perl y las librerías necesarias para manejar JSON y archivos
# libjson-perl: para que Perl entienda el formato JSON
# libfile-slurp-perl: para leer y escribir archivos de forma rápida
RUN apt-get update && apt-get install -y \
    perl \
    libjson-perl \
    libfile-slurp-perl \
    && rm -rf /var/lib/apt/lists/*

# 3. Configuramos Apache para que permita ejecutar archivos .pl (CGI)
# Activamos el módulo CGI
RUN sed -i 's/#LoadModule cgi_module/LoadModule cgi_module/' /usr/local/apache2/conf/httpd.conf

# Le decimos que los archivos .pl se traten como scripts
RUN echo "AddHandler cgi-script .pl" >> /usr/local/apache2/conf/httpd.conf

# Damos permiso de ejecución (ExecCGI) en la carpeta de htdocs y cgi-bin
RUN sed -i 's/Options Indexes FollowSymLinks/Options Indexes FollowSymLinks ExecCGI/' /usr/local/apache2/conf/httpd.conf

# 4. Copiamos tus archivos al contenedor
# Los HTML van a la carpeta pública htdocs
COPY ./index.html /usr/local/apache2/htdocs/
COPY ./swagger.html /usr/local/apache2/htdocs/

# El script de Perl va a la carpeta especial cgi-bin
COPY ./cgi-bin/ /usr/local/apache2/cgi-bin/

# 5. Permisos de seguridad y escritura
# Hacemos que el script de Perl sea ejecutable
RUN chmod +x /usr/local/apache2/cgi-bin/api.pl

# Creamos el archivo de base de datos vacío y le damos permisos totales (777)
# Esto es vital para que el servidor pueda guardar los cambios del POST y PUT
RUN touch /usr/local/apache2/cgi-bin/datos.json && chmod 777 /usr/local/apache2/cgi-bin/datos.json

# 6. Exponemos el puerto 80 (estándar web)
EXPOSE 80