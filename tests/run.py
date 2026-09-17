#!/usr/bin/env python3
"""Integration checks in caller-selected scratch space; never uses real HOME."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import sys

sys.dont_write_bytecode = True
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--work-dir', required=True, type=Path)
parser.add_argument('--plugin-cache', required=True, type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
work = args.work_dir.resolve()
work.mkdir(parents=True, exist_ok=False)


def run(command, **kwargs):
    result = subprocess.run(command, capture_output=True, text=True, **kwargs)
    if result.returncode:
        raise RuntimeError(f'{command}\n{result.stdout}\n{result.stderr}')
    return result


results = []
for mode in ['symlink', 'copy']:
    home = work / (mode + ' home')
    home.mkdir()
    original = b'" original configuration\n'
    (home / '.vimrc').write_bytes(original)
    command = [sys.executable, str(root / 'install.py'), '--home', str(home),
               '--plugin-cache', str(args.plugin_cache.resolve()), '--offline', '--mode', mode]
    run(command)
    backup = home / '.vim/config-backups'
    first = next(backup.glob('*/manifest.json'))
    run(command)
    manifests = list(backup.glob('*/manifest.json'))
    second = next(p for p in manifests if p != first)
    assert json.loads(second.read_text())['changes'] == [], 'Reinstall was not idempotent'
    env = dict(os.environ, HOME=str(home), XDG_CACHE_HOME=str(home / '.cache'),
               XDG_CONFIG_HOME=str(home / '.config'), XDG_DATA_HOME=str(home / '.local/share'),
               VIM_TEST_ERRORS=str(home / 'errors.txt'))
    for key in ['VIMINIT', 'EXINIT', 'VIM', 'VIMRUNTIME']:
        env.pop(key, None)
    run(['vim', '-i', 'NONE', '-n', '-es', '-u', str(home / '.vimrc'),
         '-V1' + str(home / 'vim.log'), '-S', str(root / 'tests/smoke.vim')], env=env)
    log = (home / 'vim.log').read_text()
    assert 'Error detected' not in log, log
    # Restoration must not overwrite edits made since installation.
    target = home / '.vim/dein.toml'
    if mode == 'copy':
        installed = target.read_bytes()
        target.write_text('# user edit\n')
        blocked = subprocess.run([sys.executable, str(root / 'install.py'), '--restore', str(first)],
                                 capture_output=True, text=True)
        assert blocked.returncode != 0 and target.read_text() == '# user edit\n'
        target.write_bytes(installed)
    run([sys.executable, str(root / 'install.py'), '--restore', str(first)])
    assert (home / '.vimrc').read_bytes() == original
    run([sys.executable, str(root / 'install.py'), '--restore', str(first)])
    results.append(mode + ': pinned install, no-op reinstall, startup, mappings, filetypes, NERDTree, re-source, restore passed')
# A new machine with no plugins should still start the configuration offline.
home = work / 'empty-home'
home.mkdir()
env = dict(os.environ, HOME=str(home), XDG_CACHE_HOME=str(home / '.cache'))
run(['vim', '-i', 'NONE', '-n', '-es', '-u', str(root / 'vimrc'),
     '-V1' + str(home / 'vim.log'), '+qa!'], env=env)
assert 'Error detected' not in (home / 'vim.log').read_text()
results.append('missing plugins: startup succeeds with default colors')
# A partial/corrupt dein checkout is also an offline-safe startup condition.
home = work / 'broken-dein-home'
manager = home / '.vim/dein/repos/github.com/Shougo/dein.vim/autoload'
manager.mkdir(parents=True)
(manager / 'dein.vim').write_text("throw 'broken dein'\n")
env = dict(os.environ, HOME=str(home), XDG_CACHE_HOME=str(home / '.cache'))
run(['vim', '-i', 'NONE', '-n', '-es', '-u', str(root / 'vimrc'),
     '-V1' + str(home / 'vim.log'), '+qa!'], env=env)
assert 'Error detected' not in (home / 'vim.log').read_text()
results.append('broken dein: startup falls back to the built-in configuration')
(work / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
print('\n'.join(results))

# Mock OS clipboard tools: no access to the user's real clipboard.
bin_dir = work / 'bin'
bin_dir.mkdir()
(bin_dir / 'win32yank').write_text('#!/bin/sh\nif [ "$1" = "-i" ]; then cat > "$CLIPBOARD_TEST_COPY"; else printf "alpha\\r\\nbeta\\r\\n"; fi\n')
(bin_dir / 'win32yank').chmod(0o755)
(bin_dir / 'wslpath').write_text('#!/bin/sh\nprintf "C:\\\\mock\\\\document.md\\n"\n')
(bin_dir / 'wslpath').chmod(0o755)
(bin_dir / 'powershell.exe').write_text('#!/bin/sh\nprintf "%s\\n" "$@" > "$MARKDOWN_TEST_COMMAND"\n')
(bin_dir / 'powershell.exe').chmod(0o755)
(bin_dir / 'mock-codex').write_text('#!/bin/sh\nwhile :; do sleep 1; done\n')
(bin_dir / 'mock-codex').chmod(0o755)
env.update(PATH=str(bin_dir) + os.pathsep + os.environ['PATH'],
           CLIPBOARD_TEST_COPY=str(work / 'copied.txt'), VIM_TEST_ERRORS=str(work / 'clipboard-errors.txt'),
           MARKDOWN_TEST_COMMAND=str(work / 'markdown-command.txt'),
           MARKDOWN_TEST_FILE=str(work / 'document.md'),
           CONSOLE_TEST_ERRORS=str(work / 'console-errors.txt'))
run(['vim', '-i', 'NONE', '-n', '-es', '-u', str(root / 'vimrc'),
     '-S', str(root / 'tests/clipboard.vim')], env=env)
clipboard_errors = work / 'clipboard-errors.txt'
if clipboard_errors.exists():
    raise RuntimeError(clipboard_errors.read_text())
results.append('mock clipboard: copy and CRLF-normalized line paste passed')
(work / 'document.md').write_text('# test\n')
run(['vim', '-i', 'NONE', '-n', '-es', '-u', str(root / 'vimrc'),
     '-S', str(root / 'tests/markdown.vim')], env=env)
markdown_errors = work / 'markdown-errors.txt'
if markdown_errors.exists():
    raise RuntimeError(markdown_errors.read_text())
results.append('mock browser: saved Markdown opens with a safely quoted default-handler command')
run(['vim', '-i', 'NONE', '-n', '-es', '-u', str(root / 'vimrc'),
     '-S', str(root / 'tests/console.vim')], env=env)
console_errors = work / 'console-errors.txt'
if console_errors.exists():
    raise RuntimeError(console_errors.read_text())
results.append('mock Codex: opens an interactive terminal buffer in the requested split')
(work / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
print(results[-1])
