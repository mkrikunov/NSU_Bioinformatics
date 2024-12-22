#!/bin/bash

REFERENCE_GENOME="../data/Escherichia_coli/reference_genome/GCA_000005845.2_ASM584v2_genomic.fna"
READS="../data/Escherichia_coli/sequencing_result/SRR31294338.fastq"
OUTPUT_DIR="output"

mkdir -p $OUTPUT_DIR

echo "Indexing the reference genome..."
bwa index $REFERENCE_GENOME

echo -e "\nMapping the reads..."
bwa mem $REFERENCE_GENOME $READS > $OUTPUT_DIR/alignment.sam

echo -e "\nConverting SAM to BAM and sorting..."
samtools view -Sb $OUTPUT_DIR/alignment.sam | samtools sort -o $OUTPUT_DIR/alignment.sorted.bam

echo -e "\nEvaluating the quality of mapping..."
samtools flagstat $OUTPUT_DIR/alignment.sorted.bam > $OUTPUT_DIR/flagstat.txt

echo -e "\nAnalyzing the results of flagstat..."
MAPPED_PERCENT=$(grep "mapped (" $OUTPUT_DIR/flagstat.txt | awk '{print $5}' | tr -d '()%mapped')

echo -e "\nPercentage of mapped reads: $MAPPED_PERCENT%"

echo -e "\nCalling of genetic variants.."
#Create index for the reference genome
samtools faidx $REFERENCE_GENOME
#Create index for the BAM file
samtools index $OUTPUT_DIR/alignment.sorted.bam
freebayes -f $REFERENCE_GENOME $OUTPUT_DIR/alignment.sorted.bam > $OUTPUT_DIR/result.vcf
