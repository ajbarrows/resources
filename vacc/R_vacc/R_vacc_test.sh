#!/bin/bash

#SBATCH --partition=short		# use Bluemoon for lengthy jobs
#SBATCH --nodes=1			# number of compute nodes -- usually no need to change
#SBATCH --ntasks=2			# number of processor cores -- important for paralleized code
#SBATCH --time=3:00			# expected job time: estimate this correctly. If too short, your job won't complete.
#SBATCH --mem=2G			# amount of RAM
#SBATCH --job-name=R_vacc_test		# job name for monitoring
#SBATCH --output=%x_%j.out		# output file
#SBATCH --mail-type=ALL			# prompts Slurm to send you emails when the job starts, completes, or fails

# Load R packages
spack load r@3.6.3
spack load r-dplyr@0.8.3
spack load r-tidyr@0.8.3

# source ${HOME}/.bashrc
# conda activate MyNewEnvironment		# loads your conda environment

cd ${HOME}/scratch/R_vacc/R		# this is the directory of your project's scripts
set -x
Rscript R_vacc_test.R			# here is the command that actually runs your script
