#!/usr/bin/env bash

if ! which hugo &> /dev/null; then
	echo "Hugo not found. Installing..."
	brew install hugo
fi

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Changelog
_chlog_src="${DIR}/../CHANGELOG.md"
_chlog_target="${DIR}/content/development/changelog.md"
cat << EOF > "${_chlog_target}"
---
title: "Changelog"
date: 2019-06-20T15:07:21-04:00
draft: false
weight: 100
---

EOF
cat "${_chlog_src}" | tail -n +2 >> "${_chlog_target}"


# Quick Reference
_qref_src="${DIR}/../README.md"
_qref_target="${DIR}/content/quick_reference/_index.md"
cat << EOF > "${_qref_target}"
+++
title = "Quick Reference"
date = 2019-06-20T15:49:49-04:00
weight = 1
chapter = false
draft = false
+++

EOF
sed -n '/Quick Reference/,$p' "${_qref_src}" | tail -n +2 >> "${_qref_target}"

hugo -d "${DIR}/../docs"
