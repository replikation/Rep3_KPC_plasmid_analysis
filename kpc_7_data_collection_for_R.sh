########################################
##_________year_file__________________##
########################################
echo "Creating a year list first for each plasmidgroup first"
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
	# these are costum made, depending on what you are looking for
	# So you need to check what the grep will give you as a result to avoid false positive hits
	prokres=$(cat Annotation_Prokka/${getname}_results/*.tsv | cut -f4)
	toxsearch=$(cat Annotation_Prokka/${getname}_results/*.tsv)
	#umuD/C error prone DNA poly
	if grep -q "umu" <<< $prokres ; then umu=2; else umu=0; fi
	printf "umuC/D;$gettype;$umu;features;$getyear\n">>R_data/genetable.csv
	#daugther cell distro parA/B/M and stbA/B/C (highly similar sequence wise) stbA is synonym for parM 
	#searches for stb if par not found
	if grep -q "par" <<< $prokres ; then par=2; else par=0; fi
	if [[ "$par" == "0" ]]; then if grep -q "stb" <<< $prokres ; then par=2; fi ; fi
	printf "Plasmid-segregation;$gettype;$par;features;$getyear\n">>R_data/genetable.csv
	#toxin antitoxing
	if grep -q "Antitoxin" <<< $toxsearch ; then tox=2; else tox=0; fi
	printf "Toxin-antitoxin;$gettype;$tox;features;$getyear\n">>R_data/genetable.csv
	#SOS inhib prot psi
	if grep -q "psi" <<< $prokres ; then psi=2; else psi=0; fi
	printf "psiA/B;$gettype;$psi;features;$getyear\n">>R_data/genetable.csv
	#Mercury resistance
	if grep -q "Mercuri" <<< $toxsearch ; then Mercuri=2; else Mercuri=0; fi
	printf "Mercuric Res.;$gettype;$Mercuri;features;$getyear\n">>R_data/genetable.csv
	#Copper resistance
	if grep -q "Copper resistance" <<< $toxsearch ; then Copper=2; else Copper=0; fi
	printf "Copper Res.;$gettype;$Copper;features;$getyear\n">>R_data/genetable.csv
	#Arsenic resistance
	if grep -q "Arsenic" <<< $toxsearch ; then Arsenic=2; else Arsenic=0; fi
	printf "Arsenic Res.;$gettype;$Arsenic;features;$getyear\n">>R_data/genetable.csv
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
	# Its using all the fasta information, not just the representatives
        list_ORG=$(grep ">" plasmid_bining/Plasmid_type_*/*.fasta | cut -f2 -d">" | cut -f2 -d" " | sort | uniq)
	bin_input=$(head -1 plasmid_bining/Plasmid_type_$gettype/*.fasta)
  	while IFS= read -r ORG; do
                if grep -wq "${ORG}" <<< $bin_input; then var=4; else var=0; fi
                printf "${ORG};$gettype;${var};Organism;$getyear\n">>R_data/genetable.csv
        done < <(printf '%s\n' "${list_ORG}")
	########################################
	##_________Transposon_________________##
	########################################
	#Is a resolvase present for transposition?
	if grep -qi "resolvase" <<< $toxsearch ; then resolvase=5; else resolvase=0; fi
	if [[ "$resolvase" == "0" ]]; then if grep -q "tnpR" <<< $toxsearch ; then resolvase=5; fi ; fi
	if [[ "$resolvase" == "0" ]]; then if grep -qi -i 'product="resolvase' plasmid_files_gb/$getname*.gb; then resolvase=5; fi ; fi
	if [[ "$resolvase" == "0" ]]; then if grep -qi -i 'product="tnpR' plasmid_files_gb/$getname*.gb; then resolvase=5; fi ; fi
	if [[ "$resolvase" == "0" ]]; then if grep -q "resolvase" Annotation_blastn/$getname*.gff; then resolvase=5; fi ; fi
	printf "Resolvase found;$gettype;$resolvase;Transpos.;$getyear\n">>R_data/genetable.csv
	echo "Getting Tn4401 informations..."
	getname2=$(echo "$getname" | cut -f1 -d ".") #removed versions like .1 or .2 to find files better
	transposontype=$(cat Additional_Tn4401_information/blast_results/${getname2}*.txt)
	if grep -q "Tn4401" <<< $transposontype ; then tn=5; else tn=0; fi
	printf "Tn4401;$gettype;$tn;Transpos.;$getyear\n">>R_data/genetable.csv
	if grep -q "fragmented" <<< $transposontype ; then tn=5; else tn=0; fi
        printf "Tn4401 fragmented;$gettype;$tn;Transpos.;$getyear\n">>R_data/genetable.csv
done
for z in plasmid_bining/*/year.tmp ; do rm $z ; done

########################################
##_________summary_4_paper____________##
########################################

# creating a summary file und R_data/summary.csv
echo "Creating statistics table under R_data/summary.csv"
listofgenes=$(cat R_data/genetable.csv | tail -n +2 | cut -f1 -d";" | sort | uniq)
printf "name,hits,total,percent\n"> R_data/summary.csv
total=$(cat R_data/genetable.csv | cut -f2 -d";" | sort | uniq | wc -l)
while IFS= read -r z || [[ -n "$z" ]]; do
    hits=$(cat R_data/genetable.csv | cut -f3,1 -d";" | grep -w "$z" | grep -wv "0" | wc -l)
    #total_per_cat=(cat R_data/genetable.csv | grep -w "$z" | cut -f3,4 -d";" |  grep -wv "0" | wc -l)
    percent=$(echo "scale=2; 100*$hits/$total" | bc -l)
printf "$z,$hits,$total,$percent\n">> R_data/summary.csv
done < <(printf '%s\n' "$listofgenes")


printf "group,amount,basepair_median\n"> R_data/summary_plasmids.csv
for x in plasmid_bining/*; do
	type=$(echo "$x" | cut -f2 -d"/")
	amount=$(ls $x | wc -l)
	bp="0"
	for y in $x/*.fasta; do
		get_bp=$(tail -n+2 $y | wc -m)
		bp=$(($bp + $get_bp))
	done
	basepair_median=$(echo "scale=2; $bp/$amount" | bc -l)
printf "${type},${amount},${basepair_median}\n">> R_data/summary_plasmids.csv
done
