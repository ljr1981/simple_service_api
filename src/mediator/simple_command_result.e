note
	description: "Result of executing a command through the mediator"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_COMMAND_RESULT

create
	make_success,
	make_failure

feature {NONE} -- Initialization

	make_success
			-- Create successful result.
		do
			is_success := True
			create errors.make (0)
			create data.make (0)
		ensure
			success: is_success
		end

	make_failure (a_error: STRING)
			-- Create failure result with error message.
		require
			error_not_empty: not a_error.is_empty
		do
			is_success := False
			create errors.make (1)
			errors.extend (a_error)
			create data.make (0)
		ensure
			failure: not is_success
			has_error: not errors.is_empty
		end

feature -- Access

	is_success: BOOLEAN
			-- Did the command succeed?

	is_failure: BOOLEAN
			-- Did the command fail?
		do
			Result := not is_success
		end

	errors: ARRAYED_LIST [STRING]
			-- Error messages if failed.

	first_error: detachable STRING
			-- First error message, if any.
		do
			if not errors.is_empty then
				Result := errors.first
			end
		end

	data: HASH_TABLE [ANY, STRING]
			-- Optional result data.

	affected_count: INTEGER
			-- Number of affected records/items (for DB operations etc.)

feature -- Data Access

	has_data (a_key: STRING): BOOLEAN
			-- Does result have data for `a_key'?
		do
			Result := data.has (a_key)
		end

	item (a_key: STRING): detachable ANY
			-- Data value for `a_key'.
		do
			Result := data.item (a_key)
		end

	string_item (a_key: STRING): detachable STRING
			-- String value for `a_key'.
		do
			if attached {STRING} data.item (a_key) as l_str then
				Result := l_str
			end
		end

	integer_item (a_key: STRING): INTEGER
			-- Integer value for `a_key'.
		do
			if attached {INTEGER_REF} data.item (a_key) as l_int then
				Result := l_int.item
			end
		end

feature -- Modification

	add_error (a_error: STRING)
			-- Add error message.
		require
			error_not_empty: not a_error.is_empty
		do
			errors.extend (a_error)
			is_success := False
		ensure
			has_error: errors.has (a_error)
			is_failure: not is_success
		end

	put_data (a_key: STRING; a_value: ANY)
			-- Add result data.
		require
			key_not_empty: not a_key.is_empty
		do
			data.force (a_value, a_key)
		ensure
			has_data: has_data (a_key)
		end

	set_affected_count (a_count: INTEGER)
			-- Set affected count.
		do
			affected_count := a_count
		ensure
			count_set: affected_count = a_count
		end

feature -- Conversion

	to_string: STRING
			-- String representation.
		do
			create Result.make (50)
			if is_success then
				Result.append ("Success")
				if affected_count > 0 then
					Result.append (" (")
					Result.append_integer (affected_count)
					Result.append (" affected)")
				end
			else
				Result.append ("Failure: ")
				if attached first_error as l_err then
					Result.append (l_err)
				else
					Result.append ("Unknown error")
				end
			end
		end

invariant
	errors_attached: errors /= Void
	data_attached: data /= Void

end
