SRC_DIR=`dirname $(readlink -f $0)`
random_hash=`date | md5sum | head -c10`

TMP_DIR=${1}/test_run_${random_hash}
#mkdir -p $TMP_DIR/out
mkdir -p $TMP_DIR/work
mkdir -p $TMP_DIR/base

mkdir -p /ngs_share/tmp/toil_out_${random_hash}/out

cd $TMP_DIR

cwltoil --logDebug --maxCores 10 --disableCaching --jobStore=/ngs_share/tmp/toil_out_${random_hash}/out/jobstore --workDir=/local_tmp/ --basedir=`pwd`/base --outdir=/ngs_share/tmp/toil_out_${random_hash}/out --batchSystem=gridEngine ${SRC_DIR}/../wgbs-workflow-pilot.yaml ${SRC_DIR}/../test/test-job-wfl-${2}.yml
