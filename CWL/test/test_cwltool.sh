SRC_DIR=`dirname $(readlink -f $0)`
random_hash=`date | md5sum | head -c10`
discription=$1

TMP_DIR=/ngs_share/scratch/breuerk/test_cwl/${random_hash}_${discription}
mkdir -p $TMP_DIR/out
mkdir -p $TMP_DIR/work
mkdir -p $TMP_DIR/base
mkdir -p $TMP_DIR/cache

source activate toil_dev

cwltool --debug --tmpdir-prefix=$TMP_DIR/work --basedir=$TMP_DIR/base --outdir=$TMP_DIR/out --cachedir=$TMP_DIR/cache ../main_workflow.yaml ./test-job-wfl-verySmallFile.yml

source deactivate toil_dev