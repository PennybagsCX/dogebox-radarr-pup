{ pkgs ? import <nixpkgs> {} }:

# Radarr movie automation pup for Dogebox.
# Config + downloads under the pup's /storage volume. Web UI on port 7878.
# Media pipeline: point Radarr's root folder at /storage/media/movies — the
# host-side sync timer (see README) moves finished files into Jellyfin.
let
  app = pkgs.radarr;

  run = pkgs.writeScriptBin "run.sh" ''
    #!${pkgs.stdenv.shell}
    mkdir -p /storage/config /storage/media/movies
    BIN="$(ls ${app}/bin | head -n1)"
    exec ${app}/bin/$BIN -data /storage/config -nobrowser
  '';
in
{
  radarr = run;
}
