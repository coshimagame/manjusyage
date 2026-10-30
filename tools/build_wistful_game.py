"""Render the separately maintained score without replacing its musical source.
Requires numpy. A standard-library PCM writer replaces optional soundfile.
"""
from pathlib import Path
import runpy, sys, types, wave
import numpy as np

def write_pcm(path, data, rate, subtype='PCM_16'):
    assert subtype == 'PCM_16'
    with wave.open(str(path), 'wb') as out:
        out.setnchannels(data.shape[1])
        out.setsampwidth(2)
        out.setframerate(rate)
        out.writeframes((np.clip(data, -1, 1)*32767).astype('<i2').tobytes())

if __name__ == '__main__':
    root=Path(__file__).resolve().parents[1]
    output=root/'audio/wistful_demo.wav'
    sys.modules['soundfile']=types.SimpleNamespace(write=write_pcm)
    sys.argv=[str(root/'tools/render_wistful_stage.py'),str(output)]
    runpy.run_path(sys.argv[0],run_name='__main__')
