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

feature -- Test: Math

	test_new_math
			-- Test creating math facade.
		local
			api: SERVICE_API
			m: SIMPLE_MATH
		do
			create api.make
			m := api.new_math
			check math_created: m /= Void end
			check pi_defined: (m.pi - 3.14159).abs < 0.001 end
		end

	test_new_vector
			-- Test creating vector.
		local
			api: SERVICE_API
			v: SIMPLE_VECTOR
		do
			create api.make
			v := api.new_vector (3)
			check vector_created: v /= Void end
			check dimension_3: v.dimension = 3 end
			check is_zero: v.is_zero end
		end

	test_new_vector_3d
			-- Test creating 3D vector.
		local
			api: SERVICE_API
			v: SIMPLE_VECTOR
		do
			create api.make
			v := api.new_vector_3d (1.0, 2.0, 3.0)
			check vector_created: v /= Void end
			check dimension_3: v.dimension = 3 end
			check x_correct: v.item (1) = 1.0 end
			check y_correct: v.item (2) = 2.0 end
			check z_correct: v.item (3) = 3.0 end
		end

	test_new_matrix
			-- Test creating matrix.
		local
			api: SERVICE_API
			m: SIMPLE_MATRIX
		do
			create api.make
			m := api.new_matrix (2, 3)
			check matrix_created: m /= Void end
			check rows_2: m.rows = 2 end
			check cols_3: m.cols = 3 end
		end

	test_new_identity_matrix
			-- Test creating identity matrix.
		local
			api: SERVICE_API
			m: SIMPLE_MATRIX
		do
			create api.make
			m := api.new_identity_matrix (3)
			check matrix_created: m /= Void end
			check is_square: m.is_square end
			check is_identity: m.is_identity end
		end

	test_new_statistics
			-- Test creating statistics.
		local
			api: SERVICE_API
			s: SIMPLE_STATISTICS
		do
			create api.make
			s := api.new_statistics_from_array (<<1.0, 2.0, 3.0, 4.0, 5.0>>)
			check stats_created: s /= Void end
			check count_5: s.count = 5 end
			check mean_3: s.mean = 3.0 end
		end

	test_vector_operations
			-- Test vector operations.
		local
			api: SERVICE_API
			v1, v2: SIMPLE_VECTOR
			dot: REAL_64
		do
			create api.make
			v1 := api.new_vector_3d (1.0, 2.0, 3.0)
			v2 := api.new_vector_3d (4.0, 5.0, 6.0)
			dot := v1.dot (v2)
			check dot_32: dot = 32.0 end  -- 1*4 + 2*5 + 3*6
		end

	test_matrix_operations
			-- Test matrix operations.
		local
			api: SERVICE_API
			m: SIMPLE_MATRIX
		do
			create api.make
			m := api.new_identity_matrix (3)
			check det_1: (m.determinant - 1.0).abs < 0.0001 end
			check trace_3: m.trace = 3.0 end
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

feature -- Test: ORM

	test_new_orm
			-- Test creating ORM.
		local
			api: SERVICE_API
			db: SIMPLE_SQL_DATABASE
			orm: SIMPLE_ORM
		do
			create api.make
			db := api.new_memory_database
			orm := api.new_orm (db)
			check orm_created: orm /= Void end
			check database_set: orm.database = db end
			db.close
		end

	test_new_orm_field
			-- Test creating ORM field.
		local
			api: SERVICE_API
			field: SIMPLE_ORM_FIELD
		do
			create api.make
			field := api.new_orm_field ("email", 1)  -- type_string = 1
			check field_created: field /= Void end
			check name_set: field.name.same_string ("email") end
			check type_string: field.field_type = 1 end
		end

	test_new_orm_primary_key_field
			-- Test creating ORM primary key field.
		local
			api: SERVICE_API
			field: SIMPLE_ORM_FIELD
		do
			create api.make
			field := api.new_orm_primary_key_field ("id")
			check field_created: field /= Void end
			check is_pk: field.is_primary_key end
			check is_auto: field.is_auto_increment end
		end

feature -- Test: Message Queue

	test_new_mq
			-- Test creating message queue facade.
		local
			api: SERVICE_API
			mq: SIMPLE_MQ
		do
			create api.make
			mq := api.new_mq
			check mq_created: mq /= Void end
		end

	test_new_mq_message
			-- Test creating message.
		local
			api: SERVICE_API
			msg: SIMPLE_MQ_MESSAGE
		do
			create api.make
			msg := api.new_mq_message ("Hello, World!")
			check msg_created: msg /= Void end
			check payload_set: msg.payload.same_string ("Hello, World!") end
			check id_set: not msg.id.is_empty end
		end

	test_new_mq_queue
			-- Test creating queue.
		local
			api: SERVICE_API
			queue: SIMPLE_MQ_QUEUE
		do
			create api.make
			queue := api.new_mq_queue ("test-queue")
			check queue_created: queue /= Void end
			check name_set: queue.name.same_string ("test-queue") end
			check is_empty: queue.is_empty end
		end

	test_new_mq_priority_queue
			-- Test creating priority queue.
		local
			api: SERVICE_API
			queue: SIMPLE_MQ_QUEUE
		do
			create api.make
			queue := api.new_mq_priority_queue ("urgent")
			check queue_created: queue /= Void end
			check is_priority: queue.is_priority_queue end
		end

	test_new_mq_bounded_queue
			-- Test creating bounded queue.
		local
			api: SERVICE_API
			queue: SIMPLE_MQ_QUEUE
		do
			create api.make
			queue := api.new_mq_bounded_queue ("bounded", 10)
			check queue_created: queue /= Void end
			check has_capacity: queue.max_size = 10 end
		end

	test_new_mq_topic
			-- Test creating topic.
		local
			api: SERVICE_API
			topic: SIMPLE_MQ_TOPIC
		do
			create api.make
			topic := api.new_mq_topic ("events.user.created")
			check topic_created: topic /= Void end
			check name_set: topic.name.same_string ("events.user.created") end
		end

	test_mq_queue_enqueue_dequeue
			-- Test enqueue and dequeue operations.
		local
			api: SERVICE_API
			queue: SIMPLE_MQ_QUEUE
			msg: SIMPLE_MQ_MESSAGE
		do
			create api.make
			queue := api.new_mq_queue ("fifo")
			msg := api.new_mq_message ("First")
			queue.enqueue (msg)
			check not_empty: not queue.is_empty end
			check count_1: queue.count = 1 end
			if attached queue.dequeue as received then
				check payload_match: received.payload.same_string ("First") end
			else
				check dequeue_worked: False end
			end
			check empty_after: queue.is_empty end
		end

	test_mq_singleton
			-- Test message queue singleton access.
		local
			api: SERVICE_API
		do
			create api.make
			check mq_singleton: api.mq /= Void end
		end

