function gcm --description "Switch to the default branch, worktree-aware"
    set -l default_branch (git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | string replace 'refs/remotes/origin/' '')
    if test -z "$default_branch"
        echo "Could not determine default branch from refs/remotes/origin/HEAD"
        return 1
    end
    sw $default_branch
end
