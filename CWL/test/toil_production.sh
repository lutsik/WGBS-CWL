SRC_DIR=`dirname $(readlink -f $0)`
random_hash=`date | md5sum | head -c10`

TMP_DIR=${1}/test_run_${random_hash}
mkdir -p $TMP_DIR/out
mkdir -p $TMP_DIR/work
mkdir -p $TMP_DIR/base

#mkdir /local_tmp/toil_work_${random_hash}

cd $TMP_DIR
cwltoil --logDebug --maxCores 10 --disableCaching --jobStore=`pwd`/jobstore --workDir=`pwd`/work --basedir=`pwd`/base --outdir=`pwd`/out --batchSystem=gridEngine ${SRC_DIR}/../wgbs-workflow-production.yaml ${SRC_DIR}/../test/test-job-wfl-${2}.yml
#cwltoil --logDebug --maxCores 10 --disableCaching --jobStore=`pwd`/jobstore --workDir=`pwd`/work --basedir=`pwd`/base --outdir=`pwd`/out --batchSystem=gridEngine ${SRC_DIR}/wgbs-workflow-pilot.yaml ${SRC_DIR}/test/test-job-wfl.yml
#cwltoil --logDebug --jobStore=`pwd`/jobstore --workDir=`pwd`/work --basedir=`pwd`/base --outdir=`pwd`/out ${SRC_DIR}/wgbs-workflow-pilot.yaml ${SRC_DIR}/test/test-job-wfl.yml
#cwltool --debug --basedir=`pwd`  --tmpdir-prefix=`pwd` --cachedir=`pwd`/work --outdir=`pwd`/out ${SRC_DIR}/wgbs-workflow-pilot.yaml ${SRC_DIR}/test/test-job-wfl.yml

