# ~/.bashrc: executed by bash(1) for non-login shells

umask 022

# Do not set anything else if not running interactively
case $- in
    *i*)
        ;;
    *)
        return
        ;;
esac

# Set a colored prompt if the terminal supports it
case "$TERM" in
    xterm-color|*-256color)
        PS1="\[\e[1;36m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\W\[\e[0m\]"
        COLOR_OPTION="--color=auto"
        ;;
    *)
        PS1="\u@\h:\W"
        ;;
esac

# Set prompt sign according to the current user
if [ "`id -u`" -eq 0 ]; then
    PS1="$PS1# "
else
    PS1="$PS1$ "
fi

alias ls="ls -F --group-directories-first $COLOR_OPTION"
alias la="ls -A"
alias ll="ls -lha"
