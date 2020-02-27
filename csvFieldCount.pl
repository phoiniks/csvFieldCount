#!/usr/bin/perl -w
use strict;
use List::Util;
use POSIX qw/strftime/;

open my $log, ">>", "fldcnt.log";

my $startzeit = strftime "%T %d.%m.%Y", localtime;
printf "\n%s\n", $startzeit;
print $log sprintf "\nGestartet: %s\n", $startzeit;

my @files = glob("*.dat");

print "\n";

foreach ( @files ) {
    print $_;
}

my %line_dictionary;
my $ld_ref = \%line_dictionary;

if ( -e "fldcnt.log" ) {
    unlink "fldcnt.log";
}

my $count = 0;
local $| = 1;
foreach ( @files ) {
    chomp;
    open my $file, "<", $_;

    foreach ( <$file> ) {
	my $d = tr/|//;
	$d++;
	$ld_ref->{$d} = $_;
    }

    if ( scalar keys %$ld_ref == 1 ) {
	printf STDERR "\e[Kref.dat %d: Alle Zeilen enthalten dieselbe Anzahl an Feldern: %s\r", ++$count, $_;
	print $log sprintf "ref.dat %d: Alle Zeilen enthalten dieselbe Anzahl an Feldern: %s\n", $count, $_;
    } else {
	print $log sprintf "Die Anzahl an Feldern in den Feldern variiert!\n";
	print $log sprintf "%d\n", $.;
	print $log sprintf "%s\n", $_;
	
	printf STDERR "\e[Kref.dat: %d: Die Anzahl an Feldern in den Feldern variiert: %s, Zeile: %d\r", $count, $_, $.;
    }
    select STDOUT;
}

print "\n\nBeispiel(e): ";
while ( my($key, $value) = each %$ld_ref ) {
    printf STDERR "%d => %s\n", $key, $value;
    print $log sprintf "%d => %s\n", $key, $value;
}

if ( scalar keys %$ld_ref == 1 ) {
    print STDERR "\nAlle Zeilen enthalten dieselbe Anzahl an Feldern!\n";
} else {
    print STDERR "\nDie Anzahl an Feldern in den Feldern variiert!\n";
}

my $endzeit = strftime "%T %d.%m.%Y", localtime;
printf "\n%s\n", $endzeit;
print $log sprintf "\nBeendet: %s\n", $endzeit;

close $log;
