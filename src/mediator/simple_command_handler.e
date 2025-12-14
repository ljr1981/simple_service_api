note
	description: "Deferred class for command handlers in the mediator pattern"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SIMPLE_COMMAND_HANDLER [C -> SIMPLE_COMMAND]

feature -- Access

	handled_command_name: STRING
			-- Name of the command this handler processes.
		deferred
		ensure
			result_not_empty: Result /= Void and then not Result.is_empty
		end

feature -- Status

	handles_command (a_command: SIMPLE_COMMAND): BOOLEAN
			-- Can this handler process `a_command'?
		do
			Result := a_command.command_name.same_string (handled_command_name)
		end

feature -- Execution

	handle (a_command: C): SIMPLE_COMMAND_RESULT
			-- Execute `a_command' and return result.
		require
			command_attached: a_command /= Void
			command_valid: a_command.is_valid
		deferred
		ensure
			result_attached: Result /= Void
		end

	try_handle (a_command: C): SIMPLE_COMMAND_RESULT
			-- Execute `a_command' with error catching.
		require
			command_attached: a_command /= Void
		local
			l_retried: BOOLEAN
		do
			if l_retried then
				create Result.make_failure ("Handler exception occurred")
			elseif not a_command.is_valid then
				create Result.make_failure ("Command validation failed")
			else
				Result := handle (a_command)
			end
		rescue
			l_retried := True
			retry
		end

end
