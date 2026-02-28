# RepositoryAPI-PERL
Anime Power Levels API - Full Stack Docker Project
Este es un proyecto académico desarrollado en febrero de 2026 que consiste en una aplicación web integral para la gestión y visualización de niveles de poder de personajes de anime. La arquitectura se basa en un backend programado en Perl, ejecutado sobre un servidor Apache dentro de un contenedor Docker, y desplegado en la plataforma Render.

Características Principales
Interfaz de Usuario: Galería dinámica que presenta tarjetas de personajes como Saitama, Goku o Shadow.

Módulo de Registro: Formulario funcional que permite la inserción de nuevos registros a la base de datos.

Backend en Perl (CGI): Lógica de servidor encargada del procesamiento de peticiones GET y POST.

Persistencia de Datos: Almacenamiento estructurado en un archivo de formato JSON (datos.json).

Entorno Contenedorizado: Configuración de infraestructura mediante un Dockerfile basado en la distribución Debian.

Stack Tecnológico
Frontend: Tecnologías estándar HTML5, CSS3 y JavaScript utilizando la Fetch API.

Backend: Lenguaje Perl 5 con implementación de los módulos CGI y JSON.

Servidor: Apache2 con el módulo de ejecución cgid debidamente configurado.

Infraestructura: Docker para la portabilidad y Render para el hosting en la nube.

Instalación y Despliegue Local
Para ejecutar este proyecto en un entorno local con Docker, siga estos pasos:

Clonación del Repositorio:

Bash
git clone https://github.com/tu-usuario/RepositoryAPI-PERL.git
cd RepositoryAPI-PERL
Construcción de la Imagen:

Bash
docker build -t anime-power-api .
Ejecución del Contenedor:

Bash
docker run -p 8080:80 anime-power-api
Acceso al Servicio: El sistema estará disponible en la dirección http://localhost:8080.

Información sobre el Despliegue
El proyecto se encuentra disponible para pruebas en la siguiente dirección de Render:
[https://repositoryapi-perl.onrender.com]

Nota Técnica sobre Persistencia: Debido a las políticas del plan gratuito de Render, el sistema de archivos es efímero. Los registros realizados durante la ejecución se mantienen mientras el contenedor permanezca activo, pero se restaurarán al estado inicial definido en el repositorio si el servicio entra en reposo o se reinicia.

Autoría
Erick - Estudiante de Ingeniería
