note
	description: "Test event handler for mediator tests"
	author: "Larry Rix"
	testing: "type/manual"

class
	TEST_EVENT_HANDLER

inherit
	SIMPLE_EVENT_HANDLER

create
	make,
	make_multi

feature {NONE} -- Initialization

	make (a_event_name: STRING)
			-- Create handler for single event.
		do
			create handled_events_impl.make (1)
			handled_events_impl.extend (a_event_name)
			received_count := 0
			enabled_impl := True
		end

	make_multi (a_event_names: ARRAY [STRING])
			-- Create handler for multiple events.
		local
			i: INTEGER
		do
			create handled_events_impl.make (a_event_names.count)
			from i := a_event_names.lower until i > a_event_names.upper loop
				handled_events_impl.extend (a_event_names [i])
				i := i + 1
			end
			received_count := 0
			enabled_impl := True
		end

feature -- Access

	handled_events: ARRAYED_LIST [STRING]
			-- <Precursor>
		do
			Result := handled_events_impl
		end

	received_count: INTEGER
			-- Number of events received.

	last_event: detachable SIMPLE_EVENT
			-- Last event received.

feature -- Execution

	handle (a_event: SIMPLE_EVENT)
			-- <Precursor>
		do
			received_count := received_count + 1
			last_event := a_event
		end

feature {NONE} -- Implementation

	handled_events_impl: ARRAYED_LIST [STRING]
			-- Events this handler processes.

end
