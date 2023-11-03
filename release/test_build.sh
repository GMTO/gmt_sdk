#!/usr/bin/env bash
set -xe

# Install the release
VERSION=$1
RC=$2

bash /module/install_release.sh $VERSION $RC

# Quick test on the Framework scripts - only if not a Release Candidate
source /root/.bashrc
if [[ $RC = "" ]]; then
    fwk_version=$VERSION
    echo "Testing alarm_server version"
    v=$(alarm_server --version)
    [[ $v == $fwk_version ]] || exit 1
    echo "Testing alarm_client version"
    v=$(alarm_client --version)
    [[ $v == $fwk_version ]] || exit 1
    echo "Testing conf_server version"
    v=$(conf_server --version)
    [[ $v == $fwk_version ]] || exit 1
    echo "Testing conf_client version"
    v=$(conf_client --version)
    [[ $v == $fwk_version ]] || exit 1
    echo "Testing data_client version"
    v=$(data_client --version)
    [[ $v == $fwk_version ]] || exit 1
    echo "Testing data_server version"
    v=$(data_server --version)
    [[ $v == $fwk_version ]] || exit 1
    echo "Testing log_server version"
    v=$(log_server --version)
    [[ $v == $fwk_version ]] || exit 1
    echo "Testing log_client version"
    v=$(log_client --version)
    [[ $v == $fwk_version ]] || exit 1
    echo "Testing sup_server version"
    v=$(sup_server --version)
    [[ $v == $fwk_version ]] || exit 1
    echo "Testing sup_client version"
    v=$(sup_client --version)
    [[ $v == $fwk_version ]] || exit 1
    echo "Testing tele_server version"
    v=$(tele_server --version)
    [[ $v == $fwk_version ]] || exit 1
    echo "Testing tele_client version"
    v=$(tele_client --version)
    [[ $v == $fwk_version ]] || exit 1

    echo "Testing gds version"
    [[ $(gds --version) == $fwk_version ]] || exit 1
    echo "Testing grs version"
    [[ $(grs --version) == $fwk_version ]] || exit 1
    echo "Testing gsq version"
    [[ $(gsq --version) == $fwk_version ]] || exit 1
    echo "Testing gtr version"
    [[ $(gtr --version) == $fwk_version ]] || exit 1
fi

# test gds
gds init tt123_dcs
gds env

# Test dependencies
# MONGODB
nohup mongod > /dev/null &
sleep 10

# test services
cs start
cs status

sleep 10

#echo "press enter to continue"
#read

# Clone core frameworks
cd $HOME
echo -e "$CL Cloning core frameworks $NC"
git clone https://$PAT:x-oauth-basic@github.com/GMTO/ocs_core_fwk
# Checkout pull requests
cd ocs_core_fwk
for id in $(echo $ocs_core_fwk_pull_requests | sed 's/,/\n/g')
do
    echo -e "$CL Checking pull request #$id $NC"
    git pull --no-edit origin pull/$id/head
done
cd ..

# NodeJS release test
# todo:
#log_client query -e '{src: "log_client_app"}' -m 5 -o json_raw
#tele_client query -e '{src: "sup_server/s/op_state/value"}' -m 10000 -t 2000
#tele_client query -e '{src: "sup_server/s/op_state/value"}' -m 100
#tele_client query -e '{src: "sup_server/s/op_state/value"}'
#grs db query tele_query_server -e '{src: {$regex: /alarm_server/}}' -m 10 -o payload
#grs db query tele_query_server -e '{src: {$regex: /alarm_server/}}' --sort '{ts: -1}' -t 3000
#grs db query tele_query_server -e '{src: {$regex: /alarm_server/}}' -m 1000
#grs db query tele_query_server -e '{src: "sup_server/s/op_state/value"}'

# C++ release test
echo -e "$CL Running C++ tests $NC"
cd $GMT_GLOBAL/test/ocs_core_fwk/bin/
for i in *
do
  # Skip some tests. See GMTO/gmt_issues#244, GMTO/gmt_issues#243, GMTO/gmt_issues#242, GMTO/gmt_issues#241
  if [ "$i" != "core_lib_pkg_functional_03_periodictask_test" ] && [ "$i" != "core_lib_pkg_functional_18_serverproxy_test" ]; then
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$GMT_GLOBAL/test/ocs_core_fwk/lib/so ./$i
  fi
done
cd $HOME

# Python release test
# Python release install
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $HOME/miniconda.sh
eval "$($HOME/miniconda/bin/conda shell.bash hook)"
conda create -y -n gmt conda-build msgpack-python=0.6.1 #numpy
conda activate gmt
conda develop "$GMT_GLOBAL/lib/py/"
pip install cson

# Install ASCII tree (optional for python test tree representations)
pip install https://github.com/spandanb/asciitree/archive/refs/heads/master.zip

# Run Python tests
cd $HOME

# add nanocat path to the PATH env var
export PATH=$PATH:$GMT_GLOBAL/ext/bin/
cd ocs_core_fwk/test/py/

cp -fr ocs_core_fwk/conf/core_fwk/ $GMT_GLOBAL/etc/conf/ # FIXME: copying config files should not be necessary

for dir in $(ls -d $PWD/*/)
  do
  echo "Testing framework: $dir"
  cd $dir
  for i in *.py
  do
    echo "Running test: $i"
    python $i
    sleep 0.2
  done
done

# test isample
# Clone isample
cd $HOME
echo -e "$CL Cloning ocs_isample_dcs $NC"
git clone https://$PAT:x-oauth-basic@github.com/GMTO/ocs_isample_dcs
# Checkout pull requests
cd ocs_isample_dcs
for id in $(echo $ocs_isample_dcs_pull_requests | sed 's/,/\n/g')
do
    echo -e "$CL Checking pull request #$id $NC"
    git pull --no-edit origin pull/$id/head
done
cd ..



echo "Finished GMT SDK tests."