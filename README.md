<p align="center">
  <img src="https://raw.githubusercontent.com/ljr1981/claude_eiffel_op_docs/main/artwork/LOGO.png" alt="simple_ library logo" width="400">
</p>

# simple_service_api

**[Documentation](https://ljr1981.github.io/simple_service_api/)** | **[GitHub](https://github.com/ljr1981/simple_service_api)**

Unified service layer facade for Eiffel web applications. Bundles authentication, email, database, CORS, rate limiting, templates, and WebSocket services.

## Overview

`simple_service_api` provides a single `SERVICE` class that gives you access to all common web application services. It inherits from `FOUNDATION`, so you also get all core utilities (encoding, hashing, JSON, etc.).

## Features

- **JWT Authentication** - Create and verify JSON Web Tokens
- **SMTP Email** - Send emails with attachments, HTML, and TLS
- **SQL Database** - SQLite database with query builder and migrations
- **CORS Handling** - Cross-Origin Resource Sharing configuration
- **Rate Limiting** - Protect endpoints from abuse
- **Templates** - Simple template rendering with variable substitution
- **WebSocket** - RFC 6455 WebSocket frame encoding/decoding
- **Foundation** - Inherits all FOUNDATION utilities (Base64, SHA, UUID, JSON, etc.)

## Dependencies

This library bundles the following service libraries:

| Library | Purpose | Environment Variable |
|---------|---------|---------------------|
| [simple_jwt](https://github.com/ljr1981/simple_jwt) | JWT authentication | `$SIMPLE_JWT` |
| [simple_smtp](https://github.com/ljr1981/simple_smtp) | Email sending | `$SIMPLE_SMTP` |
| [simple_sql](https://github.com/ljr1981/simple_sql) | SQLite database | `$SIMPLE_SQL` |
| [simple_cors](https://github.com/ljr1981/simple_cors) | CORS handling | `$SIMPLE_CORS` |
| [simple_rate_limiter](https://github.com/ljr1981/simple_rate_limiter) | Rate limiting | `$SIMPLE_RATE_LIMITER` |
| [simple_template](https://github.com/ljr1981/simple_template) | Template rendering | `$SIMPLE_TEMPLATE` |
| [simple_websocket](https://github.com/ljr1981/simple_websocket) | WebSocket protocol | `$SIMPLE_WEBSOCKET` |
| [simple_foundation_api](https://github.com/ljr1981/simple_foundation_api) | Core utilities | `$SIMPLE_FOUNDATION_API` |

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
    service: SERVICE
do
    create service.make

    -- JWT Authentication
    token := service.create_token ("secret", "user@example.com", "my-app", 3600)
    if service.verify_token ("secret", token) then
        print ("Token valid!%N")
    end

    -- Email
    smtp := service.new_smtp ("smtp.example.com", 587)
    smtp.set_credentials ("user", "pass")
    smtp.set_from ("sender@example.com", "Sender")
    smtp.add_to ("recipient@example.com", "Recipient")
    smtp.set_subject ("Hello!")
    smtp.set_body ("Test email")
    smtp.send

    -- Database
    db := service.new_memory_database
    db.execute_sql ("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)")
    db.execute_sql ("INSERT INTO users (name) VALUES ('Alice')")
    db.close

    -- CORS
    cors := service.new_cors
    cors.allow_origin ("https://example.com")
    headers := cors.get_headers ("https://example.com", "GET")

    -- Rate Limiting
    limiter := service.new_rate_limiter (100, 60)  -- 100 requests per minute
    if limiter.check ("client-ip").is_allowed then
        -- Process request
    end

    -- Templates
    result := service.render_template ("Hello, {{name}}!", data)

    -- WebSocket
    frame := service.new_ws_text_frame ("Hello", True)
    bytes := frame.to_bytes

    -- Foundation utilities (inherited)
    encoded := service.base64_encode ("data")
    hash := service.sha256 ("password")
    uuid := service.new_uuid
end
```

## API Summary

### JWT Authentication
- `new_jwt (secret)` - Create JWT handler
- `create_token (secret, subject, issuer, expires)` - Generate token
- `verify_token (secret, token)` - Verify token

### SMTP Email
- `new_smtp (host, port)` - Create SMTP client

### SQL Database
- `new_database (path)` - Open/create SQLite database
- `new_memory_database` - Create in-memory database

### CORS
- `new_cors` - Create CORS handler with defaults
- `new_cors_permissive` - Create permissive CORS handler

### Rate Limiting
- `new_rate_limiter (max_requests, window_seconds)` - Create limiter

### Templates
- `new_template` - Create template engine
- `render_template (template, data)` - Render with substitutions

### WebSocket
- `new_ws_handshake` - Create handshake handler
- `new_ws_frame_parser` - Create frame parser
- `new_ws_text_frame (text, is_final)` - Create text frame
- `new_ws_binary_frame (data, is_final)` - Create binary frame
- `new_ws_close_frame (code, reason)` - Create close frame
- `new_ws_ping_frame`, `new_ws_pong_frame` - Create control frames
- `new_ws_text_message`, `new_ws_binary_message` - Create messages

### Direct Access
- `jwt` - SIMPLE_JWT instance
- `smtp` - SIMPLE_SMTP instance
- `cors` - SIMPLE_CORS instance
- `template` - SIMPLE_TEMPLATE instance

### Inherited from FOUNDATION
All `FOUNDATION` features are available: `base64_encode`, `sha256`, `new_uuid`, `parse_json`, etc.

## License

MIT License - Copyright (c) 2024-2025, Larry Rix
