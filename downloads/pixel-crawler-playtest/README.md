# Pixel Crawler playable downloads

## Deploy on Netlify

Download **Wayside-Inn-Netlify.zip**. Extract it and upload the extracted folder to Netlify Drop. The folder must directly contain `index.html`, `index.js`, `index.wasm`, and `index.pck`. Do not upload the old Browser ZIP for a website; its entry filename was intended for local play.

If connecting this GitHub repository to Netlify instead, select branch `pixel-crawler-playtest-download`, leave the build command empty, and set publish directory to `previews/pixel-crawler`. The netlify.toml on this branch supplies the publish directory. Deploy the latest commit. Never use the repository root or the ZIP-only downloads directory as the publish directory.

## Local play

Download Wayside-Inn-Browser.zip, extract, and open Play-Wayside-Inn.html in Chrome or Edge. If local loading is blocked, run `python3 start_game.py` (Windows: `py start_game.py`).

Enter starts; WASD/arrows move; E interacts; Escape pauses. Gather three mushrooms, enter the tavern, cook, and serve the guest.

These are compiled builds of the independent Godot experiment. The main branch and The Hollow Hearth game code are unchanged. Art: Pixel Crawler Free Pack by Anokolisa; original terms and Godot notices are included. No standalone raw asset pack or editable art project is supplied.
