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

    # === Export commits ===
    echo "📤 Exporting commit log to '$OUTPUT_FILE'..."
    git log --pretty=format:'%H|%an|%ad|%s' --date=iso | \
    awk -F'|' '{
    # Remove leading/trailing spaces from date field
    gsub(/^ +| +$/, "", $3);
    
    # Split the date-time string into date, time, and timezone
    split($3, datetimeParts, " ");
    split(datetimeParts[1], dateParts, "-");  # YYYY-MM-DD → {2025, 04, 28}
    
    # Rearranged date: dd-MM-yyyy (UK format)
    formattedDate = dateParts[3] "-" dateParts[2] "-" dateParts[1];
    
    # Split the time and timezone to make them separate columns
    split(datetimeParts[2], timeParts, "+");  # Time is "HH:MM:SS" and "+TZ"
    
    # Print CSV line with separate Date and Time+TZ columns
    printf "\"%s\",\"%s\",\"%s\",\"%s\",\"%s %s\"\n", $1, $2, formattedDate, timeParts[1], "+" timeParts[2], $4
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
