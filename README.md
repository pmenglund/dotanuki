Dotanuki
========

Simple but effective executioner of commands, which will deal correctly with
failed commands.

Examples
========

class Foo
	include 'dotanuki'

	commands = [
		"mkdir /tmp/foo",
		"cd /tmp/foo",
		"cp /etc/hosts ."
	]

	execute(commands)
end