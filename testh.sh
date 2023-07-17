#!/bin/bash

generate_threads_list ()
{
#    echo 1 2 4 8 16 32 64
    echo `seq 32`
}

gold=measure-$1-hash-P`hostname | cut -c11`-`date +%H-%M@%d-%m-%y`

# how many times to repeat each test
num_runs=10
if [ $# -ge 2 ];
    then num_runs=$2
fi

num_initial_keys=10000000
if [ $# -ge 3 ];
    then num_initial_keys=$3
fi
((key_range=num_initial_keys*2))


test_file_AOA=./test-hash-AOA
test_file_MOA=./test-hash-MOA
test_file_EMOA_PA=./test-hash-EMOA-PA
test_file_EMOA_DN=./test-hash-EMOA-DN
test_file_EMOA_RM=./test-hash-EMOA-RM
test_file_TMOA_PA=./test-hash-TMOA-PA
test_file_TMOA_DN=./test-hash-TMOA-DN
test_file_TMOA_RM=./test-hash-TMOA-RM
test_file_RC=./test-hash-RC
test_file_NoRecl=./test-hash-NoRecl
test_file_NoReclMalloc=./test-hash-NoReclMalloc

log_file_AOA=$gold-AOA
log_file_MOA=$gold-MOA
log_file_EMOA_PA=$gold-EMOA-PA
log_file_EMOA_DN=$gold-EMOA-DN
log_file_EMOA_RM=$gold-EMOA-RM
log_file_TMOA_PA=$gold-TMOA-PA
log_file_TMOA_DN=$gold-TMOA-DN
log_file_TMOA_RM=$gold-TMOA-RM
log_file_RC=$gold-RC
log_file_NoRecl=$gold-NoRecl
log_file_NoReclMalloc=$gold-NoReclMalloc

if [ ! -f $test_file_AOA ]; then
    echo "Test file $test_file_AOA does not exist. Exiting"
    exit
fi
if [ ! -f $test_file_MOA ]; then
    echo "Test file $test_file_MOA does not exist. Exiting"
    exit
fi
if [ ! -f $test_file_EMOA_PA ]; then
    echo "Test file $test_file_EMOA_PA does not exist. Exiting"
    exit
fi
if [ ! -f $test_file_EMOA_DN ]; then
    echo "Test file $test_file_EMOA_DN does not exist. Exiting"
    exit
fi
if [ ! -f $test_file_EMOA_RM ]; then
    echo "Test file $test_file_EMOA_RM does not exist. Exiting"
    exit
fi
if [ ! -f $test_file_TMOA_PA ]; then
    echo "Test file $test_file_TMOA_PA does not exist. Exiting"
    exit
fi
if [ ! -f $test_file_TMOA_DN ]; then
    echo "Test file $test_file_TMOA_DN does not exist. Exiting"
    exit
fi
if [ ! -f $test_file_TMOA_RM ]; then
    echo "Test file $test_file_TMOA_RM does not exist. Exiting"
    exit
fi
if [ ! -f $test_file_NoRecl ]; then
    echo "Test file $test_file_NoRecl does not exist. Exiting"
    exit
fi
if [ ! -f $test_file_RC ]; then
    echo "Test file $test_file_RC does not exist. Exiting"
    exit
fi


if [ -f $log_file_AOA ]; then
    echo "Log file $log_file_AOA already exists. Exiting"
    exit
fi
if [ -f $log_file_NoRecl ]; then
    echo "Log file $log_file_NoReclPalloc already exists. Exiting"
    exit
fi



for f in 0 0.5 0.8 1
do

    for i in $(generate_threads_list)
    do

        args="$num_initial_keys $f 0"

        for j in `seq $num_runs`
        do
#            $test_file_AOA $i $args 2000000 $j >> $log_file_AOA 2>&1
	    LD_PRELOAD=../lrmalloc/liblrmalloc.so $test_file_MOA $i $args 32000000 $j >> $log_file_MOA 2>&1
#            $test_file_EMOA_PA $i $args 0 $j >> $log_file_EMOA_PA 2>&1
#            $test_file_EMOA_DN $i $args 0 $j >> $log_file_EMOA_DN 2>&1
            $test_file_EMOA_RM $i $args 0 $j >> $log_file_EMOA_RM 2>&1
#            $test_file_TMOA_PA $i $args 0 $j >> $log_file_TMOA_PA 2>&1
#            $test_file_TMOA_DN $i $args 0 $j >> $log_file_TMOA_DN 2>&1
            $test_file_TMOA_RM $i $args 0 $j >> $log_file_TMOA_RM 2>&1
#            $test_file_RC $i $args 0 $j >> $log_file_RC 2>&1
	    LD_PRELOAD=../lrmalloc/liblrmalloc.so $test_file_NoRecl $i $args $j >> $log_file_NoRecl 2>&1
#                $test_file_NoReclMalloc $i $args >> $log_file_NoReclMalloc 2>&1
        done
        printf "$i "
    done
    printf "finish frac $f "
    printf "\n"
done

printf "\n"
