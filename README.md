<p align="center">
  <img src="https://raw.githubusercontent.com/simple-eiffel/claude_eiffel_op_docs/main/artwork/LOGO.png" alt="simple_ library logo" width="400">
</p>

# simple_service_api

**[Documentation](https://simple-eiffel.github.io/simple_service_api/)** | **[GitHub](https://github.com/simple-eiffel/simple_service_api)**

Unified service layer facade for Eiffel web applications. Bundles authentication, email, database, CORS, rate limiting, templates, and WebSocket services.

## Overview

`simple_service_api` provides a single `SERVICE_API` class that gives you access to all common web application services. It uses composition to provide access to `FOUNDATION_API` via `api.foundation.*`, maintaining clear semantic boundaries between layers.

## Features

- **JWT Authentication** - Create and verify JSON Web Tokens
- **SMTP Email** - Send emails with attachments, HTML, and TLS
- **SQL Database** - SQLite database with query builder and migrations
- **CORS Handling** - Cross-Origin Resource Sharing configuration
- **Rate Limiting** - Protect endpoints from abuse
- **Templates** - Simple template rendering with variable substitution
- **WebSocket** - RFC 6455 WebSocket frame encoding/decoding
- **Resilience** - Circuit breaker, bulkhead, retry with backoff, timeout, fallback patterns
- **Foundation** - Access via `api.foundation.*` for Base64, SHA, UUID, JSON, etc.

## Dependencies

This library bundles the following service libraries:

| Library | Purpose | Environment Variable |
|---------|---------|---------------------|
| [simple_jwt](https://github.com/simple-eiffel/simple_jwt) | JWT authentication | `$SIMPLE_JWT` |
| [simple_smtp](https://github.com/simple-eiffel/simple_smtp) | Email sending | `$SIMPLE_SMTP` |
| [simple_sql](https://github.com/simple-eiffel/simple_sql) | SQLite database | `$SIMPLE_SQL` |
| [simple_cors](https://github.com/simple-eiffel/simple_cors) | CORS handling | `$SIMPLE_CORS` |
| [simple_rate_limiter](https://github.com/simple-eiffel/simple_rate_limiter) | Rate limiting | `$SIMPLE_RATE_LIMITER` |
| [simple_template](https://github.com/simple-eiffel/simple_template) | Template rendering | `$SIMPLE_TEMPLATE` |
| [simple_websocket](https://github.com/simple-eiffel/simple_websocket) | WebSocket protocol | `$SIMPLE_WEBSOCKET` |
| [simple_web](https://github.com/simple-eiffel/simple_web) | HTTP client/server, resilience | `$SIMPLE_WEB` |
| [simple_foundation_api](https://github.com/simple-eiffel/simple_foundation_api) | Core utilities (composed) | `$SIMPLE_FOUNDATION_API` |

## Installation

1. Clone all required repositories
2. Set environment variables for each library
3. Add to your ECF:

```xml
<library name="simple_service_api"
        location="$SIMPLE_SERVICE_API\simple_service_api.ecf"/>
```

## Quick Start

```eiffel
local
    api: SERVICE_API
do
    create api.make

    -- Service-level: JWT Authentication
    token := api.create_token ("secret", "user@example.com", "my-app", 3600)
    if api.verify_token ("secret", token) then
        print ("Token valid!%N")
    end

    -- Service-level: Email
    smtp := api.new_smtp ("smtp.example.com", 587)
    smtp.set_credentials ("user", "pass")
    smtp.set_from ("sender@example.com", "Sender")
    smtp.add_to ("recipient@example.com", "Recipient")
    smtp.set_subject ("Hello!")
    smtp.set_body ("Test email")
    smtp.send

    -- Service-level: Database
    db := api.new_memory_database
    db.execute_sql ("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)")
    db.execute_sql ("INSERT INTO users (name) VALUES ('Alice')")
    db.close

    -- Service-level: CORS
    cors := api.new_cors
    cors.allow_origin ("https://example.com")
    headers := cors.get_headers ("https://example.com", "GET")

    -- Service-level: Rate Limiting
    limiter := api.new_rate_limiter (100, 60)  -- 100 requests per minute
    if limiter.check ("client-ip").is_allowed then
        -- Process request
    end

    -- Service-level: Templates
    result := api.render_template ("Hello, {{name}}!", data)

    -- Service-level: WebSocket
    frame := api.new_ws_text_frame ("Hello", True)
    bytes := frame.to_bytes

    -- Service-level: Resilience
    cb := api.new_circuit_breaker (5, 30)  -- 5 failures, 30s cooldown
    if cb.allow_request then
        -- Make external call
        cb.record_success  -- or record_failure
    end

    bh := api.new_bulkhead (100)  -- Max 100 concurrent
    if bh.acquire then
        -- Do work
        bh.release
    end

    policy := api.new_resilience_policy
    policy.with_retry (3).with_circuit_breaker (5, 30).with_timeout (10)

    -- Foundation layer (via composition)
    encoded := api.foundation.base64_encode ("data")
    hash := api.foundation.sha256 ("password")
    uuid := api.foundation.new_uuid
end
```

## API Summary

### Service-Level Features

#### JWT Authentication
- `new_jwt (secret)` - Create JWT handler
- `create_token (secret, subject, issuer, expires)` - Generate token
- `verify_token (secret, token)` - Verify token

#### SMTP Email
- `new_smtp (host, port)` - Create SMTP client

#### SQL Database
- `new_database (path)` - Open/create SQLite database
- `new_memory_database` - Create in-memory database

#### CORS
- `new_cors` - Create CORS handler with defaults
- `new_cors_permissive` - Create permissive CORS handler

#### Rate Limiting
- `new_rate_limiter (max_requests, window_seconds)` - Create limiter

#### Templates
- `new_template` - Create template engine
- `render_template (template, data)` - Render with substitutions

#### WebSocket
- `new_ws_handshake` - Create handshake handler
- `new_ws_frame_parser` - Create frame parser
- `new_ws_text_frame (text, is_final)` - Create text frame
- `new_ws_binary_frame (data, is_final)` - Create binary frame
- `new_ws_close_frame (code, reason)` - Create close frame
- `new_ws_ping_frame`, `new_ws_pong_frame` - Create control frames
- `new_ws_text_message`, `new_ws_binary_message` - Create messages

#### Resilience
- `new_circuit_breaker (threshold, cooldown)` - Create circuit breaker
- `new_bulkhead (max_concurrent)` - Create concurrency limiter
- `new_resilience_policy` - Create policy builder (fluent API)
- `new_resilience_middleware` - Create server middleware
- `new_resilience_middleware_with_policy (policy)` - Create middleware with policy

#### Direct Access (Singletons)
- `jwt` - SIMPLE_JWT instance
- `smtp` - SIMPLE_SMTP instance
- `cors` - SIMPLE_CORS instance
- `template` - SIMPLE_TEMPLATE instance
- `circuit_breaker` - SIMPLE_CIRCUIT_BREAKER instance (5 failures, 30s cooldown)
- `bulkhead` - SIMPLE_BULKHEAD instance (100 concurrent max)
- `resilience_policy` - SIMPLE_RESILIENCE_POLICY instance

### Layer Access

- `foundation` - Access to FOUNDATION_API features

### Via `api.foundation.*`
- **Base64** - `base64_encode`, `base64_decode`, `base64_url_encode`
- **Hashing** - `sha256`, `sha1`, `md5`, `hmac_sha256`, `secure_compare`
- **UUID** - `new_uuid`, `new_uuid_compact`, `is_valid_uuid`
- **JSON** - `parse_json`, `new_json_object`, `new_json_array`
- **CSV** - `parse_csv`, `csv_field`, `csv_to_string`
- **Markdown** - `markdown_to_html`
- **Validation** - `new_validator`, `is_valid_email`, `is_valid_url`
- **Process** - `execute_command`
- **Random** - `random_integer`, `random_word`, `random_alphanumeric_string`

## Design Philosophy

**Composition over Inheritance**: When you type `api.`, IntelliSense shows only service-level features. Use `api.foundation.*` for foundation features. This makes code self-documenting and easier to understand.

## License

MIT License - Copyright (c) 2024-2025, Larry Rix
