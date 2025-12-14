note
	description: "Unified facade for web application services"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SERVICE_API

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize service API.
		do
			-- Composition: foundation accessed via `foundation' feature
		end

feature -- JWT Authentication

	new_jwt (a_secret: STRING): SIMPLE_JWT
			-- Create new JWT handler with `a_secret'.
		require
			secret_not_empty: not a_secret.is_empty
		do
			create Result.make (a_secret)
		end

	create_token (a_secret, a_subject, a_issuer: STRING; a_expires_in_seconds: INTEGER): STRING
			-- Create a JWT token with standard claims.
		require
			secret_not_empty: not a_secret.is_empty
			expires_positive: a_expires_in_seconds > 0
		local
			l_jwt: SIMPLE_JWT
		do
			create l_jwt.make (a_secret)
			Result := l_jwt.create_token_with_claims (a_subject, a_issuer, a_expires_in_seconds, Void)
		ensure
			result_not_empty: not Result.is_empty
		end

	verify_token (a_secret, a_token: STRING): BOOLEAN
			-- Verify JWT token signature and expiration.
		local
			l_jwt: SIMPLE_JWT
		do
			create l_jwt.make (a_secret)
			Result := l_jwt.verify_with_expiration (a_token)
		end

feature -- SMTP Email

	new_smtp (a_host: STRING; a_port: INTEGER): SIMPLE_SMTP
			-- Create new SMTP client for `a_host' on `a_port'.
		require
			host_not_empty: not a_host.is_empty
			port_valid: a_port > 0 and a_port < 65536
		do
			create Result.make (a_host, a_port)
		end

feature -- SQL Database

	new_database (a_path: STRING): SIMPLE_SQL_DATABASE
			-- Create new SQLite database at `a_path'.
		require
			path_not_empty: not a_path.is_empty
		do
			create Result.make (a_path)
		end

	new_memory_database: SIMPLE_SQL_DATABASE
			-- Create new in-memory SQLite database.
		do
			create Result.make_memory
		end

feature -- ORM (Object-Relational Mapping)

	new_orm (a_database: SIMPLE_SQL_DATABASE): SIMPLE_ORM
			-- Create new ORM with database connection.
			-- Provides CRUD operations for entities inheriting SIMPLE_ORM_ENTITY.
		require
			database_open: a_database.is_open
		do
			create Result.make (a_database)
		ensure
			database_set: Result.database = a_database
		end

	new_orm_field (a_name: STRING; a_type: INTEGER): SIMPLE_ORM_FIELD
			-- Create new ORM field descriptor.
			-- Types: type_string=1, type_integer=2, type_integer_64=3,
			--        type_real=4, type_boolean=5, type_datetime=6, type_blob=7
		require
			name_not_empty: not a_name.is_empty
			valid_type: a_type >= 1 and a_type <= 7
		do
			create Result.make (a_name, a_type)
		end

	new_orm_primary_key_field (a_name: STRING): SIMPLE_ORM_FIELD
			-- Create new auto-incrementing integer primary key field.
		require
			name_not_empty: not a_name.is_empty
		do
			create Result.make_primary_key (a_name)
		ensure
			is_primary_key: Result.is_primary_key
			is_auto_increment: Result.is_auto_increment
		end

feature -- CORS

	new_cors: SIMPLE_CORS
			-- Create new CORS handler with default settings.
		do
			create Result.make
		end

	new_cors_permissive: SIMPLE_CORS
			-- Create new CORS handler allowing all origins.
		do
			create Result.make_permissive
		end

feature -- Rate Limiting

	new_rate_limiter (a_max_requests: INTEGER; a_window_seconds: INTEGER): SIMPLE_RATE_LIMITER
			-- Create rate limiter: `a_max_requests' per `a_window_seconds'.
		require
			max_requests_positive: a_max_requests > 0
			window_positive: a_window_seconds > 0
		do
			create Result.make_with_limit (a_max_requests, a_window_seconds)
		end

