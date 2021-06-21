# The install.bash script installs the needed software packages
# using the requirement files.
#
# This code is available under a GPL v3.0 license and comes without
# any explicit or implicit warranty.
#
# (C) Wilfried Wöber 2021 <wilfried.woeber@technikum-wien.at>
#/bin/bash
#-----------------------------------------------------------#
# Descr.: Checks if the Python virtual environment folders  #
#           exists. A flag indicates this status.           #
# Param.: -                                                 #
#-----------------------------------------------------------#
checkInstallation() {
    echo "Check system installation"
    isInstalled=0   #This flag is needed to indicate if installation is complete
    if [ -d "./Python/VE" ] 
    then
        isInstalled=1
    else
        echo "Installation not complete"
    fi
    if [ -d "./Python/VE_DL" ] 
    then
        isInstalledDL=1
    else
        echo "Installation not complete for DL"
    fi
}
#-----------------------------------------------------------#
# Descr.: This function installs the python VE's if needed. #
# Param.: -                                                 #
#-----------------------------------------------------------#
installVE() {
    echo "Installing python virtual environment..."
    #--------------------------#
    #--- Check installation ---#
    #--------------------------#
    if [ "$isInstalled" == "1" ]
    then
        echo -e "\033[0;32mNo need for installation - check logfile if problems occurs\033[0m"
        return
    fi
    #--- Install stuff ---#
    logfile_name="./Python/$(date '+%Y%m%d_%H%M_Install.log')"
    { 
        virtualenv ./Python/VE
        #--- Install ---#
        ./Python/VE/bin/pip install -r Python/requirements.txt 
        ./Python/VE/bin/pip install GPy 
    } >> "$logfile_name"
}
installVE_DL() {
    echo "Installing python virtual environment for deep learning..."
    #--------------------------#
    #--- Check installation ---#
    #--------------------------#
    if [ "$isInstalledDL" == "1" ]
    then
        echo -e "\033[0;32mNo need for installation DL libs- check logfile if problems occurs\033[0m"
        return
    fi
    #--- Install stuff ---#
    logfile_name="./Python/$(date '+%Y%m%d_%H%M_Install_DL.log')"
    { 
        virtualenv ./Python/VE_DL
        #--- Install ---#
        ./Python/VE_DL/bin/pip install -r Python/requirements_CNN.txt 
    } >> "$logfile_name"
}
install_structure(){
    cd ./structure/install
    logfile_name="./$(date '+%Y%m%d_%H%M_Install_structure.log')"
    bash installStructure.bash > "$logfile_name"
}
#-----------------------------------------------------------#
# Descr.:  This function prints the usage of this script.   #
#-----------------------------------------------------------#
usage() { 
	echo "Usage: bash run.sh [-I] " 1>&2 
	printf "\t I... Install framework in VE\n\t i... Install DL framework (needs CUDA)\n\t s... Install structure/sastStructure\n"
    exit 1; 
}
#-----------------------#
#--- Main processing ---#
#-----------------------#
set -e      #Abort if any error occurs
#--- Check number of arguments ---#
if [ $# -lt 1 ]
then
    echo "Specify parameters"
    usage
fi
#--- Check parameters and perform given task ---#
#installNeal
checkInstallation   #Initially, we check if everything is installed
while getopts 'Iis' OPTION
do
    case "$OPTION" in
        I)
            installVE #Install the virtual environment
            ;;
        i)
            installVE_DL #Install the virtual environment for deep learning
            ;;
	s)
	    install_structure #Install structure as well as fastStrucutre
	    ;;
        *)
            usage
            ;;
    esac
done
