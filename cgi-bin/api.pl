#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use JSON;
use File::Slurp;

# 1. Configuración inicial
my $cgi = CGI->new;
my $metodo = $cgi->request_method();

# RUTA ABSOLUTA: Clave para que Render no falle al escribir
my $ruta_db = "/usr/local/apache2/cgi-bin/datos.json";
my $token_maestro = "admin123";
my $token_cliente = $cgi->http('HTTP_X_AUTH_TOKEN') || $cgi->http('X-Auth-Token') || "";

# 2. Encabezados para el navegador y Swagger
print $cgi->header(
    -type => 'application/json',
    -charset => 'utf-8',
    -access_control_allow_origin => '*',
    -access_control_allow_methods => 'GET, POST, PUT, DELETE, OPTIONS',
    -access_control_allow_headers => 'Content-Type, X-Auth-Token'
);

# Salir si es una consulta de pre-vuelo (CORS)
exit if $metodo eq 'OPTIONS';

# 3. Leer los datos actuales del archivo JSON
my $personajes = [];
if (-e $ruta_db) {
    my $contenido = read_file($ruta_db);
    $personajes = decode_json($contenido || '[]');
}

# --- ENDPOINTS (Lógica de la API) ---

if ($metodo eq 'GET') {
    # PARÁMETROS: Capturamos id o universo de la URL
    my $id_p = $cgi->param('id');
    my $uni_p = $cgi->param('universo');

    my @res = @$personajes;

    # Filtrar si se envió un parámetro
    if ($id_p) { @res = grep { $_->{id} == $id_p } @res; }
    if ($uni_p) { @res = grep { lc($_->{universo}) eq lc($uni_p) } @res; }

    print encode_json(\@res);
}
elsif ($metodo eq 'POST') {
    # Seguridad
    if ($token_cliente ne $token_maestro) { 
        print encode_json({ error => "Token invalido" }); 
        exit; 
    }

    # Leer el JSON enviado desde el index
    my $json_raw = $cgi->param('POSTDATA') || "{}";
    my $nuevo = decode_json($json_raw);
    
    # Generar el siguiente ID automáticamente
    $nuevo->{id} = (@$personajes > 0) ? $personajes->[-1]->{id} + 1 : 1;
    
    # Agregar a la lista y guardar en el archivo
    push @$personajes, $nuevo;
    write_file($ruta_db, {binmode => ':utf8'}, encode_json($personajes));
    
    print encode_json({ status => "Guardado con exito", id => $nuevo->{id} });
}
elsif ($metodo eq 'PUT') {
    if ($token_cliente ne $token_maestro) { print encode_json({error=>"Token invalido"}); exit; }
    
    my $json_raw = $cgi->param('POSTDATA') || "{}";
    my $edit = decode_json($json_raw);
    my $exito = 0;

    for (my $i = 0; $i < @$personajes; $i++) {
        if ($personajes->[$i]->{id} == $edit->{id}) {
            $personajes->[$i] = $edit; # Reemplazar datos
            $exito = 1; 
            last;
        }
    }

    if ($exito) {
        write_file($ruta_db, {binmode => ':utf8'}, encode_json($personajes));
        print encode_json({ status => "Actualizado" });
    } else {
        print encode_json({ error => "No se encontro el ID" });
    }
}
elsif ($metodo eq 'DELETE') {
    if ($token_cliente ne $token_maestro) { print encode_json({error=>"Token invalido"}); exit; }
    
    my $id_b = $cgi->param('id');
    # Filtrar la lista para quitar el ID seleccionado
    my @nueva_lista = grep { $_->{id} != $id_b } @$personajes;
    
    write_file($ruta_db, {binmode => ':utf8'}, encode_json(\@nueva_lista));
    print encode_json({ status => "Eliminado correctamente" });
}