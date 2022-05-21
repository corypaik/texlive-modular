#!/bin/sh

set -eu

YEAR=2019
DATE=20190410

validate_checksum() {
	filename=$1
	checksum=$(shasum -a 512 "$filename" | awk '{print $1}')
	expected_checksum=$(awk '{print $1}' <"$filename.sha512")
	if [ "$checksum" = "$expected_checksum" ]; then
		return 0
	fi
	return 1
}

# Downoad checksums and archives
for ext in bin extra texmf; do
	filename="texlive-$DATE-$ext.tar.xz"
	curl -sO "http://ftp.math.utah.edu/pub/tex/historic/systems/texlive/$YEAR/texlive-$DATE-$ext.tar.xz.sha512"
	if [ -f "$filename" ] && validate_checksum "$filename"; then
		echo "skipping download for $filename"
	else
		echo "downloading $filename"
		curl -sO "http://ftp.math.utah.edu/pub/tex/historic/systems/texlive/$YEAR/texlive-$DATE-$ext.tar.xz" &
	fi
done
wait

# Check integrity and unpack
for ext in bin extra texmf; do
	filename="texlive-$DATE-$ext.tar.xz"
	if ! validate_checksum "$filename"; then
		echo "Incorrect checksum for $filename!"
		echo "Expected $expected_checksum "
		echo "     Got $checksum"
		exit 1
	fi
	tar -xf $filename &
done
wait

mkdir -p output
./create_tarballs.py "texlive-$DATE-bin" &
./create_tarballs.py "texlive-$DATE-extra/tlpkg/TeXLive" &
./create_tarballs.py "texlive-$DATE-texmf" &
wait

(
	cd output
	ls | xargs sha256sum
) >sha256sums-$DATE.txt
