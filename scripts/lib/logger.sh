#!/bin/zsh

# Centralized logging utility for dotfiles
# Provides standardized, high-contrast output for transparent terminals

# Guard against multiple sourcing
if [[ -n ${LOGGER_LOADED:-} ]]; then
  return 0
fi
LOGGER_LOADED=1

# High-contrast color primitives for transparent terminals
# Using bright variants for better visibility
if [[ -z ${LOG_RED:-} ]]; then
  LOG_RED='\033[1;91m'     # Bright red
  LOG_GREEN='\033[1;92m'   # Bright green
  LOG_YELLOW='\033[1;93m'  # Bright yellow
  LOG_BLUE='\033[1;94m'    # Bright blue
  LOG_MAGENTA='\033[1;95m' # Bright magenta
  LOG_CYAN='\033[1;96m'    # Bright cyan
  LOG_WHITE='\033[1;97m'   # Bright white
  LOG_BOLD='\033[1m'       # Bold
  LOG_RESET='\033[0m'      # Reset
fi

# Block-style logging functions
log_info() {
  echo -e "${LOG_CYAN}[INFO]${LOG_RESET} $1"
}

log_success() {
  echo -e "${LOG_GREEN}[SUCCESS]${LOG_RESET} $1"
}

log_warning() {
  echo -e "${LOG_YELLOW}[WARNING]${LOG_RESET} $1"
}

log_error() {
  echo -e "${LOG_RED}[ERROR]${LOG_RESET} $1"
}

log_debug() {
  echo -e "${LOG_MAGENTA}[DEBUG]${LOG_RESET} $1"
}

# Header for major sections
log_header() {
  echo -e "${LOG_BLUE}[SECTION]${LOG_RESET} ${LOG_BOLD}$1${LOG_RESET}"
}

# Step logging for processes
log_step() {
  echo -e "${LOG_WHITE}[STEP]${LOG_RESET} $1"
}

# File logging with timestamp
log_to_file() {
  local log_file="${1:-$HOME/config.log}"
  local message="$2"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >>"$log_file"
}

# Combined console and file logging
log_info_file() {
  local message="$1"
  local log_file="${2:-$HOME/config.log}"
  log_info "$message"
  log_to_file "$log_file" "INFO: $message"
}

log_success_file() {
  local message="$1"
  local log_file="${2:-$HOME/config.log}"
  log_success "$message"
  log_to_file "$log_file" "SUCCESS: $message"
}

log_warning_file() {
  local message="$1"
  local log_file="${2:-$HOME/config.log}"
  log_warning "$message"
  log_to_file "$log_file" "WARNING: $message"
}

log_error_file() {
  local message="$1"
  local log_file="${2:-$HOME/config.log}"
  log_error "$message"
  log_to_file "$log_file" "ERROR: $message"
}

# Progress indicator
log_progress() {
  local current="$1"
  local total="$2"
  local message="$3"
  echo -e "${LOG_CYAN}[PROGRESS]${LOG_RESET} ($current/$total) $message"
}

# Dry run indicator
log_dry_run() {
  echo -e "${LOG_YELLOW}[DRY RUN]${LOG_RESET} $1"
}

# Legacy compatibility functions (for gradual migration)
print_success() { log_success "$1"; }
print_error() { log_error "$1"; }
print_warning() { log_warning "$1"; }
print_info() { log_info "$1"; }
print_header() { log_header "$1"; }
