#!/bin/bash

SE_PE=$1
fastQList=$2
nbTotalReads=$3
referenceGenome=$4

nbFastq=$(grep 'fastq.gz' $fastQList |wc -l)

mkdir -p meta-bam-out

### Sampling ###

if [[ "$SE_PE" == "-SE" ]]
  then
    nbReadsPerFastq=$(($nbTotalReads*1000000/$nbFastq))
    rm -f meta-bam-out/sample.fq
    while read p; do
      if [[ "$p" == *fastq.gz ]]
        then
          fastQ=$p
          seed=$RANDOM
          reformat.sh in=$fastQ out1=meta-bam-out/sample.fq sampleseed=$seed samplereadstarget=$nbReadsPerFastq app=t
      fi
    done<$fastQList


elif [[ "$SE_PE" == "-PE" ]]
  then
    nbReadsPerFastq=$(($nbTotalReads*1000000*2/$nbFastq))
    rm -f meta-bam-out/sample_R1.fq
    rm -f meta-bam-out/sample_R2.fq
    while read -r p1 && read -r p2; do
      order=$(diff <(fold -w1 <<< "$p1") <(fold -w1 <<< "$p2") | awk '/[<>]/{printf $2}')
      if [[ "$order" == "12" ]]
        then
          fastQR1=$p1
          fastQR2=$p2
      elif [[ "$order" == "21" ]]
        then
          fastQR1=$p2
          fastQR2=$p1
      else
        echo "Error : The fastQList file might be mixed up. Each pair should be side by side in the list."
        break
      fi
      seed=$RANDOM
      reformat.sh in1=$fastQR1 in2=$fastQR2 out1=meta-bam-out/sample_R1.fq out2=meta-bam-out/sample_R2.fq sampleseed=$seed samplereadstarget=$nbReadsPerFastq app=t
    done<$fastQList


else
    echo "Error : First argument should be either -SE or -PE"
fi


### STAR Alignment ###

if [[ "$SE_PE" == "-SE" ]]
  then
    STAR --genomeDir $referenceGenome \
    --runThreadN 2 \
    --readFilesIn meta-bam-out/sample.fq \
    --outFileNamePrefix meta-bam-out/STARoutput

elif [[ "$SE_PE" == "-PE" ]]
  then
    STAR --genomeDir $referenceGenome \
    --runThreadN 2 \
    --readFilesIn meta-bam-out/sample_R1.fq meta-bam-out/sample_R2.fq \
    --outFileNamePrefix meta-bam-out/STARoutput

fi

echo "Alignment done : Files generated in meta-bam-out/"
