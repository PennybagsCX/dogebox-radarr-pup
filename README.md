# 🎬 Radarr for Dogebox

<p align="center"><img src="radarr/logo.png" width="110" alt="Radarr pup logo"></p>

**[Radarr](https://radarr.video) — movie collection automation — packaged as a [Dogebox](https://dogebox.org) pup.**

Add movies to your wishlist; Radarr watches for releases matching your quality profiles, sends them to the download client *you* configure, renames/organizes the result, and drops it into your library. Pairs perfectly with the [Jellyfin pup](https://github.com/PennybagsCX/dogebox-jellyfin-pup).

> ⚖️ Radarr is a library manager — it downloads only what *your* configured download clients and indexers provide. Point it at sources you're entitled to use.

## Install

Dogebox dashboard → **Pup Store → Manage Sources → Add Source** (URL must end in `.git`):

```
https://github.com/PennybagsCX/dogebox-radarr-pup.git
```

then install **Radarr**. Web UI launches from the pup screen (dogebox maps a host port; e.g. `http://dogebox:100xx`).

## First run

1. Open the web UI → **Authentication** setup — create your credentials (required on modern Radarr).
2. **Settings → Media Management → Root Folder** → add `/storage/media/movies` (inside the pup).
3. **Settings → Download Clients** → add yours (qBittorrent, SABnzbd, etc. — must be reachable from the box).
4. **Settings → Indexers** → add the indexers you use.
5. Add a movie → Radarr handles the rest.

## Getting files into Jellyfin (the media pipeline)

Pups are filesystem-isolated, so Radarr writes into its own storage. Two ways to bridge into Jellyfin's library:

**A. Host sync timer (recommended, automatic).** On the box (as root), a systemd timer rsyncs finished files into the Jellyfin pup's media dir every few minutes. Example via dogebox's custom-nix (`PUT /system/custom-nix`):

```nix
systemd.services.radarr-to-jellyfin = {
  description = "Sync Radarr output into Jellyfin library";
  serviceConfig.Type = "oneshot";
  script = ''
    ${pkgs.rsync}/bin/rsync -a --remove-source-files \
      /opt/dogebox/pups/storage/<RADARR_PUP_ID>/media/movies/ \
      /opt/dogebox/pups/storage/<JELLYFIN_PUP_ID>/media/movies/
  '';
};
systemd.timers.radarr-to-jellyfin = {
  wantedBy = [ "timers.target" ];
  timerConfig.OnCalendar = "*:0/5";
};
```

(Find pup IDs with `sudo ls /opt/dogebox/pups/`. Jellyfin scans automatically.)

**B. Manual.** Copy files via the box's SMB share or scp, like any other media.

## Storage layout

```
/storage/config         # Radarr database + settings
/storage/media/movies   # root folder (organized output)
```

## Notes

- aarch64/arm64 build from nixpkgs — first start takes a moment while the DB initializes.
- One Radarr instance per box (per this pup). Sonarr sibling: [dogebox-sonarr-pup](https://github.com/PennybagsCX/dogebox-sonarr-pup).
- Radarr is GPLv3 — this repo only packages it.

## License

MIT for the packaging. Radarr and its assets belong to the Radarr project.
