note
	description: "Test application for simple_service_api"
	author: "Larry Rix"

class
	TEST_APP

create
	make

feature {NONE} -- Initialization

	make
			-- Run tests.
		local
			tests: LIB_TESTS
		do
			create tests
			io.put_string ("simple_service_api test runner%N")
			io.put_string ("====================================%N%N")

			passed := 0
			failed := 0

			-- JWT Tests
			io.put_string ("JWT Tests%N")
			io.put_string ("---------%N")
			run_test (agent tests.test_new_jwt, "test_new_jwt")
			run_test (agent tests.test_create_and_verify_token, "test_create_and_verify_token")

			-- SMTP Tests
			io.put_string ("%NSMTP Tests%N")
			io.put_string ("----------%N")
			run_test (agent tests.test_new_smtp, "test_new_smtp")

			-- SQL Tests
			io.put_string ("%NSQL Tests%N")
			io.put_string ("---------%N")
			run_test (agent tests.test_new_memory_database, "test_new_memory_database")
			run_test (agent tests.test_database_execute, "test_database_execute")

			-- CORS Tests
			io.put_string ("%NCORS Tests%N")
			io.put_string ("----------%N")
			run_test (agent tests.test_new_cors, "test_new_cors")
			run_test (agent tests.test_new_cors_permissive, "test_new_cors_permissive")

			-- Rate Limiter Tests
			io.put_string ("%NRate Limiter Tests%N")
			io.put_string ("------------------%N")
			run_test (agent tests.test_new_rate_limiter, "test_new_rate_limiter")

			-- Template Tests
			io.put_string ("%NTemplate Tests%N")
			io.put_string ("--------------%N")
			run_test (agent tests.test_new_template, "test_new_template")
			run_test (agent tests.test_render_template, "test_render_template")

			-- WebSocket Tests
			io.put_string ("%NWebSocket Tests%N")
			io.put_string ("---------------%N")
			run_test (agent tests.test_new_ws_handshake, "test_new_ws_handshake")
			run_test (agent tests.test_new_ws_frame_parser, "test_new_ws_frame_parser")
			run_test (agent tests.test_new_ws_text_frame, "test_new_ws_text_frame")
			run_test (agent tests.test_new_ws_ping_pong, "test_new_ws_ping_pong")
			run_test (agent tests.test_new_ws_message, "test_new_ws_message")

			-- Cache Tests
			io.put_string ("%NCache Tests%N")
			io.put_string ("-----------%N")
			run_test (agent tests.test_new_cache, "test_new_cache")
			run_test (agent tests.test_new_cache_with_ttl, "test_new_cache_with_ttl")
			run_test (agent tests.test_new_string_cache, "test_new_string_cache")
			run_test (agent tests.test_cache_singleton, "test_cache_singleton")

			-- Foundation Inheritance Tests
			io.put_string ("%NFoundation Inheritance Tests%N")
			io.put_string ("----------------------------%N")
			run_test (agent tests.test_foundation_features_available, "test_foundation_features_available")

			-- Resilience Tests
			io.put_string ("%NResilience Tests%N")
			io.put_string ("----------------%N")
			run_test (agent tests.test_new_circuit_breaker, "test_new_circuit_breaker")
			run_test (agent tests.test_new_bulkhead, "test_new_bulkhead")
			run_test (agent tests.test_new_resilience_policy, "test_new_resilience_policy")
			run_test (agent tests.test_new_resilience_middleware, "test_new_resilience_middleware")
			run_test (agent tests.test_new_resilience_middleware_with_policy, "test_new_resilience_middleware_with_policy")
			run_test (agent tests.test_circuit_breaker_state_transitions, "test_circuit_breaker_state_transitions")
			run_test (agent tests.test_bulkhead_acquire_release, "test_bulkhead_acquire_release")
			run_test (agent tests.test_resilience_singletons, "test_resilience_singletons")

			-- Graph Tests
			io.put_string ("%NGraph Tests%N")
			io.put_string ("-----------%N")
			run_test (agent tests.test_new_graph, "test_new_graph")
			run_test (agent tests.test_new_directed_graph, "test_new_directed_graph")
			run_test (agent tests.test_new_string_graph, "test_new_string_graph")
			run_test (agent tests.test_graph_dijkstra, "test_graph_dijkstra")
			run_test (agent tests.test_graph_bfs_dfs, "test_graph_bfs_dfs")

			-- Math Tests
			io.put_string ("%NMath Tests%N")
			io.put_string ("----------%N")
			run_test (agent tests.test_new_math, "test_new_math")
			run_test (agent tests.test_new_vector, "test_new_vector")
			run_test (agent tests.test_new_vector_3d, "test_new_vector_3d")
			run_test (agent tests.test_new_matrix, "test_new_matrix")
			run_test (agent tests.test_new_identity_matrix, "test_new_identity_matrix")
			run_test (agent tests.test_new_statistics, "test_new_statistics")
			run_test (agent tests.test_vector_operations, "test_vector_operations")
			run_test (agent tests.test_matrix_operations, "test_matrix_operations")

			-- Redis Tests
			io.put_string ("%NRedis Tests%N")
			io.put_string ("-----------%N")
			run_test (agent tests.test_new_redis, "test_new_redis")
			run_test (agent tests.test_new_redis_with_auth, "test_new_redis_with_auth")
			run_test (agent tests.test_new_redis_cache, "test_new_redis_cache")
			run_test (agent tests.test_new_redis_cache_with_ttl, "test_new_redis_cache_with_ttl")
			run_test (agent tests.test_new_redis_cache_with_auth, "test_new_redis_cache_with_auth")

			io.put_string ("%N====================================%N")
			io.put_string ("Results: " + passed.out + " passed, " + failed.out + " failed%N")

			if failed > 0 then
				io.put_string ("TESTS FAILED%N")
			else
				io.put_string ("ALL TESTS PASSED%N")
			end
		end

feature {NONE} -- Implementation

	passed: INTEGER
	failed: INTEGER

	run_test (a_test: PROCEDURE; a_name: STRING)
			-- Run a single test and update counters.
		local
			l_retried: BOOLEAN
		do
			if not l_retried then
				a_test.call (Void)
				io.put_string ("  PASS: " + a_name + "%N")
				passed := passed + 1
			end
		rescue
			io.put_string ("  FAIL: " + a_name + "%N")
			failed := failed + 1
			l_retried := True
			retry
		end

end
