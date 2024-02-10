{ lib, pkgs, ... }: let
  deskewScript = pkgs.writeShellScriptBin "deskew" ''
    p="$1"
    workdir="$2"

    out="$workdir/$(basename "$p" .jpg).deskew.jpg"
    ${pkgs.deskew}/bin/deskew -b FFFFFF a 25 -c j100 -o "$out" "$p"
  '';
in pkgs.writeShellApplication {
  name = "deskew-pdf";
  runtimeInputs = [ pkgs.ghostscript ];
  text = ''
    usage() {
      scr=$(basename "$0")

      echo "Usage: $scr <input_pdf> <output_pdf>"
      echo
      echo "Example:"
      echo "  $scr input.pdf output.pdf"
      exit 1
    }

    # Validate inputs.
    if [ -z "''${1-}" ] || [ -z "''${2-}" ]; then
      usage 
    fi

    input="$1"
    output="$2"
    dpi="''${3-300}"
    workdir=$(mktemp -d)

    echo "Deskewing PDF $input saved as $output"

    echo "Saving invididual pages to $workdir"
    ${pkgs.imagemagick}/bin/convert -density "$dpi" -quality 100 "$input" "$workdir/file.%02d.skewed.jpg"

    echo "Deskewing pages..."

    # Deskew pages in parallel.
    find "$workdir" -name "*.skewed.jpg" | ${pkgs.parallel}/bin/parallel ${deskewScript}/bin/deskew {} "$workdir"

    echo "Creating output pdf"
    ${pkgs.imagemagick}/bin/convert -quality 100 "$workdir/*.skewed.deskew.jpg" "$output"

    rm -r "$workdir"
  '';
}
