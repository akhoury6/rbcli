#!/usr/bin/env bash

if ! pip list | grep mkdocs &> /dev/null; then
	echo "Python package mkdocs not found. Installing..."
	pip install mkdocs mkdocs-material
fi

mkdocs build --clean
