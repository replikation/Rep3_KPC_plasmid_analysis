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

echo "if errors occure during the download repeat the script (it skips downloaded files)"

#dependencies
type efetch >/dev/null 2>&1 || { echo -e >&2 "${RED}  efetch not found. Aborting.${NC}"; exit 1; }
    echo "  efetch identified"


#Start of script, cleaning up the default  Hittable txt results from blastn NCBI
tail -n+8 Accessionlists/Accessionlist_KPC_nt_archive_all.txt | cut -f2 > Accessionlists/Accessionlist_KPC_nt_archive_clean.txt

#Genbank download
echo -e "${GRE}Download genbank files ${NC}"
mkdir -p plasmid_files_gb
	while IFS= read -r acc; do
            echo "Processing Accessionnumber: $acc"
                if [ -f plasmid_files_gb/$acc.gb ]; then
                    echo "$acc.gb exists, skip to next one."
                else
                    efetch -db nuccore -id $acc -format gb > plasmid_files_gb/$acc.gb
                    echo "Wrote $acc to file"
                    sleep "1"
                fi
        done < Accessionlists/Accessionlist_KPC_nt_archive_clean.txt
#removes empty files that may occure via errors
find plasmid_files_gb -size  0 -print0 |xargs -0 rm --

#fasta file download
echo -e "${GRE}Downloading fasta files ${NC}"
mkdir -p plasmid_files_fasta
	while IFS= read -r acc; do
            echo "Processing Accessionnumber: $acc"
                if [ -f plasmid_files_fasta/$acc.fasta ]; then
                    echo "$acc.fasta exists, skip to next one."
                else
                    efetch -db nuccore -id $acc -format fasta > plasmid_files_fasta/$acc.fasta
                    echo "Wrote $acc to file"
                    sleep "1"
                fi
        done < Accessionlists/Accessionlist_KPC_nt_archive_clean.txt
#removes empty files that may occure via errors
find plasmid_files_fasta -size  0 -print0 |xargs -0 rm --
