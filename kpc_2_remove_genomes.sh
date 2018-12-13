#!/bin/bash
#!/usr/bin/bash

#checking for plasmids
echo -e "Removing non plasmid entries"
for x in plasmid_files_gb/*.gb; do
	if grep -q -m1 "/plasmid=" $x ; then
	echo "		Keeping plasmid $x"
	else
		rm $x
		y=$(echo $x | cut -f2 -d"/")
		rm plasmid_files_fasta/${y%.gb}.fasta
	fi
done
#removing fasta and genbank files with less than 5000bp
echo "removing entries with not enough information (<5000bp)"
for x in plasmid_files_fasta/*.fasta; do
amount_bp=$(tail -n +2 $x | wc -m)
	if (($amount_bp<5000)); then ## change desired BASEPAIR_AMOUNT here
        echo "remove $x with ${amount_bp}bp"
	rm $x
	y=$(echo $x | cut -f2 -d"/")
	rm plasmid_files_gb/${y%.fasta}.gb
        fi
done
