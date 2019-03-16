ssh_configuration() {
	pub_ssh=$(ls "$HOME"/.ssh/*.pub 2>/dev/null)
	if [ ! -z "$pub_ssh" ]; then
		echo ""
		echo "    Your ssh-key(s):"
		while read key; do
			echo -n "    * " && ssh-keygen -lf "$key"
		done <<< "$pub_ssh"
	else
		echo ""
		echo "    No ssh-keys installed."
	fi
}

ssh_configuration
