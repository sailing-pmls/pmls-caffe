#! /bin/sh

for i in `seq 0 8`
do

  IP=`docker inspect poseidon$i 2>&1 | grep "IPAddress\"" | head -n 1 | cut -d\" -f 4`
  if [ ! -z "$IP" ]
  then
    echo "$i $IP 9999"
  fi

done
