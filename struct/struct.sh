#!/bin/bash

# Script to create directory and file structure based on a parameter or default to structure.txt

# Function to display usage information
usage() {
    echo "Usage: $0 [--path=path/to/structure_file]"
    exit 1
}

# Check if the --path argument is provided, otherwise look for structure.txt
if [[ "$1" == --path=* ]]; then
    # Extract the file path from the --path argument
    STRUCTURE_FILE="${1#--path=}"
else
    # Default to structure.txt if no --path argument is provided
    STRUCTURE_FILE="structure.txt"
fi

# Check if the structure file exists
if [ ! -f "$STRUCTURE_FILE" ]; then
    echo "Error: File '$STRUCTURE_FILE' not found!"
    exit 1
fi

echo "Using structure file: $STRUCTURE_FILE"

# Initialize an associative array to keep track of directories at each depth
declare -A DIR_STACK
DIR_STACK[0]="." # Base directory set to the current directory

# Function to trim leading tree characters and extract the name
trim_line() {
    local line="$1"
    # Remove leading tree characters (e.g., │, ├──, └──)
    echo "$line" | sed -E 's/^[│├└─ ]+//'
}

# Function to check if it's a directory based on the indentation level
is_directory() {
    local depth=$1
    local next_line=$(sed -n "$((LINE_NUMBER + 1))p" "$STRUCTURE_FILE")
    local next_depth=0
    while [[ "$next_line" =~ ^([│├└─ ]{4}) ]]; do
        next_depth=$((next_depth + 1))
        next_line="${next_line:4}"
    done
    [[ $next_depth -gt $depth ]] && return 0 || return 1
}

# Read the structure file line by line
LINE_NUMBER=0
while IFS= read -r line || [ -n "$line" ]; do
    LINE_NUMBER=$((LINE_NUMBER + 1))

    # Skip empty lines
    if [[ -z "$line" ]]; then
        continue
    fi

    # Determine the depth based on leading indentation (each level is 4 characters)
    depth=0
    temp_line="$line"
    while [[ "$temp_line" =~ ^([│├└─ ]{4}) ]]; do
        depth=$((depth + 1))
        temp_line="${temp_line:4}"
    done

    # Get the name by trimming tree characters
    name=$(trim_line "$line")

    # Build the full path
    parent_dir="${DIR_STACK[$depth]}"

    # Ensure parent_dir ends with '/'
    if [[ "${parent_dir}" != */ ]]; then
        parent_dir="${parent_dir}/"
    fi

    current_path="${parent_dir}${name}"

    # Determine if this is a directory by checking the next line
    if is_directory "$depth"; then
        # It's a directory
        mkdir -p "$current_path"
        if [ $? -eq 0 ]; then
            echo "Directory created: $current_path"
        else
            echo "Failed to create directory: $current_path"
            exit 1
        fi
        # Update the DIR_STACK for the next depth level
        DIR_STACK[$((depth + 1))]="$current_path"
    else
        # It's a file
        touch "$current_path"
        if [ $? -eq 0 ]; then
            echo "File created: $current_path"
        else
            echo "Failed to create file: $current_path"
            exit 1
        fi
    fi
done <"$STRUCTURE_FILE"

echo "Folder and file structure created successfully."
