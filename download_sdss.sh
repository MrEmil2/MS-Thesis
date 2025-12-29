#!/bin/bash
# path to CSV file
CSV="/mnt/c/Users/Daniel/Downloads/MyTable4_dweisz2.csv"
# output directory
OUTDIR="/mnt/c/Users/Daniel/Downloads/sdss_spectra"
mkdir -p "$OUTDIR"
sed -i 's/\r$//' "$CSV"
# skip header and read each line
tail -n +2 "$CSV" | while IFS=',' read -r plate mjd fiberid _; do
    url="https://dr18.sdss.org/sas/dr18/spectro/sdss/redux/26/spectra/lite/${plate}/spec-${plate}-${mjd}-${fiberid}.fits"
    echo "Downloading $url ..."
    wget -q -nc -P "$OUTDIR" "$url"
done