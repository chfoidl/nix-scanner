{ lib, pkgs, ...}: let
  deskew-pdf = import ./deskew-pdf.nix {
    inherit lib pkgs;
  };
in pkgs.writeShellApplication {
  name = "simple-scan-deskew";
  runtimeInputs = [ deskew-pdf ];
  text = ''
    mime_type="$1"
    keep_original="$2"
    target="$3"

    case "$mime_type" in
      "application/pdf")
        source="''${target%.pdf}_orig.pdf"
        mv "$target" "$source" # create a backup

        ${deskew-pdf}/bin/deskew-pdf "$source" "$target"
        ;;
      "image/jpeg")
        exit 0 # Nothing implemented
        ;;
      "image/png")
        exit 0 # Nothing implemented
        ;;
      "image/webp")
        exit 0 # Nothing implemented
        ;;
      *)
        echo "Unsupported mime-type \"$mime_type\""
        exit 1
        ;;
    esac

    dir=$(basename "$(dirname "$target")")
    if [ "$dir" == "processing" ]; then
      cd "$(dirname "$target")"
      mv "$target" ..
    fi

    # Clean up
    if [ "$keep_original" == "true" ]; then
      exit 0
    else
      rm "$source"
    fi
  '';
}
