#!/bin/bash

# Script : DD_monitorTemp.sh
# Usage  : ./DD_monitorTemp.sh sda 


# 11 mars 2026 yannick SUDRIE
#
# Script pour monitorer la temperature d'un disque dur pendant un test smart long ou autres tests.

watch -n 10 "sudo smartctl -a /dev/$1 | grep -i 'Temperature'"
