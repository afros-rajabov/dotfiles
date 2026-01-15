if status is-interactive
    # Commands to run in interactive sessions can go here

    abbr -a -- ls 'ls -la'
    abbr -a -- cls clear

    #GIT
    abbr -a -- gs 'git status'
    abbr -a -- ga 'git add .'

    #commits
    abbr -a -- gc 'git commit -m'
    abbr -a -- gcf "git commit -m 'feat"
    abbr -a -- gcx "git commit -m 'fix"
    abbr -a -- gchx "git commit -m 'hotfix"
    abbr -a -- gcd "git commit -m 'docs"
    abbr -a -- gcs "git commit -m 'style"
    abbr -a -- gcr "git commit -m 'refactor"
    abbr -a -- gcp "git commit -m 'perf"
    abbr -a -- gct "git commit -m 'test"
    abbr -a -- gcb "git commit -m 'build"
    abbr -a -- gcc "git commit -m 'ci"
    abbr -a -- gch "git commit -m 'chore"
    abbr -a -- gcv "git commit -m 'revert"

    # branching
    abbr -a -- gb 'git checkout -b'
    abbr -a -- gbf "git checkout -b feat/"
    abbr -a -- gbx "git checkout -b fix/"
    abbr -a -- gbhx "git checkout -b hotfix/"
    abbr -a -- gbd "git checkout -b docs/"
    abbr -a -- gbs "git checkout -b style/"
    abbr -a -- gbr "git checkout -b refactor/"
    abbr -a -- gbp "git checkout -b perf/"
    abbr -a -- gbt "git checkout -b test/"
    abbr -a -- gbb "git checkout -b build/"
    abbr -a -- gbc "git checkout -b ci/"
    abbr -a -- gbh "git checkout -b chore/"
    abbr -a -- gbv "git checkout -b revert/"

    # syncing
    abbr -a -- gph 'git push'
    abbr -a -- gpl 'git pull'
    abbr -a -- gfp 'git fetch -p'
    abbr -a -- gdlb 'git branch -vv | grep ": gone]" | awk "{print $1}" | xargs git branch -D'

    #Node
    abbr -a -- dev 'npm run dev'
    abbr -a -- sdev 'npm run start:dev'
    abbr -a -- lint 'npm run lint'
    abbr -a -- tsc 'npm run tsc'

    #Python
    abbr -a -- pi 'pip install'
    abbr -a -- pir 'pip install -r requirements.txt'
    abbr -a -- pui 'pip uninstall'
    abbr -a -- pfr 'pip freeze > requirements.txt'
    abbr -a -- pr 'python run.py'
    abbr -a -- savd 'source ./.venv/bin/activate
    abbr -a -- sav 'source ./venv/bin/activate

    #Docker
    abbr -a -- dstart 'bash start_all.sh'
    abbr -a -- dstop 'bash stop_all.sh'
    abbr -a -- dps 'docker ps -a'
    abbr -a -- dcl 'docker compose -f docker-compose.local.yaml'
    abbr -a -- dcld 'docker compose -f ./deployment/docker-compose.local.yaml'

    #Tmux
    abbr -a -- tma 'tmux attach -t '
    abbr -a -- tman 'tmux new -s '

    # NeoVim
    abbr -a -- nv nvim

end

# Created by `pipx` on 2025-02-05 02:27:45
set PATH $PATH /home/afros/.local/bin

function auto_venv --on-variable PWD
    status --is-command-substitution; and return

    # Check if we're already in a venv
    if set -q VIRTUAL_ENV
        # If we moved out of the venv directory, deactivate
        if not contains (pwd) $VIRTUAL_ENV
            deactivate
        end
    end

    # Activate if .venv exists and we're not already in a venv
    if test -f ".venv/bin/activate.fish" -a -z "$VIRTUAL_ENV"
        source .venv/bin/activate.fish
    end
end

alias tm="new_tmux"
alias tml="tmux attach"
alias ef="yazi"
alias c='opencode'
alias kssh="kitten ssh"

export FZF_DEFAULT_OPTS="--layout=reverse"
export MANPAGER="nvim +Man!"

starship init fish | source
