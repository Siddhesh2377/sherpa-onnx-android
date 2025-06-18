#!/usr/bin/env bash

set -ex

sed -i.bak 's/1\.12\.0/1\.12\.1/g' ./pom.xml
sed -i.bak 's/1\.12\.0/1\.12\.1/g' ./jitpack.yml
sed -i.bak 's/1\.12\.0/1\.12\.1/g' ./android/SherpaOnnxAar/README.md

find android -name build.gradle -type f -exec sed -i.bak 's/sherpa-onnx:v1\.12\.0/sherpa-onnx:v1\.12\.1/g' {} \;

find . -name "*.bak" -exec rm {} \;
