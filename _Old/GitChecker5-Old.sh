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
          if [ -d "$d/.git" ]; then
             cd $d
             git pull
             cd -
          fi
	done
}


###################################################################
# CASE Statement #                                                #
###################################################################

# Initialize variables to false or empty
SHOW_ALL=false
SHOW_GIT_ONLY=false
SHOW_NONGIT_ONLY=false
UPDATE=false
UPDATE_ALL=false

# Loop through all arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --show-all)
            SHOW_ALL=true
            ;;
        --show-git-only)
            SHOW_GIT_ONLY=true
            ;;
        --show-nongit-only)
            SHOW_NONGIT_ONLY=true
            ;;
        --update)
            UPDATE=true
            ;;
        --update-all)
            UPDATE_ALL=true
            ;;
        *)
            echo "Unknown parameter passed: $1"
            echo "Usage: $0 [--show-all] [--show-git-only] [--show-nongit-only] [--update] [--update-all]"
            exit 1
            ;;
    esac
    shift # Move to the next argument
done

# --- Script Logic Begins Here ---
if [ "$SHOW_ALL" = true ]; then
    RunChecks
elif [ "$SHOW_GIT_ONLY" = true ]; then
     echo ${red} "Not Implemented Yet! ${reset}"
elif [ "$SHOW_NONGIT_ONLY" = true ]; then
     echo ${red} "Not Implemented Yet! ${reset}"
fi

if [ "$UPDATE" = true ]; then
    echo ${green} "Updating Repos... ${reset}"
	UpdateRepos
	echo " "
elif [ "$UPDATE_ALL" = true ]; then
    echo ${green} "Updating Repos... ${reset}"
	UpdateRepos
	echo " "
fi




##################################################################
# Main Program #
################

# SanityChecker_ColorsFile
NewLine


DisplayBanner
DisplayLine
NewLine
# RunChecks | column -t


NewLine
DisplayLine
NewLine

