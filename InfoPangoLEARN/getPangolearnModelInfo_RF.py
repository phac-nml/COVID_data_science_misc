
'''
	Getting some basic information from the pangolearn RF model (since pangolin v4.0)
	Author: Julie Chih-yu Chen
    Date: 2022-04-06
	Input: 
	1. directory where the model and header files are
	2. model file name (optional)
	3. header file name (optional)
	Example:
	python getPangolearnModelInfo_RF.py pangoLEARN-2022-03-22/pangoLEARN/data/
'''


import os
import joblib
import pandas as pd
import numpy as np
import graphviz
from sklearn.ensemble import RandomForestClassifier
from sklearn import tree
from sklearn.tree import export_graphviz
from sklearn.tree import export_text
import sys


folder2use = sys.argv[1]
print(folder2use)
if len(sys.argv)==4 :
    trained_model = os.path.join(folder2use,sys.argv[2])
    header_file = os.path.join(folder2use,sys.argv[3])
else :
    trained_model = os.path.join(folder2use,"randomForestHeaders_v1.joblib")
    header_file = os.path.join(folder2use,"randomForest_v1.joblib")



# loading the list of headers the model needs.
model_headers = joblib.load(header_file)

indiciesToKeep = model_headers[1:] # this is different from the DT model. Skipping for now


# loading model
loaded_model = joblib.load(trained_model)


#################
#Extracting model information
#################
dir(model_headers)
#model_headers.__class__()#RandomForestClassifier()
#model_headers.__len__() #15
#model_headers._get_param_names()
print(model_headers.estimators_) # the list of decision tree models

### save info to text
f = open("model_info_RandomForest.txt", "w")
print(str(model_headers.estimators_)+"\n"+"\n"+"\n")
for x in range(0,len(model_headers.estimators_)):
  dtmodel=model_headers.estimators_[x]
  minfo=("model" + str(x+1) + "\n"+
  "Class/lineage count: " +str(dtmodel.n_classes_) + "\n"+
  "Total feature count: "+str(len(dtmodel.feature_importances_)) +"\n"+
  "Total feature count with non-zero importance: "+str(np.count_nonzero(dtmodel.feature_importances_)) +"\n"+
  "Model depth: " + str(dtmodel.get_depth()) +"\n"+
  "Model leave count: " + str(dtmodel.get_n_leaves()) +"\n"+
  "Model total node count: " + str(dtmodel.tree_.node_count) +"\n"+
  "Model parameters: " + str(dtmodel.__getstate__()) +"\n")
  print(minfo, sep='\n')
  f.write(minfo)

f.close()


### saving the unique lineagess in the csv file
### Numbers instead of lineage names
df = pd.DataFrame(model_headers.estimators_[0].classes_, columns=["Classes"])
df.to_csv('modelClasses_RF1.csv', index=False)

### Cursary look: don't have the corresponding name of the classes and features as in the DT script.
for x in range(0,len(model_headers.estimators_)):
  print(x)
  dtmodel=model_headers.estimators_[x]
  ############
  ### export saved tree as tree text, only the first 5 layers
  ############
  max_depth2report=5
  r = export_text(dtmodel, max_depth=max_depth2report)
  ### saving the text to file
  f = open("tree_export_byJ_maxDepth" + str(max_depth2report) + "_wfeatNames_RF"+str(x)+".txt", "w")
  f.write(r)
  f.close()
  
  ###############
  ### graphviz
  ### svg is better than png (low res, got scaled) and pdf (got chopped off)
  ### png for the birdseye view of the tree
  ############
  #dot_data = tree.export_graphviz(dtmodel, out_file=None, class_names=dtmodel.classes_, feature_names=featExpand2)
  #graph = graphviz.Source(dot_data) 
  #graph.render("tree_export_byJ.pdf") 
  
  ### png
  classesNum=dtmodel.classes_.tolist()
  dot_data = tree.export_graphviz(dtmodel, out_file=None, class_names=[str(classesNum) for classesNum in classesNum]) #, feature_names=featExpand2
  graph = graphviz.Source(dot_data) 
  graph.render("tree_export_byJ_RF"+str(x), format="png") 
  
  ### svg
  dot_data = tree.export_graphviz(dtmodel, out_file=None, class_names=[str(classesNum) for classesNum in classesNum])#, feature_names=featExpand2
  graph = graphviz.Source(dot_data) 
  graph.render("tree_export_byJ_RF"+str(x), format="svg") 


