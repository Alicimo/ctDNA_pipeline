#!/bin/bash

#SBATCH -J QDNASeq.mult		    # job name
#SBATCH -a 1-349		        # job array
#SBATCH -c 1
#SBATCH --mem=10000
#SBATCH --time=24:00:00
#SBATCH -o QDNASeq.multi.%A.%a.out  # STDOUT
#SBATCH -e QDNASeq.multi.%A.%a.err  # STDERR
#SBATCH --mail-type=ALL    	# notifications for job done & fail
#SBATCH --mail-user=alistair.martin@cruk.cam.ac.uk # send-to address

#sWG pipeline (BWA + ?)

#Written by Alistair Martin
#Last update April 2017

set -xue

# Set variables
WD=/mnt/scratchb/cclab/martin06/ctDNA.RT
NUM_CORES=${NUM_CORES:-$SLURM_CPUS_PER_TASK}
INDEX=${INDEX:-$SLURM_ARRAY_TASK_ID}

BAM_DIR=$WD/bam/picard
BAM_PATH=$(ls $BAM_DIR/*.bam | sed -n "$INDEX"p)
SAMPLE_NAME=${BAM_PATH%.bam}

export PATH=/mnt/scratcha/cclab/martin06/software/R-3.5.1/bin:${PATH}

echo "[main $(date +"%Y-%m-%d %T")] Running QDNASeq on $SAMPLE_NAME"
Rscript /home/martin06/pipelines/pipeline.QDNASeq.R $BAM_PATH $WD 1000
