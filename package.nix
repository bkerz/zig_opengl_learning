{
  stdenv,
  pkg-config,
  fontconfig,
  wayland,
  wayland-scanner,
  wayland-protocols,
  libdecor,
  libxkbcommon,
  libpulseaudio,
  xorg,
  udev,
  alsa-lib,
  dbus,
}:

stdenv.mkDerivation {
  name = "test";
  src = ./.;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs =
    [
      fontconfig
      wayland
      wayland-scanner
      wayland-protocols
      libdecor
      libxkbcommon
			libpulseaudio
      xorg.libX11
      xorg.libXcursor
      xorg.libXinerama
      xorg.libXext
      xorg.libXrandr
      xorg.libXrender
      xorg.libXi
      xorg.libXfixes
			alsa-lib
      udev
      dbus
    ];

}
