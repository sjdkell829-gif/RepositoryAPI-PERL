#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use JSON;

my $cgi = CGI->new;
my $archivo = '/usr/lib/cgi-bin/datos.json';

# Cabecera obligatoria para JSON
print $cgi->header('application/json; charset=UTF-8');

# 1. Función para leer o crear la base si no existe
sub leer_datos {
    if (!-e $archivo || -s $archivo == 0) {
        return { status => "success", data => [] };
    }
    open my $fh, '<', $archivo or return { status => "success", data => [] };
    my $contenido = do { local $/; <$fh> };
    close $fh;
    eval { return decode_json($contenido); } || return { status => "success", data => [] };
}

my $datos = leer_datos();

# 2. Lógica para REGISTRAR (POST)
if ($cgi->request_method() eq 'POST') {
    my $json_texto = $cgi->param('POSTDATA');
    my $nuevo_pj = decode_json($json_texto);
    
    push @{$datos->{data}}, $nuevo_pj;
    
    open my $fh_out, '>', $archivo or die "Error: $!";
    print $fh_out encode_json($datos);
    close $fh_out;
    
    print encode_json({status => "success", message => "Registrado"});
} else {
    # 3. Lógica para MOSTRAR (GET)
    print encode_json($datos);
}