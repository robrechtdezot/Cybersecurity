#!/bin/bash

domain=$1
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
RESET='\033[0m' # Reset color

subdomain_path=$domain/subdomains
screenshot_path=$domain/screenshots
scan_path=$domain/scans

if[ ! -d "$domain" ]; then
    mkdir $domain
fi
if[ ! -d "$subdomain_path" ]; then
    mkdir $subdomain_path
fi
if[ ! -d "$screenshot_path" ]; then
    mkdir $screenshot_path
fi
if[ ! -d "$scan_path" ]; then
    mkdir $scan_path
fi


echo -e "${RED}[*] Starting subfinder ... ${RESET}"
subfinder -d $domain > $subdomain_path/found.txt
echo -e "${GREEN}[+] Subfinder completed! ${RESET}"

echo -e "${RED}[*] Starting assetfinder ... ${RESET}"
assetfinder $domain | grep $domain >> $subdomain_path/found.txt
echo -e "${GREEN}[+] Assetfinder completed! ${RESET}"

echo -e "${RED}[*] Starting amass ... ${RESET}"
amass enum -d $domain >> $subdomain_path/found.txt
echo -e "${GREEN}[+] Amass completed! ${RESET}"

echo -e "${RED}[*] Finding alive subdomains ... ${RESET}"
cat $subdomain_path/found.txt | grep $domain | sort -u | httprobe -prefer-https |grep https | sed 's/https\?:\/\///' | tee -a $subdomain_path/alive.txt 
echo -e "${GREEN}[+] Alive subdomains found! ${RESET}"

echo -e "${RED}[*] Taking screenshots of alive subdomains ... ${RESET}"
gowitness file -f $subdomain_path/alive.txt -P $screenshot_path/ --no-http
echo -e "${GREEN}[+] Screenshots taken! ${RESET}"

echo -e "${RED}[*] Running nmap on alive subdomains ... ${RESET}"
nmap -iL $subdomain_path/alive.txt -p- -T4 -oA $scan_path/nmap.txt
echo -e "${GREEN}[+] Nmap scan completed! ${RESET}"
