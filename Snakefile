SAMPLES = open('../sample_list.txt',"r").read().split('\n')[:-1]
rule all:
	input:
		#it 1 expand('fna/{sample}.fna', sample = SAMPLES) #r1 success
		#it 2 expand('seq_placement/{sample}.tree', sample = SAMPLES)
		#it 3 expand('EC_predicted/{sample}.tsv.gz',sample = SAMPLES)
		#expand('OTU_tables/{sample}.txt', sample = SAMPLES),
		#it 5 expand('BIOM/{sample}.biom',sample = SAMPLES)
		#it 6 expand('16S_pred/{sample}_marker_nsti_predicted.tsv.gz',sample = SAMPLES)
		#expand('EC_metagenomes_strat/{sample}',sample =SAMPLES),
		#expand('pathways_unstr/{sample}', sample = SAMPLES),
		#'merged_pathways/merged.csv'
		#expand('pathways_strat/{sample}', sample = SAMPLES)
		#	wildcard_constraints:
		#		sample = "\w+"
		#expand('relabeled/{sample}.txt',sample=SAMPLES)
		#expand('metatables/{sample}.txt',sample=SAMPLES)
		#expand('relabeled_strat/{sample}.txt',sample=SAMPLES)

rule tax_meta:
	input:
		metadata = 'fna/{sample}_meta.txt'
	output:
		file = 'metatables/{sample}.txt'
	shell:
		'Rscript ../snake_pyscripts/tax_meta.R {input.metadata} {output.file}'
#broken - fix
rule relabel_strat:
	input:
		metadata= 'fna/{sample}_meta.txt',
		s_data= 'pathways_strat/{sample}/path_abun_contrib.tsv.gz'
	output:
		'relabeled_strat/{sample}.txt'
	shell:
		'Rscript ../snake_pyscripts/relabel.R {input.metadata} {input.s_data} {output}'
rule relabel_pertax:
	input:
		metadata= 'fna/{sample}_meta.txt',
		mp_data= 'pathways_strat_pertax/{sample}/path_abun_predictions.tsv.gz'
	output:
		file= 'relabeled/{sample}.txt'
	shell:
		'Rscript ../snake_pyscripts/relabel.R {input.metadata} {input.mp_data} {output.file}'

rule merge_frames:
	input:
		expand('pathways_unstr/{sample}/path_abun_unstrat.tsv.gz',sample=SAMPLES)
	output:
		'merged_pathways/merged.csv'
	shell:
		'python3 ../snake_pyscripts/merge_pw.py {input} {output}'


rule pathway_str:
    input:
        i= 'EC_metagenomes_strat/{sample}'
		#/pred_metagenome_contrib.tsv.gz',
        # default_files/pathway_mapfiles/matacyc_path2rxn_stuc_filt_pro.txt
    output:
        dir = directory('pathways_strat/{sample}'),
		#fileph = "pathways_strat/{sample}/pred_metagenome_contrib.tsv.gz"
    shell:
        'pathway_pipeline.py -i "{input.i}/pred_metagenome_contrib.tsv.gz" -o {output.dir} -p 1'
		# ; (ls "{input.fileph}" >>/dev/null 2>&1 && echo "file made") || echo "file not made"'


rule pathway_unstr:
	input:
		i= 'EC_metagenomes_strat/{sample}/pred_metagenome_unstrat.tsv.gz'
		# default_files/pathway_mapfiles/matacyc_path2rxn_stuc_filt_pro.txt
	output:
		dir = directory('pathways_unstr/{sample}')
	shell:
		'pathway_pipeline.py -i {input.i} -o {output.dir} -p 1'


# NOTE : strat_out generates unstrat aswell...

rule metagenome_strat:
	input:
		i='BIOM/{sample}.biom',
		m='16S_pred/{sample}_marker_nsti_predicted.tsv.gz',
		f='EC_predicted/{sample}.tsv.gz'
	output:
		directory('EC_metagenomes_strat/{sample}')
	shell:
		"metagenome_pipeline.py --strat_out -i {input.i} -m {input.m} -f {input.f} -o {output}"

rule metagenome_unstr:
	input:
		i='BIOM/{sample}.biom',
		m='16S_pred/{sample}_marker_nsti_predicted.tsv.gz',
		f='EC_predicted/{sample}.tsv.gz'
	output:
		dir = directory('EC_metagenomes/{sample}')
	wildcard_constraints:
		sample = "\w+"
	shell:
		'metagenome_pipeline.py -i {input.i} -m {input.m} -f {input.f} -o {output.dir}'

rule predict_16S:
	input:
		treefile='seq_placement/{sample}.tree'
	output:
		'16S_pred/{sample}_marker_nsti_predicted.tsv.gz'
	wildcard_constraints:
		sample = "\w+"
	shell:
		"hsp.py -i 16S -t {input.treefile} -o {output} -p 1 -n"
	
rule generate_biom:
	input:
		otufile= 'OTU_tables/{sample}.txt',
		metadata= "fna/{sample}_meta.txt"
	output:
		'BIOM/{sample}.biom'
	wildcard_constraints:
		sample = "\w+"
	shell:
		"Rscript ../snake_pyscripts/convert_biom.R {input.otufile} {input.metadata} {output} ; biom convert -i {output} -o {output} --to-hdf5 --table-type='OTU table'"

rule fasta:
	input:
		'../taxonomy_files_fromMMZ/{sample}.txt'
	output:
		"fna/{sample}.fna"
	wildcard_constraints:
		sample = "\w+"
	shell:
		"python3 '../snake_pyscripts/parse_fna.py' '{input}' '{output}'"

rule OTU:
	input:
		'../taxonomy_files_fromMMZ/{sample}.txt'
	output:
		"OTU_tables/{sample}.txt"
	wildcard_constraints:
		sample = "\w+"
	shell:
		"python3 '../snake_pyscripts/parse_otu_v2.py' '{input}' '{output}'"

rule placement:
	input:
		sequences='fna/{sample}.fna',
		#chunk_size= 5000
	output:
		'seq_placement/{sample}.tree'
	wildcard_constraints:
		sample = "\w+"
	shell:
		'place_seqs.py -s {input.sequences} -o {output} -p 1'

rule EC_unstrat:
	input:
		treefile='seq_placement/{sample}.tree'
	output:
		'EC_predicted/{sample}.tsv.gz'
	wildcard_constraints:
		sample = "\w+"
	shell:
		'hsp.py -i EC -t {input.treefile} -o {output} -p 1'

