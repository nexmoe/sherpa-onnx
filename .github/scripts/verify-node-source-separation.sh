#!/usr/bin/env bash

set -ex
export SHERPA_ONNX_VERIFY_ROOT="$PWD"
cp scripts/node-addon-api/lib/*.js nodejs-addon-examples/
cp scripts/node-addon-api/build/Release/sherpa-onnx.node nodejs-addon-examples/
python3 - <<'PY'
from pathlib import Path
for path in Path('nodejs-addon-examples').glob('test_offline_source_separation_*.js'):
    path.write_text(path.read_text().replace("'sherpa-onnx-node'", "'./sherpa-onnx'"))
runner = Path('.github/scripts/test-nodejs-addon-npm.sh').read_text()
block = runner.split('echo "----------Source separation----------"', 1)[1]
block = block.split('echo "----------VoxLock speech enhancement----------"', 1)[0]
prefix = 'set -ex\nsource "$SHERPA_ONNX_VERIFY_ROOT/.github/scripts/common.sh"\n'
prefix += 'cd "$SHERPA_ONNX_VERIFY_ROOT/nodejs-addon-examples"\n'
Path('build/test-source-separation-ci.sh').write_text(prefix + block)
PY
bash build/test-source-separation-ci.sh
