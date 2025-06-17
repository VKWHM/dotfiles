{ stdenv, glib, dconf, wrapGAppsHook, pkg-config, ... }:

stdenv.mkDerivation {
  pname = "gwatch";
  version = "1.0";
  src = ./.;
  nativeBuildInputs = [ pkg-config wrapGAppsHook ];
  buildInputs = [ glib dconf ];

  postFixup = ''
    wrapProgram $out/bin/gwatch \
      --prefix GIO_EXTRA_MODULES : "${glib.out}/lib/gio/modules" \
      --prefix XDG_DATA_DIRS : "${glib.out}/share:${dconf}/share"
  '';
}
