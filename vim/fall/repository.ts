import * as fn from "jsr:@denops/std/function";
import {
  defineSource,
  type Source,
} from "jsr:@vim-fall/std/source";
import type { IdItem } from "jsr:@vim-fall/std/item";
import { expandGlob } from "jsr:@std/fs/expand-glob";

type Detail = {
  path: string;
};

export type RepositoryOptions = {
  root?: string;
};

export function repository(options: Readonly<RepositoryOptions> = {}): Source<Detail> {
  const {
    root = "~/src",
  } = options;

  return defineSource(async function*(denops, _params, { signal }) {
    const rootDir = await fn.fnamemodify(denops, await fn.expand(denops, root), ":p");
    signal?.throwIfAborted();

    let id = 0;
    for await (const entry of expandGlob(rootDir + "/*/*/*")) {
      signal?.throwIfAborted();
      if (entry.isDirectory) {
        yield {
          id: id++,
          value: entry.name,
          detail: {
            path: entry.path,
          },
        };
      }
    }
  });
}
