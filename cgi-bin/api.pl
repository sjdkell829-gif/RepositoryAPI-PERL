#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use JSON;
use File::Slurp;

my $cgi = CGI->new;
my $metodo = $cgi->request_method();

# RUTA ABSOLUTA PARA RENDER
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

# Leer base de datos
my $personajes = [];
if (-e $ruta_db) {
    my $contenido = read_file($ruta_db);
    $personajes = decode_json($contenido || '[]');
}

# --- ENDPOINTS ---

if ($metodo eq 'GET') {
    # Parámetros de búsqueda: ?id=1 o ?universo=Dragon Ball
    my $id_p = $cgi->param('id');
    my $uni_p = $cgi->param('universo');

    my @res = @$personajes;
    if ($id_p) { @res = grep { $_->{id} == $id_p } @res; }
    if ($uni_p) { @res = grep { lc($_->{universo}) eq lc($uni_p) } @res; }

    print encode_json(\@res);
}
elsif ($metodo eq 'POST') {
    if ($token_cliente ne $token_maestro) { print encode_json({error=>"Token invalido"}); exit; }
    
    my $json_raw = $cgi->param('POSTDATA') || "{}";
    my $nuevo = decode_json($json_raw);
    
    # Auto-generar ID
    $nuevo->{id} = (@$personajes > 0) ? $personajes->[-1]->{id} + 1 : 1;
    
    push @$personajes, $nuevo;
    write_file($ruta_db, {binmode => ':utf8'}, encode_json($personajes));
    print encode_json({ status => "Guardado", id => $nuevo->{id} });
}
elsif ($metodo eq 'PUT') {
    if ($token_cliente ne $token_maestro) { print encode_json({error=>"Token invalido"}); exit; }
    
    my $json_raw = $cgi->param('POSTDATA') || "{}";
    my $edit = decode_json($json_raw);
    my $exito = 0;

    for (my $i = 0; $i < @$personajes; $i++) {
        if ($personajes->[$i]->{id} == $edit->{id}) {
            $personajes->[$i] = $edit;
            $exito = 1; last;
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
    if ($token_cliente ne $token_maestro) { print encode_json({error=>"Token invalido"}); exit; }
    
    my $id_b = $cgi->param('id');
    my @filt = grep { $_->{id} != $id_b } @$personajes;
    write_file($ruta_db, {binmode => ':utf8'}, encode_json(\@filt));
    print encode_json({ status => "Eliminado" });
}