feature -- Resilience

	new_circuit_breaker (a_failure_threshold: INTEGER; a_cooldown_seconds: INTEGER): SIMPLE_CIRCUIT_BREAKER
			-- Create circuit breaker: opens after `a_failure_threshold' failures,
			-- waits `a_cooldown_seconds' before half-open.
		require
			positive_threshold: a_failure_threshold > 0
			positive_cooldown: a_cooldown_seconds > 0
		do
			create Result.make (a_failure_threshold, a_cooldown_seconds)
		ensure
			is_closed: Result.is_closed
		end

	new_bulkhead (a_max_concurrent: INTEGER): SIMPLE_BULKHEAD
			-- Create bulkhead limiting to `a_max_concurrent' executions.
		require
			positive_limit: a_max_concurrent > 0
		do
			create Result.make (a_max_concurrent)
		ensure
			not_full: not Result.is_full
		end

	new_resilience_policy: SIMPLE_RESILIENCE_POLICY
			-- Create resilience policy builder.
			-- Use fluent API: policy.with_retry(3).with_circuit_breaker(5, 30).with_timeout(10)
		do
			create Result.make
		end

	new_resilience_middleware: SIMPLE_WEB_RESILIENCE_MIDDLEWARE
			-- Create resilience middleware for server pipeline.
		do
			create Result.make_default
		end

	new_resilience_middleware_with_policy (a_policy: SIMPLE_RESILIENCE_POLICY): SIMPLE_WEB_RESILIENCE_MIDDLEWARE
			-- Create resilience middleware with custom policy.
		require
			policy_not_void: a_policy /= Void
		do
			create Result.make_with_policy (a_policy)
		end

feature -- Templates

	new_template: SIMPLE_TEMPLATE
			-- Create new template engine.
		do
			create Result.make
		end

	render_template (a_template: STRING; a_data: detachable HASH_TABLE [STRING, STRING]): STRING
			-- Render `a_template' with `a_data' substitutions.
		local
			l_template: SIMPLE_TEMPLATE
		do
			create l_template.make_from_string (a_template)
			if attached a_data as l_data then
				l_template.set_variables (l_data)
			end
			Result := l_template.render
		end

feature -- WebSocket

	new_ws_handshake: WS_HANDSHAKE
			-- Create new WebSocket handshake handler.
		do
			create Result.make
		end

	new_ws_frame_parser: WS_FRAME_PARSER
			-- Create new WebSocket frame parser.
		do
			create Result.make
		end

	new_ws_text_frame (a_text: STRING; a_is_final: BOOLEAN): WS_FRAME
			-- Create WebSocket text frame with `a_text'.
		do
			create Result.make_text (a_text, a_is_final)
		ensure
			is_text: Result.is_text
			is_final_set: Result.is_fin = a_is_final
		end

	new_ws_binary_frame (a_data: ARRAY [NATURAL_8]; a_is_final: BOOLEAN): WS_FRAME
			-- Create WebSocket binary frame with `a_data'.
		do
			create Result.make_binary (a_data, a_is_final)
		ensure
			is_binary: Result.is_binary
			is_final_set: Result.is_fin = a_is_final
		end

	new_ws_close_frame (a_code: INTEGER; a_reason: STRING): WS_FRAME
			-- Create WebSocket close frame.
		do
			create Result.make_close (a_code, a_reason)
		ensure
			is_close: Result.is_close
		end

	new_ws_ping_frame: WS_FRAME
			-- Create WebSocket ping frame.
		do
			create Result.make_ping
		ensure
			is_ping: Result.is_ping
		end

	new_ws_pong_frame: WS_FRAME
			-- Create WebSocket pong frame.
		do
			create Result.make_pong
		ensure
			is_pong: Result.is_pong
		end

	new_ws_text_message (a_text: STRING): WS_MESSAGE
			-- Create WebSocket text message.
		do
			create Result.make_text (a_text)
		ensure
			is_text: Result.is_text
		end

	new_ws_binary_message (a_data: ARRAY [NATURAL_8]): WS_MESSAGE
			-- Create WebSocket binary message.
		do
			create Result.make_binary (a_data)
		ensure
			is_binary: Result.is_binary
		end

