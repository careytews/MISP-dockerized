#!/bin/bash

set -ex

# check if user has currently a installed version
    # This function checks the current version on misp-server version from docker ps
    # https://forums.docker.com/t/docker-ps-a-command-to-publish-only-container-names/8483/2
    CURRENT_CONTAINER="$(docker ps --format '{{.Image}}'|grep server|cut -d : -f 2|cut -d - -f 1)"
    [ -z "$CURRENT_CONTAINER" ] && echo "Sorry, no Upgrade is possible. The reason is there is no running misp-server. I exit now." && docker ps && exit


function upgrade_to_1_0_0() {
    echo "Upgrade from Version before 1.0.0"
    # if current folder not exists execute install.sh script
    


}

##################      MAIN        #########################

echo "#############################################################################"
echo "Please Backup your full server and your storage for all critical MISP data!!!"
echo "If the backup is already done press enter now"
echo "#############################################################################"
read TMP



# If the UPGRADE_STEP_1 File exists then check if the 'current' directory exists
if [ ! -f UPGRADE_STEP_1 ]
then
    # [1] Check if a current directory exists
    if [ ! -L ./current ]
    then
        EARLIER_1_0_0=no
        echo "no 'current' directory exists an direct upgrade is not possible."
        read -p "Do you upgrade from an version earlier than 1.0.0? [DEFAULT: $EARLIER_1_0_0]: " -ei $EARLIER_1_0_0  EARLIER_1_0_0
        [ "$EARLIER_1_0_0" == "no" ] && echo "There is a bug, please open a ticket on https://github.com/DCSO/MISP-dockerized/issues and report the Error. Now i will exit." && exit
    fi

    [ "$CURRENT_CONTAINER" == "2.4.94" ] && INSTALLED_VERSION="0.3.4"
    read -r -p "From which version do you upgrade?: " -ei "$INSTALLED_VERSION" INSTALLED_VERSION 
        case $INSTALLED_VERSION in
        0.3.4)
            [ -L ./scripts ] || ln -s ./0.3.4/scripts ./scripts
            make -C 0.3.4/ backup-all
            [ -L ./scripts ] && rm ./scripts
            break
            ;;
        0.2.0)
            [ -L ./scripts ] || ln -s ./0.2.0/scripts ./scripts
            make -C 0.2.0/ backup-all
            break
            ;;
        0.1.2)
            [ -L ./scripts ] || ln -s ./0.1.2/scripts ./scripts
            make -C 0.1.2/ backup-all
            break
            ;;
        *)
            echo -e "\nplease choose only options from the text below!\n"
            exit
        ;;
        esac



    # [2] make a backup
    echo "We do now a full backup, this can be take a long time."
    make -C current/ backup-all
    
    # [3] choose a new version
    touch UPGRADE_STEP_1
    ./FOR_NEW_INSTALL.sh

# if the UPGRADE_STEP_1 file not exists go to else
else

    # check if directory exists
    [ ! -d current ] && echo "There is a bug, please open a ticket on https://github.com/DCSO/MISP-dockerized/issues and report the Error. Now I will exit." && exit
    
    # Restore Data
    OPTION=""
    while ( [ ! "$OPTION" == "exit" ] )
    do
        read -r -p "Which component volumes you want to restore? [ server | proxy | database | all OR exit ]: " -ei "$OPTION" OPTION
        
        case $OPTION in
        [aA][lL][lL])
            make -C current/ restore-all
            break
            ;;
        [sS][eE][rR][vV][eE][rR])
            make -C current/ restore-server
            break
            ;;
        [pP][rR][oO][xX][yY])
            make -C current/ restore-server
            break
            ;;
        [dD][aA][tT][aA][bB][aA][sS][eE])
            make -C current/ restore-server
            break
            ;;
        [eE][xX][iI][tT])
            OPTION=exit
            break;
            ;;
        *)
            echo -e "\nplease choose only options from the text below!\n"
        ;;
        esac
    done
    

fi