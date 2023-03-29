#!/bin/bash
## Este script genera archivos de agrupamiento de MEGAN a partir de la ruta absoluta que contiene los archivos RM6
##
## 	Recibe los siguientes argumentos:
## 1	Carpeta de trabajo que debe contener las subcarpetas con los archivos RMA6 (ej. /scratch/victorsg/Data/Reyes/BlstMPhg/Sample1)
## 2	Archivo de texto con la lista de las carpetas que contienen los RMA6(ej. TodosMGN.txt) [Debe estar en la misma carpeta de trabajo] 
## 3	Memoria en MB(M) a asignar a la maquina virtual, depende de la cantidad de nucleos que se piden [Memoria = #Nucleos * 7 * 0.8] (ej. 110000M)
##
## ej. ejecución: qsub -R y -l h_rt=23:59:59 -t 1-4 /scratch/victorsg/Programs/compareMGN_Lst.sh /scratch/victorsg/Data/MarieClaire/ReadRECUP TodosMGN.txt 110000M
##
#$ -N compareMGN_Lst
#$ -cwd
#$ -pe mpi 4
##
# Salida y error juntas
#$ -j y
##
## Activamos conda
source /share/apps/External/Miniconda3-4.7.10/etc/profile.d/conda.sh
export PATH=/home/victorsg/.conda/envs/megan/bin:$PATH
conda activate megan
## Declaramos variables
WFL=$1
LSTF=$2
MEM=$3
## Modificamos la memoria de uso
sed -i 's/-Xmx.*/-Xmx'$MEM'/g' /home/rodrigog/.conda/envs/megan/opt/megan-6.21.2/MEGAN.vmoptions # Changed to consider any other preset, not just 8000M as before
echo "Memoria asignada:"
grep ^'-Xmx' /home/rodrigog/.conda/envs/megan/opt/megan-6.21.2/MEGAN.vmoptions
echo "$WFL"
cd $WFL
if [ $# -eq 3 ]; then
	cd $WFL
	FL=$(cat $WFL/$LSTF| head -n $SGE_TASK_ID | tail -n 1)
	echo "Se van a comparar los archivos en $WFL/$FL"
	#Estos son los parametros con los que realiza el agrupamiento
	compute-comparison -n false -s true -v -i $WFL/$FL -o $WFL/$FL\_MEGANComp.megan
	echo "Hecho"
	conda deactivate
else
	echo "Numero de parametros incorrectos"
	conda deactivate
fi
