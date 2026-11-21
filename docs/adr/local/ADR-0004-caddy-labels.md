---
adr: ADR-0004
slug: caddy-labels
title: Services are exposed through Caddy labels
status: proposed
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
---

# Services are exposed through Caddy labels

## Status

Proposed

## Context

The `cartons` server runs one Caddy for every project it hosts. It reads Docker labels and builds its own configuration from them. This repository does not own that Caddy (arc42, section 2), and one person maintains the platform: a proxy file to edit on the server for each new domain would be a step outside the repository, which engineering/ADR-0012 and ADR-0002 rule out.

This decision was in force before it was written down. This record states it; it does not change it.

## Decision

A web service is exposed by two things in its `compose.yaml`, and nothing else:

- it joins the external Docker network `caddy`;
- it carries the labels `caddy: <domain>` and `caddy.reverse_proxy: "{{upstreams <port>}}"`.

Caddy obtains the certificate and routes the domain. Access rules that belong to one service are labels too, as with the Cloudflare-only origin of `wordpress`.

A service that is not HTTP publishes a port instead: `sftp` on 2222, and the LibreTime live inputs on 8001 and 8002.

## Consequences

### Positive

- Exposing a service is part of the pull request that adds it, and is reviewed with it.
- No proxy configuration lives outside the repository.

### Negative

- Exposure depends on a Caddy this repository neither configures nor versions: a change on the server can break routing with no change here.
- A published port bypasses Caddy and gets no TLS from it. The LibreTime live inputs are in clear text.
- Traffic between Caddy and a container is plain HTTP on the `caddy` network.

### Neutral

- The labels are not checked by any linter; a typo is seen after deployment.

## Alternatives Considered

### A Caddyfile on the server

One file for all domains, edited by hand: a step outside the repository and outside review.

### A reverse proxy in each stack

Each stack would need ports 80 and 443, which one server cannot give to five stacks.

## References

- ADR-0002; engineering/ADR-0003, ADR-0012.
- arc42, sections 4, 7 and 8.
