"""Install exact Git revisions; do not reset or delete an existing checkout."""
import json
import re
import subprocess
from pathlib import Path


def git(*args):
    return subprocess.check_output(['git', *map(str, args)], text=True).strip()


def install_plugins(source, base, cache=None, offline=False):
    entries = json.loads((source / 'plugins.lock.json').read_text())
    expected_toml = '# Pinned versions; keep in sync with plugins.lock.json.\n' + '\n'.join(
        "[[plugins]]\nrepo = '%s'\nrev = '%s'\n" % (e['repo'], e['rev']) for e in entries[1:])
    if (source / 'dein.toml').read_text() != expected_toml:
        raise ValueError('dein.toml and plugins.lock.json differ')
    results = []
    for item in entries:
        repo, rev = item['repo'], item['rev']
        if not re.fullmatch(r'[\w.-]+/[\w.-]+', repo) or not re.fullmatch(r'[0-9a-f]{40}', rev):
            raise ValueError('Invalid lock entry')
        if item['url'] != 'https://github.com/' + repo + '.git':
            raise ValueError('Only explicit GitHub HTTPS sources are supported')
        dest = base / 'repos/github.com' / (repo if repo == 'Shougo/dein.vim' else repo + '_' + rev)
        if dest.exists():
            if not (dest / '.git').is_dir():
                raise RuntimeError(f'Existing non-Git path: {dest}')
            if git('-C', dest, 'rev-parse', 'HEAD') != rev:
                raise RuntimeError(f'Revision mismatch at {dest}; preserved, no automatic checkout')
            if git('-C', dest, 'diff', 'HEAD', '--name-only'):
                raise RuntimeError(f'Tracked modifications at {dest}; preserved')
        else:
            cached = cache / repo if cache else base / 'repos/github.com' / repo
            origin = str(cached) if cached and cached.is_dir() else item['url']
            if offline and origin == item['url']:
                raise RuntimeError(f'Offline source missing: {repo}')
            dest.parent.mkdir(parents=True, exist_ok=True)
            # A fixed staging name lets an interrupted clone/checkout be resumed.
            stage = dest.with_name(dest.name + '.installing')
            if not stage.exists():
                git('clone', '--no-hardlinks', '--no-checkout', origin, stage)
            if not (stage / '.git').is_dir():
                raise RuntimeError(f'Incomplete staging path; inspect manually: {stage}')
            if git('-C', stage, 'status', '--porcelain'):
                # --no-checkout naturally reports index deletions: check only
                # actual files before checkout, excluding the Git directory.
                if any(p.name != '.git' for p in stage.iterdir()):
                    raise RuntimeError(f'Staging tree contains files; preserved: {stage}')
            git('-C', stage, 'checkout', '--detach', rev)
            git('-C', stage, 'remote', 'set-url', 'origin', item['url'])
            stage.rename(dest)
        print(f'Plugin ready: {repo} @ {rev[:12]}')
        results.append(dict(repo=repo, rev=rev, path=str(dest)))
    return results
