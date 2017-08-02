This directory is for scripts/things that doesn't need to be put in a PATH, like a bin directory, but only used for other resources that would source it and move on.

For example, take color.bash.
This is a rather simple script, you enter text betweeen a ${} and ${NC}. If you use that string with an -e parameter, it will output that text.
This is one of those scripts that you never need at CLI, but maybe inside a script. Thus, you don't need it in $PATH. But it's always nice to have a bin where to access these types of files.

Another example would be git-prompt.sh. You only need it for .bashrc or whatever your shell is.
