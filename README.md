# meta-bam

This bash script produces a "meta-bam" file by :
- sampling list of reads randomly selected in a group of paired-end fastq(gz) file.
- aligning those reads to a reference genome using STAR aligner.

## Dependencies

This script requires :
- **[reformat.sh](https://github.com/BioInfoTools/BBMap)** Part of BBMap, for random sampling of reads
- **[STAR](https://github.com/alexdobin/STAR)** Version 2.7.0f was tested, but all versions should work

Both dependencies can be downloaded as so, or directly installed on a conda environment, using :
```
conda install -c bioconda star
conda install -c bioconda bbmap
```

## Preparation

STAR needs an indexed genome. To create your index, follow the steps in part 2 of the STAR manual (http://labshare.cshl.edu/shares/gingeraslab/www-data/dobin/STAR/STAR.posix/doc/STARmanual.pdf)

## How to Run it ?

Once all dependencies are installed (or your conda environment activated), run the script as follows:
```
./meta-bam.sh [fastQList] [NbTotalReads] [referenceGenome]
```

The parameters are :
- [fastQList] = A text file containing the paths to every paired-end fastq.gz to sample from
- [NbTotalReads] = An integer: millions of reads to keep in the final BAM file (input 5 means 5'000'000)
- [referenceGenome] = Path to the reference genome index for STAR alignment

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

An example of a typical fastQList file is provided in exampleFastqFile.txt.
Note that the path to the actual fastq.gz files can be either relative or absolute, as long as the file name ends with 1.fastq.gz or 2.fastq.gz, and the rest of the name matches between paired files.

## Processing time

Runtime depends on the size of your input dataset (both individual size file and number of files) and sampling depth. 

The random sampling needs to open and read each file entirely, so this step is usually the limiting one.

Example runtimes: 
- 50M reads from 108 paired-end libraries of mean size 2Gb/file (gzipped) :
Sampling : 5 hours
Alignment : 15 minutes

- 50M reads from 369 paired-end libraries of mean size 2Gb/file (gzipped) :
Sampling : 15 hours
Alignment : 17 minutes

*_ Sampling time for one file ranges from 4 minutes (2Gb fastq.gz) to 6 minutes (10Gb fastq.gz), with 1 million reads sampled._*
