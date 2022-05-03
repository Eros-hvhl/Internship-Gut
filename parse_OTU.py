#! usr/env/bin python3
"""
Author: Eros Reij
Date: 28-3-2022 
Description: parse all _tax.txt files in a dir into a single OTU CSV
Usage: python3 parse_mmz.py <dir> output.csv 

Prints CSV format into standard output.
"""
# imports
from sys import argv
import pandas as pd
import glob

def merge_csv(file_list):
    """
    merge list of TSV files into a single pandas DataFrame.

    Parameters
    ----------
    file_list : List
        List of TSV files seperated by '\t'.

    Returns
    -------
    merged : DataFrame
        DataFrame of the merged TSV files.
        
    """
    dflist = []
    for filename in file_list:
        sampleid = filename.replace(argv[1] + '/',"")
        sampleid = sampleid.replace('_tax.txt',"")
        dataframe = pd.read_csv(filename,sep='\t', index_col=None, header=0,
                                names = ['tax',sampleid])
        dflist.append(dataframe)
    merged = dflist[0]
    for index in range(len(dflist)-1):
        merged = pd.merge(merged, dflist[index+1],on = ['tax'],how='outer')
    return merged

def make_tax_table(pdDataFrame):
    """
    Make a taxonomic profile DataFrame of a merged DataFrame by 'merge_csv()'

    Parameters
    ----------
    pdDataFrame : DataFrame
        Pandas DataFrame made by merging BaseClear taxonomic profiles.

    Returns
    -------
    tax : DataFrame
        DataFrame of taxonomic profiles.

    """
    try:
        first_col = pdDataFrame.iloc[:, 0]
    except:
        first_col = pdDataFrame
    finally:
        tax = first_col[0:,].str.split(";",expand = True)
        names = [x[0] for x in list(tax.iloc[0,:])] 
        for coln in range(len(tax.columns)):
            tax.iloc[:,coln]=tax.iloc[:,coln].str.replace(".=","",regex=True)
        tax.columns = names
        return tax

def export_csv(pdDataFrame,outfile):
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
    pdDataFrame.to_csv(outfile + '.csv',index = False)
    return None

def main():
    """main function of this module
    """
    path = argv[1]
    file_list = glob.glob(path + "/*tax.txt")
    outfile = argv[2]
    merged = merge_csv(file_list)
    taxfile = make_tax_table(merged)
    export_csv(merged, outfile)
    export_csv(taxfile,"taxfile")
    
if __name__ == "__main__":
	main()
