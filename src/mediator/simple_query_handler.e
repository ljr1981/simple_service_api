note
	description: "Deferred class for query handlers in the mediator pattern"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SIMPLE_QUERY_HANDLER [Q -> SIMPLE_QUERY [G], G]

feature -- Access

	handled_query_name: STRING
			-- Name of the query this handler processes.
		deferred
		ensure
			result_not_empty: Result /= Void and then not Result.is_empty
		end

feature -- Status

	handles_query (a_query: SIMPLE_QUERY [ANY]): BOOLEAN
			-- Can this handler process `a_query'?
		do
			Result := a_query.query_name.same_string (handled_query_name)
		end

feature -- Execution

	handle (a_query: Q): detachable G
			-- Execute `a_query' and return result.
		require
			query_attached: a_query /= Void
			query_valid: a_query.is_valid
		deferred
		end

	try_handle (a_query: Q): detachable G
			-- Execute `a_query' with error catching.
		require
			query_attached: a_query /= Void
		local
			l_retried: BOOLEAN
		do
			if not l_retried and then a_query.is_valid then
				Result := handle (a_query)
			end
		rescue
			l_retried := True
			retry
		end

end
