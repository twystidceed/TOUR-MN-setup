#!/bin/bash

#usage cd TOUR-MN-setup && git fetch --all && git reset --hard origin/master && bash update.sh


#Color codes
RED='\033[0;91m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color


#Delay script execution for N seconds
function delay { echo -e "${GREEN}Sleep for $1 seconds...${NC}"; sleep "$1"; }

#Stop daemon if it's already running
function stop_daemon {
    if pgrep -x 'tourd' > /dev/null; then
        echo -e "${YELLOW}Attempting to stop tourd${NC}"
        tour-cli stop
        delay 60
        if pgrep -x 'tourd' > /dev/null; then
            echo -e "${RED}tourd daemon is still running!${NC} \a"
            echo -e "${RED}Attempting to kill...${NC}"
            pkill tourd
            delay 60
            if pgrep -x 'tourd' > /dev/null; then
                echo -e "${RED}Can't stop tourd! Reboot and try again...${NC} \a"
                exit 2
            fi
        fi
    fi
}
echo -e "${GREEN}Stopping TourCoin Daemon and Downloading new binaries${NC}"
echo -e "${GREEN}This could take up to a minute${NC}"
stop_daemon
#check for updates
echo -e "${GREEN}getting updates before install${NC}"
delay .1
sudo apt-get -y update


echo -e "${GREEN}Removing old data${NC}"
#Remove old binaries

cd ~
sudo rm /usr/bin/tour
cd .tour/
sudo rm -rf mncache* 
sudo rm -rf masternode.conf
sudo rm wallet.dat 
sudo rm -rf .lock 
sudo rm peers.dat
sudo rm db.log 
sudo rm debug.log 
sudo rm tourd.pid
sudo rm mnpayments.dat 
sudo rm mncache.dat
sudo rm banlist.dat
sudo rm -R backups/
sudo rm -R blocks/
sudo rm -R chainstate/
sudo rm -R database/
delay 5

cd ~
mkdir ~/TOUR-MN-setup/Touriva
cd ~/TOUR-MN-setup/Touriva
sudo wget https://github.com/Touriva/TOUR/releases/download/v1.1.0/Tour_linux1.1.0-1604.tar.gz
sudo dtrx -n -f Tour_linux1.1.0-1604.tar.gz
sudo rm tour-qt
sudo cp tour* /usr/bin/
sudo chmod 755 /usr/bin/tour*

stop_daemon
tour-cli addnode 45.12.213.72:5457 onetry
echo -e "${GREEN}Starting new daemon and initiating monitior script${NC}"
echo -e "${GREEN}This update REQUIRES a full resync of node${NC}"
echo -e "${GREEN}you should not have to do anything unless the node doesnt self reactivate${NC}"
echo -e "${GREEN}If not activated upon sync - Activate in local wallet and check back here${NC}"
tourd -daemon
delay 15
tourmon.sh

