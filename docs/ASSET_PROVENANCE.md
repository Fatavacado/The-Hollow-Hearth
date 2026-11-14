# Asset Provenance Log

Every asset in the repository is listed here **before** it is committed. Columns follow
[ART_BIBLE.md](ART_BIBLE.md#asset-sourcing): creator, source, license, modification rights and usage.

**Status values:** `placeholder` (temporary, replace before release) · `benchmark` (under visual review) ·
`approved` (passed the benchmark gate) · `rejected`.

| Asset | Path | Creator / tool | Source | License | Modifiable | Status |
|---|---|---|---|---|---|---|
| Project icon (hearth arch + flame) | `icon.svg` | Hand-written SVG in this repo | Original | Project-owned | Yes | placeholder |

## Generated-asset policy
- Assets produced by scripts in `tools/art/` are original work of this project. The script is the source;
  regenerate instead of hand-editing outputs, and list each output file group above.
- AI image outputs (GPT or similar) are concept references only until cleaned, validated in Godot and
  approved; log the tool, prompt summary and date.
- No purchased assets or paid API usage without explicit owner approval.
