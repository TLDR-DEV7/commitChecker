#!/bin/bash

# === Configuration ===
REPO_PATH="/Users/liamramsden/Documents/GitHub/DDG_IOSApp"
OUTPUT_FILE="commit_log.csv"

# === Script Loop ===
while true; do
    cd "$REPO_PATH" || { echo "❌ Repo not found at $REPO_PATH"; exit 1; }

    # === Show available branches ===
    echo ""
    echo "📦 Available branches:"
    git branch --list
    echo ""

    # === Prompt user to enter a branch ===
    read -p "🔧 Enter the branch name to export commits from: " BRANCH_NAME

    # === Checkout the selected branch ===
    echo "🔄 Switching to branch '$BRANCH_NAME'..."
    git checkout "$BRANCH_NAME" || { echo "❌ Failed to checkout branch '$BRANCH_NAME'"; continue; }

    # === Prompt user for author filter ===
    read -p "🔍 Enter the author's name to filter by (press Enter to skip): " AUTHOR_FILTER

    # === Build the git log command with optional author filter ===
    if [[ -n "$AUTHOR_FILTER" ]]; then
        AUTHOR_OPTION="--author=\"$AUTHOR_FILTER\""
    else
        AUTHOR_OPTION=""
    fi

    # === Export commits with author filter if provided ===
    echo "📤 Exporting commit log to '$OUTPUT_FILE'..."
    git log $AUTHOR_OPTION --pretty=format:'%H|%an|%ad|%s' --date=iso | \
    awk -F'|' '{
    # Remove leading/trailing spaces from date field
    gsub(/^ +| +$/, "", $3);
    
    # Split the date-time string into date, time, and timezone
    split($3, datetimeParts, " ");
    
    # Split the date part (YYYY-MM-DD) into separate components
    split(datetimeParts[1], dateParts, "-");
    
    # Convert to dd-MM-yyyy (UK format)
    formattedDate = dateParts[3] "-" dateParts[2] "-" dateParts[1];
    
    # Extract the time part (HH:MM:SS)
    time = datetimeParts[2];
    
    # Print the CSV line with separate Date and Time columns, with commas
    printf "\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"\n", $1, $2, formattedDate, time, $4
    }' > "$OUTPUT_FILE"

    # === Open the file ===
    echo "📂 Opening file..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "$OUTPUT_FILE"
    elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "win32" ]]; then
        start "$OUTPUT_FILE"
    else
        echo "✅ Commit log saved to '$OUTPUT_FILE'. Please open it manually."
    fi

    # === Ask to repeat, until valid input ===
    while true; do
        echo ""
        read -p "🔁 Would you like to export another branch? (y/n): " CONTINUE
        CONTINUE_LOWER=$(echo "$CONTINUE" | tr '[:upper:]' '[:lower:]')
        case "$CONTINUE_LOWER" in
            y) break ;;              # Exit this inner loop and repeat the outer loop
            n) echo "👋 Exiting. Goodbye!"; exit 0 ;;
            *) echo "⚠️ Please enter 'y' or 'n'." ;;
        esac
    done
done
