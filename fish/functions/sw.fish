function sw --description "Worktree-aware branch switch"
    if test (count $argv) -ne 1
        echo "Usage: sw <branch>"
        return 1
    end

    set -l branch $argv[1]
    set -l worktree_path ""

    # Parse `git worktree list --porcelain` to find if branch is on a worktree
    set -l current_path ""
    for line in (git worktree list --porcelain 2>/dev/null)
        if string match -q "worktree *" -- $line
            set current_path (string replace "worktree " "" -- $line)
        else if test "$line" = "branch refs/heads/$branch"
            set worktree_path $current_path
            break
        end
    end

    if test -n "$worktree_path"
        echo "Branch '$branch' is on worktree at $worktree_path, switching to it"
        cd $worktree_path
    else
        git switch $branch
    end
end
