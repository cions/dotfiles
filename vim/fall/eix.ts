import {
  defineSource,
  type Source,
} from "jsr:@vim-fall/std/source";
import type { IdItem } from "jsr:@vim-fall/std/item";
import { toLines } from "jsr:@std/streams/unstable-to-lines";

type Detail = Record<never, never>;

type EixOptions = Record<never, never>;

export function eix(_options: EixOptions = {}): Source<Detail> {
  return defineSource<Detail>(async function* (_denops, _params, { signal }) {
    const cmd = new Deno.Command("eix", {
      args: [
        "--only-names",
      ],
      env: {
        "EIX_LIMIT": "0",
      },
      stdin: "null",
      stdout: "piped",
      stderr: "null",
      signal,
    }).spawn();

    let id = 0;
    for await (const line of toLines(cmd.stdout).values()) {
      yield {
        id: id++,
        value: line,
        detail: {},
      };
    }
  });
}
