########################################
##_________year_file__________________##
########################################
echo "Creating a year list first for each plasmidgroup first"
for z in plasmid_bining/*/year.tmp ; do rm $z ; done

for x in plasmid_bining/* ; do
acclist=$(ls $x)
touch $x/year.tmp
    while IFS= read -r accession ; do
    	if
		grep -q '/collection_date="' plasmid_files_gb/${accession%.fasta}.gb
        then
        	grep '/collection_date="' plasmid_files_gb/${accession%.fasta}.gb | cut -f 2 -d '"' | grep -Eo [0-9]{4} >> $x/year.tmp
        else
            if grep -q "${accession%.fasta}" Additional_collection_dates/years.csv
            then
            grep "${accession%.fasta}" Additional_collection_dates/years.csv | cut -f2 -d";" >> $x/year.tmp
            else
            head -1 plasmid_files_gb/${accession%.fasta}.gb | rev | cut -f1 -d "-" | rev >> $x/year.tmp
            fi
        fi
    done < <(printf '%s\n' "$acclist")
done
echo "done"
########################################
## getting data into genetable.csv #####
########################################
mkdir -p R_data
printf "gene;sample;mutated;label;year\n">R_data/genetable.csv
for x in plasmids_binning_results/* ; do
	getname=$(basename -s .fasta "$x" | cut -f1 -d "_")
	gettype=$(basename -s .fasta "$x" | cut -f3 -d "_")
	getyear=$(cat plasmid_bining/Plasmid_type_$gettype/year.tmp | sort | head -1)
	echo "Analysing $getname of plasmidtype $gettype first detected in $getyear"
	########################################
	##_________BETA_LACTAMASES____________##
	########################################
	list_BLAs=$(cat Annotation_blastn/*.gff | cut -f3 | sort | uniq | grep "bla" | grep -v "KPC")
	while IFS= read -r bLa; do
		if grep -wq "${bLa}" Annotation_blastn/${getname}_resistance_genes.gff; then var=1; else var=0; fi
		printf "${bLa#bla};$gettype;${var};β-lactamases;$getyear\n">>R_data/genetable.csv
	done < <(printf '%s\n' "$list_BLAs")
	########################################
	##_________Plasmid_features___________##
	########################################
# these are normal greps from prokka, should include the gb data also, somehow

	########################################
	##_________Incgroups__________________##
	########################################
        list_INCs=$(cat Annotation_blastn/*.gff | cut -f3 | cut -f1 -d"(" | sort | uniq | grep "Inc")
        while IFS= read -r INC; do
                if grep -wq "${INC}" Annotation_blastn/${getname}_resistance_genes.gff; then var=3; else var=0; fi
                printf "${INC};$gettype;${var};Inc-group;$getyear\n">>R_data/genetable.csv
        done < <(printf '%s\n' "${list_INCs}")
	########################################
	##_________organisms__________________##
	########################################
        list_ORG=$(grep ">" plasmid_bining/Plasmid_type_*/*.fasta | cut -f2 -d">" | cut -f2 -d" " | sort | uniq)
	bin_input=$(head -1 plasmid_bining/Plasmid_type_$gettype/*.fasta)
  	while IFS= read -r ORG; do
                if grep -wq "${ORG}" <<< $bin_input; then var=4; else var=0; fi
                printf "${ORG};$gettype;${var};Organism;$getyear\n">>R_data/genetable.csv
        done < <(printf '%s\n' "${list_ORG}")
########################################
##_________Tn4401_____________________##
########################################
##Tn4401 informations are still missing

########################################
##_________summary_4_paper____________##
########################################

# creating percentages and stuff for an excel file


done
