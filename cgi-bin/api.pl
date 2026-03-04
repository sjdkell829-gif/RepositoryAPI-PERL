#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use JSON;
use File::Slurp;

my $cgi = CGI->new;
my $metodo = $cgi->request_method();
my $ruta_db = "/usr/local/apache2/cgi-bin/datos.json";
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

# Seguridad para métodos que modifican datos
if ($metodo ne 'GET' && $token_cliente ne $token_maestro) {
    print encode_json({ error => "Token invalido" });
    exit;
}

# --- ENDPOINTS ---

if ($metodo eq 'GET') {
    my $id_p = $cgi->param('id');
    my @res = @$personajes;
    if ($id_p) { @res = grep { $_->{id} == $id_p } @res; }
    print encode_json(\@res);
}
elsif ($metodo eq 'POST') {
    my $json_raw = $cgi->param('POSTDATA') || "{}";
    my $nuevo = decode_json($json_raw);
    $nuevo->{id} = (@$personajes > 0) ? $personajes->[-1]->{id} + 1 : 1;
    my $edad = $nuevo->{edad} || 0;
    $nuevo->{rango} = $edad >= 100 ? "Legendario" : ($edad >= 18 ? "Adulto" : "Joven");
    push @$personajes, $nuevo;
    write_file($ruta_db, {binmode => ':utf8'}, encode_json($personajes));
    print encode_json({ status => "Creado", id => $nuevo->{id} });
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