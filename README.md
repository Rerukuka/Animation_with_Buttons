# Crypto News Aggregator — Rust Web Application

A lightweight cryptocurrency news aggregator built with **Rust, Tokio, Warp, Reqwest, and JavaScript**.

The application allows users to search for a cryptocurrency and combines information from two external APIs:

* **CoinGecko Pro API** — cryptocurrency metadata and project description
* **NewsData.io API** — recent cryptocurrency-related news

The Rust backend exposes a JSON API and also serves a small responsive frontend.

---

## Overview

The application follows a simple client-server architecture:

```text
User
 │
 ▼
Browser
 │
 │ GET /news/{crypto}
 ▼
Rust / Warp Server
 │
 ├──────────────► CoinGecko Pro API
 │                   │
 │                   └── Coin description + homepage
 │
 └──────────────► NewsData.io
                     │
                     └── Recent news articles
 │
 ▼
Combined JSON Response
 │
 ▼
Browser
```

The server runs locally on:

```text
http://localhost:3030
```

---

# Features

The project currently provides:

* Rust asynchronous backend
* Tokio async runtime
* Warp HTTP server
* Cryptocurrency search endpoint
* CoinGecko Pro API integration
* NewsData.io API integration
* JSON serialization with Serde
* Environment-variable support
* Static HTML frontend
* Responsive interface
* CORS configuration
* Basic API error handling
* MIT License

---

# Technology Stack

## Backend

```text
Rust
Tokio
Warp
Reqwest
Serde
Serde JSON
dotenv
```

## Frontend

```text
HTML5
CSS3
Vanilla JavaScript
Fetch API
```

## External APIs

```text
CoinGecko Pro API
NewsData.io API
```

---

# Project Structure

```text
BCK1_4-main/
│
├── src/
│   ├── main.rs
│   └── api.rs
│
├── static/
│   └── index.html
│
├── Cargo.toml
├── Cargo.lock
├── .gitignore
├── LICENSE
└── README.md
```

---

# Backend Architecture

The backend is divided into two main modules.

```text
src/
│
├── main.rs
│   │
│   ├── HTTP server
│   ├── Warp routes
│   ├── CORS
│   └── Static files
│
└── api.rs
    │
    ├── CoinGecko requests
    ├── NewsData requests
    ├── JSON parsing
    └── Article generation
```

---

# `main.rs`

The application starts using Tokio:

```rust
#[tokio::main]
async fn main() {
    // ...
}
```

Environment variables are loaded with:

```rust
dotenv::dotenv().ok();
```

The main API route is:

```rust
warp::path!("news" / String)
```

which produces URLs such as:

```text
/news/bitcoin
/news/ethereum
/news/solana
```

---

# Server

The Warp server listens on:

```text
127.0.0.1:3030
```

The startup message is:

```text
Server running at http://localhost:3030
```

The server is started with:

```rust
warp::serve(routes)
    .run(([127, 0, 0, 1], 3030))
    .await;
```

Because it binds to:

```text
127.0.0.1
```

the application is accessible only from the local machine by default.

---

# API Endpoint

## Get Cryptocurrency News

```http
GET /news/{crypto}
```

Example:

```http
GET /news/bitcoin
```

The backend then requests information from:

```text
CoinGecko
+
NewsData.io
```

and combines the results into one array.

---

# Article Data Model

The backend defines:

```rust
pub struct Article {
    pub title: String,
    pub description: String,
    pub link: String,
}
```

Therefore every returned item currently contains exactly:

```text
title
description
link
```

Example response:

```json
[
  {
    "title": "About BITCOIN",
    "description": "Bitcoin is a decentralized cryptocurrency...",
    "link": "https://bitcoin.org/"
  },
  {
    "title": "Bitcoin market news",
    "description": "Latest Bitcoin-related market information...",
    "link": "https://example.com/article"
  }
]
```

---

# CoinGecko Integration

The backend uses the CoinGecko Pro endpoint:

```text
https://pro-api.coingecko.com/api/v3/coins/{crypto}
```

Authentication is sent through:

```text
x-cg-pro-api-key
```

using the environment variable:

```text
COINGECKO_API_KEY
```

---

# CoinGecko Data

The application extracts:

```text
description.en
```

and:

```text
links.homepage[0]
```

from the CoinGecko response.

The resulting synthetic article is created as:

```text
Title:
About {CRYPTO}

Description:
CoinGecko project description

Link:
Official project homepage
```

---

# Important CoinGecko Search Note

The endpoint used by this project expects a **CoinGecko coin ID**.

For example:

