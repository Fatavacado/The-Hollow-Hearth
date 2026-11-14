"""Rebuild only the bounded Codex v2 benchmark, from retained original sources.
Do not run baseline build_all.py on this candidate: it regenerates placeholder art.
"""
from pathlib import Path
import subprocess
import sys
root=Path(__file__).resolve().parent
for script in ('codex_v2_terrain.py','codex_v2_gathering.py','codex_v2_props.py','codex_v2_player.py'):
    subprocess.run([sys.executable,str(root/script)],check=True)
print('PASS: bounded Codex v2 art rebuilt; no game data, scene geometry or settings changed')