feature -- PDF Generation

	new_pdf: SIMPLE_PDF
			-- Create new PDF generator with default wkhtmltopdf engine.
		do
			create Result.make
		end

	new_pdf_with_chrome: SIMPLE_PDF
			-- Create new PDF generator using Chrome engine.
		do
			create Result.make_with_engine (create {SIMPLE_PDF_CHROME}.make)
		end

	html_to_pdf (a_html: STRING): SIMPLE_PDF_DOCUMENT
			-- Convert HTML string to PDF using default settings.
		require
			html_not_empty: not a_html.is_empty
		do
			Result := pdf.from_html (a_html)
		end

	url_to_pdf (a_url: STRING): SIMPLE_PDF_DOCUMENT
			-- Convert URL to PDF using default settings.
		require
			url_not_empty: not a_url.is_empty
		do
			Result := pdf.from_url (a_url)
		end

	new_pdf_reader: SIMPLE_PDF_READER
			-- Create new PDF text extractor.
		do
			create Result.make
		end

feature -- AI Clients

	new_claude_client,
	new_claude,
	claude_client: CLAUDE_CLIENT
			-- Create new Claude AI client (uses ANTHROPIC_API_KEY env var).
		do
			create Result.make
		end

	new_claude_client_with_key,
	claude_with_key (a_api_key: STRING): CLAUDE_CLIENT
			-- Create new Claude AI client with explicit API key.
		require
			key_not_empty: not a_api_key.is_empty
		do
			create Result.make_with_api_key (a_api_key)
		end

	new_ollama_client,
	new_ollama,
	ollama_client: OLLAMA_CLIENT
			-- Create new Ollama client (localhost:11434).
		do
			create Result.make
		end

	new_ollama_client_with_url,
	ollama_with_url (a_base_url: STRING): OLLAMA_CLIENT
			-- Create new Ollama client with custom base URL.
		require
			url_not_empty: not a_base_url.is_empty
		do
			create Result.make_with_base_url (a_base_url)
		end

	ask_claude,
	claude_ask (a_prompt: STRING): STRING
			-- Quick ask Claude a question, return response text.
		require
			prompt_not_empty: not a_prompt.is_empty
		local
			l_response: AI_RESPONSE
		do
			l_response := claude.ask (a_prompt)
			if l_response.is_error then
				if attached l_response.error_message as l_err then
					Result := "Error: " + l_err.to_string_8
				else
					Result := "Error: Unknown error"
				end
			else
				Result := l_response.text.to_string_8
			end
		end

	ask_ollama,
	ollama_ask (a_prompt: STRING): STRING
			-- Quick ask Ollama a question, return response text.
		require
			prompt_not_empty: not a_prompt.is_empty
		local
			l_response: AI_RESPONSE
		do
			l_response := ollama.ask (a_prompt)
			if l_response.is_error then
				if attached l_response.error_message as l_err then
					Result := "Error: " + l_err.to_string_8
				else
					Result := "Error: Unknown error"
				end
			else
				Result := l_response.text.to_string_8
			end
		end

