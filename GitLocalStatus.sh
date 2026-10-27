#!/bin/bash

# Here is a robust, modular snippet designed to fit right inside your directory loop. 
# This setup handles untracked files, staged changes, uncommitted work, and missing or failing upstreams without crashing your entire loop.
# It replaces your binary [Yes] / [No] with detailed, color-coded visual indicators so you can see exactly what each repository needs at a glance.




# Ensure we are in a valid git repository before running commands
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo -e " ${white}${d%/}: ${yellow}[Not a Git Repo]${reset} "
    continue
fi

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

# Verify if an upstream tracking branch is even configured
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

# 3. Print the Combined Report
if [ -n "$local_status" ]; then
    echo -e " ${white}${d%/}:${reset} ${upstream_status} ── Local Changes: ${local_status}"
else
    echo -e " ${white}${d%/}:${reset} ${upstream_status} ── ${white}Clean${reset}"
fi
