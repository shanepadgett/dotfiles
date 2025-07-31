# Git-related shell functions

# Git commit and push function
gcp() {
    if [ -z "$1" ]; then
        echo "Error: Commit message required"
        echo "Usage: gcp \"commit message\""
        return 1
    fi
    git add --all && git commit -m "$1" && git push
}
