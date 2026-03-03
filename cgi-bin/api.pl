#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use JSON;

my $cgi = CGI->new;
my $archivo = '/usr/lib/cgi-bin/datos.json';

print $cgi->header('application/json; charset=UTF-8');

# Leer base de datos
sub leer {
    if (!-e $archivo) { return { data => [] }; }
    open my $fh, '<', $archivo or return { data => [] };
    my $txt = do { local $/; <$fh> };
    close $fh;
    return $txt ? decode_json($txt) : { data => [] };
}

my $db = leer();
my $metodo = $cgi->request_method();

if ($metodo eq 'POST' || $metodo eq 'PATCH') {
    my $raw = $cgi->param('POSTDATA');
    if ($raw) {
        my $item = decode_json($raw);
        if ($metodo eq 'POST') {
            push @{$db->{data}}, $item;
        } else {
            foreach my $p (@{$db->{data}}) {
                if ($p->{nombre} eq $item->{nombre}) {
                    $p->{universo} = $item->{universo} if $item->{universo};
                    $p->{nivel_poder} = $item->{nivel_poder} if $item->{nivel_poder};
                }
            }
        }
    }
} elsif ($metodo eq 'DELETE') {
    my $nom = $cgi->param('nombre');
    my @new = grep { $_->{nombre} ne $nom } @{$db->{data}};
    $db->{data} = \@new;
}

# Guardar
open my $fh, '>', $archivo;
print $fh encode_json($db);
close $fh;

print encode_json($db);