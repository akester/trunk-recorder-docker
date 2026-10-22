#!/bin/bash

set -e
set -x

git checkout latest && git merge edge && git push && git checkout latest
git checkout v5.2.1 && git merge edge && git push && git checkout latest
git checkout v5.2.0 && git merge edge && git push && git checkout latest
git checkout v4.7.2 && git merge edge && git push && git checkout latest
