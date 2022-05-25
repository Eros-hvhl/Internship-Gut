#! usr/env/bin python3
"""
Author: Eros Reij
Date: 25-4-2022 
Description: parse all _fa.txt files in a dir into a single fasta CSV
Usage: python3 parse_mmz.py <dir> output.csv 

Prints CSV format into standard output with tax and ASV as columns.
"""
# imports
from sys import argv
import pandas as pd
import glob

def merge_fasta(file_list):
    """
    merge list of fasta files into a single pandas DataFrame.

    Parameters
    ----------
    file_list : List
        List of fasta files seperated by '\t'.

    Returns
    -------
    merged : DataFrame
        DataFrame of the merged fasta files.
        
    """
    dflist = []
    for filename in file_list:
        fa = open(filename).read() # placeholder for fasta
        fa = fa.split('\n')
        fa.pop() # IMPORTANT BAND AID FIX: 2 newlines..... fix pls
        fa = fa[1:-1]
        # list comp for every other 2 lists
        asv = [val[1:] for idx, val in enumerate(fa) if idx % 2 == 1]
        taxid = [val for idx, val in enumerate(fa) if idx % 2 != 1]
        # initialize empty DataFrame
        dataframe = pd.DataFrame()
        dataframe['tax']=taxid
        dataframe['asv']=asv
        dflist.append(dataframe)
    merged = pd.concat(dflist, axis=0, ignore_index=True)
    return merged

# duplicate function in 'parse_OTU.py' <- needs cleanup!
def export_tsv(pdDataFrame,outfile):
    """
    Write pandas DataFrame to CSV file.

    Parameters
    ----------
    pdDataFrame : DataFrame
        A pandas DataFrame to write to CSV.
    outfile : str
        Name of the output file, without extension.

    Returns
    -------
    None.

    """
    pdDataFrame.to_csv(outfile + '.txt',index = False, sep = '\t')
    return None

def main():
    """main function of this module
    """
    path = argv[1]
    file_list = glob.glob(path + "/*fa.txt")
    outfile = argv[2]
    merged = merge_fasta(file_list)
    export_tsv(merged, outfile)
    
if __name__ == "__main__":
	main()
