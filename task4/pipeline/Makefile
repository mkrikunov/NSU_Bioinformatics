SHELL := /bin/bash

REFERENCE=../data/Escherichia_coli/reference_genome/GCA_000005845.2_ASM584v2_genomic.fna
READS=../data/Escherichia_coli/sequencing_result/SRR31294338.fastq
OUTPUT_DIR=output
RESULTS_DIR=results
QUALITY_THRESHOLD=90

SAMTOOLS=samtools
BWA=bwa
FREEBAYES=freebayes


all: prepare quality_check final_result

prepare:
	@mkdir -p $(OUTPUT_DIR) $(RESULTS_DIR)

$(OUTPUT_DIR)/reference_genome.fna: $(REFERENCE)
	@echo "Indexing the reference genome..."
	$(BWA) index $(REFERENCE)

$(OUTPUT_DIR)/alignment.sam: $(OUTPUT_DIR)/reference_genome.fna $(READS)
	@echo -e "\nMapping the reads..."
	$(BWA) mem $(REFERENCE) $(READS) > $(OUTPUT_DIR)/alignment.sam

$(OUTPUT_DIR)/alignment.sorted.bam: $(OUTPUT_DIR)/alignment.sam
	@echo -e "\nConverting SAM to BAM and sorting..."
	$(SAMTOOLS) view -Sb $(OUTPUT_DIR)/alignment.sam | samtools sort -o $(OUTPUT_DIR)/alignment.sorted.bam

$(OUTPUT_DIR)/flagstat.txt: $(OUTPUT_DIR)/alignment.sorted.bam
	@echo -e "\nEvaluating the quality of mapping..."
	$(SAMTOOLS) flagstat $(OUTPUT_DIR)/alignment.sorted.bam > $(OUTPUT_DIR)/flagstat.txt

quality_check: $(OUTPUT_DIR)/flagstat.txt
	@echo -e "\nAnalyzing the results of flagstat..."
		@MAPPED_PERCENT=$(shell grep -m 1 'mapped' $(OUTPUT_DIR)/flagstat.txt | sed -E 's/.*\(([0-9]+\.[0-9]+)%.*\)/\1/') && \
	echo "$$MAPPED_PERCENT%" && \
		if echo "$$MAPPED_PERCENT < $(QUALITY_THRESHOLD)" | bc -l | grep -q 1; then \
				echo -e "\U0001F61D not OK... - Percentage of mapping is below the threshold: $$MAPPED_PERCENT%"; \
		else \
				echo -e "\U0001F605 OK! - Percentage of mapping: $$MAPPED_PERCENT%"; \
		fi

call_variants: $(OUTPUT_DIR)/alignment.sorted.bam $(OUTPUT_DIR)/reference_genome.fna
	@echo -e "\nCalling of genetic variants..."
	$(SAMTOOLS) faidx $(REFERENCE)
	$(SAMTOOLS) index $(OUTPUT_DIR)/alignment.sorted.bam
	$(FREEBAYES) -f $(REFERENCE) $(OUTPUT_DIR)/alignment.sorted.bam > $(RESULTS_DIR)/result.vcf
	@echo -e "\nGenetic variants was preserved in $(RESULTS_DIR)/result.vcf"

final_result: quality_check call_variants
	@echo -e "\nGetting results..."
	@mv $(OUTPUT_DIR)/flagstat.txt $(RESULTS_DIR)/flagstat.txt
	@echo -e "\nResults was preserved in $(RESULTS_DIR)/"

clean:
	@echo "Cleaning (deleting outputs and results)..."
	@rm -rf $(OUTPUT_DIR) $(RESULTS_DIR)

visualize:
	@echo "Generating pipeline visualization..."
	@echo "digraph G {" > pipeline.dot
	@echo "  node [shape=box];" >> pipeline.dot
	@echo "  prepare [label=\"prepare\"];" >> pipeline.dot
	@echo "  quality_check [label=\"quality_check\"];" >> pipeline.dot
	@echo "  final_result [label=\"final_result\"];" >> pipeline.dot
	@echo "  clean [label=\"clean\"];" >> pipeline.dot
	@echo "  prepare -> quality_check;" >> pipeline.dot
	@echo "  quality_check -> final_result;" >> pipeline.dot
	@echo "  final_result -> clean;" >> pipeline.dot
	@echo "}" >> pipeline.dot
	@dot -Tpng pipeline.dot -o pipeline.png
	@echo "Pipeline visualization saved to pipeline.png"
