#!/usr/bin/env bash

# This script checks subdirectories to see if they are Git repos.
#

# ShellCheck: Disable color warnings.
# shellcheck disable=SC2154


# TODO: Add CASE statment for --show-git-only and --show-nongit-only and --show-all
# 	    Add 'git pull' feature to update all repos via --update-all
#       Add feature to show update available with listing.



# Colors for Cecho-like output
CONFIG_DIR="$(pwd)"
COLORS_FILE="Colors.conf"

# Source our Color Config
if [ -f "$CONFIG_DIR"/"$COLORS_FILE" ]; then
		# shellcheck source=/dev/null
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

function UpdateRepos() {
# Update Repos  
	for d in */; do
	(
          if [ -d "$d/.git" ]; then
             cd "$d"
             git pull
             cd -
          fi
	)
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

