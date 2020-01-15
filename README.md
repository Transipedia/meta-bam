# meta-bam

This bash script produces a "meta-bam" file by :
- sampling list of reads randomly selected in a group of paired-end fastq(gz) file.
- aligning those reads to a reference genome using STAR aligner.

## Dependencies

This script requires :
- **[reformat.sh](https://github.com/BioInfoTools/BBMap)** Included in BBMap, it allows the random sampling of reads
- **[STAR](https://github.com/alexdobin/STAR)** Version 2.7.0f was tested, but all version should work

Both requirements can be downloaded as so, or directly installed on a conda environment, using :
```
conda install -c bioconda star
conda install -c bioconda bbmap
```

## Preparation

To properly align, STAR first needs an indexed genome. To create your index, follow the steps in part 2 of STAR manual (http://labshare.cshl.edu/shares/gingeraslab/www-data/dobin/STAR/STAR.posix/doc/STARmanual.pdf)

## How to Run it ?

Once all the dependencies are installed (or your conda environment activated) you can run the script.
```
./meta-bam.sh [fastQList] [NbTotalReads] [referenceGenome]
```

The parameters are :
- [fastQList] = A file containing the path to every paired-end fastq.gz to sample from
- [NbTotalReads] = An integer, total number of million reads to keep in the final BAM file (input 5 means 5'000'000)
- [referenceGenome] = Path to reference genome index for STAR alignment

Example :
```
./meta-bam.sh listFastQgz.txt 50 data/indexStar
```

## Final folder hierarchy

Every result can be found in the meta-bam-out folder :
```
├── meta-bam
│   ├── meta-bam.sh
│   ├── README.md
│   ├── listFastQgz.txt
│   ├── data
│   │   ├── indexStar
│   │   │   ├── SA
│   │   │   ├── SAindex
│   │   │   ├── {several other index files}
│   ├── meta-bam-out
│   │   ├── sample_R1.fq
│   │   ├── sample_R2.fq
│   │   ├── STARoutputLog.out
│   │   ├── STARoutputLog.progress.out
│   │   ├── STARoutputSJ.out.tab
│   │   ├── STARoutputLog.final.out
│   │   ├── STARoutputAligner.out.sam
```

An example of a typical fastq file is available as exampleFastqFile.txt on the github.
Note that the path to the actual fastq.gz files can be either relative or absolute, as long as the file name ends with 1.fastq.gz or 2.fastq.gz, and the rest of the name matches between paired files.

## Process time

Time needed to complete the jod widely depend on the size of your input dataset (both individual size file and number of files).
The random sampling needs to open and read each file entirely, so this part especially can be quite long.
The alignment depends on the time needed to load the reference, more than the number of reads.

As an example, running on 216 fastq.gz (108 paired-end samples), which had a size of 2G on average :
Sampling : 5 hours
Alignment : 15 minutes
For an other set, with 738 fastq.gz (369 paired-end samples), again with a size of 2G on average :
Sampling : 15 hours
Alignment : 17 minutes
