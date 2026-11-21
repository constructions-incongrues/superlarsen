---
adr: ADR-0007
slug: cloudflare-proxy-www-only
title: Only www goes through the Cloudflare proxy
status: proposed
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
---

# Only www goes through the Cloudflare proxy

## Status

Proposed

## Context

The zone `superlarsen.fr` is on the Cloudflare Free plan. Its proxy refuses uploads over 100 MB, and its WAF rules cannot read a request body. Castopod and LibreTime receive audio files larger than that; Icecast serves a continuous stream; SFTP is not HTTP.

On 2026-11-19 a burst of "lost password" requests on the WordPress site sent 11 e-mails in 58 seconds.

## Decision

`www` is the only proxied record. Every other record is DNS only and reaches Caddy directly.

For `www`:

- a WAF custom rule sets a managed challenge on any request whose path contains `/wp-login.php`;
- the origin answers 403 to any address outside Cloudflare's published ranges, by Caddy labels on the `wordpress` service;
- the zone is in Full (strict) mode: Cloudflare checks the certificate Caddy presents.

## Consequences

### Positive

- A robot that posts to `wp-login.php` without loading the form is stopped before WordPress.
- The site cannot be reached around the proxy.
- Large uploads to Castopod and LibreTime keep working.

### Negative

- The wiki, Castopod, LibreTime and Icecast have no WAF and expose the address of the server.
- The list of Cloudflare ranges is copied into `stacks/wordpress/compose.yaml`; if Cloudflare adds a range, visitors routed through it get a 403 until the list is updated.
- The challenge covers the whole of `wp-login.php`, not the lost-password action alone, since the Free plan cannot read the body where WordPress also reads it.

### Neutral

- A proxied record has an automatic TTL; the others keep 300 seconds.

## Alternatives Considered

### Proxy every HTTP record

Breaks uploads over 100 MB to Castopod and LibreTime.

### A paid Cloudflare plan

Lifts the upload limit and allows body inspection, at a recurring cost for one rule.

### Rate limiting in WordPress

A plugin to add and maintain in an image this repository does not build, and the request still reaches the server.

## References

- ADR-0004, ADR-0006.
- `infrastructure/terraform/cloudflare.tf`; arc42, sections 2, 7 and 10.
