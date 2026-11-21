import { defineCollection } from "astro:content";
import { glob } from "astro/loaders";
import { docsSchema } from "@astrojs/starlight/schema";

export const collections = {
  docs: defineCollection({
    // Les ADR portent un `slug:` dans leur frontmatter (ADR-0001) : l'identifiant
    // de page vient du chemin du fichier, pas de ce champ.
    loader: glob({
      pattern: "**/*.{md,mdx}",
      base: "./docs",
      generateId: ({ entry }) => entry.replace(/\.mdx?$/, "").toLowerCase(),
    }),
    schema: docsSchema(),
  }),
};
