#!/bin/bash

# === Configuration ===
REPO_PATH="/Users/liamramsden/Documents/GitHub"
OUTPUT_FILE="commit_log.csv"

# === Script Loop ===
while true; do
    # === List available repositories ===
    echo "📂 Available Repositories:"
    REPOS=($(ls -d $REPO_PATH/*/))  # List all directories in REPO_PATH
    if [ ${#REPOS[@]} -eq 0 ]; then
        echo "❌ No repositories found in $REPO_PATH."
        exit 1
    fi

    # Show the list of repositories
    for i in "${!REPOS[@]}"; do
        echo "$((i+1)). ${REPOS[$i]##*/}"
    done

    # === Prompt user to select a repository ===
    read -p "🔧 Enter the number of the repository to export commits from: " REPO_CHOICE

    # Validate input
    if [[ "$REPO_CHOICE" -gt 0 && "$REPO_CHOICE" -le "${#REPOS[@]}" ]]; then
        REPO_PATH="${REPOS[$((REPO_CHOICE-1))]}"  # Set the selected repo path
        echo "🔄 You selected repository: ${REPO_PATH##*/}"
    else
        echo "⚠️ Invalid selection. Please choose a valid number."
        continue
    fi

    # === Change to the selected repo directory ===
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
    git log --pretty=format:'"%H","%an","%ad","%s"' --date=iso > "$OUTPUT_FILE"

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
