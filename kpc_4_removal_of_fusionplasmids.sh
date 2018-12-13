#!/bin/bash
#!/usr/bin/bash

mkdir -p KPC_fusion_plasmids/
for x in Annotation_blastn/*.gff; do
	amount_of_KPCs=$(grep -c "blaKPC" $x )
	amount_of_Incs=$(grep -c "Inc" $x)
	y=$(echo "$x" | cut -f2 -d"/")
	if (($amount_of_KPCs > 1)); then
		echo "found $amount_of_KPCs KPC genes in ${y%.gff}"
		mv plasmid_files_fasta/${y%_resistance_genes.gff}.fasta KPC_fusion_plasmids/ 2>/dev/null
		mv plasmid_files_gb/${y%_resistance_genes.gff}.gb KPC_fusion_plasmids/ 2>/dev/null
		mv Annotation_blastn/${y%_resistance_genes.gff}* KPC_fusion_plasmids/ 2>/dev/null
		mv Annotation_Prokka/${y%_resistance_genes.gff}* KPC_fusion_plasmids/ 2>/dev/null
	else
		if (($amount_of_Incs > 1)); then
		echo "found $amount_of_Incs Inc groups in ${y%.gff}"
                mv plasmid_files_fasta/${y%_resistance_genes.gff}* KPC_fusion_plasmids/ 2>/dev/null
		mv plasmid_files_gb/${y%_resistance_genes.gff}* KPC_fusion_plasmids/ 2>/dev/null
                mv Annotation_blastn/${y%_resistance_genes.gff}* KPC_fusion_plasmids/ 2>/dev/null
                mv Annotation_Prokka/${y%_resistance_genes.gff}* KPC_fusion_plasmids/ 2>/dev/null
		fi
	fi
done
