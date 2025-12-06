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
			secret_not_void: a_secret /= Void
			secret_not_empty: not a_secret.is_empty
		do
			create Result.make (a_secret)
		ensure
			result_not_void: Result /= Void
		end

	create_token (a_secret, a_subject, a_issuer: STRING; a_expires_in_seconds: INTEGER): STRING
			-- Create a JWT token with standard claims.
		require
			secret_not_void: a_secret /= Void
			secret_not_empty: not a_secret.is_empty
			subject_not_void: a_subject /= Void
			issuer_not_void: a_issuer /= Void
			expires_positive: a_expires_in_seconds > 0
		local
			l_jwt: SIMPLE_JWT
		do
			create l_jwt.make (a_secret)
			Result := l_jwt.create_token_with_claims (a_subject, a_issuer, a_expires_in_seconds, Void)
		ensure
			result_not_void: Result /= Void
			result_not_empty: not Result.is_empty
		end

	verify_token (a_secret, a_token: STRING): BOOLEAN
			-- Verify JWT token signature and expiration.
		require
			secret_not_void: a_secret /= Void
			token_not_void: a_token /= Void
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
			host_not_void: a_host /= Void
			host_not_empty: not a_host.is_empty
			port_valid: a_port > 0 and a_port < 65536
		do
			create Result.make (a_host, a_port)
		ensure
			result_not_void: Result /= Void
		end

feature -- SQL Database

	new_database (a_path: STRING): SIMPLE_SQL_DATABASE
			-- Create new SQLite database at `a_path'.
		require
			path_not_void: a_path /= Void
			path_not_empty: not a_path.is_empty
		do
			create Result.make (a_path)
		ensure
			result_not_void: Result /= Void
		end

	new_memory_database: SIMPLE_SQL_DATABASE
			-- Create new in-memory SQLite database.
		do
			create Result.make_memory
		ensure
			result_not_void: Result /= Void
		end

feature -- CORS

	new_cors: SIMPLE_CORS
			-- Create new CORS handler with default settings.
		do
			create Result.make
		ensure
			result_not_void: Result /= Void
		end

	new_cors_permissive: SIMPLE_CORS
			-- Create new CORS handler allowing all origins.
		do
			create Result.make_permissive
		ensure
			result_not_void: Result /= Void
		end

feature -- Rate Limiting

	new_rate_limiter (a_max_requests: INTEGER; a_window_seconds: INTEGER): SIMPLE_RATE_LIMITER
			-- Create rate limiter: `a_max_requests' per `a_window_seconds'.
		require
			max_requests_positive: a_max_requests > 0
			window_positive: a_window_seconds > 0
		do
			create Result.make_with_limit (a_max_requests, a_window_seconds)
		ensure
			result_not_void: Result /= Void
		end

feature -- Templates

	new_template: SIMPLE_TEMPLATE
			-- Create new template engine.
		do
			create Result.make
		ensure
			result_not_void: Result /= Void
		end

	render_template (a_template: STRING; a_data: detachable HASH_TABLE [STRING, STRING]): STRING
			-- Render `a_template' with `a_data' substitutions.
		require
			template_not_void: a_template /= Void
		local
			l_template: SIMPLE_TEMPLATE
		do
			create l_template.make_from_string (a_template)
			if attached a_data as l_data then
				l_template.set_variables (l_data)
			end
			Result := l_template.render
		ensure
			result_not_void: Result /= Void
		end

feature -- WebSocket

	new_ws_handshake: WS_HANDSHAKE
			-- Create new WebSocket handshake handler.
		do
			create Result.make
		ensure
			result_not_void: Result /= Void
		end

	new_ws_frame_parser: WS_FRAME_PARSER
			-- Create new WebSocket frame parser.
		do
			create Result.make
		ensure
			result_not_void: Result /= Void
		end

	new_ws_text_frame (a_text: STRING; a_is_final: BOOLEAN): WS_FRAME
			-- Create WebSocket text frame with `a_text'.
		require
			text_not_void: a_text /= Void
		do
			create Result.make_text (a_text, a_is_final)
		ensure
			result_not_void: Result /= Void
		end

	new_ws_binary_frame (a_data: ARRAY [NATURAL_8]; a_is_final: BOOLEAN): WS_FRAME
			-- Create WebSocket binary frame with `a_data'.
		require
			data_not_void: a_data /= Void
		do
			create Result.make_binary (a_data, a_is_final)
		ensure
			result_not_void: Result /= Void
		end

	new_ws_close_frame (a_code: INTEGER; a_reason: STRING): WS_FRAME
			-- Create WebSocket close frame.
		require
			reason_not_void: a_reason /= Void
		do
			create Result.make_close (a_code, a_reason)
		ensure
			result_not_void: Result /= Void
		end

	new_ws_ping_frame: WS_FRAME
			-- Create WebSocket ping frame.
		do
			create Result.make_ping
		ensure
			result_not_void: Result /= Void
		end

	new_ws_pong_frame: WS_FRAME
			-- Create WebSocket pong frame.
		do
			create Result.make_pong
		ensure
			result_not_void: Result /= Void
		end

	new_ws_text_message (a_text: STRING): WS_MESSAGE
			-- Create WebSocket text message.
		require
			text_not_void: a_text /= Void
		do
			create Result.make_text (a_text)
		ensure
			result_not_void: Result /= Void
		end

	new_ws_binary_message (a_data: ARRAY [NATURAL_8]): WS_MESSAGE
			-- Create WebSocket binary message.
		require
			data_not_void: a_data /= Void
		do
			create Result.make_binary (a_data)
		ensure
			result_not_void: Result /= Void
		end

feature -- Layer Access

	foundation: FOUNDATION_API
			-- Access to foundation layer features ONLY.
			-- Returns isolated instance - only foundation features visible.
		once
			create Result.make
		ensure
			result_not_void: Result /= Void
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

end