feature -- Caching

	new_cache (a_max_size: INTEGER): SIMPLE_CACHE [ANY]
			-- Create new cache with maximum `a_max_size' entries.
		require
			positive_size: a_max_size > 0
		do
			create Result.make (a_max_size)
		ensure
			max_size_set: Result.max_size = a_max_size
			initially_empty: Result.is_empty
		end

	new_cache_with_ttl (a_max_size: INTEGER; a_default_ttl_seconds: INTEGER): SIMPLE_CACHE [ANY]
			-- Create new cache with max size and default TTL.
		require
			positive_size: a_max_size > 0
			positive_ttl: a_default_ttl_seconds > 0
		do
			create Result.make_with_ttl (a_max_size, a_default_ttl_seconds)
		ensure
			max_size_set: Result.max_size = a_max_size
			ttl_set: Result.default_ttl = a_default_ttl_seconds
			initially_empty: Result.is_empty
		end

	new_string_cache (a_max_size: INTEGER): SIMPLE_CACHE [STRING]
			-- Create new string-value cache.
		require
			positive_size: a_max_size > 0
		do
			create Result.make (a_max_size)
		ensure
			max_size_set: Result.max_size = a_max_size
			initially_empty: Result.is_empty
		end

feature -- Graph Data Structures

	new_graph: SIMPLE_GRAPH [ANY]
			-- Create new undirected graph.
		do
			create Result.make
		ensure
			not_directed: not Result.is_directed
			empty: Result.is_empty
		end

	new_directed_graph: SIMPLE_GRAPH [ANY]
			-- Create new directed graph.
		do
			create Result.make_directed
		ensure
			directed: Result.is_directed
			empty: Result.is_empty
		end

	new_string_graph: SIMPLE_GRAPH [STRING]
			-- Create new undirected graph with string nodes.
		do
			create Result.make
		end

	new_directed_string_graph: SIMPLE_GRAPH [STRING]
			-- Create new directed graph with string nodes.
		do
			create Result.make_directed
		end

	new_integer_graph: SIMPLE_GRAPH [INTEGER]
			-- Create new undirected graph with integer nodes.
		do
			create Result.make
		end

feature -- Math and Statistics

	new_math: SIMPLE_MATH
			-- Create new math utility facade.
		do
			create Result.make
		end

	new_vector (a_dimension: INTEGER): SIMPLE_VECTOR
			-- Create new zero vector with `a_dimension' elements.
		require
			positive_dimension: a_dimension > 0
		do
			create Result.make (a_dimension)
		ensure
			dimension_set: Result.dimension = a_dimension
		end

	new_vector_2d (x, y: REAL_64): SIMPLE_VECTOR
			-- Create new 2D vector.
		do
			create Result.make_from_array (<<x, y>>)
		ensure
			dimension_2: Result.dimension = 2
		end

	new_vector_3d (x, y, z: REAL_64): SIMPLE_VECTOR
			-- Create new 3D vector.
		do
			create Result.make_from_array (<<x, y, z>>)
		ensure
			dimension_3: Result.dimension = 3
		end

	new_matrix (a_rows, a_cols: INTEGER): SIMPLE_MATRIX
			-- Create new zero matrix with `a_rows' rows and `a_cols' columns.
		require
			positive_rows: a_rows > 0
			positive_cols: a_cols > 0
		do
			create Result.make (a_rows, a_cols)
		ensure
			rows_set: Result.rows = a_rows
			cols_set: Result.cols = a_cols
		end

	new_identity_matrix (a_size: INTEGER): SIMPLE_MATRIX
			-- Create new identity matrix of size `a_size'.
		require
			positive_size: a_size > 0
		do
			create Result.make_identity (a_size)
		ensure
			square: Result.rows = Result.cols
			size_set: Result.rows = a_size
		end

	new_statistics: SIMPLE_STATISTICS
			-- Create new statistics calculator.
		do
			create Result.make
		end

	new_statistics_from_array (a_values: ARRAY [REAL_64]): SIMPLE_STATISTICS
			-- Create statistics calculator populated with `a_values'.
		do
			create Result.make
			Result.add_all (a_values)
		ensure
			count_set: Result.count = a_values.count
		end

feature -- Redis Caching

	new_redis (a_host: STRING; a_port: INTEGER): SIMPLE_REDIS
			-- Create new Redis client.
		require
			host_not_empty: not a_host.is_empty
			valid_port: a_port > 0 and a_port < 65536
		do
			create Result.make (a_host, a_port)
		end

	new_redis_with_auth (a_host: STRING; a_port: INTEGER; a_password: STRING): SIMPLE_REDIS
			-- Create new Redis client with authentication.
		require
			host_not_empty: not a_host.is_empty
			valid_port: a_port > 0 and a_port < 65536
			password_not_empty: not a_password.is_empty
		do
			create Result.make_with_auth (a_host, a_port, a_password)
		end

	new_redis_cache (a_host: STRING; a_port: INTEGER; a_max_size: INTEGER): SIMPLE_REDIS_CACHE
			-- Create new Redis-backed cache.
		require
			host_not_empty: not a_host.is_empty
			valid_port: a_port > 0 and a_port < 65536
			positive_size: a_max_size > 0
		do
			create Result.make (a_host, a_port, a_max_size)
		end

	new_redis_cache_with_ttl (a_host: STRING; a_port: INTEGER; a_max_size: INTEGER; a_ttl: INTEGER): SIMPLE_REDIS_CACHE
			-- Create new Redis-backed cache with default TTL.
		require
			host_not_empty: not a_host.is_empty
			valid_port: a_port > 0 and a_port < 65536
			positive_size: a_max_size > 0
			positive_ttl: a_ttl > 0
		do
			create Result.make_with_ttl (a_host, a_port, a_max_size, a_ttl)
		end

	new_redis_cache_with_auth (a_host: STRING; a_port: INTEGER; a_max_size: INTEGER; a_password: STRING): SIMPLE_REDIS_CACHE
			-- Create new Redis-backed cache with authentication.
		require
			host_not_empty: not a_host.is_empty
			valid_port: a_port > 0 and a_port < 65536
			positive_size: a_max_size > 0
			password_not_empty: not a_password.is_empty
		do
			create Result.make_with_auth (a_host, a_port, a_max_size, a_password)
		end

