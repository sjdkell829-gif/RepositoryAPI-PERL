#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use JSON;

my $cgi = CGI->new;
my $archivo = '/usr/lib/cgi-bin/datos.json';

print $cgi->header('application/json; charset=UTF-8');

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
my $metodo = $cgi->request_method();

# --- LÓGICA CRUD ---

if ($metodo eq 'DELETE') {
    my $nombre = $cgi->param('nombre');
    my @nueva_lista = grep { $_->{nombre} ne $nombre } @{$datos->{data}};
    $datos->{data} = \@nueva_lista;
} 
elsif ($metodo eq 'POST') {
    my $json_texto = $cgi->param('POSTDATA');
    my $nuevo_pj = decode_json($json_texto);
    push @{$datos->{data}}, $nuevo_pj;
}
elsif ($metodo eq 'PATCH') {
    my $json_texto = $cgi->param('POSTDATA');
    my $update_data = decode_json($json_texto);
    
    foreach my $pj (@{$datos->{data}}) {
        if ($pj->{nombre} eq $update_data->{nombre}) {
            $pj->{universo} = $update_data->{universo} if $update_data->{universo};
            $pj->{nivel_poder} = $update_data->{nivel_poder} if $update_data->{nivel_poder};
            last;
        }
    }
}

# Guardar cambios en el archivo JSON
open my $fh_out, '>', $archivo or die "Error: $!";
print $fh_out encode_json($datos);
close $fh_out;

print encode_json($datos);