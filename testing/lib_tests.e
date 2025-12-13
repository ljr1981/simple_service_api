note
	description: "Tests for SERVICE facade class"
	author: "Larry Rix"

class
	LIB_TESTS

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

feature -- Test: Resilience

	test_new_circuit_breaker
			-- Test creating circuit breaker.
		local
			api: SERVICE_API
			cb: SIMPLE_CIRCUIT_BREAKER
		do
			create api.make
			cb := api.new_circuit_breaker (5, 30)
			check circuit_breaker_created: cb /= Void end
			check initially_closed: cb.is_closed end
		end

	test_new_bulkhead
			-- Test creating bulkhead.
		local
			api: SERVICE_API
			bh: SIMPLE_BULKHEAD
		do
			create api.make
			bh := api.new_bulkhead (50)
			check bulkhead_created: bh /= Void end
			check not_full: not bh.is_full end
		end

	test_new_resilience_policy
			-- Test creating resilience policy builder.
		local
			api: SERVICE_API
			policy: SIMPLE_RESILIENCE_POLICY
			l_dummy: SIMPLE_RESILIENCE_POLICY
		do
			create api.make
			policy := api.new_resilience_policy
			check policy_created: policy /= Void end
			-- Test fluent API
			l_dummy := policy.with_retry (3)
			l_dummy := policy.with_circuit_breaker (5, 30)
			l_dummy := policy.with_timeout (10)
			l_dummy := policy.with_bulkhead (100)
			check has_retry: policy.has_retry end
			check has_circuit_breaker: policy.has_circuit_breaker end
			check has_timeout: policy.has_timeout end
			check has_bulkhead: policy.has_bulkhead end
		end

	test_new_resilience_middleware
			-- Test creating resilience middleware.
		local
			api: SERVICE_API
			mw: SIMPLE_WEB_RESILIENCE_MIDDLEWARE
		do
			create api.make
			mw := api.new_resilience_middleware
			check middleware_created: mw /= Void end
		end

	test_new_resilience_middleware_with_policy
			-- Test creating resilience middleware with policy.
		local
			api: SERVICE_API
			policy: SIMPLE_RESILIENCE_POLICY
			mw: SIMPLE_WEB_RESILIENCE_MIDDLEWARE
		do
			create api.make
			policy := api.new_resilience_policy
			mw := api.new_resilience_middleware_with_policy (policy)
			check middleware_created: mw /= Void end
		end

	test_circuit_breaker_state_transitions
			-- Test circuit breaker state machine.
		local
			api: SERVICE_API
			cb: SIMPLE_CIRCUIT_BREAKER
			i: INTEGER
		do
			create api.make
			cb := api.new_circuit_breaker (3, 1)  -- 3 failures, 1 second cooldown
			check initially_closed: cb.is_closed end
			-- Record failures to open circuit
			from i := 1 until i > 3 loop
				cb.record_failure
				i := i + 1
			end
			check now_open: cb.is_open end
			check request_not_allowed: not cb.allow_request end
		end

	test_bulkhead_acquire_release
			-- Test bulkhead acquire/release.
		local
			api: SERVICE_API
			bh: SIMPLE_BULKHEAD
			acquired: BOOLEAN
		do
			create api.make
			bh := api.new_bulkhead (2)  -- Max 2 concurrent
			acquired := bh.acquire
			check first_acquired: acquired end
			acquired := bh.acquire
			check second_acquired: acquired end
			acquired := bh.acquire
			check third_rejected: not acquired end
			bh.release
			acquired := bh.acquire
			check after_release_acquired: acquired end
		end

	test_resilience_singletons
			-- Test resilience singleton instances.
		local
			api: SERVICE_API
		do
			create api.make
			check circuit_breaker_singleton: api.circuit_breaker /= Void end
			check bulkhead_singleton: api.bulkhead /= Void end
			check resilience_policy_singleton: api.resilience_policy /= Void end
		end

