# System configuration
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# History settings
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help"

# Development tools
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1

# macOS specific
export COPYFILE_DISABLE=1
export ARCHFLAGS="-arch $(uname -m)"