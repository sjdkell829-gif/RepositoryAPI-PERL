#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use JSON;

my $cgi = CGI->new;
my $archivo = '/usr/lib/cgi-bin/datos.json';

# Cabecera para que el navegador sepa que enviamos JSON
print $cgi->header('application/json; charset=UTF-8');

if ($cgi->request_method() eq 'POST') {
    my $json_texto = $cgi->param('POSTDATA');
    my $nuevo_pj = decode_json($json_texto);
    
    # 1. Leer datos con precaución
    open my $fh, '<', $archivo or die "Error al abrir: $!";
    my $contenido = do { local $/; <$fh> };
    close $fh;
    
    my $datos = decode_json($contenido);
    
    # 2. Asegurarnos de que existe la lista 'data' antes de agregar
    if (!exists $datos->{data}) {
        $datos->{data} = [];
    }
    
    push @{$datos->{data}}, $nuevo_pj;
    
    # 3. Guardar de forma segura
    open my $fh_out, '>', $archivo or die "Error al escribir: $!";
    print $fh_out encode_json($datos);
    close $fh_out;
    
    print encode_json({status => "success", message => "Registrado"});
} else {
    # Si es GET, simplemente mostramos el archivo
    open my $fh, '<', $archivo or die "No se pudo leer: $!";
    my $contenido = do { local $/; <$fh> };
    close $fh;
    print $contenido;
}