note
	description: "Base class for commands in mediator CQRS pattern"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SIMPLE_COMMAND

feature -- Access

	command_name: STRING
			-- Unique identifier for this command type.
		deferred
		ensure
			result_not_empty: Result /= Void and then not Result.is_empty
		end

	correlation_id: detachable STRING
			-- Optional ID to correlate related commands/events.

	timestamp: DATE_TIME
			-- When the command was created.
		do
			if attached timestamp_impl as l_ts then
				Result := l_ts
			else
				create Result.make_now
				timestamp_impl := Result
			end
		ensure
			result_attached: Result /= Void
		end

feature -- Status

	is_valid: BOOLEAN
			-- Is this command valid and ready to execute?
		do
			Result := True  -- Override in descendants for validation
		end

	validation_errors: ARRAYED_LIST [STRING]
			-- List of validation error messages.
		do
			if attached validation_errors_impl as l_ve then
				Result := l_ve
			else
				create Result.make (0)
				validation_errors_impl := Result
			end
		end

feature -- Modification

	set_correlation_id (a_id: STRING)
			-- Set correlation ID.
		require
			id_not_empty: not a_id.is_empty
		do
			correlation_id := a_id
		ensure
			id_set: attached correlation_id as l_id and then l_id.same_string (a_id)
		end

feature {NONE} -- Implementation

	timestamp_impl: detachable DATE_TIME
			-- Cached timestamp.

	validation_errors_impl: detachable ARRAYED_LIST [STRING]
			-- Cached validation errors.

end
