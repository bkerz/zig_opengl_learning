{
	description = "Flake for building project";

	inputs = {
		nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
		systems.url = "github:nix-systems/default";
	};

	outputs =
		{
		self,
		nixpkgs,
		systems,
		}:
		let
			forEachSupportedSystem =
				f:
				nixpkgs.lib.genAttrs (import systems) (
					system:
					f {
						pkgs = import nixpkgs { inherit system; };
					}
				);
		in
			{
			packages = forEachSupportedSystem (
				{pkgs,}:
				{
					default = pkgs.callPackage ./package.nix {};
				}
			);
			devShells = forEachSupportedSystem (
				{
				pkgs,
				}:
				{
					default =
						pkgs.mkShell.override {}
						rec {
							packages =
								with pkgs;
								[
									xorg.libX11
									xorg.libXcursor
									xorg.libXinerama
									xorg.libXext
									xorg.libXrandr
									xorg.libXrender
									xorg.libXi
									xorg.libXfixes
									libxkbcommon
									pkg-config
									zig
									zls
									glm
									fontconfig
									fontconfig.lib
									alsa-lib
									dbus
									dbus.lib
									udev
									wayland-scanner
									wayland
									libdecor
									libpulseaudio
									glui
									libGLU
									glm
									glfw
								];
							LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath packages;
							shellHook = ''
									 zsh -c '
									 echo "Inside zsh, launching tmux..."

									 # Start a new tmux session (or attach if already running)
									 tmux new-session -d -s zigsession

									 # Create a new window and run commands inside it
									 tmux send-keys -t zigsession:0 "nvim ." C-m

									 tmux new-window -t zigsession:1 -n build
									 tmux send-keys -t zigsession:1 "zig build run" C-m

									 # Attach to the tmux session
									 tmux attach -t zigsession

									 '
									 '';
						};
				}
			);
		};
}
