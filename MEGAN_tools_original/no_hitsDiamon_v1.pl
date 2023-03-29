use strict;
use warnings;
## 7 de Abril 2011 
##De un archivo de resultados BLAST  "normal"  el extendido que usa MEGAN, 
##extrae solo los resultados que SI contienen hits 

print "El archivo de entrada de no_hits es $ARGV[0]\n";
open (BLAST, "$ARGV[0]") || die "no puedo abrir $ARGV[0]";
my $str=substr($ARGV[0],0,-4);
print $str."\n";
my $outFile=$str."_Hits.txt";
open (HITS, ">$outFile") || die  "no puedo abrir $str solo hits" ;
open (NOHITS, ">$str"."_idnoHits") || die "no puedo abrir $str noHits";

my (@QUERY,@read);
my ($noHit,$primer,$secuencias)=(0,0,0);
my ($linea,$linea2,$read,$bandera);
print "Inicia analisis\n";
while (my $linea = <BLAST>) {
	if ($linea=~/^BLAS/ ){
		for(my $i=0;$i<2;$i++){
			print HITS $linea;
			$linea=<BLAST>;
		}
	}
	if ($linea=~/^Query=/  and $primer=1) {
		$bandera=0;
		foreach $linea2 (@QUERY) {
			if ($linea2=~m/No\shits\sfound/) {
				$bandera=1;
				$noHit++;
				@read=split(/\=\s/,$read);
				print NOHITS "$read[1]";
			}
		}
		if ($bandera==0) {
			foreach (@QUERY) {
				print HITS $_;
			}
		}
		undef @QUERY;
	}
	if ($linea=~/^Query=/ ) {
	$read=$linea;
	}
	push (@QUERY,$linea);
	$primer=1;
}
foreach $linea2 (@QUERY) {
	if ($linea2=~m/No\shits\sfound/) {
		$bandera=1;
		$noHit++;
		@read=split(/\=\s/,$read);
		print NOHITS "$read[1]";
	}
}
if ($bandera==0) {
	foreach (@QUERY) {
		print HITS $_;
	}
}
close BLAST;
close HITS;
close NOHITS;
print "Inicia zipiado\n";

