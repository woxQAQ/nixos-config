import { installLocalCli } from "./apps/neuve-cli/scripts/install-local.ts";
import { readSkillTemplate } from "./apps/neuve-cli/src/skill-bundle.ts";

const [prefix, cli, graph, desk, version, graphRevision] = Bun.argv.slice(2);
const graphProcess = Bun.spawn([graph, "version"], {
  stdout: "pipe",
  stderr: "inherit",
});
const graphVersion = await new Response(graphProcess.stdout).text();
if ((await graphProcess.exited) !== 0) {
  throw new Error("The built Graph engine could not report its version.");
}
const manifest = await installLocalCli({
  prefix,
  cli,
  graph,
  desk,
  graphVersion: graphVersion.trim(),
  graphWorkspaceRevision: graphRevision,
  semantic: {
    encoder: "packages/semantic-client/src/worker.py",
    reranker: "packages/semantic-client/src/reranker_worker.py",
  },
  skills: await readSkillTemplate("apps/neuve-cli/skills/neuve", version),
  expectShared: false,
});
// Store outputs use the same deterministic timestamp as the binary package.
manifest.installedAt = "1970-01-01T00:00:01Z";
await Bun.write(`${prefix}/lib/neuve/install.json`, `${JSON.stringify(manifest, null, 2)}\n`);
