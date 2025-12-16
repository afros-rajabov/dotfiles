function new_tmux
    set -l session_dir (zoxide query --list | fzf)

    if test -z "$session_dir"
        echo "No directory selected"
        return
    end

    set -l session_name (basename "$session_dir")

    if tmux has-session -t $session_name 2>/dev/null
        if set -q TMUX
            tmux switch-client -t "$session_name"
        else
            tmux attach -t "$session_name"
        end
        set notification "tmux attached to $session_name"
    else
        if set -q TMUX
            tmux new-session -d -c "$session_dir" -s "$session_name" && tmux switch-client -t "$session_name"
            set notification "new tmux session INSIDE TMUX: $session_name"
        else
            tmux new-session -c "$session_dir" -s "$session_name"
            set notification "new tmux session: $session_name"
        end
    end

    # Check if notify-send exists and session_name is not empty
    if command -q notify-send && test -n "$session_name"
        notify-send "$notification"
    end
end
