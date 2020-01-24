from sys import *

import pandas as pd
import numpy as np
from scipy import interp

from sklearn.model_selection import StratifiedKFold
from sklearn.metrics import roc_curve, precision_recall_curve, auc
from sklearn.ensemble import RandomForestClassifier

import seaborn as sns
import matplotlib.pyplot as plt
randomState = 42

# "K562" or "mESC"
cell = argv[1]
dl = pd.read_csv('./%s.tsv'%(cell), sep='\t')
# "revision" or "paper"
# running the classifications either with or without the old dataset
version = argv[2]

# lists that contain the data and annotation
datasets = []
set_names = []

# read in the datasets
for index, row in dl.iterrows():
	if version == 'paper':
		if 'Old neg. Set' == row['name']:
			continue
	datasets.append(pd.read_csv(row['file_path'], sep='\t'))
	set_names.append(row['name'])

# define the names for the features and the class
class_feature_name = 'Noisy' if 'Noisy' in datasets[0].columns else 'Class'
features = []
for col in datasets[0].columns:
	if not col in ['Class','Noisy','Id']:
		features.append(col)

# list containing the curves
rocs = []
prcs = []

# dictionary used to collect the feature importance values
# and used to plot the barchart
importance = {}
importance['Feature'] = []
importance['Importance'] = []
importance['Dataset'] = []

# used to sort the features for the barchart
feature_imp_sum = dict((f, 0.0) for f in features)

for index, name in enumerate(set_names):
	# prepare classification features and the class feature
	X = np.array(datasets[index][features])
	y = np.array(datasets[index][class_feature_name])
	
	# calculate the class balance
	balance_in_perc = int(np.mean(y) * 100.0)
	balance_ratio = np.mean(y)
	
	# set up the classification algorithm and the stratified cross-validation
	rf = RandomForestClassifier(n_estimators=100, max_features=2, random_state=randomState)
	tenFold = StratifiedKFold(n_splits=10, random_state=randomState, shuffle=True)
	
	# for the ROC-curve
	tprs = []
	mean_fpr = np.linspace(0, 1, 100)

	# for the PR-curve
	precisions = []
	mean_recall = np.linspace(0, 1, 100)

	for fold, (train, test) in enumerate(tenFold.split(X, y)):
		# train model and apply model on test set to get the classification probabilities
		model = rf.fit(X[train], y[train])
		probas = model.predict_proba(X[test])
		
		# calculate precision, recall, and FPR
		# collect these values for the curve interpolation
		precision, recall, thresholds = precision_recall_curve(y[test], probas[:,1])
		precisions.append(interp(mean_recall, precision, recall))
		precisions[0][0] = 1.0
		
		fpr, tpr, t = roc_curve(y[test], probas[:, 1])
		tprs.append(interp(mean_fpr, fpr, tpr))
		tprs[-1][0] = 0.0
		
		# collect feature importance values
		for i, feature in enumerate(features):
			importance['Feature'].append(feature)
			importance['Importance'].append(rf.feature_importances_[i])
			importance['Dataset'].append(name)
			feature_imp_sum[feature] += rf.feature_importances_[i]
	
	# finalize curve interpolation and calculate the areas under the curves
	mean_precisions = np.mean(precisions, axis=0)
	mean_precisions[0] = 1.0
	auPRC = auc(mean_recall, mean_precisions)
	
	mean_tpr = np.mean(tprs, axis=0)
	mean_tpr[-1] = 1.0
	auROC = auc(mean_fpr, mean_tpr)
	
	print('\n%s balance: %.3f'%(name,balance_in_perc))
	print('auROC: %.3f'%auROC)
	print('auPRC: %.3f\n'%auPRC)
	
	# collect curve data
	rocs.append( (mean_fpr, mean_tpr, name, auROC) )
	prcs.append( (mean_precisions, mean_recall, name, auPRC, balance_ratio) )

# define settings for the plots
colors = ['#ff8b1c','#111e6c','#7c9aa0','#008853','#2A3236']
fs_title = 28
fs_ticks = 18
fs_labels = 22
fs_legend = 22
curve_ticks = [x/10 for x in range(0,12,2)]

# plot the ROC curves
curve_width = 5
dashed_line_width = 2
fig = plt.figure(figsize=(10,10.3))
for index, (fpr, tpr, name, auc) in enumerate(rocs):
	plt.plot(fpr, tpr, color=colors[index], 
			linewidth=curve_width,
			label='AUC: %.3f - %s'%(auc, name))
plt.plot([0, 1], [0, 1], 'k--', lw=dashed_line_width)
plt.xlim([0.0, 1.01])
plt.ylim([0.0, 1.01])
plt.xlabel('False Positive Rate', fontsize=fs_labels+4)
plt.ylabel('True Positive Rate', fontsize=fs_labels+4)
plt.xticks(fontsize=fs_ticks, ticks=curve_ticks)
plt.yticks(fontsize=fs_ticks, ticks=curve_ticks)
plt.title('ROC-curves\n%s'%(cell), fontsize=fs_title, fontweight='bold')
plt.legend(loc="lower right", fontsize=fs_legend)
plt.tight_layout()
fig.savefig('%s_%s_ROC.png'%(version, cell))
plt.clf()


# plot the precision-recall curves
fig = plt.figure(figsize=(10,10.3))
for index, (prec, recall, name, auc, bal) in enumerate(prcs):
	plt.plot(recall, prec, color=colors[index], 
			linewidth=curve_width,
			label='AUC: %.3f - %s'%(auc, name))
plt.xlim([0.0, 1.01])
plt.ylim([0.0, 1.01])
plt.xlabel('Recall', fontsize=fs_labels+4)
plt.ylabel('Precision', fontsize=fs_labels+4)
plt.xticks(fontsize=fs_ticks, ticks=curve_ticks)
plt.yticks(fontsize=fs_ticks, ticks=curve_ticks)
plt.title('PRC-curves\n%s'%(cell), fontsize=fs_title, fontweight='bold')
plt.legend(loc="lower left", fontsize=fs_legend)
plt.tight_layout()
fig.savefig('%s_%s_PRC.png'%(version, cell))
plt.clf()

# plot the barchart for the feature importance
importance = pd.DataFrame(importance)
plt.grid(b=True, axis='x', color='grey', linestyle='--', linewidth=1)
ax = sns.barplot(x='Importance', y='Feature', hue='Dataset', data=importance, 
					  palette = colors,
					  ci="sd",
					  order=sorted(features, key=lambda x: feature_imp_sum[x],reverse=True),
					  errwidth=1.5,
					  capsize=.10)
ax.set_xlabel('Random Forest Feature Importance', fontsize=fs_labels)
ax.set_ylabel('', fontsize=fs_labels)
ax.set_title('Feature Importance\nto predict VOTs in %s'%(cell), fontsize=fs_title, fontweight='bold')

plt.xticks(fontsize=fs_ticks)

fig = ax.get_figure()
fig.set_size_inches(10, 8)

locs, y_labels = plt.yticks(fontsize=fs_labels)
left_shift = 25.0/100.0
for i, l in enumerate(y_labels):
	l.set_horizontalalignment('left')
	l.set_position((-left_shift, i))
plt.legend(loc="lower right", fontsize=fs_legend)
plt.tight_layout()

fig.savefig('%s_%s_FI.png'%(version, cell))
plt.clf()












