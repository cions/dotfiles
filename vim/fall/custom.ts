import type { Entrypoint } from "jsr:@vim-fall/custom";
import {
  composeActions,
  refineCurator,
  refineSource,
} from "jsr:@vim-fall/std";
import * as builtin from "jsr:@vim-fall/std/builtin";
import { SEPARATOR } from "jsr:@std/path/constants";
import { eix } from "./eix.ts";
import { repository } from "./repository.ts";

const PathActions = {
  ...builtin.action.defaultOpenActions,
  ...builtin.action.defaultSystemopenActions,
  ...builtin.action.defaultCdActions,
};

const MiscActions = {
  ...builtin.action.defaultEchoActions,
  ...builtin.action.defaultYankActions,
  ...builtin.action.defaultSubmatchActions,
};

export const main: Entrypoint = (
  {
    definePickerFromSource,
    definePickerFromCurator,
    refineSetting,
  },
) => {
  refineSetting({
    coordinator: builtin.coordinator.modern({
      heightRatio: 0.9,
      widthRatio: 0.9,
    }),
    theme: builtin.theme.SINGLE_THEME,
  });

  definePickerFromCurator(
    "grep",
    refineCurator(
      builtin.curator.grep,
      builtin.refiner.relativePath,
    ),
    {
      sorters: [
        builtin.sorter.noop,
        builtin.sorter.lexical,
        builtin.sorter.lexical({ reverse: true }),
      ],
      renderers: [builtin.renderer.noop],
      previewers: [builtin.previewer.file],
      actions: {
        ...PathActions,
        ...MiscActions,
      },
      defaultAction: "open",
    },
  );

  definePickerFromCurator(
    "git-grep",
    refineCurator(
      builtin.curator.gitGrep,
      builtin.refiner.relativePath,
    ),
    {
      sorters: [
        builtin.sorter.noop,
        builtin.sorter.lexical,
        builtin.sorter.lexical({ reverse: true }),
      ],
      renderers: [builtin.renderer.noop],
      previewers: [builtin.previewer.file],
      actions: {
        ...PathActions,
        ...MiscActions,
      },
      defaultAction: "open",
    },
  );

  definePickerFromCurator(
    "rg",
    refineCurator(
      builtin.curator.rg,
      builtin.refiner.relativePath,
    ),
    {
      sorters: [
        builtin.sorter.noop,
        builtin.sorter.lexical,
        builtin.sorter.lexical({ reverse: true }),
      ],
      renderers: [builtin.renderer.noop],
      previewers: [builtin.previewer.file],
      actions: {
        ...PathActions,
        ...MiscActions,
      },
      defaultAction: "open",
    },
  );

  definePickerFromSource(
    "file",
    refineSource(
      builtin.source.file({
        filterDirectory: (path: string) => {
          const excludes = [
            ".bzr",
            ".git",
            ".hg",
            ".svn",
            "__pycache__",
            "build",
            "node_modules",
            "target",
          ];
          return !excludes.some((x) => path.endsWith(SEPARATOR + x));
        },
      }),
      builtin.refiner.relativePath,
    ),
    {
      matchers: [builtin.matcher.fzf],
      sorters: [
        builtin.sorter.noop,
        builtin.sorter.lexical,
        builtin.sorter.lexical({ reverse: true }),
      ],
      renderers: [builtin.renderer.noop],
      previewers: [builtin.previewer.file],
      actions: {
        ...PathActions,
        ...MiscActions,
      },
      defaultAction: "open",
    },
  );

  definePickerFromSource(
    "file:all",
    refineSource(
      builtin.source.file,
      builtin.refiner.relativePath,
    ),
    {
      matchers: [builtin.matcher.fzf],
      sorters: [
        builtin.sorter.noop,
        builtin.sorter.lexical,
        builtin.sorter.lexical({ reverse: true }),
      ],
      renderers: [builtin.renderer.noop],
      previewers: [builtin.previewer.file],
      actions: {
        ...PathActions,
        ...MiscActions,
      },
      defaultAction: "open",
    },
  );

  definePickerFromSource(
    "line",
    builtin.source.line,
    {
      matchers: [builtin.matcher.fzf],
      previewers: [builtin.previewer.buffer],
      actions: {
        ...builtin.action.defaultOpenActions,
        ...MiscActions,
      },
      defaultAction: "open",
      coordinator: builtin.coordinator.modern({
        heightRatio: 0.9,
        widthRatio: 0.9,
        hidePreview: true,
      }),
    },
  );

  definePickerFromSource(
    "buffer",
    builtin.source.buffer({ filter: "bufloaded" }),
    {
      matchers: [builtin.matcher.fzf],
      sorters: [
        builtin.sorter.noop,
        builtin.sorter.lexical,
        builtin.sorter.lexical({ reverse: true }),
      ],
      previewers: [builtin.previewer.buffer],
      actions: {
        ...builtin.action.defaultOpenActions,
        ...builtin.action.defaultBufferActions,
        ...MiscActions,
      },
      defaultAction: "open",
    },
  );

  definePickerFromSource(
    "help",
    builtin.source.helptag,
    {
      matchers: [builtin.matcher.fzf],
      sorters: [
        builtin.sorter.noop,
        builtin.sorter.lexical,
        builtin.sorter.lexical({ reverse: true }),
      ],
      previewers: [builtin.previewer.helptag],
      actions: {
        ...builtin.action.defaultHelpActions,
        ...MiscActions,
      },
      defaultAction: "help",
    },
  );

  definePickerFromSource(
    "quickfix",
    builtin.source.quickfix,
    {
      matchers: [builtin.matcher.fzf],
      sorters: [
        builtin.sorter.noop,
        builtin.sorter.lexical,
        builtin.sorter.lexical({ reverse: true }),
      ],
      previewers: [builtin.previewer.buffer],
      actions: {
        ...builtin.action.defaultOpenActions,
        ...MiscActions,
      },
      defaultAction: "open",
    },
  );

  definePickerFromSource(
    "history",
    builtin.source.history,
    {
      matchers: [builtin.matcher.fzf],
      sorters: [
        builtin.sorter.noop,
        builtin.sorter.lexical,
        builtin.sorter.lexical({ reverse: true }),
      ],
      actions: {
        "cmd": builtin.action.cmd({ immediate: true }),
        ...MiscActions,
      },
      defaultAction: "cmd",
    },
  );

  definePickerFromSource(
    "repository",
    repository,
    {
      matchers: [builtin.matcher.fzf],
      sorters: [
        builtin.sorter.noop,
        builtin.sorter.lexical,
        builtin.sorter.lexical({ reverse: true }),
      ],
      renderers: [builtin.renderer.noop],
      previewers: [builtin.previewer.file],
      actions: {
        fern: builtin.action.cmd({
          attrGetter: (item) => item.detail.path,
          fnameescape: true,
          immediate: true,
          restriction: "directory",
          template: "Fern {}",
        }),
        "fern:cd": composeActions(
          builtin.action.cd,
          builtin.action.cmd({
            attrGetter: (item) => item.detail.path,
            fnameescape: true,
            immediate: true,
            restriction: "directory",
            template: "Fern {}",
          }),
        ),
        ...PathActions,
        ...MiscActions,
      },
      defaultAction: "fern:cd",
    },
  );

  definePickerFromSource(
    "eix",
    eix,
    {
      matchers: [builtin.matcher.fzf],
      actions: {
        ...MiscActions,
      },
      defaultAction: "yank",
      coordinator: builtin.coordinator.modern({
        hidePreview: true,
      }),
    },
  );
};
