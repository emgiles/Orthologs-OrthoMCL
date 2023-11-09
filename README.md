# RECOVERING ORTHOLOGS USING ORTHOMCL
This tutorial is based off that found [here](https://bioinformaticsworkbook.org/phylogenetics/00-finding-orthologs-uisng-orthoMCL.html#gsc.tab=0) with slight modifications. The proteins used for orthologous grouping were those resulting directly from the genome fuctional annotation predictions (.faa files). 

### DATA PREPRATION
Create working directory with the .faa sequence files. 

##### RENAME FILES
For convenience, rename all files with .fasta distinction and using the first four letters of the genus and first four letters of the species. For example, a file named Scurria_scurra_annotatedpeptides.faa should be renamed as Scurscur.fasta.

##### RENAME HEADERS IN THE .FASTA FILES
First, look at your headers. Here we will look at the first line of all of the files.

```head -n 1 *.fasta |grep "^>"```

Modify the headers to remove the annotation information. This can be done by creating a for loop. 

```nano modify_headers.sh```

This will open a new empty file called modify_headers.sh. Here we will write our for loop.

```#!/bin/bash```

```for fasta in *.fasta; do```

```cut -f 1 -d " " $fasta > ${fasta%.*}.temp;```

```mv ${fasta%.*}.temp $fasta```

```done```

Save changes to the .sh and exit nano.

Make the new script executable.

```chmod +x modify_headers.sh```

Run the loop

```./modify_headers.sh```

I also changed the protein names to include a species identifier. An example is given below. This was done individually for each species, but a loop could also be generated.

```sed -e 's/>XP/>HU/g' Halirufe.fasta >Halirufe.fasta```

If file is generated with 0 content, create an intermediate file and then rename back to 8 letter.fasta distinction.

### RUN ORTHOMCL VIA SINGULARITY
So that we don't have to manually install OrthoMCL we can run it via Singularity. If you are not familiar with Singularity, there is a bit of a steep learning curve. Try to understand each command before executing. Make sure that Singularity is installed on your cluster.

##### CREATE AN ORTHOMCL CONTAINER ON YOUR CLUSTER

```singularity pull --name orthomcl.simg shub://ISU-HPC/orthomcl```

This will create a .simg file in your working directory.

##### CLEAN AND FILTER SEQUENCES
We will make a new working directory called complaintFasta. The files will be adjusted to the program needs based on the 8 letter prefix of each file and field (1) that is used as the sequence identifier.

```mkdir -p original complaintFasta```

```mv *.fasta original/```

```singularity shell orthomcl.simg```

```cd complaintFasta```

```for fasta in .../original/*.fasta; do```

```orthomclAdjustFasta $(basename ${fasta%.*}) ${fasta} 1```

```done```

We will now filter the sequences. Where 10 is the minimum length for a protein to keep and 20 is the maximum allowed stop codons in the sequences. This command will create two files, goodProteins.fasta containing all of the proteins that passed filtering and poorProteins.fasta which contains the rejected proteins.

```cd ../```

```orthomclFilterFasta complaintFasta 10 20```

Now exit the singularity image shell

```exit```

Use grep to check how many proteins were left in the file goodProteins and how many were moved to poorProteins. You can also rerun the above my decreaseing the number of maximum allowed stop codons. I have tried stop codons allowed = 3

### BLAST PROTEINS

Here we will run an all-by-all blast of the proteins that passed the quality filter. Blast must be previously installed. Easy to install via conda.

First, make the blast database.

```makeblastdb -in goodProteins.fasta -dbtype prot -parse_seqids -out goodProteins.fasta```

Second, blast the proteins.

```blastp -db goodProteins.fasta -query goodProteins.fasta -outfmt 6 -out blastresults.tsv -num_threads 30```

Connect to singularity contain again to reformat the results using orthomcl.

```singularity shell orthomcl.simg```

```orthomclBlastParser blastresults.tsv ./complaintFasta/ >> similarSequences.txt```

This should have generated a similarSequence.txt.

### FIND ORTHOLOGS
Now we need to set up MySQL and link it to the orthomcl container. A config file must be generated to tell orthomcl how to access the mysql database. We will then set up the database for orthomcl and load the blast results.

##### CREATE ORTHOMCL CONFIG FILE
Use the following exactly as written

```cat > orthomcl.config <<END```

```dbVendor=mysql```

```dbConnectString=dbi:mysql:orthomcl:mysql_local_infile=1:localhost:3306```

```dbLogin=root```

```dbPassword=my-secret-pw```

```similarSequencesTable=SimilarSequences```

```orthologTable=Ortholog```

```inParalogTable=InParalog```

```coOrthologTable=CoOrtholog```

```interTaxonMatchView=InterTaxonMatch```

```percentMatchCutoff=50```

```evalueExponentCutoff=-5```

```oracleIndexTblSpc=NONE```

```END```

##### RUN MySQL VIA SINGULARITY INSTANCE

```singularity pull --name mysql.simg shub://ISU-HPC/mysql```

If you had previously started an instance called mysql you can stop it and restart. Stop instance:

``` singularity instance stop mysql```

##### BIND-MOUNT MySQL DIRECTORIES TO ORTHOMCL CONTAINER AND STORE ON WD

Make sure that you are using the orthomcl working directory and are not located in a subdirectory.

```mkdir -p ${PWD}/mysql/var/lib/mysql ${PWD}/mysql/run/mysqld```

Check to make sure that no other singularity instances are running because this can cause issues with the database creation.

```singularity instance list```

Set up the singularity instance for the MySQL server

```singularity instance start --bind ${HOME} --bind ${PWD}/mysql/var/lib/mysql/:/var/lib/mysql --bind ${PWD}/mysql/run/mysqld:/run/mysqld ./mysql.simg mysql```

This will create and instance called mysql. You can double check that it exists:

```singularity instance list```

If you get an error or the instance is not created. Check for errors in spacing in the command above. Also make sure that you created the instance in the correct WD.

Initialize and run the MySQL server. If you have not previously closed the mysql instance you do not need to repead this step. Doing so will generate an error message loop that continues for awhile until finally shutting down.

```singularity run instance://mysql```

##### MAKE THE DATABASE AND TABLES FOR OrthoMCL

```singularity exec instance://mysql mysqladmin create orthomcl```

Make sure that you are in the working directory and then we will use the orthomcl container to install the schema for the database and create the tables

```singularity shell --bind $PWD --bind ${PWD}/mysql/run/mysqld:/run/mysqld orthomcl.simg```

Install the schema

```orthomclInstallSchema orthomcl.config```

Load the parsed blast results

```orthomclLoadBlast orthomcl.config similarSequences.txt```

#### DETERMINE ORTHOLOGOUS RELATIONSHIPS AND CLUSTERING 
Call the pairs

```orthomclPairs orthomcl.config pairs.log cleanup=no```

If an error results due to duplicated sequences you must remove the database orthomcl and create it again. Duplication can occur if the sequences were loaded twice into the database. Here is how to remove the database:

```singularity exec instance://mysql mysqladmin drop orthomcl```

Again, dropping the database is only necessary if pairs could not be created due to duplicates. If no error was generated, continue to the below.

Retrieve the results

```orthomclDumpPairsFiles orthomcl.config```

If this step results in an error or empty files the pairs subdirectory must be deleted before rerunning. The output of this call will be the directory pairs and the file mclinput. The pairs directory includes orthologs.txt, coorthologs.txt, inparalogs.txt. See the original tutorial from Bioinformatics Workbook for more info. 

Stop the mysql instance

```singularity instance stop mysql```

Cluster orthologs with MCL found within the orthomcl shell.

If you exited singularity, reconnect:

```singularity shell --bind $PWD --bind ${PWD}/mysql/run/mysqld:/run/mysqld orthomcl.simg```

Run MCL, --abc is the input format, -I is the inflation value, -o is the output.

```mcl mclInput --abc -I 1.5 -o groups_1.5.txt```

Rename the groups with the ortholog group prefix OG1.5_

```orthomclMclToGroups OG1.5_ 1000 < groups_1.5.txt > named_groups_1.5.txt```

### POST-PROCESS RESULTS

First, download the following scripts from [here](https://github.com/ISUgenomics/common_scripts/tree/master), and place them in your working directory:

```CopyNumberGen.sh```

```ExtractSCOs.sh```

```ExtractSeq.sh```

Make scripts executable

```chmod +x my_script.sh```

Creating a frequency table named named_groups_1.5.txt This table will also be useful for making venn diagrams or upset plots of shared orthologous groups.

```CopyNumberGen.sh named_groups_1.5.txt > named_groups_1.5_freq.txt```

Select only 1:1 single copy orthologs (SOCs).

```ExtractSOCs.sh named_groups_1.5_freq.txt > socs_list_1.5.txt```

Count how many SOCs were recovered

```wc -l socs_list_1.5.txt```

We will now extract the fasta sequence for each SCO group and write them to a separate file based on group distinction. There should be the same number of files as the number of SOCs recovered.

Create a list of the SCO orthologous groups

```cut -f 1 socs_list_1.5.txt| grep -v "OG_name" | sed 's/$/:/' > socs.ids```

```grep -Fw -f socs.ids named_groups_1.5.txt > named_groups_1.5_socs.txt```

Extract the sequences. Must have previously installed and activated cdbtools.

```ExtractSeq.sh -o orthogroups named_groups_1.5_scos.txt goodProteins.fasta```

This will create a folder called orthogroups. There should be n files each containing y sequences where n is the number of SCOs recovered and y is the number of species compared. The sequences of each orthogroup can then be aligned individually and a tree can be generated individually. The best species tree can then be selected. This can be done in ASTRAL, BEAST, IQTREE.
