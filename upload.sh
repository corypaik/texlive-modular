#!/bin/sh

set -eu

GITHUB_USER=${GITHUB_USER:-"ProdriveTechnologies"}

for file in output/texlive-*.tar.xz; do
  echo "${file}"
  curl \
      -s \
      -H "Content-Type: application/octet-stream" \
      -H "Authorization: token $1" \
      --data-binary "@${file}" \
      "https://uploads.github.com/repos/$GITHUB_USER/texlive-modular/releases/$2/assets?name=$(basename "${file}")"
done
