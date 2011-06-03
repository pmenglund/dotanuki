Dotanuki
========

Simple but effective executioner of commands, which will deal correctly with
failed commands.

Examples
========
In the following example, if the `mkdir` fails, none of the other commands will
be executed.

	class Example
		include Dotanuki

		def test
			commands = [
				"mkdir /tmp/foo",
				"cp /etc/hosts /tmp/foo",
				"cp /etc/passwd /tmp/foo"
			]

			result = execute(commands)
			if result.failed?
				puts "execution failed: #{result.fail_message}"
			end
		end
	end

It can also be used with a `guard` block, which will raise an `ExecError` if a command fails.

    class Example
		include Dotanuki
		def test
			guard do
				execute "mkdir /tmp/foo"
				execute "cp /etc/hosts /tmp/foo"
				execute "cp /etc/passwd /tmp/foo"
			end
		end
    end
