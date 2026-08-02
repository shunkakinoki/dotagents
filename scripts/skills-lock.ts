#!/usr/bin/env bun
// Generate skills-lock.json from the canonical SKILLS.txt.
// Declared skills that are installed get their resolved metadata from the
// global CLI lock (~/.agents/.skill-lock.json); the rest get a minimal entry
// pointing at the declared source so `bun run skills:install` can fetch them.
import { existsSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

type Entry = {
  source: string;
  sourceType?: string;
  sourceUrl?: string;
  ref?: string;
  skillPath?: string;
  skillFolderHash?: string;
};

const root = join(import.meta.dir, "..");
const agentsDir = join(homedir(), ".agents");

const globalLockPath = join(agentsDir, ".skill-lock.json");
if (!existsSync(globalLockPath)) {
  console.error(
    `${globalLockPath} not found; install a skill first (bunx skills add ... --global) to initialize it.`,
  );
  process.exit(1);
}
let globalLock: { version: number; skills: Record<string, Entry> };
try {
  globalLock = await Bun.file(globalLockPath).json();
} catch (error) {
  console.error(
    `Cannot read ${globalLockPath}: ${error instanceof Error ? error.message : String(error)}`,
  );
  process.exit(1);
}
if (typeof globalLock.version !== "number" || !globalLock.skills) {
  console.error(`${globalLockPath} is missing version/skills fields.`);
  process.exit(1);
}

// CLI-managed skills actually present on disk, keyed by name.
const installed = new Map<string, Entry>();
for (const [name, entry] of Object.entries(
  globalLock.skills as Record<string, Entry>,
)) {
  if (!existsSync(join(agentsDir, "skills", name))) continue;
  const { source, sourceType, sourceUrl, ref, skillPath, skillFolderHash } =
    entry;
  installed.set(name, {
    source,
    sourceType,
    sourceUrl,
    ref,
    skillPath,
    skillFolderHash,
  });
}

// Parse SKILLS.txt: `repo [skill1,skill2,...]` per line (no list = all skills).
const spec = new Map<string, string[]>();
const skillsTxt = await Bun.file(join(root, "SKILLS.txt")).text();
for (const raw of skillsTxt.split("\n")) {
  const line = raw.trim();
  if (!line || line.startsWith("#")) continue;
  const [repo, ...rest] = line.split(/\s+/);
  const names = rest
    .join(",")
    .split(",")
    .map((s) => s.trim())
    .filter(Boolean);
  if (repo) spec.set(repo, names);
}

function minimalEntry(repo: string): Entry {
  if (/^[\w.-]+\/[\w.-]+$/.test(repo)) {
    return {
      source: repo,
      sourceType: "github",
      sourceUrl: `https://github.com/${repo}.git`,
    };
  }
  return { source: repo };
}

const skills: Record<string, Entry> = {};
for (const [repo, names] of spec) {
  const repoKey = repo.toLowerCase();
  if (names.length === 0) {
    // Install-all repo: lock whatever is currently installed from it.
    let found = 0;
    for (const [name, entry] of installed) {
      if (entry.source.toLowerCase() === repoKey) {
        skills[name] = entry;
        found++;
      }
    }
    if (found === 0) {
      console.warn(
        `warn: no installed skills for install-all repo ${repo}; run: bunx skills add ${repo} --global --yes --skill '*'`,
      );
    }
    continue;
  }
  for (const name of names) {
    const hit = installed.get(name);
    const fromRepo =
      hit && hit.source.toLowerCase() === repoKey ? hit : undefined;
    // Prefer the installed entry; a name declared by multiple repos resolves
    // to whichever repo actually installed it (skill dirs are flat by name).
    skills[name] = fromRepo ?? skills[name] ?? minimalEntry(repo);
  }
}

const undeclared = [...installed.keys()].filter((name) => !skills[name]);
if (undeclared.length > 0) {
  console.warn(
    `warn: installed but not declared in SKILLS.txt: ${undeclared.join(", ")}`,
  );
}

const sorted: Record<string, Entry> = {};
for (const name of Object.keys(skills).sort()) {
  sorted[name] = skills[name];
}

await Bun.write(
  join(root, "skills-lock.json"),
  `${JSON.stringify({ version: globalLock.version, skills: sorted }, null, 2)}\n`,
);
const missing = Object.keys(sorted).filter((n) => !installed.has(n)).length;
console.log(
  `skills-lock.json: ${Object.keys(sorted).length} skills (${missing} not yet installed)`,
);
