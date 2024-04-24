#/bin/bash
set -euo pipefail
cd $(dirname $0)

curl http://10.60.17.13:9999/gmt-sdk-20240423-202531.tar.gz -o gmt-sdk.tar.gz
mkdir -p /opt/gmt
tar zxvf gmt-sdk.tar.gz -C /opt/gmt

cd /opt/gmt
export GMT_GLOBAL=`pwd`
export GMT_LOCAL=`pwd`
source $GMT_GLOBAL/bin/gmt_env.sh

python -m venv python_modules --prompt gmt

source $GMT_GLOBAL/bin/gmt_env.sh
npm install --no-audit --progress=false
pip install -r requirements.txt -r requirements-dev.txt
