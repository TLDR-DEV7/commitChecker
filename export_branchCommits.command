#!/bin/bash

# === Configuration ===
REPO_PATH="/Users/liamramsden/Documents/GitHub/DDG_IOSApp"
BRANCH_NAME="Liam_changes_2"
OUTPUT_FILE="commit_log.csv"

# === Script ===
cd "$REPO_PATH" || { echo "Repo not found at $REPO_PATH"; exit 1; }

echo "Switching to branch $BRANCH_NAME..."
git checkout "$BRANCH_NAME"

echo "Exporting commit log to $OUTPUT_FILE..."
git log --pretty=format:'"%H","%an","%ad","%s"' --date=iso > "$OUTPUT_FILE"

echo "Opening file..."
# Use open for macOS, start for Windows
if [[ "$OSTYPE" == "darwin"* ]]; then
    open "$OUTPUT_FILE"
elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "win32" ]]; then
    start "$OUTPUT_FILE"
else
    echo "Please open $OUTPUT_FILE manually."
fi