feature -- Test: Mediator

	test_new_mediator
			-- Test creating mediator.
		local
			api: SERVICE_API
			med: SIMPLE_MEDIATOR
		do
			create api.make
			med := api.new_mediator
			check mediator_created: med /= Void end
			check no_handlers: med.event_handler_count = 0 end
		end

	test_new_event_bus
			-- Test creating event bus.
		local
			api: SERVICE_API
			bus: SIMPLE_EVENT_BUS
		do
			create api.make
			bus := api.new_event_bus
			check bus_created: bus /= Void end
			check no_handlers: bus.handler_count = 0 end
		end

	test_new_event
			-- Test creating event.
		local
			api: SERVICE_API
			evt: SIMPLE_EVENT
		do
			create api.make
			evt := api.new_event ("user.created")
			check event_created: evt /= Void end
			check name_set: evt.name.same_string ("user.created") end
			check timestamp_set: evt.timestamp /= Void end
		end

	test_event_with_data
			-- Test event with data payload.
		local
			api: SERVICE_API
			evt: SIMPLE_EVENT
			data: HASH_TABLE [ANY, STRING]
		do
			create api.make
			create data.make (2)
			data.put ("John", "name")
			data.put (42, "age")
			evt := api.new_event_with_data ("user.updated", data)
			check has_name: evt.has_key ("name") end
			if attached evt.string_item ("name") as n then
				check name_correct: n.same_string ("John") end
			end
		end

	test_event_bus_subscribe_publish
			-- Test event subscription and publishing.
		local
			api: SERVICE_API
			bus: SIMPLE_EVENT_BUS
			handler: TEST_EVENT_HANDLER
			evt: SIMPLE_EVENT
		do
			create api.make
			bus := api.new_event_bus
			create handler.make ("test.event")
			bus.subscribe (handler)
			check subscribed: bus.is_subscribed (handler) end
			check count_1: bus.handler_count = 1 end

			evt := api.new_event ("test.event")
			bus.publish (evt)
			check received: handler.received_count = 1 end
			check last_event_correct: attached handler.last_event as le and then le.name.same_string ("test.event") end
		end

	test_event_bus_unsubscribe
			-- Test event unsubscription.
		local
			api: SERVICE_API
			bus: SIMPLE_EVENT_BUS
			handler: TEST_EVENT_HANDLER
			evt: SIMPLE_EVENT
		do
			create api.make
			bus := api.new_event_bus
			create handler.make ("test.event")
			bus.subscribe (handler)
			bus.unsubscribe (handler)
			check unsubscribed: not bus.is_subscribed (handler) end

			evt := api.new_event ("test.event")
			bus.publish (evt)
			check not_received: handler.received_count = 0 end
		end

	test_mediator_publish_event
			-- Test mediator event publishing.
		local
			api: SERVICE_API
			med: SIMPLE_MEDIATOR
			handler: TEST_EVENT_HANDLER
		do
			create api.make
			med := api.new_mediator
			create handler.make ("order.placed")
			med.subscribe (handler)
			med.publish_event ("order.placed")
			check received: handler.received_count = 1 end
		end

	test_command_result_success
			-- Test successful command result.
		local
			api: SERVICE_API
			res: SIMPLE_COMMAND_RESULT
		do
			create api.make
			res := api.new_command_result_success
			check is_success: res.is_success end
			check not_failure: not res.is_failure end
			res.set_affected_count (5)
			check affected_5: res.affected_count = 5 end
		end

	test_command_result_failure
			-- Test failed command result.
		local
			api: SERVICE_API
			res: SIMPLE_COMMAND_RESULT
		do
			create api.make
			res := api.new_command_result_failure ("Validation failed")
			check is_failure: res.is_failure end
			check has_error: not res.errors.is_empty end
			if attached res.first_error as err then
				check error_message: err.same_string ("Validation failed") end
			end
		end

	test_mediator_singletons
			-- Test mediator singleton access.
		local
			api: SERVICE_API
		do
			create api.make
			check mediator_singleton: api.mediator /= Void end
			check event_bus_singleton: api.event_bus /= Void end
		end

end
