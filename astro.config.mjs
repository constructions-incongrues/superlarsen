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
      sidebar: [
        {
          label: "Guides",
          items: [{ autogenerate: { directory: "docs/how-to" } }],
        },
        {
          label: "Référence",
          items: [{ autogenerate: { directory: "docs/reference" } }],
        },
        {
          label: "Architecture (arc42)",
          items: [{ autogenerate: { directory: "docs/architecture/arc42" } }],
        },
        {
          label: "Décisions du dépôt",
          items: [{ autogenerate: { directory: "docs/adr/local" } }],
        },
        {
          label: "Décisions de gouvernance",
          collapsed: true,
          items: [{ autogenerate: { directory: "docs/adr/engineering" } }],
        },
      ],
    }),
  ],
});
