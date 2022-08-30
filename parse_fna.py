# -*- coding: utf-8 -*-
#! usr/env/bin python3
"""
Author: Eros Reij
Date: 20-6-2022 
Description: edited parsing, parse MMZ txt to FASTA (fna)
Usage: python3 parse_mmz.py <file> <output.fna> 

"""
# imports
import sys

def write_list(list_name,file_name):
    """
    Write list of tuples (x,x) to a file each tuple element per line.

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
        f.write(str(list_name[n][0] + '\n' +str(list_name[n][1])) + '\n')
    f.close()

def extract_fasta(file):
    """
    Split BaseClear in tuple of metadata,taxonomic profiles and fasta's

    Parameters
    ----------
    file : CSV file
        BaseClear provided data, taxonomic profiles.
    Returns
    -------
    metadata : List
        Sample information.
    tax_profile : List
        Taxonomic profile.
    fastadata : List
        Fasta sequences.

    """
    txt = open(file,"r").read()
    fastadata = txt.split('###')[1]
    fastalist = fastadata.split('\n')[1:-1] # pop newline + FASTA rn
    unamelist = ['>otu_'+ str(x) for x in range(len(fastalist[::2]))] #fk im good
    fasta = [x for x in list(zip(unamelist,fastalist[1::2]))] # list of tup
    meta = [x[0]+'\t'+x[1] for x in list(zip(unamelist,fastalist[::2]))]    
    return (fasta,meta)


def main():
    """main function of this module
    """
    file = sys.argv[1]
    filenam = file.split('/')[-1]
    filenam = filenam.split('.')[0] # sample as string
    sname = sys.argv[2].split('.')[0]
    fna_output = str(sname)+'.fna'
    meta_output = str(sname)+'_meta.txt'
    fastatup = extract_fasta(file)
    write_list(fastatup[0],fna_output)
    # write metadata
    met = open(meta_output, "w")
    for n in range(len(fastatup[1])):
        met.write(str(fastatup[1][n]) + '\n')
    met.close()
    
if __name__ == "__main__":
	main()
