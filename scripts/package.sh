#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
python3 - <<'PY'
import hashlib, pathlib, shutil, zipfile
root = pathlib.Path(__file__).resolve().parent.parent if False else pathlib.Path(r"""$ROOT""")
PY
# simpler: embed ROOT via env
ROOT="$ROOT" python3 - <<'PY'
import hashlib, os, pathlib, shutil, zipfile
root = pathlib.Path(os.environ['ROOT'])
ver = next(l.split('=',1)[1].strip() for l in (root/'module'/'module.prop').read_text().splitlines() if l.startswith('version='))
stage, dist = root/'out'/'stage', root/'out'/'dist'
if stage.exists(): shutil.rmtree(stage)
stage.mkdir(parents=True); (stage/'zygisk').mkdir(); dist.mkdir(parents=True, exist_ok=True)
shutil.copy(root/'module'/'module.prop', stage/'module.prop')
shutil.copy(root/'module'/'customize.sh', stage/'customize.sh')
shutil.copytree(root/'module'/'META-INF', stage/'META-INF')
for so in (root/'out'/'zygisk').glob('*.so'):
    shutil.copy(so, stage/'zygisk'/so.name)
for name in ('NOTICE','LICENSE'):
    p = root/name
    if p.exists(): shutil.copy(p, stage/name)
zip_path = dist / f'ih8SecureLock-scrcpy-{ver}.zip'
with zipfile.ZipFile(zip_path, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
    for p in sorted(stage.rglob('*')):
        if p.is_file():
            zf.write(p, p.relative_to(stage).as_posix())
h = hashlib.sha256(zip_path.read_bytes()).hexdigest()
(zip_path.with_suffix(zip_path.suffix + '.sha256')).write_text(f'{h}  {zip_path.name}\n')
print(zip_path, zip_path.stat().st_size, h)
PY
