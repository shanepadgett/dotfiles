#!/bin/bash

# Comprehensive shell script linting with shellcheck
# Usage: ./scripts/lint-shell.sh [--fix] [--verbose] [file1.sh file2.sh ...]

set -euo pipefail

# Source centralized logging system
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/logger.sh"

# Check if shellcheck is available
if ! command -v shellcheck &>/dev/null; then
  print_error "shellcheck is not installed"
  print_info "Install with: apt-get install shellcheck (Ubuntu) or brew install shellcheck (macOS)"
  exit 1
fi

# Parse arguments
FIX_MODE=false
VERBOSE_MODE=false
SPECIFIC_FILES=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --fix)
      FIX_MODE=true
      shift
      ;;
    --verbose | -v)
      VERBOSE_MODE=true
      shift
      ;;
    --help | -h)
      echo "Usage: $0 [OPTIONS] [FILES...]"
      echo ""
      echo "OPTIONS:"
      echo "  --fix         Show detailed fix suggestions for each issue"
      echo "  --verbose,-v  Show verbose output including clean files"
      echo "  --help,-h     Show this help message"
      echo ""
      echo "EXAMPLES:"
      echo "  $0                           # Check all shell scripts"
      echo "  $0 --verbose                 # Check all with verbose output"
      echo "  $0 --fix script.sh           # Check specific file with fix suggestions"
      echo "  $0 install.sh scripts/*.sh   # Check specific files"
      exit 0
      ;;
    *.sh)
      SPECIFIC_FILES+=("$1")
      shift
      ;;
    *)
      print_error "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

print_header "Shell Script Linting with shellcheck"

# Determine which files to check
if [[ ${#SPECIFIC_FILES[@]} -gt 0 ]]; then
  FILES_TO_CHECK=("${SPECIFIC_FILES[@]}")
  print_info "Checking ${#FILES_TO_CHECK[@]} specified files..."
else
  # Find all shell scripts
  mapfile -t FILES_TO_CHECK < <(find . -name "*.sh" -not -path "./.git/*" | sort)
  print_info "Checking ${#FILES_TO_CHECK[@]} shell scripts in repository..."
fi

# Counters
total_files=0
clean_files=0
files_with_issues=0
total_issues=0

# Arrays to store results
declare -a clean_file_list=()
declare -a problematic_files=()

print_info "Running shellcheck analysis..."
echo

# Check each file
for file in "${FILES_TO_CHECK[@]}"; do
  total_files=$((total_files + 1))

  if [[ ! -f $file ]]; then
    print_warning "File not found: $file"
    continue
  fi

  # Run shellcheck and capture output
  if shellcheck_output=$(shellcheck "$file" 2>&1); then
    # File is clean
    clean_files=$((clean_files + 1))
    clean_file_list+=("$file")

    if [[ $VERBOSE_MODE == "true" ]]; then
      echo "✅ $file"
    fi
  else
    # File has issues
    files_with_issues=$((files_with_issues + 1))
    problematic_files+=("$file")

    # Count issues in this file
    issue_count=$(echo "$shellcheck_output" | grep -c "^In.*line" || true)
    total_issues=$((total_issues + issue_count))

    echo "❌ $file ($issue_count issues)"

    if [[ $FIX_MODE == "true" ]]; then
      echo "   Issues found:"
      while IFS= read -r line; do
        echo "   $line"
      done <<<"$shellcheck_output"
      echo
    else
      # Show just the first few lines for summary
      echo "$shellcheck_output" | head -3 | while IFS= read -r line; do
        echo "   $line"
      done
      if [[ $issue_count -gt 1 ]]; then
        echo "   ... and $((issue_count - 1)) more issues"
      fi
      echo
    fi
  fi
done

# Print summary
echo
print_header "SUMMARY"
echo "📊 Files checked: $total_files"
echo "✅ Clean files: $clean_files"
echo "❌ Files with issues: $files_with_issues"
echo "🔍 Total issues: $total_issues"

if [[ $files_with_issues -eq 0 ]]; then
  echo
  print_success "🎉 ALL SHELL SCRIPTS PASS SHELLCHECK!"

  if [[ $VERBOSE_MODE == "true" && ${#clean_file_list[@]} -gt 0 ]]; then
    echo
    print_info "Clean files:"
    for file in "${clean_file_list[@]}"; do
      echo "  ✅ $file"
    done
  fi

  exit 0
else
  echo
  print_error "❌ $files_with_issues files need attention"

  echo
  print_info "Files with issues:"
  for file in "${problematic_files[@]}"; do
    issue_count=$(shellcheck "$file" 2>&1 | grep -c "^In.*line" || true)
    echo "  ❌ $file ($issue_count issues)"
  done

  echo
  print_info "💡 NEXT STEPS:"
  echo "1. Run with --fix flag to see detailed fix suggestions:"
  echo "   ./scripts/lint-shell.sh --fix"
  echo
  echo "2. Or check specific files:"
  echo "   ./scripts/lint-shell.sh --fix ${problematic_files[0]}"
  echo
  echo "3. After fixing, run again to verify:"
  echo "   ./scripts/lint-shell.sh"
  echo
  echo "4. Also run formatting to ensure consistent style:"
  echo "   ./scripts/format-shell.sh"

  exit 1
fi
