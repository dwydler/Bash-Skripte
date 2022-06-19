#!/bin/bash

### Variables
RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'

ENABLEIPV6=false
IANATLDSFILE="https://data.iana.org/TLD/tlds-alpha-by-domain.txt"
IANATLDS=""
IPSRAWFILE="$(pwd)/ips.raw.txt"
DNSIPSUNIQGFILE="$(pwd)/ips.uniq.txt"

# Cloudflare
#PUBLICDNSSERVERS[0]="1.1.1.1"

# Google
PUBLICDNSSERVERS[0]="8.8.8.8"
PUBLICDNSSERVERS[1]="8.8.4.4"

# QUAD9
#PUBLICDNSSERVERS[0]="9.9.9.9"
#PUBLICDNSSERVERS[1]="149.112.112.112"


### Measure run time of the scrpt
STARTTIME=$(date "+%s")


### Various functions
sec_to_time() {
        local seconds=$1
        local sign=""

        if [[ ${seconds:0:1} == "-" ]]; then
                seconds=${seconds:1}
                sign="-"
        fi

        local hours=$(( seconds / 3600 ))
        local minutes=$(( (seconds % 3600) / 60 ))
        seconds=$(( seconds % 60 ))
        printf "Laufzeit: %s%02d:%02d:%02d (Std:Min:Sek)\n" "$sign" $hours $minutes $seconds
}


###
printf "Check if one the required tools installed.\n"
if [ -x "$(which wget)" ]; then
        printf "${GREEN}wget is installed on this server.${NC}\n"
        cmd=$(which wget)

elif [ -x "$(which curl)" ]; then
        printf "${GREEN}curl is installed on this server.${NC}\n"
        cmd=$(which curl)

else
    printf "${RED}Cannot download, neither wget nor curl is available.\nPlease installed wget or curl on this server.${NC}\n"
    exit
fi


###
printf "\nCheck if old files exists.\n"
if test -f "$IPSRAWFILE"; then
        rm -f $IPSRAWFILE
        printf "${GREEN}File $IPSRAWFILE deleted.${NC}\n"
fi

if test -f "$DNSIPSUNIQGFILE"; then
        rm -f $DNSIPSUNIQGFILE
        printf "${GREEN}File $DNSIPSUNIQGFILE deleted.${NC}\n"
fi


###
printf "\nDownload current TLD list.\n"
IANATLDS=$($cmd -qO- $IANATLDSFILE | tail -n +2)
printf "${GREEN}File successfully downloaded.${NC}\n\n"


###
N=1
for TLD in $IANATLDS; do

        ##
        echo $TLD
        echo $N
        
        ##
        DNSLIST=$(dig +short "$TLD" ns)
        echo $DNSLIST

        ##
        RAND=$[$RANDOM % ${#PUBLICDNSSERVERS[@]}]
        DNSSERVER=${PUBLICDNSSERVERS[$RAND]}
        #echo $RAND
        #echo $DNSSERVER

        ##
        for DNS in $DNSLIST; do
                if [ "$ENABLEIPV6" = true ]; then
                        echo "Be careful not to fall off!"
                        dig +short $DNS A $DNS AAAA @$DNSSERVER >> $IPSRAWFILE
                else
                        dig +short $DNS A @$DNSSERVER >> $IPSRAWFILE
                fi
        done

        ##
        ((N++))
        #if [ "$N" -eq 30 ]; then
        #        break
        #fi
done


###
printf "Remove duplicate ip addresses from file.\n\n"
sort $IPSRAWFILE | uniq -u | tee $DNSIPSUNIQGFILE


### Before/after comparison
wc -l $IPSRAWFILE
wc -l $DNSIPSUNIQGFILE


### Measure run time of the script
ENDTIME=$(date "+%s")
sec_to_time $(($ENDTIME - STARTTIME))


###
printf "\nAm Ende das Scripts angekommen.\n"
