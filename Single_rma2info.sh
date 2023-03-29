#!/bin/bash
#$ -N single_rma2info
#$ -cwd
#$ -pe mpi 8
#$ -j y
source /share/apps/External/Miniconda3-4.7.10/etc/profile.d/conda.sh
export PATH=/home/victorsg/.conda/envs/megan/bin:$PATH
conda activate megan
#cd /scratch/rodrigog/01_Projects/Xoxo/01_data/
sed -i 's/-Xmx.*/-Xmx11000M/' /home/rodrigog/.conda/envs/megan/opt/megan-6.21.2/MEGAN.vmoptions # Changed to consider any other preset, not just 8000M as before
rma2info -i test16.rma6 -o test16.txt -c2c Taxonomy -mro true -vo true -p true
