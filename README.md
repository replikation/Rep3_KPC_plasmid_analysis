# New Readme

# For a fresh run with new data
* for a new analysis the following folder should be removed:
Annotation_blastn, Annotation_Prokka, plasmid_bining, plasmid_files_fasta, plasmid_files_gb, 0plasmids_binning_results
* basically 'rm -r Annotation_*/' and 'rm -r plasmid*/'
* create a new accession list under Accessionlists/ (see below)
* add new dates to Additional_collection_dates/ (see below)

# Experimental
## (Manual) Getting KPC accession numbers: Blastn at NCBI with KPC-2

Options:
* bacteria (taxid:2)
* nucleotide collection
* max target sequences 20000
* Expected threshold 10E-70

Query sequence used

'''
>NC_019161.1:c15996-15115 Klebsiella pneumoniae strain CRE79 plasmid pKPC-NY79, complete sequence
ATGTCACTGTATCGCCGTCTAGTTCTGCTGTCTTGTCTCTCATGGCCGCTGGCTGGCTTTTCTGCCACCG
CGCTGACCAACCTCGTCGCGGAACCATTCGCTAAACTCGAACAGGACTTTGGCGGCTCCATCGGTGTGTA
CGCGATGGATACCGGCTCAGGCGCAACTGTAAGTTACCGCGCTGAGGAGCGCTTCCCACTGTGCAGCTCA
TTCAAGGGCTTTCTTGCTGCCGCTGTGCTGGCTCGCAGCCAGCAGCAGGCCGGCTTGCTGGACACACCCA
TCCGTTACGGCAAAAATGCGCTGGTTCCGTGGTCACCCATCTCGGAAAAATATCTGACAACAGGCATGAC
GGTGGCGGAGCTGTCCGCGGCCGCCGTGCAATACAGTGATAACGCCGCCGCCAATTTGTTGCTGAAGGAG
TTGGGCGGCCCGGCCGGGCTGACGGCCTTCATGCGCTCTATCGGCGATACCACGTTCCGTCTGGACCGCT
GGGAGCTGGAGCTGAACTCCGCCATCCCAGGCGATGCGCGCGATACCTCATCGCCGCGCGCCGTGACGGA
AAGCTTACAAAAACTGACACTGGGCTCTGCACTGGCTGCGCCGCAGCGGCAGCAGTTTGTTGATTGGCTA
AAGGGAAACACGACCGGCAACCACCGCATCCGCGCGGCGGTGCCGGCAGACTGGGCAGTCGGAGACAAAA
CCGGAACCTGCGGAGTGTATGGCACGGCAAATGACTATGCCGTCGTCTGGCCCACTGGGCGCGCACCTAT
TGTGTTGGCCGTCTACACCCGGGCGCCTAACAAGGATGACAAGCACAGCGAGGCCGTCATCGCCGCTGCG
GCTAGACTCGCGCTCGAGGGATTGGGCGTCAACGGGCAGTAA
'''

* yields around 681 subject sequences (09.10.2018)
* download the list of accessionnumbers (Hittable as .txt) save to Accessionlists/Accessionlist_KPC_nt_archive_all.txt

## execute kpc_1_cleanup.sh
* takes a while...
* makes a clean accession list and downloads all the corresponding .fasta and .gb files
* if a download error occures (happens sometimes with efetch), redo the script after it finishes, it skips over downloaded files and re-downloads only missing files
* skript has a build in sleep(1), seems to help to reduce efetch errors
* execute it 2 times to be save

## execute kpc_2_remove_genomes.sh
* this scriptes uses the genbankfiles to remove kpc files (fasta & gb) that are located on a chromosome
* also fasta files (incl. gb) with less than 5000 bp will be removed

## execute kpc_3_annotations.sh
* does a quick prokka annotation for all .fasta files
* does a homemade blastn annotation for transposon, inc groups and beta-lactamases
* details about the database can be found in the manuscript
* database for the blast annotation is located under db_bioprj_313047/

## execute kpc_4_removal_of_fusionplasmids.sh
* fusionplasmids who a part of 2 groups would bias the results and are seperated in this step
* fusion plasmids usually contain more than on Incgroup and more than one KPC gene
* Therefore: fasta files with 2 inc_groups and/or 2 blaKPCs are moved to fusion_plasmids/

## execute kpc_5_blast_binning.sh
* does a blast based plasmid kp_plasmid_binning
* moves also largest plasmid of each bin to a seperate folder called plasmids_binning_results/

# Data visualizazion
## kpc_6_data_collection_for_R.sh
* gets all available organism and checks which plasmid group it has
* does the same with beta-lactamases and Inc-groups

### Gathering the first "year" description
* gets collection date from genbank if  present
  * if not it check a manual created file under Additional_collection_dates/years.csv
  * you can create a csv with 'accnumber;year' per information per list
  * e.g. information from publications
  * if the accnumber is also not present there it takes the upload date from the genbankfile
