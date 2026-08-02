#!/usr/bin/env bun
// Restore globally installed skills from the committed skills-lock.json --
// the global equivalent of `skills experimental_install`, which is project-only
// (see https://github.com/vercel-labs/skills/issues/549).
// Idempotent: skips skills already present in ~/.agents/skills unless --force.
import { existsSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

type Entry = { source: string; sourceUrl?: string; ref?: string };

const force = process.argv.includes("--force");
const skillsDir = join(homedir(), ".agents", "skills");
const lock = await Bun.file(
  join(import.meta.dir, "..", "skills-lock.json"),
).json();

const missing = Object.entries(lock.skills as Record<string, Entry>).filter(
  ([name]) => force || !existsSync(join(skillsDir, name)),
);

if (missing.length === 0) {
  console.log("All skills from skills-lock.json are installed.");
  process.exit(0);
}

const bySource = new Map<string, string[]>();
for (const [name, entry] of missing) {
  const source =
    (entry.sourceUrl ?? entry.source) + (entry.ref ? `#${entry.ref}` : "");
  const group = bySource.get(source);
  if (group) {
    group.push(name);
  } else {
    bySource.set(source, [name]);
  }
}

let failed = false;
for (const [source, names] of bySource) {
  console.log(`Installing ${names.length} skill(s) from ${source}...`);
  const args = ["x", "skills", "add", source, "--global", "--yes"];
  for (const name of names) {
    args.push("--skill", name);
  }
  const result = Bun.spawnSync(["bun", ...args], {
    stdin: "ignore",
    stdout: "inherit",
    stderr: "inherit",
  });
  // The CLI exits non-zero for per-agent adapter quirks (e.g. "PromptScript
  // does not support global skill installation") even when the skill landed
  // on disk, so trust the directory instead of the exit code. Under --force
  // the directories pre-exist and prove nothing, so there the exit code is
  // the only failure signal.
  const stillMissing = names.filter(
    (name) => !existsSync(join(skillsDir, name)),
  );
  if (stillMissing.length > 0 || (force && !result.success)) {
    console.error(
      `Failed to install from ${source}${stillMissing.length > 0 ? `: ${stillMissing.join(", ")}` : ""}`,
    );
    failed = true;
  }
}
process.exit(failed ? 1 : 0);
