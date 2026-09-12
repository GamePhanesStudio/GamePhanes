#!/usr/bin/env python3
import json
import re
import subprocess
import tempfile
from pathlib import Path

ROOT = Path('/app')
LOGS = Path('/logs/verifier')

def file_check(check):
    path = ROOT / check['path']
    if check['type'] == 'file_exists':
        return path.is_file(), 'file exists' if path.is_file() else 'file missing'
    text = path.read_text(encoding='utf-8', errors='replace') if path.is_file() else ''
    ok = str(check.get('expected', '')) in text
    return ok, 'expected source marker found' if ok else 'expected source marker missing'

def browser_check(check):
    sources = [f'<script src="{(ROOT / source).resolve().as_uri()}"></script>' for source in check.get('probe_sources', [])]
    html = '<!doctype html><html><body>' + ''.join(sources) + '<script>' + check['probe_script'] + '</script></body></html>'
    with tempfile.NamedTemporaryFile('w', suffix='.html', delete=False, encoding='utf-8') as handle:
        handle.write(html)
        probe_path = Path(handle.name)
    try:
        proc = subprocess.run(
            ['chromium', '--headless', '--no-sandbox', '--disable-gpu', '--disable-dev-shm-usage',
             '--allow-file-access-from-files', '--dump-dom', '--virtual-time-budget=2000', probe_path.as_uri()],
            cwd=ROOT, capture_output=True, text=True, timeout=120,
        )
        output = (proc.stdout or '') + (proc.stderr or '')
        marker = re.search(r"id=['\"]probe-result['\"][^>]*>\s*" + re.escape(check['expected']), output)
        return proc.returncode == 0 and marker is not None, output[-1200:]
    finally:
        probe_path.unlink(missing_ok=True)

def main():
    import yaml
    spec = yaml.safe_load((ROOT / 'rubric.yaml').read_text(encoding='utf-8'))
    rows = []
    for check in spec.get('checks', []):
        if check['type'] in ('file_exists', 'file_contains'):
            ok, detail = file_check(check)
        elif check['type'] == 'browser_probe':
            ok, detail = browser_check(check)
        else:
            ok, detail = False, 'unsupported verifier check type'
        rows.append({'id': check['id'], 'passed': bool(ok), 'detail': detail,
                     'type': check['type'], 'path': check.get('path', '')})
    passed = sum(row['passed'] for row in rows)
    reward = int(passed == len(rows))
    result = {'status': 'evaluated', 'reward': reward, 'score': round(passed / len(rows), 4),
              'passed': passed, 'total': len(rows), 'checks': rows}
    LOGS.mkdir(parents=True, exist_ok=True)
    (LOGS / 'result.json').write_text(json.dumps(result, ensure_ascii=False, separators=(',', ':')) + '\n', encoding='utf-8')
    (LOGS / 'reward.txt').write_text(str(reward) + '\n', encoding='utf-8')
    print(json.dumps(result, ensure_ascii=False))

if __name__ == '__main__':
    main()
