#!/usr/bin/env python
import numpy as np
import types
import sys, getopt

def main(sampleSheet="", colname=""):
    if sampleSheet == "":
        sys.stderr.write("No sample sheet was defined!")
        sys.exit()
    if colname == "":
        sys.stderr.write("No column name was defined!")
        sys.exit()
    colnames = np.array(['Library' ,'ignore', 'ignore_r2', 'ignore_3prime', 'ignore_3prime_r2'])

    if not(any(colname==colnames)):
        sys.stderr.write("Expected value for colname is one of the following: Library ,ignore, ignore_r2, ignore_3prime, ignore_3prime_r2")
        sys.exit()
    data = np.genfromtxt(sampleSheet,  delimiter = ",", skiprows = 0, dtype = '|S64')

    if not(all(colnames==data[0,:])):
        sys.stderr.write("Expected column names are: Library ,ignore, ignore_r2, ignore_3prime, ignore_3prime_r2")
        sys.exit()

    col_num = lists = np.where(colname==colnames)

    uniq = np.unique(data[:,0]) #how many unique libraries
    uniq = np.delete(uniq, (-1), None)
    return_list = []
    for element in uniq:
        lists = np.where(data==element)
        if len(lists[0]) == 1:
            return_list = np.append(return_list, data[lists[0], col_num[0]])
        elif len(lists[0])!=1:
            sys.stderr.write("One line is needed for each library")
            sys.exit()
    return return_list


if __name__ == "__main__":
   main()


