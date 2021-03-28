#!/bin/sh

for app in `seq 1 24`; do
    ./app_gen.py $app > L1_S24.apps.ini
    for i in `seq 1 10`; do
        bw=$(python -c "print($i * 0.1)")
        sed "s/available_bw = 1.0/available_bw = ${bw}/g" L1_S24.ned_template > L1_S24.ned
        echo "Started: " $app " with bw: " $i"0%" 
        $d/src/ib_flit_sim_dbg -f L1_S24.ini -u Cmdenv > results/"${app}"_$i
        echo "Finished: " $app " with bw: " $i"0%" 
    done
done