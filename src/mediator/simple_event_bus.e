note
	description: "Event bus for decoupled pub/sub communication between components"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_EVENT_BUS

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize event bus.
		do
			create handlers.make (10)
			create event_history.make (100)
			history_enabled := False
			history_limit := 100
		end

feature -- Access

	handler_count: INTEGER
			-- Number of registered handlers.
		do
			Result := handlers.count
		end

	handlers_for_event (a_event_name: STRING): ARRAYED_LIST [SIMPLE_EVENT_HANDLER]
			-- All handlers that process `a_event_name'.
		local
			i: INTEGER
		do
			create Result.make (5)
			from i := 1 until i > handlers.count loop
				if handlers.i_th (i).handles_event (a_event_name) then
					Result.extend (handlers.i_th (i))
				end
				i := i + 1
			end
		end

	recent_events (a_count: INTEGER): ARRAYED_LIST [SIMPLE_EVENT]
			-- Last `a_count' events (if history enabled).
		local
			i, start_idx: INTEGER
		do
			create Result.make (a_count)
			if history_enabled then
				start_idx := (event_history.count - a_count + 1).max (1)
				from i := start_idx until i > event_history.count loop
					Result.extend (event_history.i_th (i))
					i := i + 1
				end
			end
		end

	history_limit: INTEGER
			-- Maximum number of events to keep in history.

feature -- Status

	has_handlers_for (a_event_name: STRING): BOOLEAN
			-- Are there any handlers registered for `a_event_name'?
		local
			i: INTEGER
		do
			from i := 1 until i > handlers.count or Result loop
				Result := handlers.i_th (i).handles_event (a_event_name)
				i := i + 1
			end
		end

	is_subscribed (a_handler: SIMPLE_EVENT_HANDLER): BOOLEAN
			-- Is `a_handler' currently subscribed?
		do
			Result := handlers.has (a_handler)
		end

	history_enabled: BOOLEAN
			-- Is event history being recorded?

feature -- Subscription

	subscribe (a_handler: SIMPLE_EVENT_HANDLER)
			-- Register `a_handler' to receive events.
		require
			handler_attached: a_handler /= Void
			not_already_subscribed: not is_subscribed (a_handler)
		do
			a_handler.enable
			handlers.extend (a_handler)
		ensure
			subscribed: is_subscribed (a_handler)
			handler_enabled: a_handler.is_enabled
			count_increased: handler_count = old handler_count + 1
		end

	unsubscribe (a_handler: SIMPLE_EVENT_HANDLER)
			-- Remove `a_handler' from receiving events.
		require
			handler_attached: a_handler /= Void
		do
			handlers.prune_all (a_handler)
		ensure
			unsubscribed: not handlers.has (a_handler)
		end

	subscribe_procedure (a_event_name: STRING; a_procedure: PROCEDURE [SIMPLE_EVENT])
			-- Subscribe a procedure as handler for `a_event_name'.
			-- Convenience for simple event handling without creating handler class.
		require
			event_name_not_empty: not a_event_name.is_empty
			procedure_attached: a_procedure /= Void
		local
			l_handler: SIMPLE_PROCEDURE_HANDLER
		do
			create l_handler.make (a_event_name, a_procedure)
			subscribe (l_handler)
		ensure
			handler_added: handler_count = old handler_count + 1
		end

feature -- Publishing

	publish (a_event: SIMPLE_EVENT)
			-- Publish `a_event' to all interested handlers.
		require
			event_attached: a_event /= Void
		local
			i: INTEGER
			l_handler: SIMPLE_EVENT_HANDLER
		do
			-- Record in history if enabled
			if history_enabled then
				record_event (a_event)
			end

			-- Dispatch to all handlers that handle this event type
			from i := 1 until i > handlers.count loop
				l_handler := handlers.i_th (i)
				if l_handler.is_enabled and then l_handler.handles_event (a_event.name) then
					l_handler.handle (a_event)
				end
				i := i + 1
			end
		end

	publish_named (a_event_name: STRING)
			-- Publish a simple event with just a name.
		require
			name_not_empty: not a_event_name.is_empty
		local
			l_event: SIMPLE_EVENT
		do
			create l_event.make (a_event_name)
			publish (l_event)
		end

	publish_with_data (a_event_name: STRING; a_data: HASH_TABLE [ANY, STRING])
			-- Publish event with name and data.
		require
			name_not_empty: not a_event_name.is_empty
		local
			l_event: SIMPLE_EVENT
		do
			create l_event.make_with_data (a_event_name, a_data)
			publish (l_event)
		end

feature -- Configuration

	enable_history
			-- Start recording event history.
		do
			history_enabled := True
		ensure
			enabled: history_enabled
		end

	disable_history
			-- Stop recording event history and clear.
		do
			history_enabled := False
			event_history.wipe_out
		ensure
			disabled: not history_enabled
		end

	set_history_limit (a_limit: INTEGER)
			-- Set maximum events to keep in history.
		require
			positive: a_limit > 0
		do
			history_limit := a_limit
		ensure
			limit_set: history_limit = a_limit
		end

	clear_history
			-- Clear event history.
		do
			event_history.wipe_out
		ensure
			empty: event_history.is_empty
		end

	clear_handlers
			-- Remove all handlers.
		do
			handlers.wipe_out
		ensure
			empty: handler_count = 0
		end

feature {NONE} -- Implementation

	handlers: ARRAYED_LIST [SIMPLE_EVENT_HANDLER]
			-- Registered event handlers.

	event_history: ARRAYED_LIST [SIMPLE_EVENT]
			-- History of published events.

	record_event (a_event: SIMPLE_EVENT)
			-- Add event to history, trimming if needed.
		do
			event_history.extend (a_event)
			if event_history.count > history_limit then
				event_history.start
				event_history.remove
			end
		end

invariant
	handlers_attached: handlers /= Void
	history_attached: event_history /= Void
	positive_limit: history_limit > 0

end
