#!/bin/bash
# Copyright 2016 gRPC authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ex

cd "$(dirname "$0")/../../.."

base=$(pwd)

# All the PHP packages have been built in the artifact phase already
# and we only collect them here to deliver them to the distribtest phase.
mkdir -p artifacts/

ls "${EXTERNAL_GIT_ROOT}"/platform={windows,linux,macos}/artifacts || true
ls "${EXTERNAL_GIT_ROOT}"/input_artifacts/ || true

# Jenkins flow (deprecated)
cp -r "${EXTERNAL_GIT_ROOT}"/platform={windows,linux,macos}/artifacts/php_*/* artifacts/ || true

# Kokoro flow
cp -r "${EXTERNAL_GIT_ROOT}"/input_artifacts/php_*/* artifacts/ || true

for arch in {x86,x64}; do
  case $arch in
    x64)
      php_arch=x86_64
      ;;
    *)
      php_arch=$arch
      ;;
  esac
  for plat in {windows,linux,macos}; do
    if [ "${KOKORO_JOB_NAME}" != "" ]
    then
      input_dir="${EXTERNAL_GIT_ROOT}/input_artifacts/protoc_${plat}_${arch}"
    else
      input_dir="${EXTERNAL_GIT_ROOT}/platform=${plat}/artifacts/protoc_${plat}_${arch}"
    fi
    output_dir="$base/artifacts/php_protoc_plugin/${php_arch}-${plat}"
    mkdir -p "$base/artifacts/php_protoc_plugin/${php_arch}-${plat}"
    # output_dir="$base/artifacts"
    cp "$input_dir"/protoc* "$input_dir"/grpc_php_plugin* "$output_dir/"
    if [[ "$plat" != "windows" ]]
    then
      chmod +x "$output_dir/protoc" "$output_dir/grpc_php_plugin"
    fi
  done
done