| Cryptocurrency | Recommended Query |
| -------------- | ----------------- |
| Bitcoin        | `bitcoin`         |
| Ethereum       | `ethereum`        |
| Solana         | `solana`          |
| Cardano        | `cardano`         |
| Dogecoin       | `dogecoin`        |

Therefore:

```text
/news/bitcoin
```

is more reliable than:

```text
/news/btc
```

and:

```text
/news/ethereum
```

is more reliable than:

```text
/news/eth
```

The current frontend placeholder says:

```text
eth, btc, ...
```

but the CoinGecko endpoint used by the backend works with CoinGecko IDs rather than ticker symbols.

---

# NewsData.io Integration

Recent news is retrieved using:

```text
https://newsdata.io/api/1/news
```

with parameters:

```text
apikey
q
language=en
```

For example, logically:

```text
q=bitcoin
language=en
```

The API key is read from:

```text
NEWSDATA_API_KEY
```

---

# NewsData Fields

For each NewsData result, the backend extracts:

```text
title
description
link
```

and converts it into the shared Rust:

```rust
Article
```

structure.

---

# Combined Data Flow

```text
Search: bitcoin
       │
       ▼
GET /news/bitcoin
       │
       ▼
   fetch_news()
       │
 ┌─────┴──────────────────┐
 │                        │
 ▼                        ▼
CoinGecko              NewsData
 │                        │
 ▼                        ▼
Description           News Articles
Homepage                 Links
 │                        │
 └──────────┬─────────────┘
            │
            ▼
      Vec<Article>
            │
            ▼
         JSON
            │
            ▼
        Browser
```

---

# Error Handling

The backend uses:

```rust
match api::fetch_news(&symbol).await
```

If the API requests succeed:

```http
200 OK
```

is returned.

If a request produces a `reqwest::Error`, the server responds with:

```http
500 Internal Server Error
```

and:

```json
{
  "error": "Failed to fetch news"
}
```

---

# Static Frontend

The server also serves:

```text
static/
```

using:

```rust
warp::fs::dir("static")
```

Therefore opening:

```text
http://localhost:3030
```

loads the web interface from:

```text
static/index.html
```

---

# Frontend Interface

The frontend contains:

```text
Crypto News
────────────────────────

[ bitcoin              ] [ Search ]

News results...
```

It uses a dark interface with yellow cryptocurrency-style accents.

The layout is responsive and includes a mobile breakpoint at:

```text
600 px
```

---

# Search Workflow

When the user clicks:

```text
Search
```

JavaScript reads:

```javascript
document.getElementById('symbol').value
```

and requests:

```javascript
fetch(`/news/${symbol}`)
```

Example:

```text
bitcoin
   │
   ▼
/news/bitcoin
   │
   ▼
Rust Backend
   │
   ▼
API Results
```

---

# Current Frontend/API Mismatch

The Rust backend returns:

```text
title
description
link
```

but the current JavaScript attempts to read:

```javascript
article.title
article.source
article.published_at
article.description
article.url
```

The fields:

```text
source
published_at
url
```

do **not exist** in the current Rust `Article` structure.

As a result, the existing frontend may display:

```text
Source: undefined
Published: Invalid Date
```

and the:

```text
Read more →
```

link may not work correctly.

---

# Correct Backend Fields

The current frontend should use:

```javascript
article.title
article.description
article.link
```

instead.

A compatible result card would conceptually contain:

```text
Article Title

Description...

Read more →
```

using:

```javascript
article.link
```

as the destination.

---

# Installation

## Requirements

Install:

```text
Rust
Cargo
```

Recommended setup is through Rustup.

Verify the installation:

```bash
rustc --version
cargo --version
```

---

# Clone the Repository

```bash
git clone <repository-url>
cd BCK1_4-main
```

---

# Environment Variables

Create a file named:

```text
.env
```

inside the project root.

Configure the following variables:

```text
COINGECKO_API_KEY
NEWSDATA_API_KEY
```

`COINGECKO_API_KEY` must contain a valid CoinGecko Pro API key compatible with:

```text
pro-api.coingecko.com
```

`NEWSDATA_API_KEY` must contain a valid NewsData.io API key.

The repository already contains:

```gitignore
.env
```

so the environment file will not normally be committed to Git.

---

# Install Rust Dependencies

Run:

```bash
cargo fetch
```

Cargo downloads all dependencies specified in:

```text
Cargo.toml
```

---

# Run the Application

Start the development server:

```bash
cargo run
```

Expected console output:

```text
Server running at http://localhost:3030
```

Open:

```text
http://localhost:3030
```

in a browser.

---

# Example API Requests

## Bitcoin

```text
http://localhost:3030/news/bitcoin
```

