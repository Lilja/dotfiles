function sw --description "Worktree-aware branch switch; no args jumps to the main worktree"
    if test (count $argv) -gt 1
        echo "Usage: sw [branch]"
        return 1
    end

    set -l porcelain (git worktree list --porcelain 2>/dev/null)
    or begin
        echo "Not in a git repository"
        return 1
    end

    # No args: the first entry of `git worktree list` is always the main worktree
    if test (count $argv) -eq 0
        set -l main_path (string replace "worktree " "" -- $porcelain[1])
        if contains -- bare $porcelain
            echo "Main worktree is a bare repository, nothing to switch to"
            return 1
        end
        if test (git rev-parse --show-toplevel) = "$main_path"
            echo "Already on main worktree at $main_path"
            return 0
        end
        echo "Switching to main worktree at $main_path"
        cd $main_path
        return
    end

    set -l branch $argv[1]
    set -l worktree_path ""

    # Parse `git worktree list --porcelain` to find if branch is on a worktree
    set -l current_path ""
    for line in $porcelain
        if string match -q "worktree *" -- $line
            set current_path (string replace "worktree " "" -- $line)
        else if test "$line" = "branch refs/heads/$branch"
            set worktree_path $current_path
            break
        end
    end

    if test -n "$worktree_path"; and not test -d "$worktree_path"
        echo "Branch '$branch' is on a stale worktree ($worktree_path no longer exists), run `git worktree prune`"
        return 1
    end

    if test -n "$worktree_path"
        echo "Branch '$branch' is on worktree at $worktree_path, switching to it"
        cd $worktree_path
    else
        git switch $branch
    end
end
