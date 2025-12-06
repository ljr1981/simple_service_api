note
	description: "Tests for SERVICE facade class"
	author: "Larry Rix"

class
	SERVICE_TEST_SET

feature -- Test: JWT

	test_new_jwt
			-- Test creating JWT handler.
		local
			service: SERVICE
			jwt: SIMPLE_JWT
		do
			create service.make
			jwt := service.new_jwt ("test-secret")
			check jwt_created: jwt /= Void end
		end

	test_create_and_verify_token
			-- Test creating and verifying a token.
		local
			service: SERVICE
			token: STRING
		do
			create service.make
			token := service.create_token ("my-secret", "user@test.com", "test-app", 3600)
			check token_created: not token.is_empty end
			check token_valid: service.verify_token ("my-secret", token) end
			check token_invalid_with_wrong_secret: not service.verify_token ("wrong-secret", token) end
		end

feature -- Test: SMTP

	test_new_smtp
			-- Test creating SMTP client.
		local
			service: SERVICE
			smtp: SIMPLE_SMTP
		do
			create service.make
			smtp := service.new_smtp ("smtp.example.com", 587)
			check smtp_created: smtp /= Void end
		end

feature -- Test: SQL

	test_new_memory_database
			-- Test creating in-memory database.
		local
			service: SERVICE
			db: SIMPLE_SQL_DATABASE
		do
			create service.make
			db := service.new_memory_database
			check database_created: db /= Void end
			check database_is_open: db.is_open end
			db.close
		end

	test_database_execute
			-- Test executing SQL.
		local
			service: SERVICE
			db: SIMPLE_SQL_DATABASE
		do
			create service.make
			db := service.new_memory_database
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
			service: SERVICE
			cors: SIMPLE_CORS
		do
			create service.make
			cors := service.new_cors
			check cors_created: cors /= Void end
		end

	test_new_cors_permissive
			-- Test creating permissive CORS handler.
		local
			service: SERVICE
			cors: SIMPLE_CORS
		do
			create service.make
			cors := service.new_cors_permissive
			check cors_created: cors /= Void end
		end

feature -- Test: Rate Limiter

	test_new_rate_limiter
			-- Test creating rate limiter.
		local
			service: SERVICE
			limiter: SIMPLE_RATE_LIMITER
		do
			create service.make
			limiter := service.new_rate_limiter (100, 60)
			check limiter_created: limiter /= Void end
		end

feature -- Test: Template

	test_new_template
			-- Test creating template engine.
		local
			service: SERVICE
			tpl: SIMPLE_TEMPLATE
		do
			create service.make
			tpl := service.new_template
			check template_created: tpl /= Void end
		end

	test_render_template
			-- Test rendering a template.
		local
			service: SERVICE
			data: HASH_TABLE [STRING, STRING]
			l_result: STRING
		do
			create service.make
			create data.make (2)
			data.put ("World", "name")
			l_result := service.render_template ("Hello, {{name}}!", data)
			check template_rendered: l_result.has_substring ("World") end
		end

feature -- Test: WebSocket

	test_new_ws_handshake
			-- Test creating WebSocket handshake handler.
		local
			service: SERVICE
			hs: WS_HANDSHAKE
		do
			create service.make
			hs := service.new_ws_handshake
			check handshake_created: hs /= Void end
		end

	test_new_ws_frame_parser
			-- Test creating WebSocket frame parser.
		local
			service: SERVICE
			parser: WS_FRAME_PARSER
		do
			create service.make
			parser := service.new_ws_frame_parser
			check parser_created: parser /= Void end
		end

	test_new_ws_text_frame
			-- Test creating text frame.
		local
			service: SERVICE
			frame: WS_FRAME
		do
			create service.make
			frame := service.new_ws_text_frame ("Hello", True)
			check frame_created: frame /= Void end
			check is_text: frame.is_text end
		end

	test_new_ws_ping_pong
			-- Test creating ping and pong frames.
		local
			service: SERVICE
			ping, pong: WS_FRAME
		do
			create service.make
			ping := service.new_ws_ping_frame
			pong := service.new_ws_pong_frame
			check ping_created: ping /= Void end
			check pong_created: pong /= Void end
			check ping_is_ping: ping.is_ping end
			check pong_is_pong: pong.is_pong end
		end

	test_new_ws_message
			-- Test creating WebSocket message.
		local
			service: SERVICE
			msg: WS_MESSAGE
		do
			create service.make
			msg := service.new_ws_text_message ("Test message")
			check message_created: msg /= Void end
		end

feature -- Test: Foundation Inheritance

	test_foundation_features_available
			-- Test that FOUNDATION features are inherited.
		local
			service: SERVICE
		do
			create service.make
			-- Test some foundation features
			check base64_works: service.base64_encode ("test").is_equal ("dGVzdA==") end
			check uuid_works: not service.new_uuid.is_empty end
			check sha256_works: not service.sha256 ("test").is_empty end
		end

end