feature -- Test: Graph

	test_new_graph
			-- Test creating undirected graph.
		local
			api: SERVICE_API
			g: SIMPLE_GRAPH [ANY]
		do
			create api.make
			g := api.new_graph
			check graph_created: g /= Void end
			check not_directed: not g.is_directed end
			check empty: g.is_empty end
		end

	test_new_directed_graph
			-- Test creating directed graph.
		local
			api: SERVICE_API
			g: SIMPLE_GRAPH [ANY]
		do
			create api.make
			g := api.new_directed_graph
			check graph_created: g /= Void end
			check directed: g.is_directed end
		end

	test_new_string_graph
			-- Test creating string graph.
		local
			api: SERVICE_API
			g: SIMPLE_GRAPH [STRING]
			a, b: INTEGER
		do
			create api.make
			g := api.new_string_graph
			a := g.add_node ("A")
			b := g.add_node ("B")
			g.add_edge (a, b)
			check has_edge: g.has_edge (a, b) end
		end

	test_graph_dijkstra
			-- Test shortest path with graph.
		local
			api: SERVICE_API
			g: SIMPLE_GRAPH [STRING]
			a, b, c: INTEGER
			path: ARRAYED_LIST [INTEGER]
		do
			create api.make
			g := api.new_string_graph
			a := g.add_node ("A")
			b := g.add_node ("B")
			c := g.add_node ("C")
			g.add_edge (a, b)
			g.add_edge (b, c)
			path := g.dijkstra (a, c)
			check path_found: not path.is_empty end
			check path_correct: path.count = 3 end
		end

	test_graph_bfs_dfs
			-- Test graph traversals.
		local
			api: SERVICE_API
			g: SIMPLE_GRAPH [STRING]
			a, b, c: INTEGER
			bfs_result, dfs_result: ARRAYED_LIST [INTEGER]
		do
			create api.make
			g := api.new_string_graph
			a := g.add_node ("A")
			b := g.add_node ("B")
			c := g.add_node ("C")
			g.add_edge (a, b)
			g.add_edge (a, c)
			bfs_result := g.bfs (a)
			dfs_result := g.dfs (a)
			check bfs_visits_all: bfs_result.count = 3 end
			check dfs_visits_all: dfs_result.count = 3 end
		end

feature -- Test: Redis

	test_new_redis
			-- Test creating Redis client.
		local
			api: SERVICE_API
			redis: SIMPLE_REDIS
		do
			create api.make
			redis := api.new_redis ("localhost", 6379)
			check redis_created: redis /= Void end
			check host_set: redis.host.same_string ("localhost") end
			check port_set: redis.port = 6379 end
		end

	test_new_redis_with_auth
			-- Test creating Redis client with authentication.
		local
			api: SERVICE_API
			redis: SIMPLE_REDIS
		do
			create api.make
			redis := api.new_redis_with_auth ("localhost", 6379, "secret")
			check redis_created: redis /= Void end
			check password_set: attached redis.password end
		end

	test_new_redis_cache
			-- Test creating Redis cache.
		local
			api: SERVICE_API
			cache: SIMPLE_REDIS_CACHE
		do
			create api.make
			cache := api.new_redis_cache ("localhost", 6379, 1000)
			check cache_created: cache /= Void end
			check max_size_set: cache.max_size = 1000 end
		end

	test_new_redis_cache_with_ttl
			-- Test creating Redis cache with TTL.
		local
			api: SERVICE_API
			cache: SIMPLE_REDIS_CACHE
		do
			create api.make
			cache := api.new_redis_cache_with_ttl ("localhost", 6379, 500, 3600)
			check cache_created: cache /= Void end
			check ttl_set: cache.default_ttl = 3600 end
		end

	test_new_redis_cache_with_auth
			-- Test creating Redis cache with authentication.
		local
			api: SERVICE_API
			cache: SIMPLE_REDIS_CACHE
		do
			create api.make
			cache := api.new_redis_cache_with_auth ("localhost", 6379, 1000, "password")
			check cache_created: cache /= Void end
		end

end
