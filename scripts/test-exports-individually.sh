#!/bin/bash

# Test each export file individually to find the problematic one

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/lib/logger.sh"

# Test function
test_app() {
    print_info "Testing if Block Goose AI agent UI opens..."
    print_info "Please try to open the app now and type 'y' if it works, 'n' if it doesn't: "
    read -r response
    [[ "$response" =~ ^[Yy]$ ]]
}

print_header "Testing Individual Export Files"

# First, ensure exports directory is removed
if [[ -d "$HOME/.exports" ]]; then
    print_info "Backing up current exports directory..."
    mv "$HOME/.exports" "$HOME/.exports.full-backup"
fi

# Create a temporary exports directory
mkdir -p "$HOME/.exports"

# Test each export file individually
export_files=(
    "system.sh"
    "editor.sh"
    "path.sh"
    "development.sh"
)

for export_file in "${export_files[@]}"; do
    print_header "Testing with only $export_file"
    
    # Copy only this export file
    if [[ -f "$HOME/.exports.full-backup/$export_file" ]]; then
        cp "$HOME/.exports.full-backup/$export_file" "$HOME/.exports/$export_file"
        
        # Source the shell to apply changes
        print_info "Please open a new terminal window to apply changes, then test the app"
        
        if test_app; then
            print_success "App works with $export_file"
        else
            print_error "App FAILS with $export_file - THIS IS THE PROBLEM FILE!"
            
            # Show contents of the problematic file
            print_info "Contents of $export_file:"
            cat "$HOME/.exports/$export_file"
        fi
        
        # Remove the file for next test
        rm "$HOME/.exports/$export_file"
    else
        print_warning "$export_file not found in backup"
    fi
    
    echo
done

# Test with all files except one at a time
print_header "Testing with all files EXCEPT one"

for skip_file in "${export_files[@]}"; do
    print_info "Testing with all exports EXCEPT $skip_file"
    
    # Copy all files except the skip file
    for export_file in "${export_files[@]}"; do
        if [[ "$export_file" != "$skip_file" ]] && [[ -f "$HOME/.exports.full-backup/$export_file" ]]; then
            cp "$HOME/.exports.full-backup/$export_file" "$HOME/.exports/$export_file"
        fi
    done
    
    print_info "Please open a new terminal window to apply changes, then test the app"
    
    if test_app; then
        print_success "App works WITHOUT $skip_file - $skip_file IS THE PROBLEM!"
    else
        print_info "App still fails without $skip_file"
    fi
    
    # Clean up for next test
    rm -f "$HOME/.exports"/*.sh
done

# Restore or remove based on user preference
print_header "Cleanup"
print_info "Do you want to:"
print_info "1) Keep exports disabled (app will work)"
print_info "2) Restore all exports (app will fail again)"
print_info "3) Restore all exports except the problematic one"
print_info "Enter choice [1-3]: "
read -r choice

case "$choice" in
    1)
        rm -rf "$HOME/.exports"
        print_success "Exports removed - app should continue working"
        ;;
    2)
        rm -rf "$HOME/.exports"
        mv "$HOME/.exports.full-backup" "$HOME/.exports"
        print_warning "All exports restored - app will likely fail again"
        ;;
    3)
        print_info "Which file should we exclude? "
        read -r exclude_file
        rm -rf "$HOME/.exports"
        mv "$HOME/.exports.full-backup" "$HOME/.exports"
        if [[ -f "$HOME/.exports/$exclude_file" ]]; then
            rm "$HOME/.exports/$exclude_file"
            print_success "Restored all exports except $exclude_file"
        fi
        ;;
esac

print_success "Testing complete!"