#!C:/xampp/perl/bin/perl.exe
use strict;
use warnings;
use JSON::PP;

# 1. ESTO ES VITAL: Le decimos a Apache manualmente que enviaremos un JSON.
# Los dos saltos de línea (\n\n) son obligatorios para que no dé el Error 500.
print "Content-Type: application/json; charset=utf-8\n\n";

# 2. Nuestra "base de datos" de personajes
my $personajes = [
    {
        id => 1,
        nombre => "Saitama",
        universo => "One-Punch Man",
        nivel_poder => "Infinito (Rompe su limitador)",
        estado => "Vivo"
    },
    {
        id => 2,
        nombre => "Goku (Ultra Instinto)",
        universo => "Dragon Ball Super",
        nivel_poder => "Nivel Dios",
        estado => "Vivo"
    },
    {
        id => 3,
        nombre => "Frieren",
        universo => "Frieren",
        nivel_poder => "Más de 100,000 de maná",
        estado => "Viva"
    },
    {
        id => 4,
        nombre => "Cid Kagenou",
        universo => "The Eminence in Shadow",
        nivel_poder => "I am Atomic",
        estado => "Vivo"
    }
];

# 3. Enviamos la lista completa
print encode_json({ status => "success", total => scalar(@$personajes), data => $personajes });