#! usr/env/bin python3

from sys import argv
import pandas as pd
import glob
import gzip
import re

def merge_csv(file_list):
    dflist = []
    for filename in file_list:
        data = gzip.open(filename, mode = 'rt').read()
        # parse samplename
        sname = re.search('pathways_unstr/(.+?)/path_abun_unstrat.tsv.gz',filename).group(1)
        # replace samplename 
        data = data.replace('SAMPLE',sname)
        #wrap string in IO
        import io
        y = io.StringIO(data)
        # convert to pd
        data = pd.read_table(y)
        dflist.append(data)
    merged = dflist[0]
    for index in range(len(dflist)-1):
        merged = pd.merge(merged, dflist[index+1],on = ['pathway'],how='outer')
    return merged

def main():
	file_list = argv[1:-1]
	merged = merge_csv(file_list)
	merge_name = argv[-1]
	merged.to_csv(merge_name,sep='\t')

if __name__ == '__main__':
	main()
