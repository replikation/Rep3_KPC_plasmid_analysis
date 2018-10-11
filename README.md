# Rep3_KPC_plasmid_analysis

* this includes a step by step overview for the scripts used
* each script tells you if a dependency/program is missing

# For a fresh run with new data:
* for a new analysis the following folder should be removed:
```bash
Annotation_blastn/ #annotations made with blastn are stored here
Annotation_Prokka/ #annotations made with prokka are stored here
plasmid_bining/ #blastn based binning ist stored here
plasmid_files_fasta/ #all fasta files, downloaded via accessionnumbers are stored here
plasmid_files_gb/ #like fasta files but genebank files
plasmids_binning_results/ #One plasmid representative from each plasmidgroup is stored here
KPC_fusion_plasmids/ #plasmids with more than one inc or KPC gene are stored here
```
* basically `rm -r Annotation_*/` and `rm -r *plasmid*/`
* create a new accession list under `Accessionlists/` (see below)
  * (optional) add new dates to `Additional_collection_dates/` (see below)

# Workflow step by step

* all steps are seperatly saved as scripts and numbered, so you can redo certain steps if you are not happy about the results

## (Manual) Getting KPC accession numbers: Blastn at NCBI with KPC-2

blastn Options:
* bacteria (taxid:2)
* nucleotide collection
* max target sequences 20000
* Expected threshold 10E-70

Query sequence i used is KPC-2 (most common one), e-value will consider variations of it:
```
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
```

* yields around 681 subject sequences (09.10.2018)
* download the list of accessionnumbers (use the Hittable as .txt) and save it to `Accessionlists/Accessionlist_KPC_nt_archive_all.txt`

## bash kpc_1_cleanup.sh
* takes a while...
* makes a clean accession list and downloads all the corresponding .fasta and .gb files
* if a download error occures (happens sometimes with efetch), redo the script after it finishes, it skips already downloaded files and re-downloads missing files only
* skript includes `sleep(1)`, seems to reduce efetch errors
* you can execute it 2 times to be save, or check the command line output

## bash kpc_2_remove_genomes.sh
* this scriptes uses the genbankfiles to remove kpc files (.fasta & .gb) that are located on a chromosome
* also .fasta files (incl. .gb) with less than 5000 bp will be removed

## bash kpc_3_annotations.sh
* does a quick prokka annotation for all .fasta files
* does a homemade blastn annotation for transposon, inc groups and beta-lactamases
* details about the database can be found in the manuscript
* database for the blast annotation is located under `db_bioprj_313047/`

## bash kpc_4_removal_of_fusionplasmids.sh
* fusionplasmids who a part of 2 groups would bias the results and are seperated in this step
* fusion plasmids usually contain more than on Incgroup and more than one KPC gene
* Therefore: files with 2 inc_groups and/or 2 blaKPCs are moved to `KPC_fusion_plasmids/`
  * includes .gb, .fasta and all annotation files

## bash kpc_5_blast_binning.sh
* does a blast based plasmid binning
* moves also largest plasmid of each bin to a seperate folder called `plasmids_binning_results/`

## bash kpc_6_Tn4401_check.sh
* blasts a Tn4401 reference sequence against the representative plasmid group members
* script checks the blast output to see if its a full Tn4401 or fragmented one is present
* everything (Tn template and results) is stored under `Additional_Tn4401_information/`

# Data visualizazion
## kpc_7_data_collection_for_R.sh
* gets all available organism and checks which plasmid group which organism includes
* does the same with beta-lactamases and Inc-groups
* creates a file under `R_data/genetable.csv` for R visualization
* the R script is located in `R_data/gene_features.R`
* also creates a few summary .csv files under `R_data/`

### Gathering the first "year" description
* scripts gets collection date from genbank if present
* if not it check the manually created file under `Additional_collection_dates/years.csv`
  * you can create this textfile on your own (without header) and each line represents a accessionnumber and corresponding date which should be written as follows: `accessionnumber;year`
* if the accessionnumber is also not present in `years.csv` it takes the upload date from the genebankfile
