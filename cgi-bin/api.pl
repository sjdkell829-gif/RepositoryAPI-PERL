#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use JSON;

my $cgi = CGI->new;
my $archivo = '/usr/lib/cgi-bin/datos.json';

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

# FUNCIÓN DE LÓGICA: Clasifica según la edad
sub clasificar_rango {
    my ($edad) = @_;
    if ($edad < 0) { return "Invalido"; }
    if ($edad < 18) { return "Joven"; }
    if ($edad < 100) { return "Adulto"; }
    return "Legendario (No Humano)";
}

my $db = leer_db();
my $metodo = $cgi->request_method();

if ($metodo eq 'GET') {
    my $id = $cgi->param('id');
    if ($id) {
        my ($p) = grep { $_->{id} == $id } @{$db->{data}};
        print encode_json($p || { error => "No existe" });
    } else {
        print encode_json($db);
    }
} 
elsif ($metodo eq 'POST') {
    my $nuevo = decode_json($cgi->param('POSTDATA'));
    
    # Validar edad máxima
    if ($nuevo->{edad} > 150) {
        print encode_json({ error => "Edad fuera de rango humano" });
        exit;
    }

    # Asignar Rango y ID
    $nuevo->{rango} = clasificar_rango($nuevo->{edad});
    my $max_id = 0;
    foreach my $p (@{$db->{data}}) { $max_id = $p->{id} if $p->{id} > $max_id; }
    $nuevo->{id} = $max_id + 1;
    
    push @{$db->{data}}, $nuevo;
    guardar_db($db);
    print encode_json({ status => "Creado", id => $nuevo->{id}, rango => $nuevo->{rango} });
} 
elsif ($metodo eq 'PATCH') {
    my $update = decode_json($cgi->param('POSTDATA'));
    my $hecho = 0;
    foreach my $p (@{$db->{data}}) {
        if ($p->{id} == $update->{id}) {
            $p->{nombre} = $update->{nombre} if $update->{nombre};
            $p->{universo} = $update->{universo} if $update->{universo};
            $p->{nivel_poder} = $update->{nivel_poder} if $update->{nivel_poder};
            if ($update->{edad}) {
                $p->{edad} = $update->{edad};
                $p->{rango} = clasificar_rango($update->{edad});
            }
            $hecho = 1; last;
        }
    }
    guardar_db($db) if $hecho;
    print encode_json({ status => $hecho ? "Ok" : "No encontrado" });
} 
elsif ($metodo eq 'DELETE') {
    my $id = $cgi->param('id');
    my @lista = grep { $_->{id} != $id } @{$db->{data}};
    $db->{data} = \@lista;
    guardar_db($db);
    print encode_json({ status => "Eliminado" });
}