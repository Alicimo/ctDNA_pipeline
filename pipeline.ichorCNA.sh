#!/bin/bash

#SBATCH -J ichorCNA.mult		    # job name
#SBATCH -a 1-349		        # job array
#SBATCH -c 1
#SBATCH --mem=10000
#SBATCH --time=24:00:00
#SBATCH -o ichorCNA.multi.%A.%a.out  # STDOUT
#SBATCH -e ichorCNA.multi.%A.%a.err  # STDERR
#SBATCH --mail-type=ALL    	# notifications for job done & fail
#SBATCH --mail-user=alistair.martin@cruk.cam.ac.uk # send-to address

#Written by Alistair Martin
#Last update April 2017

set -xue

# Set variables
WD=/mnt/scratchb/cclab/martin06/ctDNA.RT
NUM_CORES=${NUM_CORES:-$SLURM_CPUS_PER_TASK}
INDEX=${INDEX:-$SLURM_ARRAY_TASK_ID}
export PATH=/mnt/scratcha/cclab/martin06/software/R-3.5.1/bin:${PATH}

QDNA_DIR=$WD/QDNA/bin.1000
CN_DIR=$QDNA_DIR/CNs
CN_PATH=$(ls $CN_DIR/*.tsv | sed -n "$INDEX"p)
SAMPLE_NAME=${CN_PATH%.tsv}

CN_BC_PATH=$QDNA_DIR/BC.CNs.ave.tsv
if [ ! -f $CN_BC_PATH ]; then
    echo "BC file not found"
    exit 0
fi

echo "[main $(date +"%Y-%m-%d %T")] Running ichorCNA on $SAMPLE_NAME"
Rscript /home/martin06/pipelines/pipeline.ichorCNA.R $CN_PATH $WD $CN_BC_PATH
