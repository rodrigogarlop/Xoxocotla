#!/bin/bash
## Este script exporta informacion en archivos txt a partir de archivos RMA6 generados en MEGAN mediante una lista de los RMA6 en txt, con los siguientes parametros
## Entrega una lista con conteo por taxon (-c2c Taxonomy) Adjnuta valor de rango correspondiente al orden taxonomico (K:Reino, P:Filum... (-p true)
## Reporta el mayor rango taxonomico (-mro true) Reporta solo virus (-vo true) , Verbose (-v)
##
## 	Recibe los siguientes argumentos:
## 1	Carpeta de trabajo que debe contener los RMA6 y la lista de los archivos (ej. /scratch/victorsg/Data/Reyes/BlstMPhg)
## 2	Archivo de texto con la lista de los RMA6 a procesar(ej. TodosRMA6.txt)##
## 3	Sufijo de salida para los txt exportados ej: Vir
## 4	Memoria en MB(M) a asignar a la maquina virtual, depende de la cantidad de nucleos que se piden [Memoria = #Nucleos * 7 * 0.8] (ej. 110000M)
##
## ej. ejecución: qsub -R y -l h_rt=23:59:59 -t 1-4  /scratch/victorsg/Programs/rma62txt_Lst.sh /scratch/victorsg/Data/Reyes/BlstMPhg TodosRMA6.txt Vir 11000M
##
#$ -N rma62txt_MGNLst_p
#$ -cwd
#$ -pe mpi 8
##
# Salida y error juntas
#$ -j y
#$ -o /scratch/victorsg/Data/MarieClaire/ReadRECUP/OUT
## Activamos conda
source /share/apps/External/Miniconda3-4.7.10/etc/profile.d/conda.sh
export PATH=/home/victorsg/.conda/envs/megan/bin:$PATH
conda activate megan
## Declaramos variables
WFL=$1
LSTRMA6=$2
SUFX=$3
MEM=$4
## Modificamos la memoria de uso
sed -i 's/-Xmx8000M/-Xmx$MEM/g' /home/victorsg/.conda/envs/megan/opt/megan-6.21.2/MEGAN.vmoptions
echo "Memoria asignada:"
grep ^'-Xmx' /home/victorsg/.conda/envs/megan/opt/megan-6.21.2/MEGAN.vmoptions
echo "$WFL $LSTRMA6"
cd $WFL
if [ $# -eq 4 ]; then
	RMA=$(cat $WFL/$LSTRMA6 | wc -l)
	echo "Hay $RMA archivos RMA6"
	cd $WFL
	FL1=$(cat $WFL/$LSTRMA6 | head -n $SGE_TASK_ID | tail -n 1)
	FLN=$WFL/"$(echo $FL1 | sed -e 's/.rma6/$SUFX.txt/g')"
	echo "entrada RMA6 $FL1"
	echo "salida txt $FLN"
	rma2info -c2c Taxonomy -p true -mro true -vo true -v -i $FL1 -o $FLN
	echo "Hecho"
	conda deactivate
else
	echo "Numero de parametros incorrectos"
	conda deactivate
fi
