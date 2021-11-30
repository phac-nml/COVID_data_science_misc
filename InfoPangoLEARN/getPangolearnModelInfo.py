
'''
	Getting some basic information from the pangolearn DT model
	Julie Chih-yu Chen
	Input: 
	1. directory where the model and header files are
	2. model file name (optional)
	3. header file name (optional)
	Example:
	python getPangolearnModelInfo.py pangoLEARN-2021-11-18\pangoLEARN\data
'''

import os
import joblib
import pandas as pd
import numpy as np
import graphviz
from sklearn import tree
from sklearn.tree import DecisionTreeClassifier
from sklearn.tree import export_text
import sys


print(sys.getrecursionlimit())
### this is needed for larger trees, to avoid recursion error
sys.setrecursionlimit(3000) #2021-07-28; technically don't need this anymore due to feature selection


folder2use = sys.argv[1]
print(folder2use)
if len(sys.argv)==4 :
    trained_model = os.path.join(folder2use,sys.argv[2])
    header_file = os.path.join(folder2use,sys.argv[3])
else :
    trained_model = os.path.join(folder2use,"decisionTree_v1.joblib")
    header_file = os.path.join(folder2use,"decisionTreeHeaders_v1.joblib")



# loading the list of headers the model needs.
model_headers = joblib.load(header_file)

indiciesToKeep = model_headers[1:]
len(indiciesToKeep) 
len(np.unique(indiciesToKeep))


loaded_model = joblib.load(trained_model)


#################
#Extracting model information
#################

minfo=("Class/lineage count: " +str(loaded_model.n_classes_) + "\n"+
"Total position count: " + str(len(indiciesToKeep)) + "\n"+
"Total feature count: "+str(len(loaded_model.feature_importances_)) +"\n"+
"Total feature count with non-zero importance: "+str(np.count_nonzero(loaded_model.feature_importances_)) +"\n"+
"Model depth: " + str(loaded_model.get_depth()) +"\n"+
"Model leave count: " + str(loaded_model.get_n_leaves()) +"\n"+
"Model total node count: " + str(loaded_model.tree_.node_count) +"\n"+
"Model parameters: " + str(loaded_model.__getstate__()))

print(minfo, sep='\n')

### save model info to text
f = open(os.path.join(folder2use,"model_info.txt"), "a")
f.write(minfo)
f.close()


### saving the unique lineagess in the csv file
df = pd.DataFrame(loaded_model.classes_, columns=["Classes"])
df.to_csv(os.path.join(folder2use,'modelClasses.csv'), index=False)



#### getting feature names in the model
### concatenate features with #categories = ['A', 'C', 'G', 'T', '-']
#categories = ['-','A', 'C', 'G', 'T']
categories = ['T','-','A', 'C', 'G'] ### only in this order that the labels match the decision tree rule, ODD. need to double check
categoriesRep = np.tile(categories,len(indiciesToKeep)) ## now 131365 in length
featExpand = [y for x in indiciesToKeep for y in (x,)*5] ## now 131365 in length as well
featExpand = map(str, featExpand) ## int to string
# using list comprehension + zip(); interlist element concatenation
featExpand2 = [i +"_"+ j for i, j in zip(featExpand, categoriesRep)]
## dec data has one more element somehow ## featExpand2.extend(["last"])

#### getting feature importance
featImp = list(zip(featExpand2, loaded_model.feature_importances_))
# Index of Non-Zero elements in Python list
# using list comprehension + enumerate()
nonz = [idx for idx, val in enumerate(loaded_model.feature_importances_) if val != 0]

##  features of non-zero importance
featImpPlus = [ featImp[index] for index in nonz ]
featImpPlus = sorted(featImpPlus, key=lambda x: x[1], reverse=True)
print(f"Top 11 features:",featImpPlus[0:10])

#### saving the feature importance to a csv file
df = pd.DataFrame(featImpPlus, columns=["Feature", "Importance"])
df.to_csv(os.path.join(folder2use,'featImpPlus.csv'), index=False)



############
### export saved tree as tree text, only the first 5 layers
############
max_depth2report=5
r = export_text(loaded_model, max_depth=max_depth2report, feature_names=featExpand2)
### saving the text to file
f = open(os.path.join(folder2use,"tree_export_byJ_maxDepth" + str(max_depth2report) + "_wfeatNames.txt"), "a")
f.write(r)
f.close()


###############
### graphviz
### svg is better than png (low res, got scaled) and pdf (got chopped off)
### png for the birdseye view of the tree
############
#dot_data = tree.export_graphviz(loaded_model, out_file=None, class_names=loaded_model.classes_, feature_names=featExpand2)
#graph = graphviz.Source(dot_data) 
#graph.render(os.path.join(folder2use),"tree_export_byJ.pdf")

### png
dot_data = tree.export_graphviz(loaded_model, out_file=None, class_names=loaded_model.classes_, feature_names=featExpand2)
graph = graphviz.Source(dot_data) 
graph.render(os.path.join(folder2use,"tree_export_byJ"), format="png")

### svg
dot_data = tree.export_graphviz(loaded_model, out_file=None, class_names=loaded_model.classes_ , feature_names=featExpand2)
graph = graphviz.Source(dot_data) 
graph.render(os.path.join(folder2use,"tree_export_byJ"), format="svg")



