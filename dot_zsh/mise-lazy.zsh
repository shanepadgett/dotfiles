# Lazy-load mise (activates on first use of runtimes)

_mise_activate_once() {
  unfunction _mise_activate_once 2>/dev/null || true
  eval "$(command mise activate zsh)"
}

# If any of these are defined as aliases (e.g. via ~/.aliases.zsh), remove them.
# In zsh, functions cannot be defined over an alias.
unalias node npm npx bun deno go mise 2>/dev/null || true

mise() { _mise_activate_once; unfunction mise 2>/dev/null || true; command mise "$@"; }
node() { _mise_activate_once; unfunction node 2>/dev/null || true; command node "$@"; }
npm() { _mise_activate_once; unfunction npm 2>/dev/null || true; command npm "$@"; }
npx() { _mise_activate_once; unfunction npx 2>/dev/null || true; command npx "$@"; }
bun() { _mise_activate_once; unfunction bun 2>/dev/null || true; command bun "$@"; }
deno() { _mise_activate_once; unfunction deno 2>/dev/null || true; command deno "$@"; }
go() { _mise_activate_once; unfunction go 2>/dev/null || true; command go "$@"; }
