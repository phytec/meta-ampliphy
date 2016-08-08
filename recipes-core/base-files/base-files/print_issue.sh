#!/bin/sh

# Only print the issue for interactive logins, not for scp and sftp sessions.
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
	cat /etc/issue.net
fi
