#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use JSON;

my $cgi = CGI->new;
my $archivo = '/usr/lib/cgi-bin/datos.json';

# Cabecera para JSON
print $cgi->header('application/json; charset=UTF-8');

sub leer_json {
    if (!-e $archivo || -s $archivo == 0) { return { status => "ok", data => [] }; }
    open my $fh, '<', $archivo or return { status => "ok", data => [] };
    my $content = do { local $/; <$fh> };
    close $fh;
    return decode_json($content);
}

sub guardar_json {
    my ($datos) = @_;
    open my $fh, '>', $archivo or die "Error: $!";
    print $fh encode_json($datos);
    close $fh;
}

my $datos = leer_json();
my $metodo = $cgi->request_method();

if ($metodo eq 'POST') {
    # CREAR
    my $json_input = $cgi->param('POSTDATA');
    my $nuevo = decode_json($json_input);
    push @{$datos->{data}}, $nuevo;
} 
elsif ($metodo eq 'PATCH') {
    # ACTUALIZAR
    my $json_input = $cgi->param('POSTDATA');
    my $update = decode_json($json_input);
    foreach my $pj (@{$datos->{data}}) {
        if ($pj->{nombre} eq $update->{nombre}) {
            $pj->{universo} = $update->{universo} if $update->{universo};
            $pj->{nivel_poder} = $update->{nivel_poder} if $update->{nivel_poder};
            last;
        }
    }
} 
elsif ($metodo eq 'DELETE') {
    # ELIMINAR
    my $nombre_a_borrar = $cgi->param('nombre');
    my @filtrado = grep { $_->{nombre} ne $nombre_a_borrar } @{$datos->{data}};
    $datos->{data} = \@filtrado;
}

guardar_json($datos);
print encode_json($datos); # Retorna la lista actualizada