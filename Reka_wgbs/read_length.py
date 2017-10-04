__author__ = 'tkike'

import pysam
import itertools


samfileIN = pysam.Samfile("/media/tkike/Reka/WGBS/tmp_test//Human_B3_sorted_test1.bam", "rb")



sequence=range(1, 22)
complete=0
for i in sequence:
    chr = "chr"+str(i)
    print chr
    complete=complete+samfileIN.count(chr)
    reads = samfileIN.fetch(chr)
    for x in reads:
        if x.qlen>48:
            print x

print complete


