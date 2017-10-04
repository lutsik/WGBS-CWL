#!/usr/bin/env python

import subprocess
import sys
import read_in
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
	reports = config.get('locations', 'reports')
	process_ref = config.getboolean('otherOptions', 'process_ref')
	paired = config.getboolean('otherOptions', 'paired')
	lanes = config.getint('otherOptions', 'lanes')
	parallel_samples = config.getint('otherOptions', 'parallel_samples')
	bowtie_threads = config.getint('otherOptions', 'bowtie_threads')

	if paired:
		sample_number = read_in.main(sampleSheet=sample_sheet, read=1, count=True, paired=True)
	elif not(paired):
		sample_number = read_in.main(sampleSheet=sample_sheet, read=1, count=True, paired=False)

	if paired:
		read1=read_in.main(sampleSheet=sample_sheet, read=1, count=False, paired=True)
		read2=read_in.main(sampleSheet=sample_sheet, read=2, count=False, paired=True)
		read3=read_in.main(sampleSheet=sample_sheet, read=3, count=False, paired=True)
	elif not(paired):
		read1=read_in.main(sampleSheet=sample_sheet, read=1, count=False, paired=False)
		read3=read_in.main(sampleSheet=sample_sheet, read=3, count=False, paired=False)

	if process_ref:
		subprocess.call(['bash %s/preprocess_reference.sh --location %s ' % (scripts, reference_loc)], shell=True)


#start parallel processing

	pool = multiprocessing.Pool(parallel_samples)

	task = []
	if paired:
		for i in range(1, sample_number+1):
			task.append('bash %s/pipeline.sh --paired --lanes %s --input_loc %s --read1 %s'
						' --read2 %s --library %s --tmp %s --logs %s --reports %s --reference_loc %s --output_loc %s  --bowtie_threads %s'
						% (scripts, lanes, input_loc, read1[i-1], read2[i-1], read3[i-1], tmp, logs, reports, reference_loc, output_loc, bowtie_threads))
	elif not(paired):
		for i in range(1, sample_number+1):
			task.append('bash %s/pipeline.sh --lanes %s --input_loc %s --read1 %s '
						' --library %s --tmp %s --logs %s --reports %s --reference_loc %s --output_loc %s --bowtie_threads %'
						% (scripts, lanes, input_loc, read1[i-1], read3[i-1], tmp, logs, reports, reference_loc, output_loc, bowtie_threads))

    #for i in range(1, sample_number+1):
    #    TASK.append("bash %s/test.sh --paired --read1 %s -l %s " % (scripts, read1[i-1], read3[i-1]))

    #then pass it to the pool

#check if everything was all right
	result = []
	for x in pool.imap_unordered(subprocessExe, task):
		result.append(x)

	for x in range(0, len(result)):
		if result[x]==0:
			print "The library %s run without a problem." % read3[x]
		else:
			print "The library %s stopped during running. Check log files." % read3[x]


if __name__ == "__main__":
	main(sys.argv[1:])



