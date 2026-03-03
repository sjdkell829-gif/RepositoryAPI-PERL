#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use JSON;

my $cgi = CGI->new;
my $archivo = '/usr/lib/cgi-bin/datos.json';
my $PASSWORD_MAESTRA = "admin123"; # Esta es la contraseña para editar

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
    return $edad < 18 ? "Joven" : $edad < 100 ? "Adulto" : "Legendario";
}

my $db = leer_db();
my $metodo = $cgi->request_method();

# --- SEGURIDAD: Validar contraseña en métodos de escritura ---
if ($metodo ne 'GET') {
    my $auth = $cgi->http('HTTP_X_AUTH_TOKEN') || ""; 
    if ($auth ne $PASSWORD_MAESTRA) {
        print encode_json({ error => "No tienes permiso (Login requerido)" });
        exit;
    }
}

if ($metodo eq 'GET') {
    print encode_json($db);
} 
elsif ($metodo eq 'POST') {
    my $nuevo = decode_json($cgi->param('POSTDATA'));
    
    # VALIDACIÓN DE 3 CIFRAS
    if ($nuevo->{edad} > 999 || $nuevo->{nivel_poder} > 999) {
        print encode_json({ error => "Error: No se permiten valores de más de 3 cifras" });
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
elsif ($metodo eq 'PATCH') {
    my $update = decode_json($cgi->param('POSTDATA'));
    foreach my $p (@{$db->{data}}) {
        if ($p->{id} == $update->{id}) {
            $p->{nombre} = $update->{nombre} if $update->{nombre};
            if ($update->{edad}) {
                if($update->{edad} > 999) { print encode_json({error=>"Max 3 cifras"}); exit; }
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