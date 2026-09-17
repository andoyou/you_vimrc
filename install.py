#!/usr/bin/env python3
"""Install pinned Vim plugins and deploy this configuration (Python 3.8+)."""
import argparse
import datetime
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import uuid

sys.dont_write_bytecode = True
from lib.deploy import Deployment, restore
from lib.plugins import install_plugins


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=Path(__file__).resolve().parent)
    parser.add_argument('--home', type=Path, default=Path.home(), help='Target user home')
    parser.add_argument('--backup-dir', type=Path, help='Backup parent; default TARGET/.vim/config-backups')
    parser.add_argument('--mode', choices=['symlink', 'copy'], default='symlink')
    parser.add_argument('--plugin-cache', type=Path, help='Local owner/repository clone source')
    parser.add_argument('--offline', action='store_true', help='Never clone from the network')
    parser.add_argument('--vim', default='vim', help='Vim executable for prerequisite check')
    parser.add_argument('--restore', type=Path, help='Restore configuration from an install manifest')
    args = parser.parse_args()
    if args.restore:
        restore(args.restore.resolve())
        return
    if not shutil.which('git') or not shutil.which(args.vim):
        parser.error('Git and Vim must be installed and on PATH')
    version = subprocess.check_output([args.vim, '--version'], text=True)
    match = re.search(r'VIM - Vi IMproved (\d+)\.(\d+)', version)
    if not match or tuple(map(int, match.groups())) < (8, 2):
        parser.error('Vim 8.2+ is required (Neovim is not supported)')
    source, target_home = args.source.expanduser().resolve(), args.home.expanduser().resolve()
    required = ['vimrc', 'dein.toml', 'plugins.lock.json']
    required += ['vim/' + name + '.vim' for name in ['options', 'plugins', 'filetypes', 'mappings', 'clipboard']]
    for name in required:
        if not (source / name).is_file():
            parser.error(f'Missing source file: {name}')
    config = target_home / '.vim/config'
    if source == config or config in source.parents:
        parser.error('Source repository must be outside the deployment directory')
    # Install/verify dependencies before touching any active configuration.
    plugins = install_plugins(source, target_home / '.vim/dein',
                              args.plugin_cache.expanduser().resolve() if args.plugin_cache else None,
                              args.offline)
    backup_parent = (args.backup_dir.expanduser().resolve() if args.backup_dir
                     else target_home / '.vim/config-backups')
    run_id = datetime.datetime.now().strftime('%Y%m%d-%H%M%S') + '-' + uuid.uuid4().hex[:8]
    deploy = Deployment(backup_parent / run_id)
    try:
        # Individual files preserve any unrelated content under .vim/config.
        for name in required:
            deploy.put(source / name, config / name, args.mode)
        entry = target_home / ( '_vimrc' if os.name == 'nt' else '.vimrc')
        if args.mode == 'symlink':
            deploy.put(source / 'vimrc', entry, 'symlink')
        else:
            loader = deploy.backup / 'loader.vim'
            loader.write_text("execute 'source ' . fnameescape(expand('~/.vim/config/vimrc'))\n")
            deploy.put(loader, entry)
        deploy.put(source / 'dein.toml', target_home / '.vim/dein.toml', args.mode)
        deploy.finish(plugins)
    except Exception:
        print(f'Installation interrupted. Inspect/restore with: {deploy.manifest}', file=sys.stderr)
        raise
    print(f'Installed ({args.mode}). Manifest: {deploy.manifest}')
    print('Reopen Vim to load the new configuration.')


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, RuntimeError, subprocess.CalledProcessError) as exc:
        print(f'Error: {exc}', file=sys.stderr)
        sys.exit(1)
