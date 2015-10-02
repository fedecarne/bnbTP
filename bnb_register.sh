#!/bin/bash
# specify BASH shell
#$ -S /bin/bash
#$ -t 1-"30"
# pass environment variables to job, e.g. LD_LIBRARY_PATH
#$ -v LD_LIBRARY_PATH
# run job in the current working directory where qsub is executed from
#$ -cwd
#  specify that the job requires 16GB of memory
#$ -l m_mem_free="16"G

# run commands and application
pwd
date
./run_recursive_register.sh /opt/hpc/pkg/MATLAB/R2013a "data/zstack" "z2_830farrred_" ".tif" "1"  "data_out/out$SGE_TASK_ID" $SGE_TASK_ID
date
