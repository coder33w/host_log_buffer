#!/bin/bash

### Extracts syslog payload from PCAP and writes to raw logs as the base CEF format

BASE_DIR=/ep_logs

PCAP_DIR=$BASE_DIR/pcap
WRKNG_DIR=$BASE_DIR/temp
LOG_DIR=$BASE_DIR/raw_logs


if [ ! "$(pgrep netsniff-ng)" ]
then
  echo -e "\n\tWaiting for netsniff-ng to start . . .\n\n"
  sleep 120
fi


while `pgrep netsniff-ng > /dev/null`
do
  if [ ! "$(ls -A /ep_logs/pcap/)" ] 
  then
    echo "Waiting for PCAP . . ."
    sleep 180
  fi

  for capFile in `ls $PCAP_DIR`
  do
    if ! [[ `lsof -c netsniff | grep $capFile > /dev/null` ]]
    then
      echo "Extracting payload from PCAP . . ."

      fBase=`echo $capFile | cut -d. -f 1`            # Set base filename
      tshark -2nr $PCAP_DIR/$capFile -z follow,udp,ascii,0 > $WRKNG_DIR/$fBase.tmp
#      grep "CEF" $WRKNG_DIR/$fBase.tmp > $LOG_DIR/$fBase.log			# This version doesn't strip off the Syslog header from the CEF entries
      grep "CEF" $WRKNG_DIR/$fBase.tmp | sed -e 's/\(^.\+Syslog[ 0-9]\+\)//' > $LOG_DIR/$fBase.log
      rm -f $WRKNG_DIR/$fBase.tmp                     # Cleanup Temp
      rm -f $PCAP_DIR/$capFile                        # CLEANUP ORIGINAL, ELSE IT WILL BE PROCESSED AGAIN (AO 18OCT19)

      echo "Iteration Complete"
#      mv $PCAP_DIR/$capFile $BASE_DIR/test           #test set for functionality
    else
      echo "Waiting for netsniff-ng to finish with file . . ."
      sleep 60                                        # Wait 60 seconds if file is being written to
    fi
  done

#  echo -e "\n\n\tONE ITERATION OF while LOOP\n\n"    #test set for functionality
#  break                                              #test set for functionality

done
