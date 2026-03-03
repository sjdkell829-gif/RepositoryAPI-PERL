#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use JSON;
use File::Slurp;

my $cgi = CGI->new;
my $metodo = $cgi->request_method();

# AJUSTE CRÍTICO: Se usa HTTP_X_AUTH_TOKEN para máxima compatibilidad en Render/Linux
my $token_cliente = $cgi->http('HTTP_X_AUTH_TOKEN') || $cgi->http('X-Auth-Token') || "";
my $token_maestro = "admin123";
my $ruta_db = "datos.json";

# Encabezados CORS y JSON
print $cgi->header(
    -type => 'application/json',
    -access_control_allow_origin => '*',
    -access_control_allow_methods => 'GET, POST, PUT, DELETE, OPTIONS',
    -access_control_allow_headers => 'Content-Type, X-Auth-Token'
);

if ($metodo eq 'OPTIONS') { exit; }

sub leer_db {
    if (-e $ruta_db) {
        my $contenido = read_file($ruta_db);
        return decode_json($contenido || '[]');
    }
    return [];
}

sub guardar_db {
    my ($data) = @_;
    write_file($ruta_db, encode_json($data));
}

sub clasificar_rango {
    my $edad = shift || 0;
    return $edad >= 100 ? "Legendario" : ($edad >= 18 ? "Adulto" : "Joven");
}

# Validación de Seguridad
if ($metodo ne 'GET' && $token_cliente ne $token_maestro) {
    print encode_json({ error => "Token invalido o ausente", recibido => $token_cliente });
    exit;
}

my $personajes = leer_db();

if ($metodo eq 'GET') {
    my $id_buscado = $cgi->param('id');
    if ($id_buscado) {
        my ($p) = grep { $_->{id} == $id_buscado } @$personajes;
        print encode_json($p || { error => "ID no encontrado" });
    } else {
        print encode_json($personajes);
    }
}
elsif ($metodo eq 'POST') {
    my $json_texto = $cgi->param('POSTDATA') || '{}';
    my $nuevo = decode_json($json_texto);
    $nuevo->{id} = (@$personajes > 0) ? $personajes->[-1]->{id} + 1 : 1;
    $nuevo->{rango} = clasificar_rango($nuevo->{edad});
    push @$personajes, $nuevo;
    guardar_db($personajes);
    print encode_json({ status => "Creado", id => $nuevo->{id} });
}
elsif ($metodo eq 'PUT') {
    my $json_texto = $cgi->param('POSTDATA') || '{}';
    my $editado = decode_json($json_texto);
    my $encontrado = 0;
    for (my $i = 0; $i < @$personajes; $i++) {
        if ($personajes->[$i]->{id} == $editado->{id}) {
            $editado->{rango} = clasificar_rango($editado->{edad});
            $personajes->[$i] = $editado;
            $encontrado = 1;
            last;
        }
    }
    if ($encontrado) {
        guardar_db($personajes);
        print encode_json({ status => "Actualizado" });
    } else {
        print encode_json({ error => "ID no encontrado" });
    }
}
elsif ($metodo eq 'DELETE') {
    my $id_borrar = $cgi->param('id');
    my @filtrados = grep { $_->{id} != $id_borrar } @$personajes;
    guardar_db(\@filtrados);
    print encode_json({ status => "Eliminado" });
}