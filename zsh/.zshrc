# ################### #
# aliases and exports #
# ################### #

export DOTS="$HOME/.dotfiles"
export ZDOTDIR="$DOTS/zsh"

export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=100000000
export SAVEHIST=100000000

setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY

export PATH="$HOME/.local/bin":$PATH
export PATH="$HOME/bin":$PATH
export PATH="/usr/local/bin":$PATH

export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin":$PATH

export PATH="$HOME/.local/share/gem/ruby/3.0.0/bin/":$PATH

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

source $ZDOTDIR/.zsh_aliases
source $ZDOTDIR/ls_colors.zsh

if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
    source "${ZDOTDIR:-$HOME}/.zprofile"
fi


export EDITOR=nvim
export PAGER=less
export BROWSER=firefox


case "$OSTYPE" in
    linux*)
        export TERMINAL=alacritty
    ;;
    darwin*)
        export TERMINAL=/Applications/iTerm.app
    ;;
esac

if [ "`type -p bat`" ]; then
	export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi


if [ "`type -p thefuck`" ]; then
    eval $(thefuck --alias)
fi


# ####### #
# PLUGINS #
# ####### #

[[ -e ~/.antidote ]] || git clone https://github.com/mattmc3/antidote.git ~/.antidote
. ~/.antidote/antidote.zsh
antidote load

# ######### #
# NVM STUFF #
# ######### #

autoload -U add-zsh-hook
load-nvmrc() {
    local node_version="$(nvm version)"
    local nvmrc_path="$(nvm_find_nvmrc)"
    
    if [ -n "$nvmrc_path" ]; then
        local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")
        
        if [ "$nvmrc_node_version" = "N/A" ]; then
            nvm install
            elif [ "$nvmrc_node_version" != "$node_version" ]; then
            nvm use
        fi
        elif [ "$node_version" != "$(nvm version default)" ]; then
        echo "Reverting to nvm default version"
        nvm use default
    fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc



# ##### #
# LS Colours #
# ##### #

zstyle ':compinstall:*default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

export CLICOLORS=1


# ###### #
# PROMPT #
# ###### #

setopt PROMPT_SUBST

status_ok() {echo '%F{green}\uf00c%f'}

status_err() {echo '%F{red}\uf467%f'}

ret_status() {echo "%(?:$(status_ok):$(status_err))"}

prompt_indicator() {echo "%F{cyan}\uf054%f"}

prompt_username() {echo "%F{blue}%n%f@%F{blue}%m%f"}

prompt_dir() {echo "%F{9}%~%f"}

git_status() {
    if (( $+commands[git] )) && $(git branch >/dev/null 2>&1); then
        print -n "%F{magenta}%B"
        print -n "$(git rev-parse --abbrev-ref HEAD 2>/dev/null)%b:"
        # untracked
        [[ "$(git clean -n 2>/dev/null | wc -l)" -ne "0" ]] && print -n "%{%F{red}%}?%{%f%}"
        
        # dirty
        $(git diff-index --quiet HEAD >/dev/null 2>&1) || print -n "%{%F{yellow}%}!%{%f%}"
        print -n " \u00b1%{%f%k%}"
    fi
    
}

PROMPT='$(ret_status) $(prompt_username) $(prompt_dir) $(prompt_indicator) '
RPROMPT='[$(git_status)]'

