eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
export EDITOR="nvim"
export SUDO_EDITOR="$EDITOR"


source ~/.local/share/omarchy/default/bash/aliases


HISTFILE=~/.history
HISTSIZE=10000
SAVEHIST=50000

setopt inc_append_history

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$HOME/.local/share/omarchy/bin:$PATH"

new_tmux () {
  session_dir=$(zoxide query --list | fzf)
  session_name=$(basename "$session_dir")

  if tmux has-session -t $session_name 2>/dev/null; then
    if [ -n "$TMUX" ]; then
      tmux switch-client -t "$session_name"
    else
      tmux attach -t "$session_name"
    fi
    notification="tmux attached to $session_name"
  else
    if [ -n "$TMUX" ]; then
      tmux new-session -d -c "$session_dir" -s "$session_name" && tmux switch-client -t "$session_name"
      notification="new tmux session INSIDE TMUX: $session_name"
    else
      tmux new-session -c "$session_dir" -s "$session_name"
      notification="new tmux session: $session_name"
    fi
  fi

  if [-s "$session_name" ]; then
    notify-send "$notification"
  fi
}

alias tm=new_tmux

# Clear aliases
alias cls='clear'

# GIT
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gco='git checkout -b'
alias gph='git push'
alias gpl='git pull'
alias gfp='git fetch -p'

# Function for gdlb (requires more complex logic)
function gdlb() {
    git branch -vv | grep ": gone]" | awk '{print $1}' | xargs git branch -D
}

# Node
alias dev='npm run dev'
alias sdev='npm run start:dev'
alias lint='npm run lint'
alias tsc='npm run tsc'

# Python
alias pi='pip install'
alias pir='pip install -r requirements.txt'
alias pui='pip uninstall'
alias pfr='pip freeze > requirements.txt'
alias pr='python run.py'

# Virtual environment activation aliases
alias savd='source ./.venv/bin/activate'
alias sav='source ./venv/bin/activate'

# Docker
alias dstart='bash start_all.sh'
alias dstop='bash stop_all.sh'
alias dps='docker ps -a'
alias dcl='docker compose -f docker-compose.local.yaml'
alias dcld='docker compose -f ./deployment/docker-compose.local.yaml'

# Tmux
alias tma='tmux attach -t'
alias tman='tmux new -s'

# Enhanced auto_venv with more options
function auto_venv() {
    # Don't run in command substitution
    # [[ -n "$ZSH_SUBSHELL" ]] && return
    
    local venv_dirs=(".venv" "venv" "env" ".virtualenv")
    local found_venv=""
    
    # Check if we're already in a venv
    if [[ -n "$VIRTUAL_ENV" ]]; then
        # If we moved out of the venv directory, deactivate
        local venv_parent=$(dirname "$VIRTUAL_ENV")
        if [[ "$PWD" != "$venv_parent"* ]]; then
            echo "Leaving virtual environment: $(basename $VIRTUAL_ENV)"
            deactivate
        else
            # Still in the venv directory, no action needed
            return
        fi
    fi
    
    # Look for virtual environment directories
    for venv_dir in $venv_dirs; do
        if [[ -d "$venv_dir" ]] && [[ -f "$venv_dir/bin/activate" ]]; then
            found_venv="$venv_dir"
            break
        fi
    done
    
    # Activate if found
    if [[ -n "$found_venv" ]]; then
        echo "Activating virtual environment: $found_venv"
        source "$found_venv/bin/activate"
    fi
}

# Add hooks
autoload -U add-zsh-hook
add-zsh-hook chpwd auto_venv

# Run on startup (with a slight delay to ensure proper initialization)
(( ${+commands[python]} )) && auto_venv

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
