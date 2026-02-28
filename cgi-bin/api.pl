#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use JSON;

my $cgi = CGI->new;
my $archivo = '/usr/lib/cgi-bin/datos.json';

print $cgi->header('application/json; charset=UTF-8');

# 1. Leer el archivo actual con precaución
my $contenido = "";
if (-e $archivo) {
    open my $fh, '<', $archivo;
    local $/; $contenido = <$fh>;
    close $fh;
}

# 2. Si está vacío o dañado, crear estructura base
my $datos;
if (!$contenido || $contenido eq "") {
    $datos = { status => "success", data => [] };
} else {
    eval { $datos = decode_json($contenido); };
    if ($@) { $datos = { status => "success", data => [] }; }
}

# 3. Lógica para GUARDAR (POST)
if ($cgi->request_method() eq 'POST') {
    my $json_texto = $cgi->param('POSTDATA');
    my $nuevo_pj;
    eval { $nuevo_pj = decode_json($json_texto); };
    
    if ($nuevo_pj) {
        push @{$datos->{data}}, $nuevo_pj;
        # Escribir en el archivo
        open my $fh_out, '>', $archivo or die "Error: $!";
        print $fh_out encode_json($datos);
        close $fh_out;
        print encode_json({status => "success", message => "Registrado"});
    }
} else {
    # 4. Lógica para MOSTRAR (GET)
    print encode_json($datos);
}