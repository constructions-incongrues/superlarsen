---
adr: ADR-0008
slug: documentation
title: Documentation
status: accepted
revision: 3
date: 2026-11-21
authors: [Tristan Rivoallan]
supersedes: []
check: npx --no-install ontrack-engineering-check ADR-0008
traits:
  docs:
    tool: starlight
    root: docs/
    audience: public
    channels: [main]
---

# Documentation

## Status

Accepted

> **What is this file?** A question governance asks your repository, with
> the answer it recommends. While it says `status: proposed`, you may edit
> it freely. `revision:` dates the question, not the file: you do not fill
> it, and it only moves when the question changes. `rejected` is a full
> answer: when the question does not apply here, rule `rejected`, remove
> the whole `traits:` block, and say what stands in for it.
> [ADR-0001](ADR-0001-record-architecture-decisions.md) explains the
> mechanics.

## Context

While these keys are empty, an agent that has to write a page does not know
**where to put it**, whether **it has to touch a navigation file**, or **what
it may write in it**. It drops the file by guesswork, leaves a stale table
of contents behind, and may publish an internal URL in a page the world
reads. Nor does it know **which version of the pages the site shows**: a
site deployed from the default branch describes features no release has,
and whoever installed the latest release copies an option that does not
exist yet. Once these four values are written, it knows.

**This ADR governs the documentation written for whoever uses the
product**: guides, tutorials, references. Two other readers have their own
documents, ruled elsewhere: whoever changes the product reads the
architecture document ([ADR-0010](ADR-0010-architecture-documentation.md)),
and whoever rules reads the ADRs in `docs/adr/`. `docs.root`,
`docs.audience`, `docs.channels` and Diátaxis apply to the user
documentation only.

**The classification is not decided here.** governance requires
[Diátaxis](https://diataxis.fr/) (tutorial, how-to guide, explanation,
reference) and the Google developer documentation style for prose. What is
yours is the **tooling**, the **location** and the **audience**.

## Decision

**What governance recommends, and why.**

| Key             | Recommended value                                                                                                      | Reason                                                                                                                                                                                                                                             |
| --------------- | ---------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `docs.tool`     | `starlight`                                                                                                            | the fastest build measured (see References), navigation **generated from the directory tree** so adding a page touches no table of contents, built-in search, and LikeC4 views (ADR-0010) embedded through its Vite plugin with no generation step |
| `docs.root`     | `docs/`                                                                                                                | an agent looking for where to put a page has nothing to guess, and sharing the directory with `docs/adr/` and `docs/architecture/` lets one site serve all three if you want it to; that is a convenience, not a constraint                        |
| `docs.audience` | `public`                                                                                                               | governance's repositories are public on GitHub, so their documentation is read by anyone whether or not that was intended; writing for that audience from the start is the honest default                                                          |
| `docs.channels` | _by target_: `[release, main]` when ADR-0012's `delivery.target` is `package`, `[main]` when every merge reaches users | a package's users run a release, so the site's root must show that release, and the default branch stays readable under `next/` for whoever tests before the release; where every merge is deployed, the default branch _is_ what users run        |

**Starlight does not read `docs/` by default**: it expects
`src/content/docs/`. Point its `docs` collection at `docs/` with Astro's
`glob` loader, in `src/content.config.ts`:

```ts
import { defineCollection } from "astro:content";
import { glob } from "astro/loaders";
import { docsSchema } from "@astrojs/starlight/schema";

export const collections = {
  docs: defineCollection({
    loader: glob({ pattern: "**/*.{md,mdx}", base: "./docs" }),
    schema: docsSchema(),
  }),
};
```

**This pattern also publishes `docs/adr/` and `docs/architecture/`.**
Whether that is right depends on who may read them, which is not
`docs.audience` (see ADR-0010). To publish the user documentation only,
exclude them in the pattern:

```ts
loader: glob({ pattern: ['**/*.{md,mdx}', '!adr/**', '!architecture/**'], base: './docs' }),
```

Each page then needs a `title:` in its frontmatter. Mermaid diagrams
(ADR-0010) need the `astro-mermaid` integration, which renders them in the
browser and adds nothing to the build.

**`public` is the strict end of the scale, and that is the point.** A page
read more widely than it was written for cannot be unpublished, while a
page written for the public is never wrong for a smaller audience. For a
private repository, `team` or `single-user` is a legitimate answer: it is
taken, not suffered.