feature -- Layer Access

	foundation: FOUNDATION_API
			-- Access to foundation layer features ONLY.
			-- Returns isolated instance - only foundation features visible.
		once
			create Result.make
		end

feature -- Direct Access (Singleton Instances)

	jwt: SIMPLE_JWT
			-- Direct access to JWT handler (create with default empty secret).
			-- Use `new_jwt' for production with actual secret.
		once
			create Result.make ("")
		end

	smtp: SIMPLE_SMTP
			-- Direct access to SMTP client (localhost:25 default).
			-- Use `new_smtp' for production configuration.
		once
			create Result.make ("localhost", 25)
		end

	cors: SIMPLE_CORS
			-- Direct access to CORS handler with defaults.
		once
			create Result.make
		end

	rate_limiter: SIMPLE_RATE_LIMITER
			-- Direct access to rate limiter (100 requests/minute default).
			-- Use `new_rate_limiter' for custom configuration.
		once
			create Result.make
		end

	template: SIMPLE_TEMPLATE
			-- Direct access to template engine.
		once
			create Result.make
		end

	websocket_handshake: WS_HANDSHAKE
			-- Direct access to WebSocket handshake handler.
		once
			create Result.make
		end

	websocket_parser: WS_FRAME_PARSER
			-- Direct access to WebSocket frame parser.
		once
			create Result.make
		end

	cache: SIMPLE_CACHE [ANY]
			-- Direct access to shared cache (1000 entries default).
			-- Use `new_cache' for custom configuration.
		once
			create Result.make (1000)
		end

	pdf: SIMPLE_PDF
			-- Direct access to PDF generator with default engine.
			-- Use `new_pdf' or `new_pdf_with_chrome' for specific engines.
		once
			create Result.make
		end

	pdf_reader: SIMPLE_PDF_READER
			-- Direct access to PDF text extractor.
		once
			create Result.make
		end

	claude: CLAUDE_CLIENT
			-- Direct access to Claude client (uses ANTHROPIC_API_KEY env var).
		once
			create Result.make
		end

	ollama: OLLAMA_CLIENT
			-- Direct access to Ollama client (localhost:11434).
		once
			create Result.make
		end

	circuit_breaker: SIMPLE_CIRCUIT_BREAKER
			-- Direct access to shared circuit breaker (5 failures, 30s cooldown).
			-- Use `new_circuit_breaker' for custom configuration.
		once
			create Result.make (5, 30)
		end

	bulkhead: SIMPLE_BULKHEAD
			-- Direct access to shared bulkhead (100 concurrent max).
			-- Use `new_bulkhead' for custom configuration.
		once
			create Result.make (100)
		end

	resilience_policy: SIMPLE_RESILIENCE_POLICY
			-- Direct access to shared resilience policy (default settings).
			-- Use `new_resilience_policy' for custom configuration.
		once
			create Result.make
		end

	math: SIMPLE_MATH
			-- Direct access to math utility facade.
		once
			create Result.make
		end

	statistics: SIMPLE_STATISTICS
			-- Direct access to shared statistics calculator.
			-- Use `new_statistics' for isolated instances.
		once
			create Result.make
		end

end