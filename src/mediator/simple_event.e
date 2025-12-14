note
	description: "Event object for mediator pub/sub communication"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_EVENT

create
	make,
	make_with_data

feature {NONE} -- Initialization

	make (a_name: READABLE_STRING_8)
			-- Create event with `a_name'.
		require
			name_not_empty: not a_name.is_empty
		do
			create name.make_from_string (a_name)
			create timestamp.make_now
			create data.make (0)
		ensure
			name_set: name.same_string (a_name)
		end

	make_with_data (a_name: READABLE_STRING_8; a_data: HASH_TABLE [ANY, STRING])
			-- Create event with `a_name' and `a_data'.
		require
			name_not_empty: not a_name.is_empty
		do
			create name.make_from_string (a_name)
			create timestamp.make_now
			data := a_data
		ensure
			name_set: name.same_string (a_name)
			data_set: data = a_data
		end

feature -- Access

	name: STRING
			-- Event name/type identifier.

	timestamp: DATE_TIME
			-- When the event was created.

	data: HASH_TABLE [ANY, STRING]
			-- Event payload data.

	source: detachable ANY
			-- Optional source object that raised the event.

feature -- Data Access

	has_key (a_key: STRING): BOOLEAN
			-- Does event have data for `a_key'?
		do
			Result := data.has (a_key)
		end

	item (a_key: STRING): detachable ANY
			-- Data value for `a_key', if any.
		do
			Result := data.item (a_key)
		end

	string_item (a_key: STRING): detachable STRING
			-- String value for `a_key', if any.
		do
			if attached {STRING} data.item (a_key) as l_str then
				Result := l_str
			end
		end

	integer_item (a_key: STRING): INTEGER
			-- Integer value for `a_key' (0 if not found or wrong type).
		do
			if attached {INTEGER_REF} data.item (a_key) as l_int then
				Result := l_int.item
			elseif attached {INTEGER} data.item (a_key) as l_int then
				Result := l_int
			end
		end

feature -- Modification

	set_source (a_source: ANY)
			-- Set event source.
		do
			source := a_source
		ensure
			source_set: source = a_source
		end

	put (a_key: STRING; a_value: ANY)
			-- Add or replace data with `a_key'.
		require
			key_not_empty: not a_key.is_empty
		do
			data.force (a_value, a_key)
		ensure
			has_key: has_key (a_key)
		end

	put_string (a_key: STRING; a_value: STRING)
			-- Add string value.
		require
			key_not_empty: not a_key.is_empty
		do
			data.force (a_value, a_key)
		end

	put_integer (a_key: STRING; a_value: INTEGER)
			-- Add integer value.
		require
			key_not_empty: not a_key.is_empty
		do
			data.force (a_value, a_key)
		end

	put_boolean (a_key: STRING; a_value: BOOLEAN)
			-- Add boolean value.
		require
			key_not_empty: not a_key.is_empty
		do
			data.force (a_value, a_key)
		end

feature -- Conversion

	to_string: STRING
			-- String representation of event.
		do
			create Result.make (100)
			Result.append ("Event[")
			Result.append (name)
			Result.append ("] at ")
			Result.append (timestamp.out)
			if data.count > 0 then
				Result.append (" with ")
				Result.append_integer (data.count)
				Result.append (" data items")
			end
		end

invariant
	name_not_empty: not name.is_empty
	timestamp_attached: timestamp /= Void
	data_attached: data /= Void

end
