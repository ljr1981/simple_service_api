note
	description: "Tests for SERVICE facade class"
	author: "Larry Rix"

class
	SERVICE_TEST_SET

feature -- Test: JWT

	test_new_jwt
			-- Test creating JWT handler.
		local
			api: SERVICE_API
			jwt: SIMPLE_JWT
		do
			create api.make
			jwt := api.new_jwt ("test-secret")
			check jwt_created: jwt /= Void end
		end

	test_create_and_verify_token
			-- Test creating and verifying a token.
		local
			api: SERVICE_API
			token: STRING
		do
			create api.make
			token := api.create_token ("my-secret", "user@test.com", "test-app", 3600)
			check token_created: not token.is_empty end
			check token_valid: api.verify_token ("my-secret", token) end
			check token_invalid_with_wrong_secret: not api.verify_token ("wrong-secret", token) end
		end

feature -- Test: SMTP

	test_new_smtp
			-- Test creating SMTP client.
		local
			api: SERVICE_API
			smtp: SIMPLE_SMTP
		do
			create api.make
			smtp := api.new_smtp ("smtp.example.com", 587)
			check smtp_created: smtp /= Void end
		end

feature -- Test: SQL

	test_new_memory_database
			-- Test creating in-memory database.
		local
			api: SERVICE_API
			db: SIMPLE_SQL_DATABASE
		do
			create api.make
			db := api.new_memory_database
			check database_created: db /= Void end
			check database_is_open: db.is_open end
			db.close
		end

	test_database_execute
			-- Test executing SQL.
		local
			api: SERVICE_API
			db: SIMPLE_SQL_DATABASE
		do
			create api.make
			db := api.new_memory_database
			db.execute ("CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT)")
			check no_error_create: not db.has_error end
			db.execute ("INSERT INTO test (name) VALUES ('hello')")
			check insert_ok: not db.has_error end
			db.close
		end

feature -- Test: CORS

	test_new_cors
			-- Test creating CORS handler.
		local
			api: SERVICE_API
			cors: SIMPLE_CORS
		do
			create api.make
			cors := api.new_cors
			check cors_created: cors /= Void end
		end

	test_new_cors_permissive
			-- Test creating permissive CORS handler.
		local
			api: SERVICE_API
			cors: SIMPLE_CORS
		do
			create api.make
			cors := api.new_cors_permissive
			check cors_created: cors /= Void end
		end

feature -- Test: Rate Limiter

	test_new_rate_limiter
			-- Test creating rate limiter.
		local
			api: SERVICE_API
			limiter: SIMPLE_RATE_LIMITER
		do
			create api.make
			limiter := api.new_rate_limiter (100, 60)
			check limiter_created: limiter /= Void end
		end

feature -- Test: Template

	test_new_template
			-- Test creating template engine.
		local
			api: SERVICE_API
			tpl: SIMPLE_TEMPLATE
		do
			create api.make
			tpl := api.new_template
			check template_created: tpl /= Void end
		end

	test_render_template
			-- Test rendering a template.
		local
			api: SERVICE_API
			data: HASH_TABLE [STRING, STRING]
			l_result: STRING
		do
			create api.make
			create data.make (2)
			data.put ("World", "name")
			l_result := api.render_template ("Hello, {{name}}!", data)
			check template_rendered: l_result.has_substring ("World") end
		end

feature -- Test: WebSocket

	test_new_ws_handshake
			-- Test creating WebSocket handshake handler.
		local
			api: SERVICE_API
			hs: WS_HANDSHAKE
		do
			create api.make
			hs := api.new_ws_handshake
			check handshake_created: hs /= Void end
		end

	test_new_ws_frame_parser
			-- Test creating WebSocket frame parser.
		local
			api: SERVICE_API
			parser: WS_FRAME_PARSER
		do
			create api.make
			parser := api.new_ws_frame_parser
			check parser_created: parser /= Void end
		end

	test_new_ws_text_frame
			-- Test creating text frame.
		local
			api: SERVICE_API
			frame: WS_FRAME
		do
			create api.make
			frame := api.new_ws_text_frame ("Hello", True)
			check frame_created: frame /= Void end
			check is_text: frame.is_text end
		end

	test_new_ws_ping_pong
			-- Test creating ping and pong frames.
		local
			api: SERVICE_API
			ping, pong: WS_FRAME
		do
			create api.make
			ping := api.new_ws_ping_frame
			pong := api.new_ws_pong_frame
			check ping_created: ping /= Void end
			check pong_created: pong /= Void end
			check ping_is_ping: ping.is_ping end
			check pong_is_pong: pong.is_pong end
		end

	test_new_ws_message
			-- Test creating WebSocket message.
		local
			api: SERVICE_API
			msg: WS_MESSAGE
		do
			create api.make
			msg := api.new_ws_text_message ("Test message")
			check message_created: msg /= Void end
		end

feature -- Test: Cache

	test_new_cache
			-- Test creating cache.
		local
			api: SERVICE_API
			cache: SIMPLE_CACHE [ANY]
		do
			create api.make
			cache := api.new_cache (100)
			check cache_created: cache /= Void end
			check cache_empty: cache.is_empty end
		end

	test_new_cache_with_ttl
			-- Test creating cache with TTL.
		local
			api: SERVICE_API
			cache: SIMPLE_CACHE [ANY]
		do
			create api.make
			cache := api.new_cache_with_ttl (50, 3600)
			check cache_created: cache /= Void end
		end

	test_new_string_cache
			-- Test creating typed string cache.
		local
			api: SERVICE_API
			cache: SIMPLE_CACHE [STRING]
		do
			create api.make
			cache := api.new_string_cache (100)
			cache.put ("key1", "value1")
			check value_stored: attached cache.get ("key1") as v and then v.is_equal ("value1") end
		end

	test_cache_singleton
			-- Test cache singleton access.
		local
			api: SERVICE_API
		do
			create api.make
			api.cache.put ("test_key", "test_value")
			check cache_has_key: api.cache.has ("test_key") end
		end

feature -- Test: Foundation Composition

	test_foundation_features_available
			-- Test that FOUNDATION features are accessible via composition.
		local
			api: SERVICE_API
		do
			create api.make
			-- Test foundation features via composition
			check base64_works: api.foundation.base64_encode ("test").is_equal ("dGVzdA==") end
			check uuid_works: not api.foundation.new_uuid.is_empty end
			check sha256_works: not api.foundation.sha256 ("test").is_empty end
		end

end
