#!/usr/bin/env bash

if ! pip list | grep mkdocs &> /dev/null; then
	echo "Python package mkdocs not found. Installing..."
	sudo -H pip install mkdocs mkdocs-material
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

mkdir -p "${DIR}/docs/imported" || true
cp "${DIR}/../CHANGELOG.md" "${DIR}/docs/imported/changelog.md"
sed -n '/Quick Reference/,$p' "${DIR}/../README.md" > "${DIR}/docs/imported/quick_reference.md"

mkdocs build --clean
