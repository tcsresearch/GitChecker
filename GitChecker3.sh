#!/usr/bin/env bash

# This script checks subdirectories to see if they are Git repos.
#

# TODO: Enable Cecho
# 	Also show folder that are NOT Git repos.
#
# 	Example: display all folder with green and yes for Git, but red and No for non-Git.
#




# Colors for Cecho-like output
CONFIG_DIR="$(pwd)"
COLORS_FILE="Colors.conf"

# Source our Color Config
if [ -f "$CONFIG_DIR"/"$COLORS_FILE" ]; then
        source "$CONFIG_DIR"/"$COLORS_FILE"
fi


##################################################################################################


function DisplayLine() {
	echo " ${brightblue}__________________________________________________${reset}"
}

function NewLine() {
	echo " "
}

function DisplayBanner() {
	echo "Git Status Of Directories Is Displayed Below:"
}

function AlignOutput() {
# Aligns the first column to 15 characters, left-justified
    printf "%-15s %s\n" "Name" "Status"
    printf "%-15s %s\n" "ServiceA" "Running"
    printf "%-15s %s\n" "ServiceB" "Stopped"
}




function RunChecks() {
# Run Checks  
	for d in */; do
          if [ -d "$d/.git" ]; then
             echo "${white} $d:	${green} [Yes] ${reset}"
     	  else 
  	     echo "${white} $d: ${red} 	 [No]  ${reset}"
     	  fi
	done
}


##################################################################
# Main Program #
################

# SanityChecker_ColorsFile
NewLine


DisplayBanner
DisplayLine
NewLine
RunChecks | column -t


NewLine
DisplayLine
NewLine

