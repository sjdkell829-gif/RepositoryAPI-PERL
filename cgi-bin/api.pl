#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use JSON;
use File::Slurp;

my $cgi = CGI->new;
my $metodo = $cgi->request_method();
my $token_cliente = $cgi->http('X-Auth-Token') || "";
my $token_maestro = "admin123";
my $ruta_db = "datos.json";

print $cgi->header(
    -type => 'application/json',
    -access_control_allow_origin => '*',
    -access_control_allow_methods => 'GET, POST, PUT, DELETE, OPTIONS',
    -access_control_allow_headers => 'Content-Type, X-Auth-Token'
);

exit if $metodo eq 'OPTIONS';

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
    return "Legendario" if $edad >= 100;
    return "Adulto"     if $edad >= 18;
    return "Joven";
}

my $path_info = $cgi->path_info();
if ($path_info eq '/health') {
    print encode_json({ status => "UP", db_writable => (-w $ruta_db ? "Si" : "No") });
    exit;
}

if ($metodo ne 'GET' && $token_cliente ne $token_maestro) {
    print encode_json({ error => "Acceso denegado. Token invalido." });
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
    my $nuevo = decode_json($cgi->param('POSTDATA'));
    $nuevo->{id} = (scalar @$personajes > 0) ? $personajes->[-1]->{id} + 1 : 1;
    $nuevo->{rango} = clasificar_rango($nuevo->{edad});
    push @$personajes, $nuevo;
    guardar_db($personajes);
    print encode_json({ status => "Creado", id => $nuevo->{id} });
}
elsif ($metodo eq 'PUT') {
    my $editado = decode_json($cgi->param('POSTDATA'));
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
        print encode_json({ status => "Actualizado", id => $editado->{id} });
    } else {
        print encode_json({ error => "ID no encontrado" });
    }
}
elsif ($metodo eq 'DELETE') {
    my $id_borrar = $cgi->param('id');
    my @filtrados = grep { $_->{id} != $id_borrar } @$personajes;
    guardar_db(\@filtrados);
    print encode_json({ status => "Eliminado", id => $id_borrar });
}