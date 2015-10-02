#!/bin/bash
# specify BASH shell
#$ -S /bin/bash
# pass environment variables to job, e.g. LD_LIBRARY_PATH
#$ -v LD_LIBRARY_PATH
# run job in the current working directory where qsub is executed from
#$ -cwd
#  specify that the job requires 16GB of memory
#$ -l m_mem_free=16G

# run commands and application
pwd
date
./run_bnb_consolidate.sh /opt/hpc/pkg/MATLAB/R2013a "data_out" "reg_results"
date
