#!/bin/bash

#SBATCH -J ctDNA.sWG		    # job name
#SBATCH -a 1-24 # job array
#SBATCH -c 10
#SBATCH --mem=100000
#SBATCH --time=24:00:00
#SBATCH -o ctDNA.sWG.%A.%a.out  # STDOUT
#SBATCH -e ctDNA.sWG.%A.%a.err  # STDERR
#SBATCH --mail-type=ALL    	# notifications for job done & fail
#SBATCH --mail-user=alistair.martin@cruk.cam.ac.uk # send-to address

#sWG pipeline (BWA + ?)

#Written by Alistair Martin
#Last update April 2017

set -xue

# Set variables
WD=/mnt/scratchb/cclab/martin06/ctDNA.RT

echo "[main $(date +"%Y-%m-%d %T")] Starting pipeline"

# Load paths, configure directory structure, set variables based on cluster setup
source /home/martin06/paths/path-genome-b37.sh
source /home/martin06/paths/path-software.sh
source /home/martin06/pipelines/pipeline.setup.sh

#Get sample name, remove $FASTQ1_SUFFIX
echo "[main $(date +"%Y-%m-%d %T")] Analysing sample: $SAMPLE_NAME"

#Set sample specific working directory
SAMPLE_WD=$TMP_DIR/$SAMPLE_NAME
mkdir -p $SAMPLE_WD
cd $SAMPLE_WD

#========================================================================
# Download fastq(s)
#========================================================================

source /home/martin06/pipelines/pipeline.clarity.sh

#========================================================================
# Trim custom adapters - 
#========================================================================
echo "[main $(date +"%Y-%m-%d %T")] Trimming adaptors"

CUTADAPT_DIR=$FASTQ_DIR/cutadapt
CUT_FQ=${SAMPLE_NAME}_cut.fq.qz

mkdir -p $CUTADAPT_DIR
cutadapt -a TGAGCTAC -g GTAGCTCA -o $CUT_FQ $FASTQ1_PATH
mv $CUT_FQ $CUTADAPT_DIR
> $FASTQ1_PATH
FASTQ1_PATH=$CUTADAPT_DIR/$CUT_FQ

#========================================================================   
# Alignment
#========================================================================
echo "[main $(date +"%Y-%m-%d %T")] Aligning"

if $PAIRED ; then
    bwa mem -t $NUM_CORES $REFERENCE_FA_PATH $FASTQ1_PATH $FASTQ2_PATH > ${SAMPLE_NAME}.sam
    > $FASTQ1_PATH
    > $FASTQ2_PATH
else
    bwa mem -t $NUM_CORES $REFERENCE_FA_PATH $FASTQ1_PATH > ${SAMPLE_NAME}.sam
    > $FASTQ1_PATH
fi

samtools view -b -@ $NUM_CORES ${SAMPLE_NAME}.sam > ${SAMPLE_NAME}.bam
rm ${SAMPLE_NAME}.sam

samtools sort -@ $NUM_CORES ${SAMPLE_NAME}.bam  > ${SAMPLE_NAME}.sorted.bam
rm ${SAMPLE_NAME}.bam

samtools index ${SAMPLE_NAME}.sorted.bam

mkdir -p ${BAM_DIR}/bwa
mv ${SAMPLE_NAME}.sorted.ba* ${BAM_DIR}/bwa
BWA_BAM=${BAM_DIR}/bwa/${SAMPLE_NAME}.sorted.bam

#========================================================================   
# Dedupping
#========================================================================
echo "[main $(date +"%Y-%m-%d %T")] Dedupping"

java -jar $PICARD_PATH/picard.jar MarkDuplicates \
	I=$BWA_BAM \
	O=${SAMPLE_NAME}.sorted.dedupped.bam \
	CREATE_INDEX=true \
	VALIDATION_STRINGENCY=SILENT \
	M=$SAMPLE_NAME.picard.log
	
rm $BWA_BAM*

mkdir -p ${BAM_DIR}/picard
mv ${SAMPLE_NAME}.sorted.dedupped.ba* ${BAM_DIR}/picard

mkdir -p ${REPORT_DIR}/picard
mv ${SAMPLE_NAME}.picard.log ${REPORT_DIR}/picard

#========================================================================   
# Clean up
#========================================================================

cd $WD
rm -rf $SAMPLE_WD