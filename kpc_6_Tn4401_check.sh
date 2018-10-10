#!/bin/bash
#!/usr/bin/bash
RED='\033[0;31m'
NC='\033[0m'
GRE='\033[0;32m'
# Absolute path to this script, e.g. /home/user/bin/cb_test.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
SCRIPTPATH=$(dirname "$SCRIPT")
CPU=$(lscpu -p | egrep -v '^#' | wc -l)

mkdir -p Additional_Tn4401_information/Plasmid_Group_blast_database
mkdir -p Additional_Tn4401_information/blast_results
cat plasmids_binning_results/*.fasta > Additional_Tn4401_information/plasmid_group_member.fasta
#creates blast database for each plasmid representative from the plasmid groups
makeblastdb -in Additional_Tn4401_information/plasmid_group_member.fasta -dbtype nucl -parse_seqids -out Additional_Tn4401_information/Plasmid_Group_blast_database/plasmid_grp_db -title plasmid_grp_db > /dev/null
#blast comparison
blastn -query Additional_Tn4401_information/Tn4401.fasta -db Additional_Tn4401_information/Plasmid_Group_blast_database/plasmid_grp_db -out Additional_Tn4401_information/Plasmid_Group_blast_database/Tn4401.blast -outfmt "6 sseqid qlen length sstart send" -num_threads $CPU -evalue 10E-100

## checking if Transposon is complete
# LT216438.1
for x in plasmids_binning_results/*.fasta; do
	accnumb=$(echo "$x" | cut -f2 -d"/" | cut -f1 -d".")
	all_hits=$(grep "$accnumb" Additional_Tn4401_information/Plasmid_Group_blast_database/Tn4401.blast)
	hit_space=$(grep "$accnumb" Additional_Tn4401_information/Plasmid_Group_blast_database/Tn4401.blast |cut -f4,5 | sort -nr)
	fragments=$(echo "$all_hits" | wc -l)
	totallength="0"
	while IFS=$'\t' read acc qlen alignlen sstart send ; do
		totallength=$(($totallength + $alignlen))
	done < <(printf '%s\n' "$all_hits")
	diff="-"
	diff2="-"
#positive strand check for frag differences
 	if (($totallength > 9000)); then
		sstart_2="0"
		send_2=$(echo "$hit_space" | head -1 | cut -f1)
		diff="0"
        	while IFS=$'\t' read sstart send ; do
                	sstart_2=$sstart
			diff=$(($diff + $send_2 - $sstart_2))
			send_2=$send
        	done < <(printf '%s\n' "$hit_space")
#negative strand check for frag differences
		if (($diff > 100 )); then
		send_2="0"
                sstart_2=$(echo "$hit_space" | head -1 | cut -f2)
                diff2="0"
			while IFS=$'\t' read sstart send ; do
                        	send_2=$send
                        	diff2=$(($diff2 + $sstart_2 - $send_2))
                        	sstart_2=$sstart
                	done < <(printf '%s\n' "$hit_space")
			if (($diff2 > 100)); then lengthok="fragmented"; else lengthok="Tn4401"; fi
		else lengthok="Tn4401"; fi
	else lengthok="nothing"; fi
	echo "${accnumb}: total length ${totallength}bp; $fragments blast-hit(s), ${diff}bp or ${diff2}bp between these fragments" 
	echo "    Result: $lengthok"
	echo "$lengthok" > Additional_Tn4401_information/blast_results/$accnumb.txt
done

