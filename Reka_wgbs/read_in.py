#!/usr/bin/env python
import numpy as np
import types
import sys, getopt

def main(sampleSheet="", read=1, count=False, lanes=1, paired=False):
    if lanes != 1:
        sys.stderr.write("Currently working only with 1 lane/read")
        sys.exit()
    if type(count) != types.BooleanType:
        sys.stderr.write("count should be True or False")
        sys.exit()
    if sampleSheet == "":
        sys.stderr.write("No sample sheet was defined!")
        sys.exit()
    if not (read>=1 and read<=3):
        sys.stderr.write("Invalid value for read. It should be between 1 and 3")
        sys.exit()
    if type(paired) != types.BooleanType:
        sys.stderr.write("paired should be True or False")
        sys.exit()
    if read==2 and not(paired):
        sys.stderr.write("No second reads in single-end sequencing!")
        sys.exit()

    data = np.genfromtxt(sampleSheet,  delimiter = ",", skiprows = 1, dtype = '|S64')
    uniq = np.unique(data[:,2]) #how many unique libraries
    #data check
    for element in uniq:
        lists = np.where(data==element)
        if lanes==1:
            if len(lists[0])==2 and paired:
                if (data[lists[0],1][0]==data[lists[0],1][1] and data[lists[0],2][0]==data[lists[0],2][1]
                    and ((data[lists[0],3][0]=="1" and data[lists[0],3][1]=="2") or (data[lists[0],3][0]=="2" and data[lists[0],3][1]=="1"))):
                    continue
                else:
                    sys.stderr.write("The library " + data[lists[0],2][0] + " is not correctly paired\n")
                    sys.exit()
            elif len(lists[0])==1 and not(paired):
                continue
            else:
                sys.stderr.write("The library number " + data[lists[0],2][0] + " has more or less samples than it should per library\n")
                sys.exit()
    if count==True:
        return len(uniq)
        sys.exit()
    #element=uniq[number-1]
    #print element
   # for element in uniq:
    return_list = []
    for element in uniq:
        lists = np.where(data==element)
        if lanes==1:
            if len(lists[0])==2 and paired:
                if (data[lists[0],3][0]=="1" and data[lists[0],3][1]=="2"):
                    if read == 1:
                        return_list.append(data[lists[0][0],0])
                    elif read == 2:
                        return_list.append(data[lists[0][1],0])
                    elif read == 3:
                        return_list.append(data[lists[0],2][0])
                    #print ' '.join(data[lists[0],0]), ' ', data[lists[0],2][0]
                    sys.stdout.write("\n")
                else:
                    if read == 2:
                        return_list.append(data[lists[0][0],0])
                    elif read == 1:
                        return_list.append(data[lists[0][1],0])
                    elif read == 3:
                        return_list.append(data[lists[0],2][0])
                    #print data[lists[0],0][1], ' ', data[lists[0],0][0], ' ', data[lists[0],2][0]
                    #sys.stdout.write("\t")
            elif len(lists[0])==1 and not(paired):
                if read == 1:
                    return_list.append(data[lists[0][0],0])
                elif read == 2:
                    sys.stderr.write("No second read in non-paired data!")
                    sys.exit()
                elif read == 3:
                    return_list.append(data[lists[0],2][0])
                #print ' '.join(data[lists[0],0]), ' ', data[lists[0],2][0]
    return return_list

if __name__ == "__main__":
   main()


