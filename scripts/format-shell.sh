#!/bin/bash

# Format all shell scripts in the repository using shfmt
# Usage: ./scripts/format-shell.sh [--check]

set -euo pipefail

# Source centralized logging system
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$SCRIPT_DIR/lib/logger.sh"

# Check if shfmt is available
if ! command -v shfmt &>/dev/null; then
  print_error "shfmt is not installed"
  print_info "Install with: go install mvdan.cc/sh/v3/cmd/shfmt@latest"
  exit 1
fi

# Parse arguments
CHECK_MODE=false
if [[ ${1:-} == "--check" ]]; then
  CHECK_MODE=true
fi

# shfmt options:
# -i 2: indent with 2 spaces
# -ci: indent case statements
# -s: simplify code
SHFMT_OPTS=(-i 2 -ci -s)

print_header "Shell Script Formatting"

if [[ $CHECK_MODE == "true" ]]; then
  print_info "Checking shell script formatting..."

  # Find all shell scripts and check formatting
  failed_files=()
  while IFS= read -r -d '' file; do
    if ! shfmt "${SHFMT_OPTS[@]}" -d "$file" >/dev/null 2>&1; then
      failed_files+=("$file")
    fi
  done < <(find . -name "*.sh" -not -path "./.git/*" -print0)

  if [[ ${#failed_files[@]} -eq 0 ]]; then
    print_success "All shell scripts are properly formatted"
    exit 0
  else
    print_error "The following files need formatting:"
    for file in "${failed_files[@]}"; do
      echo "  ❌ $file"
    done
    print_info "Run './scripts/format-shell.sh' to fix formatting"
    exit 1
  fi
else
  print_info "Formatting shell scripts..."

  # Find and format all shell scripts
  formatted_count=0
  total_count=0

  while IFS= read -r -d '' file; do
    total_count=$((total_count + 1))

    # Check if file needs formatting
    if ! shfmt "${SHFMT_OPTS[@]}" -d "$file" >/dev/null 2>&1; then
      print_info "Formatting $file"
      shfmt "${SHFMT_OPTS[@]}" -w "$file"
      formatted_count=$((formatted_count + 1))
    fi
  done < <(find . -name "*.sh" -not -path "./.git/*" -print0)

  if [[ $formatted_count -eq 0 ]]; then
    print_success "All $total_count shell scripts were already properly formatted"
  else
    print_success "Formatted $formatted_count out of $total_count shell scripts"
  fi
fi
