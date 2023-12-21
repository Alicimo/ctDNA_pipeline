#!/usr/bin/env bash

mkdir -p fastq/raw
mkdir -p metadata
mkdir -p report/sequencing
mkdir -p bam/raw

for LIBRARY in "$@"; do
    java -jar /mnt/scratcha/cclab/martin06/software/clarity-tools.jar -D -l $LIBRARY -f "*.fq.gz"
    java -jar /mnt/scratcha/cclab/martin06/software/clarity-tools.jar -l $LIBRARY -f "*.csv" 
    java -jar /mnt/scratcha/cclab/martin06/software/clarity-tools.jar -l $LIBRARY -f "*.html" 
    java -jar /mnt/scratcha/cclab/martin06/software/clarity-tools.jar -l $LIBRARY -f "*.txt" 

    rm $LIBRARY/*.md5sums.txt
    rm $LIBRARY/*.lostreads.fq.gz

    mv $LIBRARY/*.fq.gz fastq/raw
    mv $LIBRARY/*.tar fastq/raw
    mv $LIBRARY/*.csv metadata
    mv $LIBRARY/*.html report/sequencing
    mv $LIBRARY/*.txt report/sequencing
    rm -r $LIBRARY
done


