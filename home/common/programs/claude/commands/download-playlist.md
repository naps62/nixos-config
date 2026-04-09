Download a music playlist for "aulas de música" (kids music classes).

The user will paste the content of a monthly playlist from the teacher. Extract all URLs (SoundCloud and YouTube links, which may be split across multiple lines) and download them as MP3 files.

## Steps

1. Parse the pasted content to extract all URLs. Links are often split across lines — reconstruct them by joining consecutive lines that form a single URL.
2. Determine the month name from the content (e.g., "Creche - março" → "marco").
3. Create the folder `aulas-musica-{month}` in the current directory.
4. Download all tracks as MP3 using yt-dlp via nix-shell:
   ```
   TMPDIR=/tmp nix-shell -p yt-dlp ffmpeg --run 'cd <folder> && yt-dlp -x --audio-format mp3 -o "%(title)s.%(ext)s" <urls>'
   ```
5. List the downloaded files to confirm everything worked.

## Important

- Always use `TMPDIR=/tmp` before `nix-shell` (NixOS sandbox compatibility).
- Always use `dangerouslyDisableSandbox: true` for the download command.
- Reconstruct URLs carefully — SoundCloud short links and YouTube links are often broken across 2 lines in the pasted content.
