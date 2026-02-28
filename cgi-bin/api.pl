#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use JSON;

my $cgi = CGI->new;
# Ruta absoluta para que Docker y Render no se pierdan
my $archivo = '/usr/lib/cgi-bin/datos.json';

print $cgi->header('application/json; charset=UTF-8');

if ($cgi->request_method() eq 'POST') {
    my $json_texto = $cgi->param('POSTDATA');
    my $nuevo_pj = decode_json($json_texto);
    
    # Leer datos actuales
    my $contenido = do {
        open my $fh, '<', $archivo or die "Error al abrir: $!";
        local $/; <$fh>
    };
    
    my $datos = decode_json($contenido);
    # Agregar el nuevo personaje (como Shadow o Saitama)
    push @{$datos->{data}}, $nuevo_pj;
    
    # Guardar cambios
    open my $fh_out, '>', $archivo or die "Error al escribir: $!";
    print $fh_out encode_json($datos);
    close $fh_out;
    
    print encode_json({status => "success", message => "Registrado correctamente"});
} else {
    # Método GET: Solo mostrar los personajes
    open my $fh, '<', $archivo or die "Error al leer: $!";
    my $contenido = do { local $/; <$fh> };
    close $fh;
    print $contenido;
}