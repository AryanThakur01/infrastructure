#!/bin/bash

set -e

LUA_FILTER="mermaid.lua"
OUTPUT_DIR="final-docs"

echo "Creating output directory..."
mkdir -p "$OUTPUT_DIR"

echo "Starting recursive Markdown → DOCX conversion..."

find . -type f -name "*.md" ! -path "./$OUTPUT_DIR/*" | while read -r file; do
    # Remove leading ./ 
    clean_path="${file#./}"
    
    # Change extension to .docx
    output_path="$OUTPUT_DIR/${clean_path%.md}.docx"
    
    # Create destination directory if it doesn't exist
    mkdir -p "$(dirname "$output_path")"
    
    echo "Converting: $file"
    
    pandoc "$file" \
        --lua-filter="$LUA_FILTER" \
        -o "$output_path"
done

echo "All documents successfully generated in $OUTPUT_DIR"
