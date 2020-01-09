#!/bin/bash

fastQList=$1
nbTotalReads=$2
referenceGenome=$3

nbFastq=$(grep 'fastq.gz' $fastQList |wc -l)
nbReadsPerFastq=$(($nbTotalReads*1000000*2/$nbFastq))
mkdir -p meta-bam-out
rm -f meta-bam-out/sample_R1.fq
rm -f meta-bam-out/sample_R2.fq
while read p; do
  if [[ "$p" == *1.fastq.gz ]]
    then
      fastQR1=$p
      fastQR2=$(echo $p | sed "s/1.fastq.gz/2.fastq.gz/")
      seed=$RANDOM
      reformat.sh in1=$fastQR1 in2=$fastQR2 out1=meta-bam-out/sample_R1.fq out2=meta-bam-out/sample_R2.fq sampleseed=$seed samplereadstarget=$nbReadsPerFastq app=t
  fi
done<$fastQList

STAR --genomeDir $referenceGenome \
--runThreadN 2 \
--readFilesIn meta-bam-out/sample_R1.fq meta-bam-out/sample_R2.fq \
--outFileNamePrefix meta-bam-out/STARoutput

echo "Alignment done : Files generated in meta-bam-out/"
