// Site de documentation (ADR-0008 : starlight, docs/, public, channels [main]).
import { defineConfig } from "astro/config";
import starlight from "@astrojs/starlight";
import mermaid from "astro-mermaid";

export default defineConfig({
  site: "https://constructions-incongrues.github.io",
  base: "/superlarsen",
  integrations: [
    mermaid(),
    starlight({
      title: "Superlarsen",
      defaultLocale: "root",
      locales: { root: { label: "Français", lang: "fr" } },
      social: [
        {
          icon: "github",
          label: "GitHub",
          href: "https://github.com/constructions-incongrues/superlarsen",
        },
      ],
      // Barre latérale : spec docs-navigation (openspec/specs/docs-navigation).
      sidebar: [
        {
          label: "Guides",
          items: [{ autogenerate: { directory: "docs/how-to" } }],
        },
        {
          label: "Plateforme",
          items: [
            {
              label: "Architecture",
              items: [
                "architecture/arc42/01-introduction-and-goals",
                "architecture/arc42/02-constraints",
                "architecture/arc42/03-context-and-scope",
                "architecture/arc42/04-solution-strategy",
                "architecture/arc42/05-building-block-view",
                "architecture/arc42/06-runtime-view",
                "architecture/arc42/07-deployment-view",
                "architecture/arc42/08-cross-cutting-concepts",
                {
                  label: "Décisions",
                  items: [
                    "architecture/arc42/09-architecture-decisions",
                    { autogenerate: { directory: "docs/adr/local" } },
                  ],
                },
                "architecture/arc42/10-quality-requirements",
                "architecture/arc42/11-risks-and-technical-debt",
                "architecture/arc42/12-glossary",
              ],
            },
            {
              label: "Model",
              link: "/model/",
              attrs: { target: "_blank", rel: "noopener" },
            },
            {
              label: "Conventions",
              items: [
                {
                  label: "ontrack-engineering",
                  collapsed: true,
                  items: [
                    { autogenerate: { directory: "docs/adr/engineering" } },
                  ],
                },
              ],
            },
          ],
        },
      ],
      // Préfixe les liens d'ADR de la barre latérale par leur numéro (ADR-NNNN).
      routeMiddleware: "./src/routeData.ts",
    }),
  ],
});
