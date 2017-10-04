#!/usr/bin/env python

import subprocess
import sys
import read_in_meth
import numpy as np
import multiprocessing
import ConfigParser
import argparse
import os.path

def subprocessExe(cmd):

    return subprocess.call(cmd, shell=True)



def main(sysargv):
    parser = argparse.ArgumentParser(description='The location of the config file')
    #get the config file
    parser.add_argument("-c", "--config", metavar="cF", dest="configFile", type=str, default=False, action="store", help="The location of the config file")

    args = parser.parse_args(sysargv)

    config = ConfigParser.RawConfigParser()

     #read in the config file:

    try:
        config.read(args.configFile)

    except IOError as strerror:
        sys.exit("pipeline.py: error: %s" % strerror)

    sample_sheet = config.get('locations', 'sample_sheet')
    scripts = config.get('locations', 'scripts')
    reference_loc = config.get('locations', 'reference_loc')
    input_loc = config.get('locations', 'input_loc')
    output_loc = config.get('locations', 'output_loc')
    tmp = config.get('locations', 'tmp')
    logs = config.get('locations', 'logs')
    paired = config.getboolean('otherOptions', 'paired')
    lanes = config.getint('otherOptions', 'lanes')
    parallel_samples = config.getint('otherOptions', 'parallel_samples')
    bowtie_threads = config.getint('otherOptions', 'bowtie_threads')
    non_cpg = config.getboolean('otherOptions', 'non_cpg')


    lib_name = read_in_meth.main(sampleSheet=sample_sheet, colname="Library")
    ignore = read_in_meth.main(sampleSheet=sample_sheet, colname="ignore")
    ignore_r2 = read_in_meth.main(sampleSheet=sample_sheet, colname="ignore_r2")
    ignore_3prime = read_in_meth.main(sampleSheet=sample_sheet, colname="ignore_3prime")
    ignore_3prime_r2 = read_in_meth.main(sampleSheet=sample_sheet, colname="ignore_3prime_r2")


#start parallel processing

    pool = multiprocessing.Pool(parallel_samples)

    task = []
    for i in range(0, len(lib_name)):
        if paired:
            if non_cpg:
                task.append('bash %s/pipeline_meth_ext.sh --input_loc %s --ignore %s'
                            ' --ignore_r2 %s  --ignore_3prime %s --ignore_3prime_r2 %s  --library %s --tmp %s --logs %s --reference_loc %s --output_loc %s --bowtie_threads %s --paired'
                            % (scripts, input_loc, ignore[i], ignore_r2[i], ignore_3prime[i], ignore_3prime_r2[i], lib_name[i], tmp, logs, reference_loc, output_loc, bowtie_threads))
            elif not(non_cpg):
                task.append('bash %s/pipeline_meth_ext.sh --input_loc %s --ignore %s'
                            ' --ignore_r2 %s  --ignore_3prime %s --ignore_3prime_r2 %s  --library %s --tmp %s --logs %s --reference_loc %s --output_loc %s --bowtie_threads %s --paired --non_cpg'
                            % (scripts, input_loc, ignore[i], ignore_r2[i], ignore_3prime[i], ignore_3prime_r2[i], lib_name[i], tmp, logs, reference_loc, output_loc, bowtie_threads))
        elif not(paired):
            if non_cpg:
                task.append('bash %s/pipeline_meth_ext.sh --input_loc %s --ignore %s'
                        ' --ignore_r2 %s  --ignore_3prime %s --ignore_3prime_r2 %s  --library %s --tmp %s --logs %s --reference_loc %s --output_loc %s --bowtie_threads %s'
                        % (scripts, input_loc, ignore[i], ignore_r2[i], ignore_3prime[i], ignore_3prime_r2[i], lib_name[i], tmp, logs, reference_loc, output_loc, bowtie_threads))
            elif not(non_cpg):
                task.append('bash %s/pipeline_meth_ext.sh --input_loc %s --ignore %s'
                        ' --ignore_r2 %s  --ignore_3prime %s --ignore_3prime_r2 %s  --library %s --tmp %s --logs %s --reference_loc %s --output_loc %s --bowtie_threads %s --non_cpg'
                        % (scripts, input_loc, ignore[i], ignore_r2[i], ignore_3prime[i], ignore_3prime_r2[i], lib_name[i], tmp, logs, reference_loc, output_loc, bowtie_threads))

   # for i in range(0, len(lib_name)):
   #     TASK.append("bash %s/test.sh --paired --read1 %s -l %s " % (scripts, read1[i-1], read3[i-1]))

    #then pass it to the pool

#check if everything was all right
    result = []
    for x in pool.imap_unordered(subprocessExe, task):
        result.append(x)

    for x in range(0, len(result)):
        if result[x]==0:
            print "The library %s run without a problem." % lib_name[x]
        else:
            print "The library %s stopped during running. Check log files." % lib_name[x]


if __name__ == "__main__":
   main(sys.argv[1:])



