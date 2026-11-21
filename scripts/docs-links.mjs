// Après `astro build` : les liens entre pages visent des fichiers .md, lisibles
// sur GitHub. Sur le site, chaque page est un dossier en minuscules, un niveau
// plus bas que son fichier : `../x/ADR-0001-foo.md#bar` → `../../x/adr-0001-foo/#bar`.
// ponytail: liens relatifs dans href="…" seulement ; un lien absolu vers un .md resterait cassé.
import { readdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const fix = (html) =>
  html.replace(
    /href="(?![a-z]+:|\/|#)([^"#]*?)\.mdx?(#[^"]*)?"/gi,
    (_, path, hash = "") => `href="../${path.toLowerCase()}/${hash}"`,
  );

for (const entry of readdirSync("dist", { recursive: true })) {
  if (!entry.endsWith(".html")) continue;
  const file = join("dist", entry);
  writeFileSync(file, fix(readFileSync(file, "utf8")));
}

// Vérification minimale : un lien .md relatif doit être réécrit.
console.assert(
  fix('<a href="../x/ADR-0001-Foo.md#bar">') ===
    '<a href="../../x/adr-0001-foo/#bar">',
);

// La barre latérale doit lister les pages : Starlight cherche les dossiers
// `autogenerate` sous le chemin du fichier (docs/…), et un dossier mal nommé
// donne une navigation vide sans erreur de build.
const page = readFileSync(
  "dist/architecture/arc42/01-introduction-and-goals/index.html",
  "utf8",
);
if (!page.includes('href="/superlarsen/adr/engineering/')) {
  console.error(
    "docs: barre latérale vide, vérifier les `autogenerate.directory` d’astro.config.mjs",
  );
  process.exit(1);
}
