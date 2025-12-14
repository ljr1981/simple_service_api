note
	description: "Central mediator for decoupled component communication"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SIMPLE_MEDIATOR

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize mediator.
		do
			create event_bus.make
			create command_handlers.make (10)
			create query_handlers.make (10)
		end

feature -- Access

	event_bus: SIMPLE_EVENT_BUS
			-- Event bus for pub/sub communication.

feature -- Event Operations

	publish (a_event: SIMPLE_EVENT)
			-- Publish event to all subscribers.
		require
			event_attached: a_event /= Void
		do
			event_bus.publish (a_event)
		end

	publish_event (a_name: STRING)
			-- Publish simple named event.
		require
			name_not_empty: not a_name.is_empty
		do
			event_bus.publish_named (a_name)
		end

	publish_event_with_data (a_name: STRING; a_data: HASH_TABLE [ANY, STRING])
			-- Publish event with data payload.
		require
			name_not_empty: not a_name.is_empty
		do
			event_bus.publish_with_data (a_name, a_data)
		end

	subscribe (a_handler: SIMPLE_EVENT_HANDLER)
			-- Subscribe handler to events.
		require
			handler_attached: a_handler /= Void
		do
			event_bus.subscribe (a_handler)
		end

	subscribe_to (a_event_name: STRING; a_procedure: PROCEDURE [SIMPLE_EVENT])
			-- Subscribe procedure to specific event.
		require
			name_not_empty: not a_event_name.is_empty
			procedure_attached: a_procedure /= Void
		do
			event_bus.subscribe_procedure (a_event_name, a_procedure)
		end

	unsubscribe (a_handler: SIMPLE_EVENT_HANDLER)
			-- Unsubscribe handler from events.
		require
			handler_attached: a_handler /= Void
		do
			event_bus.unsubscribe (a_handler)
		end

feature -- Command Operations

	register_command_handler (a_name: STRING; a_handler: SIMPLE_COMMAND_HANDLER [SIMPLE_COMMAND])
			-- Register command handler.
		require
			name_not_empty: not a_name.is_empty
			handler_attached: a_handler /= Void
		do
			command_handlers.force (a_handler, a_name)
		ensure
			registered: has_command_handler (a_name)
		end

	has_command_handler (a_name: STRING): BOOLEAN
			-- Is there a handler for command `a_name'?
		do
			Result := command_handlers.has (a_name)
		end

	send (a_command: SIMPLE_COMMAND): SIMPLE_COMMAND_RESULT
			-- Send command to its handler.
		require
			command_attached: a_command /= Void
		do
			if attached command_handlers.item (a_command.command_name) as l_handler then
				Result := l_handler.try_handle (a_command)
				-- Publish command executed event
				publish_command_executed (a_command, Result)
			else
				create Result.make_failure ("No handler registered for command: " + a_command.command_name)
			end
		ensure
			result_attached: Result /= Void
		end

	send_and_forget (a_command: SIMPLE_COMMAND)
			-- Send command without waiting for result.
		require
			command_attached: a_command /= Void
		local
			l_result: SIMPLE_COMMAND_RESULT
		do
			l_result := send (a_command)
			-- Result discarded
		end

feature -- Query Operations

	register_query_handler (a_name: STRING; a_handler: SIMPLE_QUERY_HANDLER [SIMPLE_QUERY [ANY], ANY])
			-- Register query handler.
		require
			name_not_empty: not a_name.is_empty
			handler_attached: a_handler /= Void
		do
			query_handlers.force (a_handler, a_name)
		ensure
			registered: has_query_handler (a_name)
		end

	has_query_handler (a_name: STRING): BOOLEAN
			-- Is there a handler for query `a_name'?
		do
			Result := query_handlers.has (a_name)
		end

	query (a_query: SIMPLE_QUERY [ANY]): detachable ANY
			-- Execute query and return result.
		require
			query_attached: a_query /= Void
		do
			if attached query_handlers.item (a_query.query_name) as l_handler then
				Result := l_handler.try_handle (a_query)
			end
		end

feature -- Statistics

	event_handler_count: INTEGER
			-- Number of registered event handlers.
		do
			Result := event_bus.handler_count
		end

	command_handler_count: INTEGER
			-- Number of registered command handlers.
		do
			Result := command_handlers.count
		end

	query_handler_count: INTEGER
			-- Number of registered query handlers.
		do
			Result := query_handlers.count
		end

feature -- Configuration

	enable_event_history
			-- Enable event history tracking.
		do
			event_bus.enable_history
		end

	disable_event_history
			-- Disable event history tracking.
		do
			event_bus.disable_history
		end

	clear_all
			-- Clear all handlers and history.
		do
			event_bus.clear_handlers
			event_bus.clear_history
			command_handlers.wipe_out
			query_handlers.wipe_out
		ensure
			no_event_handlers: event_handler_count = 0
			no_command_handlers: command_handler_count = 0
			no_query_handlers: query_handler_count = 0
		end

feature {NONE} -- Implementation

	command_handlers: HASH_TABLE [SIMPLE_COMMAND_HANDLER [SIMPLE_COMMAND], STRING]
			-- Registered command handlers by command name.

	query_handlers: HASH_TABLE [SIMPLE_QUERY_HANDLER [SIMPLE_QUERY [ANY], ANY], STRING]
			-- Registered query handlers by query name.

	publish_command_executed (a_command: SIMPLE_COMMAND; a_result: SIMPLE_COMMAND_RESULT)
			-- Publish event that command was executed.
		local
			l_event: SIMPLE_EVENT
			l_data: HASH_TABLE [ANY, STRING]
		do
			create l_data.make (3)
			l_data.put (a_command.command_name, "command_name")
			l_data.put (a_result.is_success, "success")
			if attached a_command.correlation_id as l_id then
				l_data.put (l_id, "correlation_id")
			end
			create l_event.make_with_data ("mediator.command.executed", l_data)
			event_bus.publish (l_event)
		end

invariant
	event_bus_attached: event_bus /= Void
	command_handlers_attached: command_handlers /= Void
	query_handlers_attached: query_handlers /= Void

end