**The audience is a scale, not a switch.** Three steps, from narrowest to
widest, and each widens who may read:

| Value         | Who reads                                    |
| ------------- | -------------------------------------------- |
| `single-user` | one person, the one who opens the repository |
| `team`        | the people who maintain this repository      |
| `public`      | anyone                                       |

**This is not a vocabulary detail.** Each step decides what an agent may
write in a page: a customer name, an internal URL, an infrastructure detail,
a person's address. What passes at `team` does not pass at `public`, and
nothing catches it afterwards.

**Channels: which versions the site publishes.** `release` is the latest
published release, `main` the default branch. Six rules follow from the
list:

1. **`release` is served at the site root** when it is listed, otherwise
   `main` is. The other listed channel is served under `next/`.
2. **Until a first release exists**, `main` is served at the root and
   `next/` does not exist.
3. **One workflow deploys the site, and every run rebuilds every listed
   channel.** GitHub Pages holds one site per repository and each deploy
   replaces all of it: a workflow for tags and another for the default
   branch would each erase the other's channel.
4. **Each channel builds from its own checkout of its own commit.** A site
   often imports the code it documents, so the pages of one commit only
   build against the code of that commit. Check out the latest release and
   the default branch into two folders, build each, set the default
   branch's base path to `next/`, and deploy one artifact.
5. **When both channels are listed, the pages of `main` carry a banner**
   that points to the released documentation, for whoever lands there from
   a search engine.
6. **An agent writes a feature's pages in the pull request that adds the
   feature**, whatever has been released. The channels decide who sees
   them, and when; nothing is copied, and nothing waits for the release.

With `[release, main]`, the workflow that deploys the site runs on both
pushes:

```yaml
on:
  push:
    branches: [main]
    tags: ["v*"]
```

**Without a site, the key is absent.** With `docs.tool: none`, the forge
already shows `docs/` at every tag, and there is nothing to publish.

**Diátaxis quadrants are not a key of this ADR, on purpose.** The quadrants
a repository holds are **observed** once it has pages, and at adoption it has
none. Asking would force an invented answer or an empty key the schema
refuses. The classification still applies, page by page, when each is
written.

**Ruling: the recommendation, adopted as is**, with `channels: [main]`
because every merge to `main` is deployed by Cartons and there are no
releases. At ruling time GitHub Pages serves `main:/docs` as raw files, with
a placeholder `index.html`: the Starlight site is a target, to be set up. It
is also meant to serve the arc42 document and LikeC4 views of ADR-0010.

## Consequences

### Positive

- An agent knows where a page goes and never has to edit a table of
  contents.
- A reader of the site's root reads the version they installed, and a
  feature's pages ship with the feature.
- A full build stays in seconds, and search works without an external
  service.
- With `public`, an agent never writes an internal URL, a customer name or
  an infrastructure detail into a page.

### Negative

- `starlight` is a Node.js site to install, build and keep up to date,
  even in a repository that has no other JavaScript.
- Reading `docs/` and rendering Mermaid both take configuration Starlight
  does not ship by default, and Mermaid goes through a third-party
  integration.
- `public` forbids the raw notes and internal details that a private
  repository's documentation could usefully hold.
- `[release, main]` doubles the site's build, and the default branch must
  know how to build under another base path.

### Neutral

- The language of the documentation is decided by
  [ADR-0002](ADR-0002-localization.md), not here.

## Alternatives Considered

### Starlight

A generated site on Astro, automatic navigation. Recommended, for the
reasons above.

### Docusaurus

A generated site on React, automatic navigation. It reads `docs/` by
default and renders Mermaid through an official theme (which also needs
`@mermaid-js/layout-elk` installed). Its versioning copies the pages per
version, which `docs.channels` does not need (see below). Its default build was the
slowest measured, about seven times Starlight's; with `future.faster` and
`future.v4` turned on it comes within about 25 % of Starlight. LikeC4 views
need `likec4 codegen webcomponent` before every build. A sound answer:
turn `future.faster` on if you choose it.

### MkDocs

A generated site in Python, for a repository with no Node.js at all.

### A generated site, hand-kept navigation

More control over order, and one more file to update with every page.