## Ethereum

```text
http://localhost:3030/news/ethereum
```

## Solana

```text
http://localhost:3030/news/solana
```

---

# Example with `curl`

```bash
curl http://localhost:3030/news/bitcoin
```

A successful response returns a JSON array.

---

# Cargo Configuration

The package is defined as:

```toml
[package]
name = "crypto_news"
version = "0.1.0"
edition = "2024"
```

Therefore:

```text
Package: crypto_news
Version: 0.1.0
Rust Edition: 2024
```

---

# Dependencies

The current project declares:

```text
reqwest
serde
tokio
serde_json
yew
warp
dotenv
chrono
```

---

## Reqwest

```toml
reqwest = {
    version = "0.12.15",
    features = ["json"]
}
```

Used for HTTP requests to external APIs.

---

## Serde

```toml
serde = {
    version = "1.0",
    features = ["derive"]
}
```

Used for JSON serialization and deserialization.

---

## Tokio

```toml
tokio = {
    version = "1",
    features = ["full"]
}
```

Provides the asynchronous runtime.

---

## Warp

```toml
warp = "0.3"
```

Provides:

```text
HTTP server
Routes
Static file serving
CORS
JSON replies
```

---

## dotenv

```toml
dotenv = "0.15"
```

Loads API credentials from:

```text
.env
```

---

# Currently Unused Dependencies

The repository currently declares:

```text
yew
chrono
```

but neither library is used by the current source code.

### Yew

```toml
yew = {
    version = "0.21",
    features = ["csr"]
}
```

The frontend is currently plain:

```text
HTML + CSS + JavaScript
```

rather than a Yew application.

### Chrono

```toml
chrono = "0.4"
```

is also not currently imported by the Rust source.

These dependencies can potentially be removed unless they are intended for future development.

---

# CORS

The news API route uses:

```rust
warp::cors()
    .allow_any_origin()
    .allow_method("GET")
    .allow_header("content-type");
```

This means API GET requests are allowed from any origin.

For local development this is convenient.

For a production deployment, restricting the allowed origins is recommended.

---

# Security Notice

API keys should never be committed directly to Git.

The project correctly ignores:

```text
.env
```

through `.gitignore`.

However, there is an additional issue in the current code.

The NewsData request URL is printed using:

```rust
println!("🔍 NewsData URL: {}", newsdata_url);
```

Because the API key is embedded directly in that URL:

```text
?apikey=...
```

the complete:

```text
NEWSDATA_API_KEY
```

can appear in server logs.

For production usage, the application should avoid logging the complete NewsData URL.

---

# CoinGecko Logging

The project also prints:

```text
CoinGecko URL
```

but the CoinGecko key itself is sent as an HTTP header:

```text
x-cg-pro-api-key
```

and is therefore not included in the printed URL.

---

# NewsData Response Logging

The server currently logs the complete NewsData JSON response:

```rust
println!(
    "📰 NewsData Response: {:#?}",
    newsdata_json
);
```

This can be useful during development but can create large production logs.

It should normally be removed or replaced with structured debug logging before production deployment.

---

# Empty Search Input

The current frontend does not validate whether the search field is empty before requesting:

```text
/news/{symbol}
```

A future version should check:

```text
symbol.length > 0
```

before making the request.

---

# HTML Rendering Security

The frontend currently creates result cards using:

```javascript
card.innerHTML = `...`;
```

Article content comes from third-party APIs.

For a production application, rendering external data with:

```text
textContent
```

or another escaping strategy is safer than inserting API values directly through `innerHTML`.

---

# Current Limitations

The project currently has several limitations:

1. CoinGecko expects coin IDs rather than common ticker symbols.
2. The frontend placeholder suggests `btc` and `eth`, which may not work with the CoinGecko endpoint.
3. The Rust response structure and frontend fields do not currently match.
4. `source` is not returned by the backend.
5. `published_at` is not returned by the backend.
6. The frontend reads `article.url`, while Rust returns `article.link`.
7. Empty search values are not validated.
8. CoinGecko Pro requires an appropriate API key.
9. Failure of an external request can result in a complete `500` response.
10. NewsData API credentials can appear in server logs.
11. Full NewsData responses are printed to the console.
12. CORS currently allows any origin.
13. External article data is rendered with `innerHTML`.
14. No caching is implemented.
15. No request rate limiting is implemented.
16. No automated test suite is included.
17. `yew` is currently unused.
18. `chrono` is currently unused.
19. The server binds only to `127.0.0.1`.
20. Pagination is not implemented.

---

# Recommended Improvements

Useful next steps include:

