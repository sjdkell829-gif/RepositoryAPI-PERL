#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use strict;
use warnings;
use CGI;
use JSON;
use File::Slurp;
use POSIX qw(strftime);

my $cgi    = CGI->new;
my $metodo = $cgi->request_method();

my $ruta_db       = "/usr/local/apache2/cgi-bin/datos.json";
my $token_maestro = "admin123";
my $token_cliente = $cgi->http('HTTP_X_AUTH_TOKEN')
                 || $cgi->http('X-Auth-Token')
                 || $ENV{HTTP_X_AUTH_TOKEN}
                 || $ENV{X_AUTH_TOKEN}
                 || "";
my $path_info = $ENV{PATH_INFO} || "";

print $cgi->header(
    -type                         => 'application/json',
    -charset                      => 'utf-8',
    -access_control_allow_origin  => '*',
    -access_control_allow_methods => 'GET, POST, PUT, DELETE, OPTIONS',
    -access_control_allow_headers => 'Content-Type, X-Auth-Token'
);

exit if $metodo eq 'OPTIONS';

# HEALTH CHECK
if ($path_info eq '/health' || $path_info eq '/health/') {
    my $db_writable = (-e $ruta_db && -w $ruta_db) ? JSON::true : JSON::false;
    my $db_exists   = (-e $ruta_db)                ? JSON::true : JSON::false;
    my $timestamp   = strftime("%Y-%m-%dT%H:%M:%SZ", gmtime());
    print encode_json({
        status      => "OK",
        servidor    => "Apache/Perl CGI",
        version     => "8.0.0",
        db_exists   => $db_exists,
        db_writable => $db_writable,
        timestamp   => $timestamp
    });
    exit;
}

# Cargar base de datos
my $personajes = [];
if (-e $ruta_db) {
    my $contenido = read_file($ruta_db);
    $personajes = decode_json($contenido || '[]');
}

# Seguridad
if ($metodo ne 'GET' && $token_cliente ne $token_maestro) {
    print encode_json({ error => "Token invalido o ausente" });
    exit;
}

# GET
if ($metodo eq 'GET') {
    my $id_p  = $cgi->param('id');
    my $uni_p = $cgi->param('universo');
    my $pow_p = $cgi->param('poder_min');

    my @res = @$personajes;
    if (defined $id_p  && $id_p  ne '') { @res = grep { $_->{id}          == $id_p  } @res; }
    if (defined $uni_p && $uni_p ne '') { @res = grep { lc($_->{universo}) eq lc($uni_p) } @res; }
    if (defined $pow_p && $pow_p ne '') { @res = grep { $_->{nivel_poder} >= $pow_p  } @res; }

    print encode_json(\@res);
}

# POST
elsif ($metodo eq 'POST') {
    my $json_raw = $cgi->param('POSTDATA') || "{}";
    my $nuevo;
    eval { $nuevo = decode_json($json_raw); };
    if ($@) { print encode_json({ error => "JSON invalido" }); exit; }

    if (!$nuevo->{nombre} || !defined $nuevo->{edad} || !defined $nuevo->{nivel_poder}) {
        print encode_json({ error => "Campos requeridos: nombre, edad, nivel_poder" }); exit;
    }
    if ($nuevo->{nivel_poder} < 0 || $nuevo->{nivel_poder} > 999) {
        print encode_json({ error => "nivel_poder debe estar entre 0 y 999" }); exit;
    }
    if ($nuevo->{edad} < 0 || $nuevo->{edad} > 999) {
        print encode_json({ error => "edad debe estar entre 0 y 999" }); exit;
    }

    my $max_id = 0;
    for my $p (@$personajes) {
        $max_id = $p->{id} if $p->{id} > $max_id;
    }
    $nuevo->{id} = $max_id + 1;

    my $edad = $nuevo->{edad};
    $nuevo->{rango} = $edad >= 100 ? "Legendario" : ($edad >= 18 ? "Adulto" : "Joven");

    push @$personajes, $nuevo;
    write_file($ruta_db, { binmode => ':utf8' }, encode_json($personajes));
    print encode_json({ status => "Creado", id => $nuevo->{id} });
}

# PUT
elsif ($metodo eq 'PUT') {
    my $json_raw = $cgi->param('POSTDATA') || "{}";
    my $edit;
    eval { $edit = decode_json($json_raw); };
    if ($@) { print encode_json({ error => "JSON invalido" }); exit; }

    if (!defined $edit->{id}) {
        print encode_json({ error => "El campo 'id' es requerido en el body" }); exit;
    }
    if (!$edit->{nombre} || !defined $edit->{edad} || !defined $edit->{nivel_poder}) {
        print encode_json({ error => "Campos requeridos: nombre, edad, nivel_poder" }); exit;
    }
    if ($edit->{nivel_poder} < 0 || $edit->{nivel_poder} > 999) {
        print encode_json({ error => "nivel_poder debe estar entre 0 y 999" }); exit;
    }
    if ($edit->{edad} < 0 || $edit->{edad} > 999) {
        print encode_json({ error => "edad debe estar entre 0 y 999" }); exit;
    }

    my $exito = 0;
    for (my $i = 0; $i < @$personajes; $i++) {
        if ($personajes->[$i]->{id} == $edit->{id}) {
            $edit->{rango} = ($edit->{edad} >= 100) ? "Legendario"
                           : ($edit->{edad} >= 18)  ? "Adulto"
                           :                          "Joven";
            $personajes->[$i] = $edit;
            $exito = 1;
            last;
        }
    }

    if ($exito) {
        write_file($ruta_db, { binmode => ':utf8' }, encode_json($personajes));
        print encode_json({ status => "Actualizado" });
    } else {
        print encode_json({ error => "ID no encontrado" });
    }
}

# DELETE
elsif ($metodo eq 'DELETE') {
    my $id_b = $cgi->param('id');

    if (!defined $id_b || $id_b eq '') {
        print encode_json({ error => "El parametro 'id' es requerido" }); exit;
    }

    my $existe = grep { $_->{id} == $id_b } @$personajes;
    if (!$existe) {
        print encode_json({ error => "ID no encontrado" }); exit;
    }

    my @filt = grep { $_->{id} != $id_b } @$personajes;
    write_file($ruta_db, { binmode => ':utf8' }, encode_json(\@filt));
    print encode_json({ status => "Eliminado", id => $id_b + 0 });
}

else {
    print encode_json({ error => "Metodo no soportado" });
}