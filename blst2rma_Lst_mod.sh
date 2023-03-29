#!/bin/bash
# UPDATE 2021-06-03 by Rodrigo García López: The script was adjusted to use new additional parameters for min evalue, blast type, minimum reads, alignment min, and identity percentage
## Este script genera archivos RMA de MEGAN a partir de una lista txt con la salidas de BLAST (long format) y los siguientes parametros
## formato del txt de Blast (-f) BlastText, Blast realizado (-bm) BlastN, min score (-ms) 40, evalue (-me) 0.001
## min support (-sup) 1, algoritmo (-alg) naive, % covertura (-lcp) 90, asignación de reads (-ram) ReadMagnitude, verbose (-v)
##
## 	Recibe los siguientes argumentos:
## 1	Carpeta de trabajo que debe contener los txt de blast y fasta correspondientes, aquí saldrán los RMA6 (ej. /mnt/d/victorsg/Data/Reyes/BlstMPhg)
## 2	Archivo de texto con la lista de los txt de BLAST (ej. BlastTodosMegan.txt)[Archivo de salida BLAST como TXT; ¡Cambia la línea 48 si la extensión es diferente!]
## 3	Archivo de texto con la lista de los archivos fasta (ej. FastaTodosMegan.txt).¡Deben estar en el mismo orden que los BLAST!
## 4	Ruta absoluta de archivo de mapeo para MEGAN (ej. /home/victor/dbs/megan/megan-nucl-map-Jul2020.db)
## 5	Memoria en MB(M) a asignar a la maquina virtual, depende de la cantidad de nucleos que se piden [Memoria = #Nucleos * 7 * 0.8] (ej. 110000M)
# UPDATE 2021-06-03: Added more params:
#	6	Min evalue cutoff
#	7	Type of BLAST	
#	8	Min reads cutoff (support)
#	9	Min alignment
#	10	Identity
##
## ej. ejecución: qsub -R y -l h_rt=23:59:59 -t 1-4 /scratch/victorsg/Programs/blst2rma_Lst.sh /scratch/victorsg/Data/MarieClaire/ReadRECUP TodosBlast.txt TodosReads.txt /scratch/victorsg/dbs/megan/megan-nucl-Jan201.db 110000M 0.0001 BlastN 5 80 40
##
#$ -N blst2rma_Lst_p
#$ -cwd
#$ -pe mpi 4
##
# Salida y error juntas
#$ -j y
## Activamos conda
source /share/apps/External/Miniconda3-4.7.10/etc/profile.d/conda.sh # Uncomment if required
export PATH=/home/victorsg/.conda/envs/megan/bin:$PATH
conda activate megan
## Declaramos variables
WFL=$1
LSTBLST=$2
LSTFAST=$3
MEM=$5
EVAL=$6
BLSTY=$7
MIN=$8
ALN=$9
PID=$10
echo "$WFL $LSTBLST $LSTFAST $EVAL $MEM $BLSTY $MIN $ALN"
cd $WFL
## Modificamos la memoria de uso
sed -i 's/-Xmx.*/-Xmx'$MEM'/g' /home/rodrigog/.conda/envs/megan/opt/megan-6.21.2/MEGAN.vmoptions # Changed to consider any other preset, not just 8000M as before
echo "Memoria asignada:"
grep ^'-Xmx' /home/rodrigog/.conda/envs/megan/opt/megan-6.21.2/MEGAN.vmoptions
## Comienza asignacion
if [ $# -eq 10 ]; then # Changed to include 3 more
	BLS=$(cat $WFL/$LSTBLST | wc -l)
	FST=$(cat $WFL/$LSTFAST | wc -l)
	if [ $BLS -eq $FST ]; then
		echo ""
		echo "Hay $BLS archivos Blast y $FST archivos fasta en las listas"
		cd $WFL
		FL1=$(cat $LSTBLST | head -n $SGE_TASK_ID | tail -n 1)
		FL2=$(cat $LSTFAST | head -n $SGE_TASK_ID | tail -n 1)
		FLN=$WFL/"$(echo $FL1 | sed -e 's/.txt/.rma6/g' -e 's/\.gz$//')"
		echo "entrada BLAST $FL1"
		echo "entrada FASTA $FL2"
		echo "salida RMA $FLN"
		echo ""
		#Estos son los parametros con los que arma la asignacion
		echo "blast2rma -f BlastText -bm BlastN -ms 40 -me 0.0001 -sup 5 -alg weighted -lcp 80 -ram readMagnitude -t $NSLOTS -v -mdb $4 -i $FL1 -r $FL2 -o $FLN"
		blast2rma -f BlastText -bm $BLSTY -ms 40 -me $EVAL -sup $MIN -mpi $PID -alg weighted -lcp 80 -mrc $ALN -ram readMagnitude -t $NSLOTS -v -mdb $4 -i $FL1 -r $FL2 -o $FLN
		echo "Hecho"
		conda deactivate
	else
		echo "El numero de archivos BLAST y FASTA no coincide"
		conda deactivate
	fi
else
	echo "Numero de parametros incorrectos"
	conda deactivate
fi

