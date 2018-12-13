#!/bin/bash
#!/usr/bin/bash
RED='\033[0;31m'
NC='\033[0m'
CPU=$(lscpu -p | egrep -v '^#' | wc -l)

#dependencies
type prokka >/dev/null 2>&1 || { echo -e >&2 "${RED}  prokka not found. Aborting.${NC}"; exit 1; }
    echo "  prokka identified"
type blastn >/dev/null 2>&1 || { echo -e >&2 "${RED}  blastn not found. Aborting.${NC}"; exit 1; }
    echo "  blastn identified"

########Prokka loop ########
prokka_loop()
{
echo "starting prokka for plasmids"
for x in plasmid_files_fasta/*.fasta; do
	prokka $x --outdir ${x%.fasta}_results --cpus 20 --force
done
mkdir -p Annotation_Prokka
mv plasmid_files_fasta/*_results/ Annotation_Prokka/
}
########Prokka end ########


######## blast annotation ########
blast()
{
mkdir -p Annotation_blastn
plasmidlist=$(ls plasmid_files_fasta/)
while IFS= read -r z || [[ -n "$z" ]]; do
    echo "  Blasting contig $z against resistance database"
    blastn -query plasmid_files_fasta/$z -db db_bioprj_313047/resistance_db -out Annotation_blastn/${z%.fasta}.blast -outfmt "6 qseqid length qstart qend sstrand stitle evalue mismatch" -num_threads $CPU -culling_limit 1 -evalue 10E-150
    done < <(printf '%s\n' "$plasmidlist")
}

gff_conversion()
{
#skripted csv to gff file
echo "  Creating annotation files for each contig..."
for u in Annotation_blastn/*.blast
    do
    echo "##gff-version	3" > ${u%.blast}_resistance_genes.gff
        while IFS=$'\t' read f1 f2 f3 f4 f5 f6 f7 f8; #reads first lines and gives each tab a value
            do
            echo "$f6" > f6.tmp
            genname=$(cat f6.tmp | awk -vRS="]" -vFS="[" '{print $2}' | grep "gene=")
            protname=$(cat f6.tmp | awk -vRS="]" -vFS="[" '{print $2}' | grep "protein=")
            protid=$(cat f6.tmp | awk -vRS="]" -vFS="[" '{print $2}' | grep "protein_id=")
            #if variable is empty
            if [ -z "${genname}" ]; then
            genname=$(echo "unknown_gene")
            fi
            if [ -z "${protname}" ]; then
            protname=$(echo "unknown_protein")
            fi
            if [ -z "${protid}" ]; then
            protid=$(echo "unknown_accession")
            fi
            if [ $f5 == "plus" ]; then
                pvalue=$(echo ".")
                else
                pvalue=$(echo "-")
                fi
            #create gff file
            echo -e "$f1\t.\t${genname//gene=}\t$f3\t$f4\t.\t$pvalue\t.\tname=${genname//gene=};description=${protname//protein=};accession=${protid//protein_id=};missmatches=$f8;evalue=$f7" >> ${u%.blast}_resistance_genes.gff
        done < "$u"
done
rm f6.tmp
}

######Start of Script#####
# add a "#" infront of a command if you want to skip the step

 prokka_loop
 blast
 gff_conversion
#########end##############
