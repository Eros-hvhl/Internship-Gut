# -*- coding: utf-8 -*-
"""
Created on Sun Jul  3 18:08:20 2022

@author: Eros
"""

# imports
import sys

def write_list(list_name,file_name):
    """
    Write list to txt, each element to a line.

    Parameters
    ----------
    list_name : List
        List of lines to write.
    file_name : Str
        name and extension of desired outputfile.

    Returns
    -------
    None.

    """
    f = open(file_name, "w+")
    for n in range(len(list_name)):
        f.write(list_name[n] + '\n')
    f.close()

def extract_otu(file):
    """

    """
    txt = open(file,"r").read()
    otudata = txt.split('###')[0].split('\n')[3:-1]
    return otudata

def main():
    """main function of this module
    """
    file = sys.argv[1]
    filenam = file.split('/')[-1]
    filenam = filenam.split('.')[0] # sample as string
    sname = sys.argv[2].split('.')[0]
    data = extract_otu(file)
    otu_output = str(sname)+'.txt'
    write_list(data,otu_output)
    
if __name__ == "__main__":
	main()
