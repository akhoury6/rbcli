#!/usr/bin/env bash

if ! which hugo &> /dev/null; then
	echo "Hugo not found. Installing..."
	brew install hugo
fi

hugo server -D
