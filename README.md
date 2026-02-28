# RepositoryAPI-PERL
Anime Power Levels API - Full Stack Deployment
Descripción del Proyecto
Este proyecto consiste en el desarrollo y despliegue de una aplicación web diseñada para la gestión de estadísticas y niveles de poder de personajes de anime. La solución integra un frontend dinámico con un backend robusto basado en scripts CGI de Perl, todo contenido dentro de un entorno virtualizado con Docker para garantizar su portabilidad y escalabilidad.

Enlace del Proyecto
El sistema se encuentra desplegado y operativo en la siguiente dirección:
URL: https://repositoryapi-perl.onrender.com

Arquitectura del Sistema
La aplicación sigue una arquitectura de tres capas dentro de un contenedor:

Capa de Presentación: Interfaz desarrollada en HTML5 y JavaScript que consume la API mediante peticiones asíncronas (Fetch API).

Capa de Lógica (Backend): Scripts en lenguaje Perl ejecutados bajo el servidor Apache (módulo cgid) que procesan las operaciones de lectura y escritura.

Capa de Datos: Almacenamiento basado en archivos con formato JSON (datos.json) que actúa como base de datos persistente durante la ejecución del contenedor.

Stack Tecnológico
Contenedores: Docker (Imagen base Debian Bullseye).

Servidor Web: Apache 2.4 con configuración de directorios CGI.

Lenguaje de Backend: Perl 5 (Módulos: CGI, JSON).

Frontend: JavaScript ES6+, CSS3 y HTML5.

Configuración y Despliegue Local
Para replicar este entorno de desarrollo de manera local, siga las instrucciones a continuación:

Requisitos previos
Docker Desktop instalado y en ejecución.

Git para la clonación del repositorio.

Instrucciones de ejecución
Clonación del repositorio:

Bash
git clone https://github.com/tu-usuario/RepositoryAPI-PERL.git
cd RepositoryAPI-PERL
Construcción de la imagen Docker:

Bash
docker build -t anime-api-perl .
Lanzamiento del contenedor:

Bash
docker run -p 8080:80 anime-api-perl
Acceso: El servicio estará disponible en http://localhost:8080.

Notas sobre el Despliegue en Render
Se debe tener en cuenta que el entorno de hosting utilizado (Render Free Tier) emplea un sistema de archivos efímero. Esto significa que los registros de personajes nuevos realizados a través de la interfaz se mantendrán activos mientras el contenedor esté en ejecución, pero se restablecerán a los valores por defecto (como Saitama o Goku) en caso de reinicio o suspensión del servicio.

Información del Autor
Desarrollador: Erick.
