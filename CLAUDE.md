# CLAUDE.md

This file gives Claude Code guidance for working in this repository.

## What this is

`marxsay` is a Bash-only toy: `fortune` + `cowsay -f tux` (+ `lolcat` / `sed` ANSI colouring), fed by a custom fortune database of revolutionary quotes. It has no build, no tests, and no dependencies beyond the Debian packages `fortune-mod`, `cowsay` and `lolcat`.

## Files

- `marxism.txt`: the quote database in fortune format. Each entry is the quote, a blank line, `-- Author`, a blank line, then `%` on its own line. The file ends with `%`. Keep this layout exactly, because `strfile` splits entries on `%` lines and cowsay shows the blank lines inside the bubble.
- `setup.sh`: an idempotent installer. It:
  1. installs any missing apt packages (checked with `dpkg -s`);
  2. copies `marxism.txt` to `~/.fortunes/marxism` (no extension, so it matches the `.dat` file name) and runs `strfile` to build `~/.fortunes/marxism.dat`;
  3. appends a block to `~/.bashrc` between `# MARXSAY_CONFIG_START` / `# MARXSAY_CONFIG_END`, guarded by a `grep` for the start tag. That block defines the aliases `marxsay` and `marxsay-col`, the function `marxsay-red`, and a startup call to `${defaultHello}`.
- `demo/`: reference output. `zedong.txt` is a plain `marxsay` render and `zedong.png` is a screenshot of `marxsay-red`. Both are embedded in `README.md`.

Reference rendering (the bubble width and Tux art the sed colouring depends on):

@demo/zedong.txt

## Gotchas

- **Double escaping in the heredoc.** The `marxsay-red` sed script is written through an *unquoted* heredoc (`<< EOF`). That way `${defaultHello}` expands when the block is written, but it also means every backslash appears doubled in `setup.sh` (`\\x1b`, `[\/\\\\|<]`). When you change the regex, think about what ends up in `~/.bashrc`, not what the source shows. To check, run setup against a scratch `HOME` and read the generated rc file.
- The long comment block above the heredoc documents the sed regex. Keep it in sync with any regex change.
- The colouring relies on cowsay's bubble delimiters (`/ \ | < >`) and on the `o_o` / `:_/` substrings of the `tux` cow. Changing the cow file breaks the eye and beak highlighting.
- The `.bashrc` block is never rewritten once it is there. To test changes to the block, delete it (`sed -i '/# MARXSAY_CONFIG_START/,/# MARXSAY_CONFIG_END/d' ~/.bashrc`) or use a throwaway `HOME`.

## Testing changes safely

```bash
export HOME=$(mktemp -d) && touch ~/.bashrc && ./setup.sh && cat ~/.bashrc
bash -c 'source ~/.bashrc; marxsay; marxsay-red'
```

Never run `setup.sh` against the user's real `~/.bashrc` unless they ask you to.
