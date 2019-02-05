# call it like this:
#       python pca.py ./matrix.tsv

import pandas as pd
from sklearn.decomposition import PCA
from sklearn.manifold import TSNE
from sys import *
import matplotlib.pyplot as plt
import numpy as np

# path to the matrix file as first command line argument
data_file = argv[1]
# read in as tab separated table
data = pd.read_csv(data_file, sep='\t')

# for the PCA collect all columns starting with "bin"
bin_cols = [True if col_name[:3] == 'chr' else False for col_name in data.columns.values]
# settup and do the PCA based on these columns
pca = PCA(n_components=2)
pca_result = pca.fit_transform(data.iloc[:, bin_cols].values)

# collect data needed for the legend (the protein names)
# (proteins are ordered as in matrix file)
protein_names = list(sorted(set(data['protein']), key=lambda x: list(data['protein']).index(x)))
y = np.array([protein_names.index(protein) for protein in data['protein']])

# select some nice colors
color_list = ['slateblue', 'darkgreen', 'c', 'darkorange', 'firebrick', 'mediumaquamarine', 'yellow', 'olive','black','red']
colors = color_list[:len(protein_names)]

# set the size of the figure
plt.figure(figsize=(8,8))
# plot the points
for color, i, protein in zip(colors, list(range(len(protein_names))), protein_names):
        plt.scatter(pca_result[y == i, 0], pca_result[y == i, 1],
                color=color, lw=2, label=protein)
plt.title('The Title')
plt.xlabel('PC-1')
plt.ylabel('PC-2')
plt.legend(loc="best", shadow=False, scatterpoints=1)
# here it is possible to set the minimum and maximum values for the x- and y-axis
#plt.axis([-2, 2, -2, 2])
plt.savefig('%s'%(data_file.replace('.tsv', '.pdf')))
plt.show()





