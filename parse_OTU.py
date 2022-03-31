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

def merge_csv(file_list): #finished
    if not isinstance(file_list, list):
        return("input is not a list")
    dflist = []
    for filename in file_list:
        sampleid = filename.replace(argv[1],"")
        sampleid = sampleid.replace('_tax.txt',"")
        dataframe = pd.read_csv(filename,sep='\t', index_col=None, header=0,
                                names = ['tax',sampleid])
        dflist.append(dataframe)
    merged = dflist[0]
    for index in range(len(dflist)-1):
        merged = pd.merge(merged, dflist[index+1],on = ['tax'],how='outer')
    return merged

def make_tax_table(pdDataFrame): # finished
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

def export_csv(pdDataFrame,outfile): # finished
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
