note
	description: "Deferred class for event handlers in the mediator pattern"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SIMPLE_EVENT_HANDLER

feature -- Access

	handled_events: ARRAYED_LIST [STRING]
			-- List of event names this handler processes.
		deferred
		ensure
			result_attached: Result /= Void
		end

feature -- Status

	handles_event (a_event_name: STRING): BOOLEAN
			-- Does this handler process events named `a_event_name'?
		local
			i: INTEGER
		do
			from i := 1 until i > handled_events.count or Result loop
				Result := handled_events.i_th (i).same_string (a_event_name)
				i := i + 1
			end
		end

	is_enabled: BOOLEAN
			-- Is this handler currently active?
		do
			Result := enabled_impl
		end

feature -- Modification

	enable
			-- Enable this handler.
		do
			enabled_impl := True
		ensure
			enabled: is_enabled
		end

	disable
			-- Disable this handler.
		do
			enabled_impl := False
		ensure
			disabled: not is_enabled
		end

feature -- Execution

	handle (a_event: SIMPLE_EVENT)
			-- Process `a_event'.
		require
			event_attached: a_event /= Void
			handles_this_event: handles_event (a_event.name)
			is_enabled: is_enabled
		deferred
		end

feature {NONE} -- Implementation

	enabled_impl: BOOLEAN
			-- Implementation flag for enabled state.

end
