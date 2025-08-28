# #!/bin/bash

# # === Configuration ===
# GITHUB_PATH="/Users/liamramsden/Documents/GitHub"
# OUTPUT_FILE="commit_log.csv"

# # === Script Loop ===
# while true; do
#     # === List available repositories ===
#     echo "📂 Available Repositories:"
#     REPOS=($(find "$GITHUB_PATH" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;))
    
#     if [ ${#REPOS[@]} -eq 0 ]; then
#         echo "❌ No repositories found in $GITHUB_PATH."
#         exit 1
#     fi

#     for i in "${!REPOS[@]}"; do
#         echo "$((i+1)). ${REPOS[$i]}"
#     done

#     # === Prompt for repository selection ===
#     read -p "🔧 Enter the number of the repository to export commits from: " REPO_CHOICE
#     if [[ "$REPO_CHOICE" -gt 0 && "$REPO_CHOICE" -le "${#REPOS[@]}" ]]; then
#         REPO_NAME="${REPOS[$((REPO_CHOICE-1))]}"
#         REPO_PATH="$GITHUB_PATH/$REPO_NAME"
#         echo "🔄 You selected repository: ${REPO_NAME}"
#     else
#         echo "⚠️ Invalid selection. Please choose a valid number."
#         continue
#     fi

#     cd "$REPO_PATH" || { echo "❌ Repo not found at $REPO_PATH"; exit 1; }

#     # === Show available branches ===
#     echo ""
#     echo "📦 Available branches:"
#     git branch --list
#     echo ""

#     # === Prompt for branch name ===
#     read -p "🔧 Enter the branch name to export commits from: " BRANCH_NAME
#     echo "🔄 Switching to branch '$BRANCH_NAME'..."
#     git checkout "$BRANCH_NAME" || { echo "❌ Failed to checkout branch '$BRANCH_NAME'"; continue; }

#     # === Optional author filter ===
#     read -p "👤 Enter author name to filter by (leave blank for all): " AUTHOR_FILTER

#     # === Optional date filters ===
#     read -p "📅 From date (YYYY-MM-DD, leave blank for earliest): " FROM_DATE
#     read -p "📅 To date (YYYY-MM-DD, leave blank for latest): " TO_DATE

#     # === Build git log command ===
#     GIT_LOG_CMD="git log --pretty=format:'%H|%an|%ad|%s' --date=iso"
#     if [[ -n "$AUTHOR_FILTER" ]]; then
#         GIT_LOG_CMD+=" --author=\"$AUTHOR_FILTER\""
#     fi
#     if [[ -n "$FROM_DATE" ]]; then
#         GIT_LOG_CMD+=" --since=\"$FROM_DATE\""
#     fi
#     if [[ -n "$TO_DATE" ]]; then
#         GIT_LOG_CMD+=" --until=\"$TO_DATE\""
#     fi

#     # === Export commits to CSV ===
#     echo "📤 Exporting commit log to '$OUTPUT_FILE'..."
#     eval "$GIT_LOG_CMD" | \
#     awk -F'|' '{
#         gsub(/^ +| +$/, "", $3);
#         split($3, datetimeParts, " ");
#         split(datetimeParts[1], dateParts, "-");
#         formattedDate = dateParts[3] "-" dateParts[2] "-" dateParts[1];
#         time = datetimeParts[2];
#         printf "\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"\n", $1, $2, formattedDate, time, $4
#     }' > "$OUTPUT_FILE"

#     # === Open the file ===
#     echo "📂 Opening file..."
#     if [[ "$OSTYPE" == "darwin"* ]]; then
#         open "$OUTPUT_FILE"
#     elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "win32" ]]; then
#         start "$OUTPUT_FILE"
#     else
#         echo "✅ Commit log saved to '$OUTPUT_FILE'. Please open it manually."
#     fi

