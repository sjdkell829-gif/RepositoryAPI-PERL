Documentacion Tecnica: Anime Power - Sistema Admin Z
Enlaces del Proyecto
Interfaz de Usuario: https://anime-power-api.onrender.com/index.html

Documentacion Interactiva (Swagger): https://anime-power-api.onrender.com/swagger.html

Descripcion del Proyecto
Este sistema consiste en una API RESTful desarrollada en lenguaje Perl para la gestion de personajes de anime. El proyecto permite realizar operaciones CRUD completas y almacena la informacion en un archivo con formato JSON, garantizando la persistencia de los datos en el servidor sin necesidad de bases de datos externas.

Funcionalidades del Sistema
Metodos HTTP Soportados: Implementacion de los verbos GET, POST, PUT y DELETE.

Clasificacion Automatica: Asignacion de rango (Joven, Adulto, Legendario) basada en la edad procesada en el servidor.

Control de Integridad: Validacion de longitud de datos para campos numericos con un limite de 3 cifras (0-999).

Health Check: Endpoint dedicado para monitorear el estado operativo del servidor y los permisos de escritura del sistema.

Persistencia JSON: Almacenamiento directo en servidor que permite mantener los datos tras reinicios del servicio.

Estructura de Archivos
index.html: Panel de control y gestion visual para el usuario final.

swagger.html: Especificacion OpenAPI y herramientas de prueba para desarrolladores.

cgi-bin/api.pl: Script de servidor encargado del procesamiento de peticiones y logica de negocio.

cgi-bin/datos.json: Archivo de almacenamiento persistente.

Autenticacion y Seguridad
Las operaciones que modifican la integridad de los datos (POST, PUT y DELETE) requieren la validacion de una cabecera de seguridad obligatoria:

Cabecera: X-Auth-Token

Valor: admin123

Especificacion de Endpoints
Metodo GET (Listado General)
Ruta: /cgi-bin/api.pl

Descripcion: Recupera la coleccion completa de guerreros almacenados.

Metodo GET (Consulta Individual)
Ruta: /cgi-bin/api.pl?id={valor}

Descripcion: Recupera la informacion de un unico registro filtrado por su ID.

Metodo GET (Salud del Sistema)
Ruta: /cgi-bin/api.pl/health

Descripcion: Informa el estado del servidor y si el archivo JSON tiene permisos de escritura.

Metodo POST (Registro)
Ruta: /cgi-bin/api.pl

Descripcion: Registra un nuevo guerrero. Requiere cuerpo JSON y token de seguridad.

Metodo PUT (Actualizacion)
Ruta: /cgi-bin/api.pl

Descripcion: Reemplaza un registro existente de forma total. Requiere ID dentro del JSON y token de seguridad.

Metodo DELETE (Eliminacion)
Ruta: /cgi-bin/api.pl?id={valor}

Descripcion: Remueve permanentemente un registro del sistema. Requiere token de seguridad.

Requisitos de Implementacion
El servidor debe contar con Perl 5 y soporte para Common Gateway Interface (CGI).

Es indispensable configurar permisos de escritura (chmod 777) para el archivo datos.json en el entorno de despliegue.

La configuracion de red debe permitir el paso de cabeceras personalizadas (Custom Headers).

Desarrollado por: Erick
