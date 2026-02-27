#!/usr/bin/perl
use strict;
use warnings;

print "=== SISTEMA DE ESCÁNER DE NIVELES DE PODER ===\n\n";

# Creamos un "Hash" (como un diccionario) para guardar personajes y sus niveles
my %personajes = (
    "Saitama"               => "Infinito (Rompe su limitador)",
    "Goku (Ultra Instinto)" => "Nivel Dios",
    "Frieren"               => "Más de 100,000 de maná (Oculto)",
    "Meruem"                => 2000000,
    "Ainz Ooal Gown"        => "Supera el nivel 100",
    "Cid Kagenou"           => "I am Atomic",
    "Naruto Uzumaki"        => 1500000
);

print "Cargando datos de la Asociación de Héroes y otros universos...\n";
print "--------------------------------------------------------------\n";

# Un ciclo para leer y mostrar a todos los personajes registrados
foreach my $nombre (keys %personajes) {
    my $poder = $personajes{$nombre};
    print "Personaje: $nombre \n";
    print "Poder: $poder \n";
    print "---\n";
}

print "Escaneo completado.\n";