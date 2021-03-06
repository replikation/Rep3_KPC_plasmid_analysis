#!/bin/bash
#!/usr/bin/bash
RED='\033[0;31m'
NC='\033[0m'
GRE='\033[0;32m'
CPU=$(lscpu -p | egrep -v '^#' | wc -l)

#dependency check
type blastn >/dev/null 2>&1 || { echo -e >&2 "${RED}  blastn not found. Aborting.${NC}"; exit 1; }
    echo "  blastn identified"

move_to_folder()
{
rm -r plasmid_bining
mkdir -p "plasmid_bining"
mkdir -p plasmid_bining/Plasmid_type_1
cp plasmid_files_fasta/*.fasta plasmid_bining/Plasmid_type_1
}

bining()
{
mkdir -p plasmid_bining/tmp_blast
plasmid_list="$(ls plasmid_bining/Plasmid_type_1 | wc -l)"

for ((i=1;i<=$plasmid_list;i++)); do
	cat plasmid_bining/Plasmid_type_$i/*.fasta > plasmid_bining/all.fasta
	makeblastdb -in plasmid_bining/all.fasta -dbtype nucl -parse_seqids -out tmp_blast/plasmid_db -title plasmid_db > /dev/null
	binadd1=$(($i+1)) #need one Plasmid_type above i to move files there
    	mkdir -p plasmid_bining/Plasmid_type_$binadd1
# biggest plasmid is the query for blast against all other plasmids (stored in variable "query_blast")
    	query_blast=$(ls -S plasmid_bining/Plasmid_type_$i | head -n 1)
    	if [ "$query_blast" = "" ]; then break; fi #if folder empty then break
# Starting the blast against the database
    	echo -e "${RED}Plasmid_type $i using for blast the subject [$query_blast]  ${NC}"
    	blastn -query plasmid_bining/Plasmid_type_$i/$query_blast -db tmp_blast/plasmid_db -out plasmid_bining/plasmid_comparision_$i.blast -outfmt "6 qseqid sseqid qstart qend slen sstart send  score" -num_threads $CPU -evalue 10E-100
# checking which blast hit to keep (needs to cover atleast 10% of the subject in database)
    	while IFS=$'\t' read f1 f2 f3 f4 f5 f6 f7 f8;
        do
        	coverage=$(($f4-$f3)) #how long is hit against the subject in DB
        	coverper=$((100*$coverage/$f5)) #coverage (%) of that hit against subject length (smaller plasmid)
        	touch plasmid_bining/Plasmid_type_$i/$f2.tmp
        	echo "0" >> plasmid_bining/Plasmid_type_$i/$f2.tmp # so that i can track plasmids with no coverage
        	if (($coverper>10)); then #HERE YOU CAN CHANGE THE 10% HIT COVERAGE
        	echo "$coverper" >> plasmid_bining/Plasmid_type_$i/$f2.tmp
        	fi
    	done < "plasmid_bining/plasmid_comparision_$i.blast"

    	for x in plasmid_bining/Plasmid_type_$i/*.tmp; do
        	value=$(paste -s -d+ $x | bc)
        	if (($value>80)); then #HERE YOU CAN CHANGE THE TOTAL COVERAGE OF 80%
            		y=${x/"plasmid_bining/Plasmid_type_$i/"}
            		echo -e "${GRE}Keeping ${y%.tmp} with $value ${NC}"
            		mv ${x%.tmp}.fasta ${x%.tmp}.control
        	else
            		y=${x/"plasmid_bining/Plasmid_type_$i/"}
            		echo -e "  transfering ${y%.tmp} to Plasmid_type_$binadd1 with $value"
        	fi
    	done
    	for x in plasmid_bining/Plasmid_type_$i/*.tmp; do rm $x; done
    	mv plasmid_bining/Plasmid_type_$i/*.fasta plasmid_bining/Plasmid_type_$binadd1/ 2> /dev/null
    	query_blast2=$(ls -S plasmid_bining/Plasmid_type_$binadd1 | head -n 1)
    	if [ "$query_blast2" = "" ]; then break; fi
done

#renaming all controls files (files that stay in a bin)
#removing temporary files
for x in plasmid_bining/*/*.control; do mv $x ${x%.control}.fasta; done
find . -type d -empty -delete #removes the last empty bin folder
for x in plasmid_bining/*.blast; do rm $x; done
rm -r tmp_blast/
rm plasmid_bining/all.fasta
}


big_plasmids_seperate()
{
#takes biggest plasmid in each bin and puts it to a results folder
rm -r plasmids_binning_results/
mkdir -p plasmids_binning_results/
for x in plasmid_bining/* ; do
echo "Processing folder $x"
name=$(ls -S $x | head -1 )
type=$(echo "$x" | cut -f2 -d "/" | cut -f3 -d "_")
cp $x/$name plasmids_binning_results/${name%.fasta}_type_$type.fasta
done
}

### Start of script ###
###The three steps for binning###
move_to_folder
bining
big_plasmids_seperate
################################
