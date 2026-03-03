#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use JSON;

my $cgi = CGI->new;
my $archivo = '/usr/lib/cgi-bin/datos.json';

print $cgi->header('application/json; charset=UTF-8');

# Función para leer el archivo JSON
sub leer_db {
    if (!-e $archivo) { return { data => [] }; }
    open my $fh, '<', $archivo or return { data => [] };
    my $content = do { local $/; <$fh> };
    close $fh;
    return $content ? decode_json($content) : { data => [] };
}

# Función para guardar el archivo JSON
sub guardar_db {
    my ($datos) = @_;
    open my $fh, '>', $archivo or die "Error al guardar: $!";
    print $fh encode_json($datos);
    close $fh;
}

my $db = leer_db();
my $metodo = $cgi->request_method();

# --- LÓGICA DE RUTAS ---

if ($metodo eq 'GET') {
    my $id_buscado = $cgi->param('id');
    if ($id_buscado) {
        # Buscar un personaje específico por ID
        my ($encontrado) = grep { $_->{id} == $id_buscado } @{$db->{data}};
        print encode_json($encontrado || { error => "No encontrado" });
    } else {
        # Listar todos
        print encode_json($db);
    }
} 
elsif ($metodo eq 'POST') {
    my $raw = $cgi->param('POSTDATA');
    my $nuevo = decode_json($raw);
    
    # GENERAR ID AUTOMÁTICO (Busca el ID más alto y suma 1)
    my $max_id = 0;
    foreach my $p (@{$db->{data}}) {
        $max_id = $p->{id} if $p->{id} > $max_id;
    }
    $nuevo->{id} = $max_id + 1;
    
    push @{$db->{data}}, $nuevo;
    guardar_db($db);
    print encode_json({ status => "Creado", id => $nuevo->{id} });
} 
elsif ($metodo eq 'PATCH') {
    my $raw = $cgi->param('POSTDATA');
    my $update = decode_json($raw);
    my $hecho = 0;
    
    foreach my $p (@{$db->{data}}) {
        if ($p->{id} == $update->{id}) {
            $p->{nombre} = $update->{nombre} if $update->{nombre};
            $p->{universo} = $update->{universo} if $update->{universo};
            $p->{nivel_poder} = $update->{nivel_poder} if $update->{nivel_poder};
            $hecho = 1;
            last;
        }
    }
    guardar_db($db) if $hecho;
    print encode_json({ status => $hecho ? "Actualizado" : "No encontrado" });
} 
elsif ($metodo eq 'DELETE') {
    my $id_borrar = $cgi->param('id');
    my @nueva_lista = grep { $_->{id} != $id_borrar } @{$db->{data}};
    
    if (scalar @nueva_lista != scalar @{$db->{data}}) {
        $db->{data} = \@nueva_lista;
        guardar_db($db);
        print encode_json({ status => "Eliminado" });
    } else {
        print encode_json({ status => "ID no existe" });
    }
}