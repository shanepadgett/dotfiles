# Replace ls with eza (adds icons, git status, and better colors)
alias ls='eza --icons --group-directories-first'
alias ll='eza -lah --icons --group-directories-first --git'
alias la='eza -A --icons'
alias tree='eza --tree --icons'

# Replace cat with bat (syntax highlighting and paging)
alias cat='bat --paging=never'
alias preview='bat'

# Replace grep with ripgrep (way faster, respects .gitignore)
alias grep='rg'

# Replace find with fd
alias find='fd'

# --- Tool Specific Aliases ---
# Chezmoi
alias cm="chezmoi"
alias cma="chezmoi add"
alias cme="chezmoi edit --apply"
alias cmes="chezmoi-symlink edit"
alias cmdf="chezmoi diff"
alias cmap="chezmoi -v apply"
alias cmu="chezmoi update"
alias cz="cme ~/.zshrc"
alias cmeo="cmes ~/.config/opencode/opencode.json"
alias cmeg="cme '/Users/shanepadgett/Library/Application Support/com.mitchellh.ghostty/config'"

# Directory Nav
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~'
alias dev='cd $DEV_PATH'

# Teach me helpers
alias h='history 0'
alias hg='history 0 | rg'     # search history with ripgrep
alias which='type -a'         # more informative than macOS which
alias path='echo $PATH | tr ":" "\n"'
alias fpath='echo $fpath | tr " " "\n"'

# Git (Keeping your flow, but adding lazygit)
alias g='git'
alias lg='lazygit'  # This is a game changer for staging hunks
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -m'
alias gca='git commit -am'
alias gp='git push'
alias gpl='git pull'
alias gst='git status'
alias gl='git log --oneline --graph --decorate'
alias gco='git checkout'

# System
alias top='btop'    # Use that aesthetic system monitor instead of top
alias help='tldr'   # Use tldr for quick command examples
alias brewup="brew bundle --file=~/Brewfile"

# Utilities
alias cc='pbcopy <'
alias reload='source ~/.zshrc' # Renamed from 'source' to avoid shadowing the command

# System / inspection
alias path='echo $PATH | tr ":" "\n"' # Print PATH line by line
alias ports='lsof -i -P | grep LISTEN' # Show listening ports
alias sz='source ~/.zshrc' # Reload config
alias envs='printenv | sort' # Print environment variables sorted
alias shims='ls $HOME/.local/share/mise/shims' # Show mise shims

# Mise helpers (short, beginner-friendly)
alias m='mise'
alias mi="mise use -g"     # Install runtime verion e.g. mi go@1.25.5
alias mc='mise current'
alias md='mise doctor'
alias mr='mise reshim'

# Runtimes
# Managed by `mise` (see lazy activation in `~/.zshrc`).

# npm workflow helpers
alias ni='npm install'              # Install dependencies
alias nig='npm install -g'          # Install dependencies
alias nr='npm run'                  # Run a script from package.json (ex: nr dev)
alias ndev='npm run dev'            # Common dev script shortcut
alias ntest='npm test'              # Run test script
alias nup='npm update'              # Update dependencies semver-safely
alias nout='npm outdated'           # List outdated dependencies
alias nclean='rm -rf node_modules package-lock.json' # Wipe install state if things break
alias nrel='npm install'            # Reinstall after running nclean (ex: nclean && nrel)
alias nver='node -v && npm -v'      # Print active node + npm version quickly

# Bun shortcuts
alias bi='bun install'      # Install dependencies
alias big='bun install -g'  # Install dependencies
alias bug='bun remove -g'  # Install dependencies
alias br='bun run'          # Run a script from package.json
alias bx='bunx'             # Execute packages without installing (like npx)
alias bdev='bun run dev'    # Run the "dev" script quickly
alias btest='bun test'      # Run Bun test runner
alias bup='bun upgrade'     # Upgrade dependencies
alias bout='bun outdated'   # Check outdated deps
alias bs='bunx serve'  # Serve static content from directory

# Deno shortcuts
alias dr='deno run -A'    # Run a Deno script with all permissions
alias dt='deno test -A'   # Run tests with all permissions
alias dlint='deno lint'   # Run linter
alias dfmt='deno fmt'     # Format code
alias ddoc='deno doc --open' # Open documentation for module
alias dcash='deno cache'  # Cache dependencies
alias drepl='deno repl'   # Open Deno REPL
alias dcheck='deno check' # Type-check without running
alias drun='deno task run' # Run default task if defined
alias dbench='deno bench' # Run benchmarks

# Go runtime & tooling
alias gob='go build'             # Build the current package
alias gor='go run'               # Run a Go file or package
alias got='go test ./...'        # Run all tests in the module
alias gotv='go test -v ./...'    # Run all tests verbosely
alias gom='go mod tidy'          # Clean up and sync go.mod dependencies
alias gomu='go get -u ./...'     # Update all module dependencies
alias gov='go version'           # Show installed Go version
alias godoc='go doc'             # Quick docs for a symbol/package
alias gof='gofmt -w .'         # Format all Go files in place
alias gol='golangci-lint run' # Run linter (after you install golangci-lint)
alias gocov='go test -cover ./...' # Run tests with coverage summary
alias gobench='go test -bench=.' # Run benchmarks in current package
alias goclean='go clean -modcache' # Clear module cache if things get weird

# --- Advanced FZF Integration ---
# This allows you to use 'fzf' to quickly find and open files in Zed
# usage: fo <filename>
fo() {
  local file
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    file=$(git ls-files | fzf)
  else
    file=$(fd --type f | fzf)
  fi
  [[ -n "$file" ]] && zed "$file"
}

proj() {
  local dir
  dir=$(fd --type d --max-depth 2 . $DEV_PATH 2>/dev/null | fzf) && cd "$dir"
}
