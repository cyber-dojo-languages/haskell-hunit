#!/bin/sh -eu

# Records in /versions.json the HUnit that cabal installed into the sandbox
# user's package store. Run as root, because /versions.json belongs to root.

# Appends one test framework to the test_frameworks list the base image
# wrote in /versions.json, keeping any entry an earlier image added. Stops
# the build if the list is not found, rather than record nothing.
add_test_framework()
{
  name="${1}"
  version="${2}"
  entry="{\"name\": \"${name}\", \"version\": \"${version}\"}"
  if grep -q '"test_frameworks": \[\]' /versions.json; then
    sed -i "s|\"test_frameworks\": \[\]|\"test_frameworks\": [${entry}]|" /versions.json
  else
    sed -i "/\"test_frameworks\": \[/s|}\]|}, ${entry}]|" /versions.json
  fi
  if ! grep -q -F "${entry}" /versions.json; then
    echo "Could not add ${name} to /versions.json" >&2
    cat /versions.json >&2
    exit 1
  fi
}

# cabal names each package in its store as <name>-<version>-<hash>, so the
# version is read from the directory it unpacked HUnit into.
readonly HUNIT_DIR=$(find /home/sandbox -type d -name 'HUnit-[0-9]*' | head -1)
readonly HUNIT_VERSION=$(basename "${HUNIT_DIR}" | sed -n 's/^HUnit-\([0-9.]*[0-9]\).*$/\1/p')

if [ -z "${HUNIT_VERSION}" ]; then
  echo 'Could not find HUnit in the sandbox user cabal store' >&2
  exit 1
fi

add_test_framework HUnit "${HUNIT_VERSION}"
cat /versions.json
