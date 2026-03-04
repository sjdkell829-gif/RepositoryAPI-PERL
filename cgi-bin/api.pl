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

# Captura de token (compatible con Render y Swagger)
my $token_cliente = $cgi->http('HTTP_X_AUTH_TOKEN') || $cgi->http('X-Auth-Token') || "";

# Encabezado JSON obligatorio para que Swagger no falle
print $cgi->header(
    -type => 'application/json',
    -charset => 'utf-8',
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
    write_file($ruta_db, {binmode => ':utf8'}, encode_json($data));
}

sub clasificar_rango {
    my $edad = shift || 0;
    return $edad >= 100 ? "Legendario" : ($edad >= 18 ? "Adulto" : "Joven");
}

my $personajes = leer_db();

# Seguridad: GET es público, lo demás requiere token
if ($metodo ne 'GET' && $token_cliente ne $token_maestro) {
    print encode_json({ error => "Acceso denegado. Token invalido.", recibido => $token_cliente });
    exit;
}

# --- ENDPOINTS (GET, POST, PUT, DELETE) ---

if ($metodo eq 'GET') {
    my $id_p = $cgi->param('id');
    my $uni_p = $cgi->param('universo');
    my $pow_p = $cgi->param('poder_min');

    my @res = @$personajes;

    # Filtrar por ID individual
    if ($id_p) {
        @res = grep { $_->{id} == $id_p } @res;
    }
    # Filtrar por Universo
    if ($uni_p) {
        @res = grep { lc($_->{universo}) eq lc($uni_p) } @res;
    }
    # Filtrar por Poder Mínimo
    if ($pow_p) {
        @res = grep { $_->{nivel_poder} >= $pow_p } @res;
    }

    # Si se buscó por ID y no hay nada, avisar
    if ($id_p && !@res) {
        print encode_json({ error => "Guerrero con ID $id_p no encontrado" });
    } else {
        print encode_json(\@res);
    }
}
elsif ($metodo eq 'POST') {
    my $json = decode_json($cgi->param('POSTDATA') || '{}');
    $json->{id} = (@$personajes > 0) ? $personajes->[-1]->{id} + 1 : 1;
    $json->{rango} = clasificar_rango($json->{edad});
    push @$personajes, $json;
    guardar_db($personajes);
    print encode_json({ status => "Creado con exito", id => $json->{id}, guerrero => $json });
}
elsif ($metodo eq 'PUT') {
    my $edit = decode_json($cgi->param('POSTDATA') || '{}');
    my $exito = 0;
    for (my $i = 0; $i < @$personajes; $i++) {
        if ($personajes->[$i]->{id} == $edit->{id}) {
            $edit->{rango} = clasificar_rango($edit->{edad});
            $personajes->[$i] = $edit;
            $exito = 1;
            last;
        }
    }
    if ($exito) {
        guardar_db($personajes);
        print encode_json({ status => "Actualizado correctamente", id => $edit->{id} });
    } else {
        print encode_json({ error => "No se pudo actualizar. ID no encontrado." });
    }
}
elsif ($metodo eq 'DELETE') {
    my $id_b = $cgi->param('id');
    my @filt = grep { $_->{id} != $id_b } @$personajes;
    if (scalar @filt == scalar @$personajes) {
        print encode_json({ error => "ID no encontrado para eliminar" });
    } else {
        guardar_db(\@filt);
        print encode_json({ status => "Guerrero eliminado satisfactoriamente", id => $id_b });
    }
}