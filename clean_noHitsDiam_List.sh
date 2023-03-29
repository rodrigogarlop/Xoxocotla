#!/bin/bash


# Salida estandar y de errror juntas en la salida estandar y las coloca en la carpeta de Programas
#$ -j y
#$ -o /scratch/rodrigog/qsubout

# $1: Path donde estan los archivos a analizar. Ejemplo: /home/btaboada/Results/Xoxocotla/Prueba/
# $2: Nombre del archivo a analizar sin extensión (debe de estar en la misma direccion que 1). Ejemplo: AllFiles_Qual_CDhit_Human_noM_Ribo_NoM_Virus_NoM_FileNames.txt
# $3: Tipo de Archivos: 1) gz o 2)txt.

# Ejemplo: qsub -t 1-1196 clean_noHits.sh /home/btaboada/Results/Xoxocotla/Prueba/ AllFiles_Qual_CDhit_Human_noM_Ribo_NoM_Virus_NoM_FileNames.txt 
#$ -N cleanDiamon
 
source ~/.bashrc
cd $1
LISTAFILE=$1/$2
FILE=$(cat $LISTAFILE | head -n $SGE_TASK_ID | tail -n 1)
echo $FILE
if  [ $3 -eq 1 ]; then
STR='.txt'
txtGZ='.txt.gz'
# gzip -d $FILE
FL=${FILE/$txtGZ/$STR}
zcat $FILE >$FL
echo $FL
fi

perl /home/rodrigog/bin/no_hitsDiamon_v1.pl $FL

#gzip -q -f $FL
rm $FL
TXT='.txt'
RESUL='_Hits.txt'
FL2=${FL/$TXT/$RESUL}
echo $FL2
gzip -q $FL2


