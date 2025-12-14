note
	description: "Base class for queries in mediator CQRS pattern (read-only requests)"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	SIMPLE_QUERY [G]

feature -- Access

	query_name: STRING
			-- Unique identifier for this query type.
		deferred
		ensure
			result_not_empty: Result /= Void and then not Result.is_empty
		end

	correlation_id: detachable STRING
			-- Optional ID to correlate related queries.

	timestamp: DATE_TIME
			-- When the query was created.
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
			-- Is this query valid?
		do
			Result := True  -- Override in descendants for validation
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

end