#     # === Ask to repeat ===
#     while true; do
#         echo ""
#         read -p "🔁 Would you like to export another branch or repo? (y/n): " CONTINUE
#         CONTINUE_LOWER=$(echo "$CONTINUE" | tr '[:upper:]' '[:lower:]')
#         case "$CONTINUE_LOWER" in
#             y) break ;;
#             n) echo "👋 Exiting. Goodbye!"; exit 0 ;;
#             *) echo "⚠️ Please enter 'y' or 'n'." ;;
#         esac
#     done
# done

#!/bin/bash

# === Configuration ===
GITHUB_PATH="/c/Users/liamramsden/Documents/GitHub"  # Windows-style path for Git Bash
OUTPUT_FILE="commit_log.csv"

# === Script Loop ===
while true; do
    echo "📂 Available Repositories:"
    REPOS=($(find "$GITHUB_PATH" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;))

    if [ ${#REPOS[@]} -eq 0 ]; then
        echo "❌ No repositories found in $GITHUB_PATH."
        exit 1
    fi

    for i in "${!REPOS[@]}"; do
        echo "$((i+1)). ${REPOS[$i]}"
    done

    read -p "🔧 Enter the number of the repository to export commits from: " REPO_CHOICE
    if [[ "$REPO_CHOICE" -gt 0 && "$REPO_CHOICE" -le "${#REPOS[@]}" ]]; then
        REPO_NAME="${REPOS[$((REPO_CHOICE-1))]}"
        REPO_PATH="$GITHUB_PATH/$REPO_NAME"
        echo "🔄 You selected repository: ${REPO_NAME}"
    else
        echo "⚠️ Invalid selection. Please choose a valid number."
        continue
    fi

    cd "$REPO_PATH" || { echo "❌ Repo not found at $REPO_PATH"; exit 1; }

    echo ""
    echo "📦 Available branches:"
    git branch --list
    echo ""

    read -p "🔧 Enter the branch name to export commits from: " BRANCH_NAME
    echo "🔄 Switching to branch '$BRANCH_NAME'..."
    git checkout "$BRANCH_NAME" || { echo "❌ Failed to checkout branch '$BRANCH_NAME'"; continue; }

    read -p "👤 Enter author name to filter by (leave blank for all): " AUTHOR_FILTER
    read -p "📅 From date (YYYY-MM-DD, leave blank for earliest): " FROM_DATE
    read -p "📅 To date (YYYY-MM-DD, leave blank for latest): " TO_DATE

    GIT_LOG_CMD="git log --pretty=format:'%H|%an|%ad|%s' --date=iso"
    [[ -n "$AUTHOR_FILTER" ]] && GIT_LOG_CMD+=" --author=\"$AUTHOR_FILTER\""
    [[ -n "$FROM_DATE" ]] && GIT_LOG_CMD+=" --since=\"$FROM_DATE\""
    [[ -n "$TO_DATE" ]] && GIT_LOG_CMD+=" --until=\"$TO_DATE\""

    echo "📤 Exporting commit log to '$OUTPUT_FILE'..."
    eval "$GIT_LOG_CMD" | \
    awk -F'|' '{
        gsub(/^ +| +$/, "", $3);
        split($3, datetimeParts, " ");
        split(datetimeParts[1], dateParts, "-");
        formattedDate = dateParts[3] "-" dateParts[2] "-" dateParts[1];
        time = datetimeParts[2];
        printf "\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"\n", $1, $2, formattedDate, time, $4
    }' > "$OUTPUT_FILE"

    echo "📂 Opening file..."
    cmd.exe /c start "" "$OUTPUT_FILE"  # Windows-friendly file open

    while true; do
        echo ""
        read -p "🔁 Would you like to export another branch or repo? (y/n): " CONTINUE
        CONTINUE_LOWER=$(echo "$CONTINUE" | tr '[:upper:]' '[:lower:]')
        case "$CONTINUE_LOWER" in
            y) break ;;
            n) echo "👋 Exiting. Goodbye!"; exit 0 ;;
            *) echo "⚠️ Please enter 'y' or 'n'." ;;
        esac
    done
done
