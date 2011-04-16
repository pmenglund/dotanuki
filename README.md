Dotanuki
========

Simple but effective executioner of commands, which will deal correctly with
failed commands.

Examples
========
In the following example, if the mkdir fails, none of the other commands will
be executed.

	class Foo
		include 'dotanuki'

		def test
			commands = [
				"mkdir /tmp/foo",
				"cd /tmp/foo",
				"cp /etc/hosts ."
			]

			result = execute(commands)
			if result.failed?
				puts "execution failed: #{result.fail_message}"
			end
		end
	end
