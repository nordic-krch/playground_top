#!/bin/bash

# File to be searched
file_to_search="west.yaml"
regex_to_match="pr/[0-9]+/head"

# Function to find the last commit that modifies the specified file
find_last_commit_for_file() {
    local file="$1"
    
    # Get the commit hash of the last modification to the specified file
    local commit_hash=$(git log -1 --pretty=format:"%H" -- "$file")

    # Print the commit hash
    echo "$commit_hash"
}

# Function to check if the specified regex is present in the added lines of a commit
check_commit_for_regex() {
    local commit_hash="$1"
    local regex="$2"

    # Get the added lines of the commit
    local added_lines=$(git diff --cached --unified=0 "$commit_hash" "$file_to_search" | grep '^\+' | sed 's/^\+//')

    # Check if the regex is present in the added lines
    if [[ "$added_lines" =~ $regex ]]; then
        return 0  # Regex found
    else
        return 1  # Regex not found
    fi
}

# Find the last commit that modifies the specified file
last_commit_for_file=$(find_last_commit_for_file "$file_to_search")

if [ -n "$last_commit_for_file" ]; then
    echo "Last commit that modifies '$file_to_search': $last_commit_for_file"

    # Check if the modification in the commit adds a line matching the specified regex
    if check_commit_for_regex "$last_commit_for_file" "$regex_to_match"; then
        echo "The modification in the commit adds a line matching the regex '$regex_to_match'."
    else
        echo "The modification in the commit does not add a line matching the regex '$regex_to_match'."
    fi
else
    echo "No commit found that modifies '$file_to_search'."
fi
