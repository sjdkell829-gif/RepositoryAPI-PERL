#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use JSON;

my $cgi = CGI->new;
my $archivo = '/usr/lib/cgi-bin/datos.json';
my $PASSWORD_MAESTRA = "admin123";

print $cgi->header('application/json; charset=UTF-8');

sub leer_db {
    if (!-e $archivo) { return { data => [] }; }
    open my $fh, '<', $archivo or return { data => [] };
    my $content = do { local $/; <$fh> };
    close $fh;
    return $content ? decode_json($content) : { data => [] };
}

sub guardar_db {
    my ($datos) = @_;
    open my $fh, '>', $archivo;
    print $fh encode_json($datos);
    close $fh;
}

sub clasificar_rango {
    my ($edad) = @_;
    return $edad < 18 ? "Joven" : $edad < 100 ? "Adulto" : "Legendario (No Humano)";
}

my $db = leer_db();
my $metodo = $cgi->request_method();

# --- SEGURIDAD ---
if ($metodo ne 'GET') {
    my $auth = $cgi->http('HTTP_X_AUTH_TOKEN') || ""; 
    if ($auth ne $PASSWORD_MAESTRA) {
        print encode_json({ error => "Acceso denegado. Contraseña incorrecta." });
        exit;
    }
}

# --- RUTAS ---
if ($metodo eq 'GET') {
    my $id_buscado = $cgi->param('id');
    if ($id_buscado) {
        # GET Individual: Busca solo uno
        my ($encontrado) = grep { $_->{id} == $id_buscado } @{$db->{data}};
        print encode_json($encontrado || { error => "Guerrero no encontrado" });
    } else {
        # GET General: Muestra todos
        print encode_json($db);
    }
} 
elsif ($metodo eq 'POST') {
    my $nuevo = decode_json($cgi->param('POSTDATA'));
    
    # Validaciones de 3 cifras y existencia de edad
    if (!$nuevo->{edad} || $nuevo->{edad} > 999 || ($nuevo->{nivel_poder} && $nuevo->{nivel_poder} > 999)) {
        print encode_json({ error => "Datos inválidos (Máximo 3 cifras)" });
        exit;
    }

    $nuevo->{rango} = clasificar_rango($nuevo->{edad});
    my $max_id = 0;
    foreach my $p (@{$db->{data}}) { $max_id = $p->{id} if $p->{id} > $max_id; }
    $nuevo->{id} = $max_id + 1;
    
    push @{$db->{data}}, $nuevo;
    guardar_db($db);
    print encode_json({ status => "Creado", id => $nuevo->{id} });
}
# (PATCH y DELETE se mantienen igual con la validación de X-Auth-Token)
elsif ($metodo eq 'PATCH') {
    my $update = decode_json($cgi->param('POSTDATA'));
    foreach my $p (@{$db->{data}}) {
        if ($p->{id} == $update->{id}) {
            $p->{nombre} = $update->{nombre} if $update->{nombre};
            if ($update->{edad}) {
                $p->{edad} = $update->{edad};
                $p->{rango} = clasificar_rango($update->{edad});
            }
            $p->{nivel_poder} = $update->{nivel_poder} if $update->{nivel_poder};
            last;
        }
    }
    guardar_db($db);
    print encode_json({ status => "Ok" });
}
elsif ($metodo eq 'DELETE') {
    my $id = $cgi->param('id');
    my @lista = grep { $_->{id} != $id } @{$db->{data}};
    $db->{data} = \@lista;
    guardar_db($db);
    print encode_json({ status => "Eliminado" });
}