#!/usr/bin/env bash

# This script improves on git-check.sh by adding an option to pull when needed.

# Color codes
white='\033[1;37m'
green='\033[0;32m'
red='\033[0;31m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
reset='\033[0m'

# Initialize variables
AUTO_PULL=false
TARGET_DIR="."

# Parse arguments to handle flags vs paths
for arg in "$@"; do
    case $arg in
        -p|--pull)
            AUTO_PULL=true
            shift
            ;;
        *)
            TARGET_DIR="$arg"
            shift
            ;;
    esac
done

if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${red}Error: Directory '$TARGET_DIR' does not exist.${reset}"
    exit 1
fi

echo -e "${white}Scanning for Git repositories in: ${TARGET_DIR}${reset}"
if [ "$AUTO_PULL" = true ]; then
    echo -e "${yellow}⚠️  Auto-pull mode enabled. Will pull repositories that are behind.${reset}\n"
else
    echo -e "${blue}ℹ️  Read-only mode. Use -p or --pull to auto-update behind repos.${reset}\n"
fi

# Find all directories up to 2 levels deep that contain a .git folder
find "$TARGET_DIR" -maxdepth 2 -mindepth 1 -type d | sort | while read -r d; do
    
    # Check if the directory is a git repository
    if [ ! -d "$d/.git" ] && ! git -C "$d" rev-parse --is-inside-work-tree &>/dev/null; then
        continue
    fi

    folder_name=$(basename "$d")
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
    needs_pull_flag=false

    if ! git rev-parse --abbrev-ref @{u} &>/dev/null; then
        upstream_status="${yellow}[No Upstream]${reset}"
    else
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
                needs_pull_flag=true
            elif [ "$REMOTE" = "$BASE" ]; then
                upstream_status="${blue}[Needs Push]${reset}"
            else
                upstream_status="${yellow}[Diverged]${reset}"
            fi
        fi
    fi

    # 3. Handle Auto-Pull Action if requested
    pull_message=""
    if [ "$needs_pull_flag" = true ] && [ "$AUTO_PULL" = true ]; then
        # Try a fast-forward pull to prevent unexpected manual merge conflicts
        if git pull --ff-only &>/dev/null; then
            upstream_status="${green}[Pulled OK]${reset}"
        else
            upstream_status="${yellow}[Pull Failed]${reset}"
            pull_message=" (Requires manual merge/rebase)"
        fi
    fi

    # 4. Print the Combined Report
    printf " ${white}%-25s${reset} │ %-25b │ " "$folder_name" "$upstream_status"
    if [ -n "$local_status" ]; then
        echo -e "Local Changes: ${local_status}${pull_message}"
    else
        echo -e "${white}Clean${reset}${pull_message}"
    fi

done
