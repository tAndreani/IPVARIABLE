import numpy as np
import pandas as pd
from sys import *

# example call: 	python get_list.py K562 3 4 GRCh38
#					python get_list.py HepG2 2 4 hg19

sample = argv[1]
n_replicates = int(argv[2])
n_targets = int(argv[3])
assembly = argv[4]
col_opt_IDR = 'opt_IDR_' + assembly

table = pd.read_csv('table.tsv', sep='\t')

# select only experiment for the given sample (cell-type or tissue)
# at the same time, select only those experiments having 
# an optimal IDR thresholded peak file for the given genome assembly
table = table.loc[(table['sample'] == sample) & (table[col_opt_IDR].notnull())]

# check if there are targets having at least "n_replicates" replicates
target_count = dict((target, sum(table['target'] == target)) for target in set(table['target']))
targets = list(filter(lambda x: target_count[x] >= n_replicates, target_count.keys()))

# check if the replicated experiments for the targets are 
# either all from the same lab or from different labs
target_labs = dict( (target, list(table.loc[table['target'] == target]['lab'])) for target in targets)
targets = []
target_good_labs = {}
for target in target_labs: 
	keep_target = False
	labs = set()
	lab_count = dict( (lab, target_labs[target].count(lab)) for lab in target_labs[target])
	temp_labs = []
	# first it is checked if there is there are n_replicates experiment investigated in the same lab 
	# if so, this lab is added to the targets labs and the flag "keep target" is True
	for lab, count in lab_count.items():
		if count >= n_replicates:
			keep_target = True
			labs.add(lab)
		else:
			temp_labs.append(lab)
	# if there were not enough experiments in one lab 
	# check if there are n_replicates experiments in different labs
	if not keep_target:
		if len(temp_labs) >= n_replicates:
			keep_target = True
			labs = set(temp_labs)
	
	if keep_target:
		targets.append(target)
		target_good_labs[target] = labs

sub_tables = []
for target in targets:
	for lab in target_good_labs[target]:
		sub_tables.append(table.loc[(table['target'] == target) & (table['lab'] == lab)])

#  TODO: check what happens if one of them is empty
final_list = pd.concat(sub_tables)

if len(targets) < n_targets:
	print('Unfortunately only %d targets apply with the conditions'%len(targets))
	print('Final list was not created')
else:
	print('Final list was created for in total %d different targets!'%len(targets))
	final_list.to_csv('./list.tsv',sep='\t',index=False)

