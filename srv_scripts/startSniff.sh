#!/bin/bash

netsniff-ng --in eno2 --out "/ep_logs/pcap/" --filter "host 131.78.240.117" --interval 2min --prefix capt- --bind-cpu 0 --silent 

