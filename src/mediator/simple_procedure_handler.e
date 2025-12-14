note
	description: "Event handler that wraps a procedure for simple event handling"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_PROCEDURE_HANDLER

inherit
	SIMPLE_EVENT_HANDLER

create
	make,
	make_multi

feature {NONE} -- Initialization

	make (a_event_name: STRING; a_procedure: PROCEDURE [SIMPLE_EVENT])
			-- Create handler for single event type.
		require
			name_not_empty: not a_event_name.is_empty
			procedure_attached: a_procedure /= Void
		do
			create handled_events_impl.make (1)
			handled_events_impl.extend (a_event_name)
			procedure := a_procedure
			enabled_impl := True
		ensure
			handles_event: handles_event (a_event_name)
			enabled: is_enabled
		end

	make_multi (a_event_names: ARRAY [STRING]; a_procedure: PROCEDURE [SIMPLE_EVENT])
			-- Create handler for multiple event types.
		require
			names_not_empty: not a_event_names.is_empty
			procedure_attached: a_procedure /= Void
		local
			i: INTEGER
		do
			create handled_events_impl.make (a_event_names.count)
			from i := a_event_names.lower until i > a_event_names.upper loop
				handled_events_impl.extend (a_event_names [i])
				i := i + 1
			end
			procedure := a_procedure
			enabled_impl := True
		ensure
			enabled: is_enabled
		end

feature -- Access

	handled_events: ARRAYED_LIST [STRING]
			-- <Precursor>
		do
			Result := handled_events_impl
		end

feature -- Execution

	handle (a_event: SIMPLE_EVENT)
			-- <Precursor>
		do
			procedure.call ([a_event])
		end

feature {NONE} -- Implementation

	handled_events_impl: ARRAYED_LIST [STRING]
			-- Events this handler processes.

	procedure: PROCEDURE [SIMPLE_EVENT]
			-- The procedure to call when handling events.

invariant
	procedure_attached: procedure /= Void
	events_not_empty: not handled_events_impl.is_empty

end
