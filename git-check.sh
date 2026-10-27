#!/usr/bin/env bash

# Color codes
white='\033[1;37m'
green='\033[0;32m'
red='\033[0;31m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
reset='\033[0m'

# Target directory defaults to current directory, or accepts a path as an argument
TARGET_DIR="${1:-.}"

if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${red}Error: Directory '$TARGET_DIR' does not exist.${reset}"
    exit 1
fi

echo -e "${white}Scanning for Git repositories in: ${TARGET_DIR}${reset}\n"

# Find all directories exactly 1 level deep that contain a .git folder
# Change "-maxdepth 2" if your repos are nested deeper
find "$TARGET_DIR" -maxdepth 2 -mindepth 1 -type d | sort | while read -r d; do
    
    # Check if the directory is actually a git repository
    if [ ! -d "$d/.git" ] && ! git -C "$d" rev-parse --is-inside-work-tree &>/dev/null; then
        continue
    fi

    # Extract just the folder name for clean printing
    folder_name=$(basename "$d")

    # Move context into the target repository
    cd "$d" || continue

    # 1. Check Local Worktree Status (Staged, Unstaged, Untracked)
    local_status=""
    git_status=$(git status --porcelain 2>/dev/null)

    if echo "$git_status" | grep -E '^[MADRC ]M|^[MADRC ]D' &>/dev/null; then
        local_status="${local_status}${yellow}Unstaged ${reset}"
    fi
    if echo "$git_status" | grep -E '^[MADRC]' | grep -vE '^ ' &>/dev/null; then
        local_status="${local_status}${green}Staged ${reset}"
    fi
    if echo "$git_status" | grep -E '^\?\?' &>/dev/null; then
        local_status="${local_status}${magenta}Untracked ${reset}"
    fi

    # 2. Check Upstream Status (Fetch & Sync)
    upstream_status=""

    # Verify if an upstream tracking branch is configured
    if ! git rev-parse --abbrev-ref @{u} &>/dev/null; then
        upstream_status="${yellow}[No Upstream]${reset}"
    else
        # Fetch silently; if it fails (offline/auth), don't crash the loop
        if ! git fetch &>/dev/null; then
            upstream_status="${red}[Fetch Failed]${reset}"
        else
            LOCAL=$(git rev-parse HEAD 2>/dev/null)
            REMOTE=$(git rev-parse @{u} 2>/dev/null)
            BASE=$(git merge-base HEAD @{u} 2>/dev/null)

            if [ "$LOCAL" = "$REMOTE" ]; then
                upstream_status="${red}[In Sync]${reset}"
            elif [ "$LOCAL" = "$BASE" ]; then
                upstream_status="${green}[Needs Pull]${reset}"
            elif [ "$REMOTE" = "$BASE" ]; then
                upstream_status="${blue}[Needs Push]${reset}"
            else
                upstream_status="${yellow}[Diverged]${reset}"
            fi
        fi
    fi

    # 3. Print the Combined Report with aligned columns
    printf " ${white}%-25s${reset} │ %-25b │ " "$folder_name" "$upstream_status"
    if [ -n "$local_status" ]; then
        echo -e "Local Changes: ${local_status}"
    else
        echo -e "${white}Clean${reset}"
    fi

done
