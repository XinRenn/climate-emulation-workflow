# integrate data of prediction_data/{i}case_LOO_emulation_predictions.nc from i=0 to 121
#!/bin/bash
inputs=(prediction_data/*case_LOO_emulation_predictions.nc)
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
# Ensure time is an unlimited record dimension before concatenation
for src in "${inputs[@]}"; do
    dst="$tmpdir/$(basename "$src")"
    ncks -O --mk_rec_dmn time "$src" "$dst"
done
ncrcat "$tmpdir"/*case_LOO_emulation_predictions.nc prediction_LOO_modlowice.nc