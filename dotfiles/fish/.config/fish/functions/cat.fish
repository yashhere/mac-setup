function cat -d "Use bat instead of cat unless it's a Markdown file, then use glow"
	set -l exts md markdown txt

	if not test -f $argv
		echo "File not found: $argv"
		return 0
	end

	if contains (get_ext $argv) $exts
		glow $argv
	else
		command bat --style plain $argv
	end
end