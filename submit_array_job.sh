#!/bin/bash

#SBATCH --job-name=array_job1           #Job name
#SBATCH --time=01:00:00                 #hours:minutes:seconds
#SBATCH --cpus-per-task=8               #CPU number must equal thread number of invoked commands
#SBATCH --mem=80G                       #Memory pool for all cores (see also --mem-per-cpu)
#SBATCH --partition=partition_name      #Partition name of your cluster
#SBATCH --output=array_job1-%A_\%a.out  #File to which STDOUT will be written
#SBATCH --error=array_job1-%A_\%a.err   #File to which STDERR will be written 
#SBATCH --array=1-6                     #range of array jobs, e.g. single-end read files 1-6 will be processed in 6 individual jobs

#source .bashrc to make sure your exported PATHs and other settings are invoked
source ~/.bashrc

#If your cluster uses vital-it (https://www.vital-it.ch/services/software), add and load required software here
#Make sure the path to the software is correct
module add vital-it UHTS/Aligner/bowtie2/2.3.4.1 UHTS/Analysis/samtools/1.8 UHTS/Analysis/rsem/1.3.0
module load UHTS/Aligner/bowtie2/2.3.4.1 UHTS/Analysis/samtools/1.8 UHTS/Analysis/rsem/1.3.0

start=`date +%s`

pwd; hostname; date

#Set the number of runs that each SLURM task should do
PER_TASK=1

echo "Hostname: $(eval hostname)"

if [ -z ${SLURM_NTASKS} ]; then THREADS=$( nproc ); else THREADS=${SLURM_NTASKS}; fi

if [ -z $1 ]; then echo "json path is unset"; exit 1; else echo "json setup file: '$1'"; fi

#Access input files specified in a .json file
#basepath is where the output directory will be created
#fastqs is the directory where the RNAseq read files are located in this example
#samples is a file which will provide the sample names for the variables below
basepath=$(eval jq .pipeline.basepath $1 | sed 's/^"\(.*\)"$/\1/')
fastqs=$(eval jq .project.fastqs $1 | sed 's/^"\(.*\)"$/\1/')
samples=$(eval jq .project.samples $1 | sed 's/^"\(.*\)"$/\1/')

#Create a variable with the name of your output directory, feel free to rename the output directory
array_job1_out="${basepath}array_job1_out"

#Create an output directory based on the variable above
echo $basepath
mkdir $array_job1_out
cd $array_job1_out
echo sample is $samples

declare -a sam=(`cat $samples`)

#Calculate the starting and ending values for this task based
#on the SLURM task and the number of runs per task.
START_NUM=$(( ($SLURM_ARRAY_TASK_ID - 1) * $PER_TASK + 1 ))
END_NUM=$(( $SLURM_ARRAY_TASK_ID * $PER_TASK ))

echo $STAR_NUM
echo $END_NUM
 
#Print the task and run range
echo This is task $SLURM_ARRAY_TASK_ID, which will do runs $START_NUM to $END_NUM
 
#Run the loop of runs for this task
for (( run=$START_NUM; run<=END_NUM; run++ )); do
  echo This is SLURM task $SLURM_ARRAY_TASK_ID, run number $run
  idx=$(($run - 1))
  echo This is idx $idx
  sam=$(sed "${SLURM_ARRAY_TASK_ID}q;d" $samples)
  echo Sample is $sam
  echo Sample in run is ${sam[$idx]}
  
#Enter the code that will be invoked for every array job here
#For example "rsem-calculate-expression" on 6 Arabidopsis thaliana RNAseq single-end read files
#From the .json file, fastq file paths and sample names are accessed

RSEM="rsem-calculate-expression --bowtie2 --num-threads 8 --no-bam-output \
${fastqs}/${sam[$idx]}.fastq.gz \
~/path/to/rsem-reference-file \
${sam}"


echo $RSEM
eval $RSEM
done
 
