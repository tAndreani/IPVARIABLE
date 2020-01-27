from sys import *
import os
from subprocess import call
import subprocess
import locale
import random

def getSystemCall(call):
	process = subprocess.Popen(call, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
	out, err = process.communicate()
	out = out.decode(locale.getdefaultlocale()[1])
	err = err.decode(locale.getdefaultlocale()[1])
	if process.returncode:
		print("call failed, call was: %s" % ' '.join(call), file=sys.stderr)
		print("Message was: %s" % str(out), file=sys.stderr)
		print("Error code was %s, stderr: %s" % (process.returncode, err), file=sys.stderr, end='')
		raise Exception('runSystemCall Exception') 
	return out, err

genome = '/project/jgu-cbdm/andradeLab/scratch/tandrean/Data/Revision3_NAR_paper/Predicion.VOT/Homo_sapiens/UCSC/hg19/Sequence/WholeGenomeFasta/genome.fa'

input_bed = argv[1]
output_null_bed = argv[2]

name = input_bed.split('/')[-1]
temp_input_fasta = './%s.fa'%(name)

n_regions = int(getSystemCall(['wc', '-l', input_bed])[0].split()[0])

print('%s has %d regions'%(name, n_regions))

bedtools = 'bedtools getfasta -fi %s -bed %s -fo %s'%(genome, input_bed, temp_input_fasta)
print('Running bedtools ...')
#os.system(bedtools)
print('bedtools DONE!\n')

unsorted_output_bed = './%s_NULL_unsorted.bed'%(name)
temp_output_null_fasta = './%s_NULL.fa'%(name)
rscript = 'Rscript genNullSeqs_in.R %s %s %s %s'%(input_bed, temp_input_fasta, unsorted_output_bed, temp_output_null_fasta)
print('Running genNullSeqs ...')
os.system(rscript)
print('genNullSeqs DONE!\n')

# sort final bed file
bedtools = 'bedtools sort -i %s > %s'%(unsorted_output_bed, output_null_bed)
os.system(bedtools)

print('removing temporary files ...')
# remove fasta files
os.system('rm %s'%(temp_input_fasta))
os.system('rm %s'%(temp_output_null_fasta))
os.system('rm %s'%(unsorted_output_bed))
print('DONE!')
