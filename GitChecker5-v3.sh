#!/usr/bin/env bash

# This script checks subdirectories to see if they are Git repos.
# Last Updated: Wed Aug 05, 2026

# ShellCheck: Disable color warnings.
# shellcheck disable=SC2154


# TODO: Add CASE statment for --show-git-only and --show-nongit-only and --show-all
# 	    Add 'git pull' feature to update all repos via --update-all
#       Add feature to show update available with listing.

#################################################################################################
# Sanity Checks / Source Configs & Functions Library #						#
#################################################################################################

# Define Colors File & Location
COLORS_DIR="$(pwd)"
COLORS_FILE="Colors.conf"

# Define Config File & Location
CONFIG_DIR="$(pwd)"
CONFIG_FILE="GitChecker.conf"

# Define Functions File & Location
FUNCTIONS_DIR="$(pwd)"
FUNCTIONS_FILE="GitChecker.bfunc"



# Source our Color Config
# TODO: Upgrade if statement to produce an error if file not found.
if [ -f "$COLORS_DIR"/"$COLORS_FILE" ]; then
		# shellcheck source=/dev/null
        source "$CONFIG_DIR"/"$COLORS_FILE"
fi

# Source our Main Config
# TODO: Upgrade if statement to produce an error if file not found.
if [ -f "$CONFIG_DIR"/"$CONFIG_FILE" ]; then
                # shellcheck source=/dev/null
        source "$CONFIG_DIR"/"$CONFIG_FILE"
fi


# Source our Functions Library
# TODO: Upgrade if statement to produce an error if file not found.
if [ -f "$FUNCTIONS_DIR"/"$FUNCTIONS_FILE" ]; then
                # shellcheck source=/dev/null
        source "$FUNCTIONS_DIR"/"$FUNCTIONS_FILE"
fi


##################################################################
# Main Program #
################

# SanityChecker_ColorsFile
 NewLine


 DisplayBanner
 DisplayLine
 NewLine

# New July 29, 2026
 RunCase
 ScriptLogic

 ChecksBanner
# ChecksBanner | column -t

 RunChecks | column -t
# RunChecks 

# New Aug 08, 2026
  # CheckUpdate_New | column -t
  

 NewLine
 DisplayLine
 NewLine
#
