#!/bin/bash


#SBATCH -p debug
#SBATCH -N 30
#SBATCH -t 00:10:00
#SBATCH -e mysparkjob_%j.err
#SBATCH -o mysparkjob_%j.out
#SBATCH --ccm
module unload spark/hist-server
module load spark
module unload python
module load python/2.7-anaconda
module load collectl
start-collectl.sh 
start-all.sh

####load multiple hdf5 files###
export PYTHONPATH=$PYTHONPATH:src/main/python/h5spark

#spark-submit --master $SPARKURL --executor-cores 20 --driver-memory 20G --executor-memory 80G  --conf spark.eventLog.enabled=true --conf spark.eventLog.dir=$SCRATCH/spark/spark_event_logs --py-files src/main/python/h5spark/read.py src/main/python/tests/multi-file-test.py  src/resources/hdf5/python-filelist-sample 1 10 

#spark-submit --master $SPARKURL --executor-cores 20 --driver-memory 20G --executor-memory 80G  --conf spark.eventLog.enabled=true --conf spark.eventLog.dir=$SCRATCH/spark/spark_event_logs --py-files src/main/python/h5spark/read.py src/main/python/tests/new-multi-file-test.py  ('/global/cscratch1/sd/jialin/dayabay/preprocess/hdf/output-muo-large/','inputs') partition=10 

###load single large hdf5 file####
inputfile=/global/cscratch1/sd/gittens/CFSROhdf5/oceanTemps.hdf5
dataset=temperatures
rows=6349676
type=64
csvlist=src/resources/hdf5/oceanlist.csv
partition=1
repartition=1000
#input=/global/cscratch1/sd/jialin/dayabay/dayabay-final.h5
#dataset=autoencoded
#rows=2759895880
#type=32
#csvlist=src/resources/hdf5/dayabay-slice.csv

spark-submit --master $SPARKURL --executor-cores 32 --driver-memory 20G --executor-memory 80G --conf spark.eventLog.enabled=true --conf spark.eventLog.dir=$SCRATCH/spark/spark_event_logs src/main/python/tests/single-file-test.py $csvfile $partition $repartition $inputfile $dataset $rows 

#python generate_csv.py /global/cscratch1/sd/gittens/CFSROhdf5/oceanTemps.hdf5 temperatures ../../../resources/hdf5/oceanlist.csv 6349676 2000

# 2759895880 is the total number of rows in the 2d array, the number of columns is 11(reduced from 192)
###check history server information####

#module load spark/hist-server
#./run_history_server.sh $EVENT_LOGS_DIR 

stop-all.sh
stop-collectl.sh
