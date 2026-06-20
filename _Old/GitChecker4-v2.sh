#!/usr/bin/env bash

# This script checks subdirectories to see if they are Git repos.
#

# ShellCheck: Disable color warnings.
# shellcheck disable=SC2154


# TODO: Add CASE statment for --show-git-only and --show-nongit-only and --show-all
# 	    Add 'git pull' feature to update all repos via --update-all
#       Add feature to show update available with listing.



# Define our Colors for Cecho-like output
CONFIG_DIR="$(pwd)"
COLORS_FILE="Colors.conf"

# Source our Color Config
if [ -f "$CONFIG_DIR"/"$COLORS_FILE" ]; then
	# shellcheck source=/dev/null
        source "$CONFIG_DIR"/"$COLORS_FILE"
fi

# Define our functions library
GCT_FUNCFILE="./GitChecker.bfunc"

# Source our functions library
if [ -f "$GCT_FUNCFILE" ]; then
        # shellcheck source=/dev/null
	source "$GCT_FUNCFILE"
fi


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

