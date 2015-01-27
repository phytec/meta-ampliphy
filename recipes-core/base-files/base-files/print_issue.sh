if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
	cat /etc/issue.net
fi