### No site

Pages are read on the forge. A tenable answer, frequent for a repository
with no outside readers; write `docs.tool: none`.

### Versioned copies

A copy of the pages per version, as Docusaurus's `versioned_docs/`.
Refused: an agent finds the same page several times and edits the wrong
copy, or fixes one and forgets the others. Building each channel from its
own commit keeps `docs/` in one place.

### Channels derived from ADR-0012

Publish `release` when `delivery.environments` deploys on tags, `main` when
it deploys on merge. Refused: what a reader of the documentation should see
is not what a user receives. A package deployed only on tags may still want
its default branch readable.

### One enum value

`docs.channels: release | main | both`. Simpler to read, but a later
value, such as older majors kept online, would turn it into a list and
break every answer. The list takes that value without breaking any.

## References

- Suggested skills: `write-for-humans` from `docs-hygiene@melodic-software`.
- Adapted from surdesrails [SDR-0008](https://github.com/trivoallan/surdesrails/blob/main/resources/docs/adr/SDR-0008-documentation.md), revision 1 (audience scale reduced to three steps; recommends `public` rather than the team step, and `starlight` rather than `docusaurus`).
- Build times measured on 2026-11-14, Apple M1 Pro, Node 22, three cold
  builds each (outputs and caches removed), on 302 Markdown pages of which 30
  hold a Mermaid diagram, plus one page with a LikeC4 view. Medians:
  Docusaurus 3.10.2 default, 57.6 s (including 1.5 s of LikeC4 code
  generation); Docusaurus 3.10.2 with `future.faster`, 10.4 s (including
  1.6 s); Starlight 0.43.1 on Astro 7.4, 7.6 s (including the Pagefind
  index). The development server was not measured.
- [ADR-0001](ADR-0001-record-architecture-decisions.md): how governance ADRs are ruled on.
- [Diátaxis](https://diataxis.fr/) and the [Google developer documentation style guide](https://developers.google.com/style).

**The keys.**

| Key             | What it holds                                  | Allowed values                                                                             |
| --------------- | ---------------------------------------------- | ------------------------------------------------------------------------------------------ |
| `docs.tool`     | what generates the site, if there is one       | `starlight`, `docusaurus`, `mkdocs`, `none`                                                |
| `docs.root`     | the directory the pages live in                | a path, for example `docs/`                                                                |
| `docs.audience` | how far this documentation reaches             | `single-user`, `team`, `public`, as described above                                        |
| `docs.channels` | which versions of the pages the site publishes | a list of `release`, `main`, or both, each at most once; absent when `docs.tool` is `none` |

**`docs.audience` is not decorative.** `public` commits an agent to never
writing an internal URL, a customer name or an infrastructure detail in a
page. `single-user` says the opposite: nothing leaves the repository, and a
raw note belongs there. **Nothing checks it**: review does, which is why the
value must be written rather than assumed.

**Two of these keys are decided by looking at the repository**, not by
reading this file: does a site already exist, and where do the pages live.
Only `docs.audience` is decided by reading.

**`docs/adr/` does not move with `docs.root`.** It is where ontrack reads
the ADRs, not a documentation page; the architecture document stays where
ADR-0010 puts it.

**What these keys do not cover:** the Diátaxis classification, the prose
style, the language, the architecture document and the ADRs. **And Diátaxis
itself is not refused here**: `rejected` means you keep no user
documentation, whatever ADR-0010 answers, not that you classify it
differently.

**`docs.tool`, `docs.root` and `docs.audience` are required, and so is
`docs.channels` unless `docs.tool` is `none`**: an empty key is not an
answer. The value is
written in this file and nowhere else; whoever needs it links here. See
ADR-0001 for the check command.

**Revisions.** What changed in the question at each revision, and what
a repository that already ruled must re-answer.

- Revision 2: the ADR governs the user documentation only; the architecture document and the ADRs are ADR-0010's, and no path moves with `docs.root` any more. Keys and values are unchanged, but the scope of `docs.root` and `docs.audience` narrowed: check that your answers still hold for the user documentation alone.
- Revision 3: adds `docs.channels`, the versions of the pages the site publishes. A repository whose `docs.tool` is not `none` must answer it, and its deploy workflow must run on the pushes the answer names; with `docs.tool: none`, there is nothing to answer.