```text
Fix frontend response fields
        │
        ▼
Use CoinGecko coin IDs
        │
        ▼
Add input validation
        │
        ▼
Remove API-key logging
        │
        ▼
Add source + publication time
        │
        ▼
Add caching
        │
        ▼
Add pagination
        │
        ▼
Add automated tests
```

Additional improvements could include:

* convert ticker symbols to CoinGecko IDs
* search by both token name and symbol
* add article source information
* add publication timestamps
* add loading skeletons
* improve API error messages
* independently tolerate failure of one provider
* cache cryptocurrency metadata
* cache news results
* add request timeouts
* add rate limiting
* add structured logging
* add configuration for host and port
* add Docker support
* add integration tests
* remove unused dependencies
* migrate the frontend to Yew if desired

---

# Better Error Isolation

The current implementation effectively performs:

```text
CoinGecko
    │
    ├── Failure
    │      │
    │      ▼
    │   Entire Request Fails
    │
NewsData
```

A stronger aggregator could behave like:

```text
CoinGecko ──── success ───┐
                          │
                          ▼
                     Combined Results
                          ▲
                          │
NewsData ───── failure ───┘
```

so that one unavailable provider does not prevent results from the other provider from being displayed.

---

# Suggested Future API Response

A more complete article representation could include:

```json
{
  "title": "Bitcoin market update",
  "description": "Article summary",
  "link": "https://example.com/article",
  "source": "Example News",
  "published_at": "2026-01-01T12:00:00Z"
}
```

This would match the fields that the existing frontend was originally designed to display.

---

# Suggested Production Architecture

```text
                           Browser
                              │
                              ▼
                         Rust / Warp
                              │
                 ┌────────────┴─────────────┐
                 │                          │
                 ▼                          ▼
            Cache Layer                Rate Limiter
                 │                          │
                 └────────────┬─────────────┘
                              │
                  ┌───────────┴───────────┐
                  │                       │
                  ▼                       ▼
              CoinGecko                NewsData
                  │                       │
                  └───────────┬───────────┘
                              │
                              ▼
                       Normalized Article
                              │
                              ▼
                         JSON Response
```

---

# Testing

The repository currently contains no dedicated:

```text
tests/
```

directory.

Recommended tests include:

```text
Article Serialization
│
├── title
├── description
└── link

API
│
├── successful CoinGecko response
├── successful NewsData response
├── provider failure
├── empty result list
└── invalid crypto

HTTP Server
│
├── GET /news/{crypto}
├── 200 response
├── 500 response
└── static index page
```

Mock HTTP servers should preferably be used instead of real third-party API calls during automated testing.

---

# Build

Create a development build:

```bash
cargo build
```

For an optimized release build:

```bash
cargo build --release
```

The resulting executable is normally created under:

```text
target/release/crypto_news
```

or the platform-specific equivalent.

---

# Run Release Build

After:

```bash
cargo build --release
```

run the generated executable or simply use:

```bash
cargo run --release
```

---

# `.gitignore`

The project currently excludes:

```text
/target
.env
```

This prevents:

* Rust build artifacts
* local API credentials

from being committed.

---

# License

The repository contains:

```text
LICENSE
```

with the:

```text
MIT License
```

Copyright:

```text
Copyright (c) 2025 fellinluvva
```

The project can therefore be used, modified, distributed, and sublicensed under the conditions of the MIT License.

---

# Learning Objectives

This project demonstrates:

* Rust web development
* asynchronous Rust
* Tokio
* HTTP APIs with Reqwest
* Warp routes
* JSON handling
* Serde
* environment variables
* third-party API integration
* static frontend serving
* CORS
* JavaScript Fetch API
* combining multiple API sources

---

# Summary

```text
Project:       Crypto News Aggregator
Package:       crypto_news
Version:       0.1.0
Language:      Rust
Rust Edition:  2024
Runtime:       Tokio
HTTP Server:   Warp
HTTP Client:   Reqwest
Serialization: Serde
Frontend:      HTML / CSS / JavaScript
Coin Data:     CoinGecko Pro
News:          NewsData.io
Port:          3030
License:       MIT
```

## Current Data Flow

```text
Search Cryptocurrency
        │
        ▼
GET /news/{crypto}
        │
        ▼
     Warp Server
        │
   ┌────┴────────┐
   │             │
   ▼             ▼
CoinGecko     NewsData
   │             │
   └──────┬──────┘
          │
          ▼
    Vec<Article>
          │
          ▼
        JSON
          │
          ▼
       Browser
```

The repository provides a compact example of building an asynchronous cryptocurrency-news aggregator in Rust while integrating multiple external REST APIs.
