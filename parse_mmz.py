# -*- coding: utf-8 -*-
#! usr/env/bin python3
"""
Author: Eros Reij
Date: 28-3-2022 
Description: parse all MMZ files in a dir into 3 csv files:
             metadata, taxonomic profile and fasta records.
Usage: python3 parse_mmz.py <dir> <list of tsv files> 

"""
# imports
from sys import argv
import os
import re


def write_list(list_name,file_name):
    f = open(file_name, "w")
    for element in list_name:
        f.write(element + '\n')
    f.close()

def parse_taxprofile(file):
    txt = open(file,"r").read()
    txtnofasta = txt.split('###')[0]
    metadata = txtnofasta.split('\n')[0:3]
    tax_profile = txtnofasta.split('\n')[3:-1]
    fastadata = txt.split('###')[1]
    return (metadata,tax_profile,fastadata)

def main():
    """main function of this module
    """
    file_list = argv[1]
    for file in os.listdir(file_list):
        file_name = re.split("_",os.path.basename(file))[0]
        tempfile = parse_taxprofile(file_list + file)
        write_list(tempfile[0],file_name + '_metadata.txt')
        os.system('mv ' + file_name + '_metadata.txt'+' '+ argv[1])
        write_list(tempfile[1],file_name + '_tax.txt')
        os.system('mv ' + file_name + '_tax.txt'+' '+ argv[1])
        write_list(tempfile[2],file_name + '_fa.txt')
        os.system('mv ' + file_name + '_fa.txt'+' '+argv[1])
        os.system('rm ' + argv[1] + os.path.basename(file))
        

if __name__ == "__main__":
	main()
