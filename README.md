# COG - Scripts for setting up NCBI's COG function database

When annotating a microbial metagenome or metatranscriptome, organism annotations are often not enough - sometimes, functional annotations are also desired.  One useful database for functional annotation of genomes is the Clusters of Orthologous Groups (COG), run by NCBI ([https://www.ncbi.nlm.nih.gov/COG/](https://www.ncbi.nlm.nih.gov/COG/)).  

These COG files can be downloaded directly from NCBI's FTP site ([ftp://ftp.ncbi.nlm.nih.gov/pub/COG/COG2014/data/](ftp://ftp.ncbi.nlm.nih.gov/pub/COG/COG2014/data/)), but they aren't immediately structured in a searchable form if using a high-speed aligner like DIAMOND.  This repo contains a few quick scripts to get a workable merged database file for use as a DIAMOND reference.

## Instructions

**Setting up the COG database for DIAMOND**

To convert the downloaded COG files from NCBI's FTP archive into a single FASTA-structured file that can be loaded into DIAMOND as a database, run the following command:

    python merger.py prot2003-2014.fa cog2003-2014.csv cognames2003-2014.tab
    
This will output a single file called "merged_cogs.fa", that contains all of the COG information in FASTA format:

```
>gi|103485499|ref|YP_615060.1| chromosomal replication initiation protein [Sphingopyxis alaskensis RB2256] | COG0593 | L
MSGDAAALWPRVAEGLRRDLGARTFDHWLKPVRFADYCALSGVVTLETASRFSANWINERFGDRLELAWRQQLPAVRSVS
VRGGVAATERAATLASVPLPTFDAPAAPAANPALLGFDPRLSFDRFVVARSNILAANAARRMAMVERPQFNPLYLCSGTG
QGKTHLLQAIAQDYAAAHPTATIILMSAEKFMLEFVGAMRGGDMMAFKARLRAADLLLLDDLQFVIGKNSTQEELLHTID
DLMTAGKRLVVTADRPPAMLDGVEARLLSRLSGGLVADIEAPEDDLRERIIRQRLAAMPMVEVPDDVIAWLVKHFTRNIR
ELEGALNKLLAYAALTGARIDLMLAEDRLAENVRSARPRITIDEIQRAVCAHYRLDRSDMSSKRRVRAVARPRQVAMYLA
KELTPRSYPEIGRRFGGRDHSTVIHAVRTVEALRVADSELDAEIAAIRRSLNS
>gi|103485500|ref|YP_615061.1| glutathione S-transferase-like protein [Sphingopyxis alaskensis RB2256] | COG0625 | O
MKLFIGNKAYSSWSLRGWLAARHSGLPFEEVTVPLYNEEWNQRREGDEFAPSGGKVPILWDGADIVVWDSLAIIDYLNEK
TGGTRGYWPDDMAARAMARSMAAEMHSSFAALRREHSMNIRRIYPAAELTPEVQADVIRILQIWAEARARFGGEGDYLFG
DWSAADMMFAPVVTRFITYSIPLPRFALPYAQAVISHPHMQEWIGGAQAEDWVIEKFEGPVEG
>gi|103485501|ref|YP_615062.1| ribosome biogenesis GTP-binding protein YsxC [Sphingopyxis alaskensis RB2256] | COG0218 | D
MSEIELEPGADPERAERARKLFSGPIAFLKSAPALQHLPVPSVPEIAFAGRSNVGKSSLLNALTNRNGLARTSVTPGRTQ
ELNYFDVGEPPVFRLVDMPGYGFAKAPKDVVRKWRFLINDYLRGRQVLKRTLVLIDSRHGIKDVDRDVLEMLDTAAVSYR
LVLTKADKIKASALADVHAATEAEARKHPAAHPEVIATSSEKGMGIAELRTAVLEAVEL
```

Note that, for each header line (indicated by a > symbol), this merged file now contains the COG ID and the COG category, separated by vertical lines ( | ) from the other entries.

This file can be converted to DIAMOND format easily:

    diamond makedb --in merged_cogs.fa -d COG_diamond.dmnd
    
*****

**Annotating sequences against this COG database**

Once this database is set up in DIAMOND (.dmnd) format, it can be searched against like any other:

    diamond blastx --db COG_diamond.dmnd -q test_file.fastq -a test.cogs

This produces a DIAMOND outfile that must be converted to a viewable format:

    diamond view --daa test.cogs.daa -o test.cogs -f tab

*****

**Analyzing the results of a DIAMOND search against the COG database**

After searching a set of FASTQ or FASTA sequences against the COG database using DIAMOND, it is possible to analyze these results, condensing down the receipt of all matches to get a summary of the most abundantly matched categories.

This can be accomplished using the included Python script, "DIAMOND_COG_analysis_counter.py":

    python DIAMOND_COG_analysis_counter.py -I test.cogs -O result.cogs -D merged_cogs.fa

This script produces an outfile, "result.cogs", which contains a summary of the abundance of each COG hit from the DIAMOND annotation step.  This output file contains 3 columns:

```
2.16863838445	2878	 COG3328  | X
1.42340441564	1889	 COG3335  | X
1.32846055309	1763	 COG3436  | X
1.02629794288	1362	 COG2801  | X
0.799487604551	1061	 COG3415  | X
0.785170672896	1042	 COG0366  | G
0.68344510587	907	 COG0480  | J
0.646522492653	858	 COG3385  | X
0.616381583905	818	 COG0488  | R
0.59000828875	783	 COG0085  | K
```

The first column is the percentage abundance for that particular COG.  The second column contains the number of raw hits for that particular COG.  The third column contains both the COG ID and the COG category, represented by one or more letters.

This file can be used for other analyses, including comparisons between different annotations or figure generation.  One example of figure generation is in the "COG_analysis.R" script included in this repo.

This script runs on the result.cogs outfile:

    Rscript COG_analysis.R -I result.cogs -O graph.pdf -T 20

The -O option designates the name of the created image, saved as a PDF vector file.  The -T option indicates the cutoff for how many top COG categories are included.  The default cutoff is at 20, but fewer or more levels may be included.

The result is a PDF containing a pie chart, along with a legend depicting the top COG categories.

![Pie chart](https://raw.githubusercontent.com/transcript/COG/master/Rplot.png)

A guide for each letter code can be found here: [http://www.sbg.bio.ic.ac.uk/~phunkee/html/old/COG_functions.html](http://www.sbg.bio.ic.ac.uk/~phunkee/html/old/COG_functions.html)





