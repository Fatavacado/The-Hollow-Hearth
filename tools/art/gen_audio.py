"""Synthesised placeholder audio (original, deterministic): short feedback SFX and two ambience loops.

Output: assets/audio/*.wav (16-bit mono, 22.05 kHz). Ambience files loop seamlessly (cross-faded).
"""
from __future__ import annotations

import math
import random
import struct
import wave

from pixelkit import ROOT

SR = 22050
OUT = ROOT / "assets" / "audio"


def silence(seconds: float) -> list[float]:
    return [0.0] * int(seconds * SR)


def add(dst: list[float], src: list[float], at: float = 0.0, gain: float = 1.0) -> list[float]:
    start = int(at * SR)
    need = start + len(src)
    if need > len(dst):
        dst.extend([0.0] * (need - len(dst)))
    for i, s in enumerate(src):
        dst[start + i] += s * gain
    return dst


def tone(freq: float, seconds: float, amp: float = 0.5, decay: float = 8.0, attack: float = 0.004,
         harmonics: tuple = ((2.0, 0.25),), sweep_to: float | None = None) -> list[float]:
    out = []
    phase = 0.0
    n = int(seconds * SR)
    for i in range(n):
        t = i / SR
        f = freq if sweep_to is None else freq + (sweep_to - freq) * (i / n)
        phase += 2 * math.pi * f / SR
        env = min(1.0, t / attack) * math.exp(-decay * t)
        s = math.sin(phase)
        for mult, weight in harmonics:
            s += weight * math.sin(phase * mult)
        out.append(s * env * amp)
    return out


def noise(seconds: float, amp: float, seed: int, smooth: float = 1.0, decay: float = 0.0) -> list[float]:
    """Noise through a one-pole low-pass (smooth in (0, 1]: smaller = darker)."""
    rng = random.Random(seed)
    out, y = [], 0.0
    for i in range(int(seconds * SR)):
        y += smooth * (rng.uniform(-1, 1) - y)
        out.append(y * amp * math.exp(-decay * i / SR))
    return out


def loopable(samples: list[float], fade: float) -> list[float]:
    """Cross-fades the tail into the head so the file loops without a click."""
    n = int(fade * SR)
    body = samples[:-n]
    tail = samples[-n:]
    for i in range(n):
        w = i / n
        body[i] = body[i] * w + tail[i] * (1 - w)
    return body


def write(name: str, samples: list[float], peak: float = 0.8) -> None:
    top = max(1e-6, max(abs(s) for s in samples))
    scale = min(1.0, peak / top)
    OUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT / f"{name}.wav"), "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, s * scale)) * 32767)) for s in samples))


def sfx() -> dict[str, list[float]]:
    sounds = {}
    sounds["pickup"] = add(tone(660, 0.09, 0.5, 30), tone(990, 0.16, 0.5, 18), 0.06)
    sounds["store"] = add(tone(150, 0.22, 0.7, 14, harmonics=((1.5, 0.3),)), noise(0.06, 0.5, 2, 0.3, 40))
    sounds["stir"] = tone(320, 0.11, 0.45, 20, sweep_to=640)
    chime = silence(0.0)
    for k, f in enumerate((523.3, 659.3, 784.0)):
        add(chime, tone(f, 0.7, 0.35, 5, harmonics=((2.0, 0.3), (3.0, 0.08))), 0.11 * k)
    sounds["cook_done"] = chime
    sounds["coin"] = add(tone(1318.5, 0.08, 0.35, 25, harmonics=((3.0, 0.3),)),
                         tone(1760, 0.22, 0.35, 12, harmonics=((3.0, 0.3),)), 0.07)
    sounds["bell"] = tone(880, 1.1, 0.4, 3.2, harmonics=((2.0, 0.5), (3.0, 0.25), (4.2, 0.1)))
    sounds["door"] = add(noise(0.32, 0.5, 5, 0.08, 9), tone(95, 0.3, 0.6, 12, harmonics=()))
    sounds["ui"] = tone(1000, 0.05, 0.3, 60, harmonics=())
    rise = silence(0.0)
    for k, f in enumerate((523.3, 659.3, 784.0, 1046.5)):
        add(rise, tone(f, 0.25, 0.3, 10), 0.06 * k)
    sounds["buy"] = rise
    return sounds


def forest_ambience() -> list[float]:
    seconds = 12.0
    wind = noise(seconds + 1.0, 0.35, 11, 0.015)
    for i in range(len(wind)):
        wind[i] *= 0.65 + 0.35 * math.sin(2 * math.pi * 0.12 * i / SR)
    rng = random.Random(12)
    t = 0.6
    while t < seconds - 0.5:
        base = rng.uniform(2300, 3400)
        for k in range(rng.randint(2, 4)):
            add(wind, tone(base, 0.07, 0.07, 30, harmonics=(), sweep_to=base * 1.25), t + k * 0.11)
        t += rng.uniform(1.2, 3.0)
    return loopable(wind, 1.0)


def tavern_ambience() -> list[float]:
    seconds = 10.0
    fire = noise(seconds + 1.0, 0.25, 21, 0.01)
    rng = random.Random(22)
    t = 0.05
    while t < seconds + 0.9:
        add(fire, noise(rng.uniform(0.002, 0.006), rng.uniform(0.25, 0.6), rng.randrange(1 << 30), 0.9), t)
        t += rng.expovariate(7.0)
    return loopable(fire, 1.0)


def main() -> None:
    for name, samples in sfx().items():
        write(name, samples)
    write("ambience_forest", forest_ambience(), 0.5)
    write("ambience_tavern", tavern_ambience(), 0.5)
    print("wrote", len(sfx()) + 2, "audio files")


if __name__ == "__main__":
    main()
