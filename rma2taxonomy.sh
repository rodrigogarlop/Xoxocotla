#!/bin/bash
# Update 2021-02-04: By Rodrigo García-López I removed the working directory to receive only full paths for the rma6 files instead. This script will now output a taxonomy-count table
## Este script exporta informacion en archivos txt a partir de archivos RMA6 generados en MEGAN mediante una lista de los RMA6 en txt, con los siguientes parametros. I also commented the only viruses part to get any other item
## Entrega una lista con conteo por taxon (-c2c Taxonomy) Adjnuta valor de rango correspondiente al orden taxonomico (K:Reino, P:Filum... (-p true)
## Reporta el mayor rango taxonomico (-mro true) , Verbose (-v)
##
## 	Recibe los siguientes argumentos:
## 1	Archivo de texto con la lista de los RMA6 a procesar(ej. TodosRMA6.txt)##
## 2	Sufijo de salida para los txt exportados ej: Vir
## 3	Memoria en MB(M) a asignar a la maquina virtual, depende de la cantidad de nucleos que se piden [Memoria = #Nucleos * 7 * 0.8] (ej. 110000M)
##
## ej. ejecución: qsub -R y -l h_rt=23:59:59 -t 1-4  rma62txt_Lst.sh TodosRMA6.txt taxonomy 11000M true
##
#$ -N rma62txt_MGNLst_p
#$ -cwd
#$ -pe mpi 4
##
# Salida y error juntas
#$ -j y
## Activamos conda
source /share/apps/External/Miniconda3-4.7.10/etc/profile.d/conda.sh
export PATH=/home/victorsg/.conda/envs/megan/bin:$PATH
conda activate megan
## Declaramos variables
LSTRMA6=$1
SUFX=$2
MEM=$3
## Modificamos la memoria de uso
sed -i 's/-Xmx.*/-Xmx'$MEM'/g' /home/rodrigog/.conda/envs/megan/opt/megan-6.21.2/MEGAN.vmoptions # Changed to consider any other preset, not just 8000M as before
echo "Memoria asignada:"
grep ^'-Xmx' /home/rodrigog/.conda/envs/megan/opt/megan-6.21.2/MEGAN.vmoptions
echo "$WFL $LSTRMA6"
if [ $# -eq 4 ]; then
	RMA=$(cat $LSTRMA6 | wc -l)
	echo "Hay $RMA archivos RMA6"
	FL1=$(cat $LSTRMA6 | head -n $SGE_TASK_ID | tail -n 1)
	FLN=$(echo $FL1 | sed -e 's/$/-'$SUFX'.txt/' -e 's/.rma6//')
	echo "entrada RMA6 $FL1"
	echo "salida txt $FLN"
	rma2info -i $FL1 -o $FLN -c2c Taxonomy -v -p true -mro true # -vo true
	echo "Hecho"
	conda deactivate
else
	echo "Numero de parametros incorrectos"
	conda deactivate
fi
