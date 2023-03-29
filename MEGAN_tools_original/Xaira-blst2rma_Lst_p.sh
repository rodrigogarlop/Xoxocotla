#!/bin/bash
## Este script genera archivos RMA de MEGAN a partir de una lista txt con la salidas de BLAST y los siguientes parametros
## formato del txt de Blast (-f) BlastText, Blast realizado (-bm) BlastN, min score (-ms) 40, evalue (-me) 0.001
## min support (-sup) 1, algoritmo (-alg) naive, % covertura (-lcp) 90, asignación de reads (-ram) ReadCount, verbose (-v)
## Debe agregar el directorio ~/megan/tools a sus variables de entorno (ej. export PATH=$PATH:~/megan/tools)
##
## 	Recibe los siguientes argumentos:
## 1	Carpeta de trabajo que debe contener los txt de blast y fasta correspondientes, aquí saldrán los RMA6 (ej. /mnt/d/victorsg/Data/Reyes/BlstMPhg)
## 2	Archivo de texto con la lista de los txt de BLAST (ej. BlastTodosMegan.txt)
## 3	Archivo de texto con la lista de los archivos fasta (ej. FastaTodosMegan.txt).¡Deben estar en el mismo orden que los BLAST!
## 4	Ruta absoluta de archivo de mapeo para MEGAN (ej. /home/victor/dbs/megan/megan-nucl-map-Jul2020.db)
## 5	Memoria en MB(M) a asignar a la maquina virtual, depende de la cantidad de nucleos que se piden [Memoria = #Nucleos * 7 * 0.8] (ej. 110000M)
##
## ej. ejecución: qsub -R y -l h_rt=23:59:59 -t 1-4 /scratch/victorsg/Programs/blst2rma_Lst_p.sh /scratch/victorsg/Data/MarieClaire/ReadRECUP TodosBlast.txt TodosReads.txt /scratch/victorsg/dbs/megan/megan-nucl-Jan201.db 110000M
##
#$ -N blst2rma_Lst_p
#$ -cwd
#$ -pe mpi 16
##
# Salida y error juntas
#$ -j y
#$ -o /scratch/victorsg/Data/MarieClaire/OUT
## Activamos conda
source /share/apps/External/Miniconda3-4.7.10/etc/profile.d/conda.sh
export PATH=/home/victorsg/.conda/envs/megan/bin:$PATH
conda activate megan
## Declaramos variables
WFL=$1
LSTBLST=$2
LSTFAST=$3
MEM=$6
echo "$WFL $LSTBLST $LSTFAST $MEM"
cd $WFL
## Modificamos la memoria para la máquina virtual
sed -i 's/-Xmx8000M/-Xmx$MEM/g' /home/victorsg/.conda/envs/megan/opt/megan-6.21.2/MEGAN.vmoptions
echo "Memoria asignada:"
grep ^'-Xmx' /home/victorsg/.conda/envs/megan/opt/megan-6.21.2/MEGAN.vmoptions
## Comienza asignacion
if [ $# -eq 5 ]; then
	BLS=$(cat $WFL/$LSTBLST | wc -l)
	FST=$(cat $WFL/$LSTFAST | wc -l)
	if [ $BLS -eq $FST ]; then
		echo ""
		echo "Hay $BLS archivos Blast y $FST archivos fasta en las listas"
		cd $WFL
		FL1=$(cat $LSTBLST | head -n $SGE_TASK_ID | tail -n 1)
		FL2=$(cat $LSTFAST | head -n $SGE_TASK_ID | tail -n 1)
		FLN=$WFL/"$(echo $FL1 | sed -e 's/.txt/.rma6/g')"
		echo "entrada BLAST $FL1"
		echo "entrada FASTA $FL2"
		echo "salida RMA $FLN"
		echo ""
		#Estos son los parametros con los que arma la asignacion
		echo "blast2rma -f BlastText -bm BlastN -ms 40 -me 0.0001 -sup 5 -alg weighted -lcp 80 -ram readMagnitude -t $NSLOTS -v -mdb $4 -i $FL1 -r $FL2 -o $FLN"
		blast2rma -f BlastText -bm BlastN -ms 40 -me 0.0001 -sup 5 -alg weighted -lcp 80 -ram readMagnitude -t $NSLOTS -v -mdb $4 -i $FL1 -r $FL2 -o $FLN
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

sed -i 's/-Xmx$MEM/-Xmx8000M/g' /home/victorsg/.conda/envs/megan/opt/megan-6.21.2/MEGAN.vmoptions
