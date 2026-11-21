// Spec docs-navigation, « Numéro des ADR » : dans la barre latérale, un lien vers
// un ADR (…/adr-0006-commits/) devient « ADR-0006 Commits ». Le numéro vient du
// nom de fichier, qu'ADR-0001 impose égal au champ `adr` ; aucun ADR n'est modifié.
import { defineRouteMiddleware } from "@astrojs/starlight/route-data";

type Entry = { type: string; href?: string; label: string; entries?: Entry[] };

const number = (entries: Entry[]): void => {
  for (const entry of entries) {
    if (entry.type === "group" && entry.entries) number(entry.entries);
    const match = entry.href?.match(/\/adr-(\d{4})-[^/]*\/?$/);
    if (entry.type === "link" && match && !entry.label.startsWith("ADR-")) {
      entry.label = `ADR-${match[1]} ${entry.label}`;
    }
  }
};

export const onRequest = defineRouteMiddleware((context) => {
  number(context.locals.starlightRoute.sidebar as Entry[]);
});
