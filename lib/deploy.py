"""Backed-up, journaled deployment of files or symlinks."""
import hashlib
import json
import os
import shutil
from pathlib import Path


def fingerprint(path):
    if path.is_symlink():
        return 'link:' + os.readlink(path)
    if path.is_file():
        return 'file:' + hashlib.sha256(path.read_bytes()).hexdigest()
    if path.is_dir():
        raise ValueError(f'Refusing to replace directory: {path}')
    return None


class Deployment:
    def __init__(self, backup):
        self.backup = backup
        self.backup.mkdir(parents=True, exist_ok=False)
        self.manifest = backup / 'manifest.json'
        self.data = {'version': 1, 'changes': [], 'status': 'running'}
        self.save()

    def save(self):
        tmp = self.manifest.with_suffix('.tmp')
        tmp.write_text(json.dumps(self.data, indent=2) + '\n')
        tmp.replace(self.manifest)

    def put(self, source, target, mode='copy'):
        target.parent.mkdir(parents=True, exist_ok=True)
        previous = fingerprint(target)
        desired = 'link:' + str(source) if mode == 'symlink' else fingerprint(source)
        if previous == desired:
            return
        saved = self.backup / str(len(self.data['changes']))
        change = dict(target=str(target), backup=str(saved), previous=previous,
                      installed=desired, status='prepared')
        self.data['changes'].append(change)
        self.save()
        if previous is not None:
            # Preserve symlinks as links, not the referenced file.
            if target.is_symlink():
                saved.symlink_to(os.readlink(target))
            else:
                shutil.copy2(target, saved)
        change['status'] = 'backed_up'
        self.save()
        tmp = target.with_name(target.name + '.vim-config-installing')
        if tmp.exists() or tmp.is_symlink():
            raise RuntimeError(f'Staging path exists; preserved: {tmp}')
        if mode == 'symlink':
            tmp.symlink_to(source)
        else:
            shutil.copy2(source, tmp)
        os.replace(tmp, target)
        change['status'] = 'installed'
        self.save()

    def finish(self, plugins):
        self.data.update(status='complete', plugins=plugins)
        self.save()


def restore(manifest):
    data = json.loads(manifest.read_text())
    # Preflight all targets before changing any of them.
    for entry in data['changes']:
        target = Path(entry['target'])
        current = fingerprint(target)
        if current not in (entry['previous'], entry['installed']):
            raise RuntimeError(f'Changed since install; preserved: {target}')
        if current == entry['installed'] and entry['previous'] is not None:
            if fingerprint(Path(entry['backup'])) != entry['previous']:
                raise RuntimeError(f'Backup missing or modified: {entry["backup"]}')
    for entry in reversed(data['changes']):
        target = Path(entry['target'])
        if fingerprint(target) == entry['previous']:
            continue
        if entry['previous'] is None:
            target.unlink()
        else:
            saved = Path(entry['backup'])
            tmp = target.with_name(target.name + '.vim-config-restoring')
            if tmp.exists() or tmp.is_symlink():
                raise RuntimeError(f'Staging path exists: {tmp}')
            if saved.is_symlink():
                tmp.symlink_to(os.readlink(saved))
            else:
                shutil.copy2(saved, tmp)
            os.replace(tmp, target)
    print('Configuration restored; plugin downloads and backups retained.')
