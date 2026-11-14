"""Regenerates every placeholder asset produced by this folder (deterministic).

Usage (from repo root):  python tools/art/build_all.py
Then let Godot re-import (open the editor, or run tools/run_tests.sh).
"""
import gen_characters
import gen_font
import gen_tavern
import gen_world

if __name__ == "__main__":
    gen_font.build()
    gen_characters.main()
    gen_world.main()
    gen_tavern.main()
