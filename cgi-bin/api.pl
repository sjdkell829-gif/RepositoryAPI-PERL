#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use JSON::PP;

my $cgi = CGI->new;
# Permitimos que cualquier página web pueda leer esta API (CORS)
print $cgi->header(-type => 'application/json', -charset => 'utf-8', -access_control_allow_origin => '*');

my $archivo = 'datos.json';
my $personajes = [];

# Leer los personajes guardados
if (open(my $fh, '<', $archivo)) {
    local $/ = undef;
    my $json_texto = <$fh>;
    close($fh);
    $personajes = decode_json($json_texto) if $json_texto;
}

# Revisar si queremos "leer" o "agregar"
my $accion = $cgi->param('accion') || 'leer';

if ($accion eq 'agregar') {
    # Recibir los datos del nuevo personaje
    my $nombre = $cgi->param('nombre');
    my $universo = $cgi->param('universo');
    my $poder = $cgi->param('nivel_poder');

    if ($nombre && $poder) {
        my $nuevo_id = scalar(@$personajes) + 1;
        my $nuevo_personaje = {
            id => $nuevo_id,
            nombre => $nombre,
            universo => $universo || "Desconocido",
            nivel_poder => $poder,
            estado => "Vivo"
        };

        push(@$personajes, $nuevo_personaje);

        # Guardar en el archivo JSON
        if (open(my $fh, '>', $archivo)) {
            print $fh encode_json($personajes);
            close($fh);
            print encode_json({ status => "success", message => "Personaje agregado" });
        }
    } else {
        print encode_json({ status => "error", message => "Faltan datos" });
    }
} else {
    # Mostrar la lista
    print encode_json({ status => "success", data => $personajes });
}