#!/bin/bash
set -euo pipefail

MAP=$1

echo Testing $MAP

tools/deploy.sh ci_test
mkdir ci_test/data

#set the map
# CHAOS-EDIT START: the JSON of a universe's map is in modular_chaos/universes/<universe>/maps/
# cp maps/$MAP.json ci_test/data/next_map.json
MAP_JSON=maps/$MAP.json
if [ ! -f $MAP_JSON ]; then
	MAP_JSON=$(ls modular_chaos/universes/*/maps/$MAP.json | head -n 1)
fi
cp $MAP_JSON ci_test/data/next_map.json
# CHAOS-EDIT END
cp maps/templates/space.json ci_test/data/next_ship.json

cd ci_test
DreamDaemon colonialmarines.dmb -close -trusted -verbose -params "log-directory=ci"
cd ..
cat ci_test/data/logs/ci/clean_run.lk
