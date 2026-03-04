#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use JSON;
use File::Slurp;

my $cgi = CGI->new;
my $metodo = $cgi->request_method();
my $ruta_db = "datos.json";
my $token_maestro = "admin123";
my $token_cliente = $cgi->http('HTTP_X_AUTH_TOKEN') || $cgi->http('X-Auth-Token') || "";

print $cgi->header(
    -type => 'application/json',
    -charset => 'utf-8',
    -access_control_allow_origin => '*',
    -access_control_allow_methods => 'GET, POST, PUT, DELETE, OPTIONS',
    -access_control_allow_headers => 'Content-Type, X-Auth-Token'
);

exit if $metodo eq 'OPTIONS';

# Leer Base de Datos
my $personajes = [];
if (-e $ruta_db) {
    my $contenido = read_file($ruta_db);
    $personajes = decode_json($contenido || '[]');
}

if ($metodo ne 'GET' && $token_cliente ne $token_maestro) {
    print encode_json({ error => "Token invalido" });
    exit;
}

if ($metodo eq 'GET') {
    my $id_p = $cgi->param('id');
    if ($id_p) {
        my ($p) = grep { $_->{id} == $id_p } @$personajes;
        print encode_json($p || { error => "No encontrado" });
    } else {
        print encode_json($personajes);
    }
}
elsif ($metodo eq 'POST') {
    # SOLUCIÓN AL ERROR DE GUARDADO:
    # Capturamos el JSON crudo del cuerpo de la petición
    my $json_raw = $cgi->param('POSTDATA') || $cgi->param('keywords') || "{}";
    
    my $nuevo;
    eval { $nuevo = decode_json($json_raw); };
    
    if ($@ || !$nuevo->{nombre}) {
        print encode_json({ error => "Datos invalidos o vacios", detalle => $@ });
        exit;
    }

    # Generar ID basado en el último elemento real
    my $ultimo_id = 0;
    if (scalar @$personajes > 0) {
        $ultimo_id = $personajes->[-1]->{id};
    }
    $nuevo->{id} = $ultimo_id + 1;

    # Clasificar Rango
    my $e = $nuevo->{edad} || 0;
    $nuevo->{rango} = $e >= 100 ? "Legendario" : ($e >= 18 ? "Adulto" : "Joven");

    push @$personajes, $nuevo;
    
    # Escribir físicamente en el archivo
    write_file($ruta_db, {binmode => ':utf8'}, encode_json($personajes));
    
    print encode_json({ status => "Creado", id => $nuevo->{id}, guerrero => $nuevo });
}
elsif ($metodo eq 'PUT') {
    my $json_raw = $cgi->param('POSTDATA') || "{}";
    my $edit = decode_json($json_raw);
    my $exito = 0;

    for (my $i = 0; $i < @$personajes; $i++) {
        if ($personajes->[$i]->{id} == $edit->{id}) {
            $edit->{rango} = ($edit->{edad} >= 100) ? "Legendario" : (($edit->{edad} >= 18) ? "Adulto" : "Joven");
            $personajes->[$i] = $edit;
            $exito = 1;
            last;
        }
    }
    if ($exito) {
        write_file($ruta_db, {binmode => ':utf8'}, encode_json($personajes));
        print encode_json({ status => "Actualizado" });
    } else {
        print encode_json({ error => "ID no encontrado" });
    }
}
elsif ($metodo eq 'DELETE') {
    my $id_b = $cgi->param('id');
    my @filt = grep { $_->{id} != $id_b } @$personajes;
    write_file($ruta_db, {binmode => ':utf8'}, encode_json(\@filt));
    print encode_json({ status => "Eliminado" });
}