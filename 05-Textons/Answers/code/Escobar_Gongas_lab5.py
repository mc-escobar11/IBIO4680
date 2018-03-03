#!/usr/local/bin/python2
import sys
sys.path.append('lib/python')
import os, random
import numpy as np
from skimage import io
from fbRun import fbRun
from computeTextons import computeTextons
from assignTextons import assignTextons
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import accuracy_score
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics.pairwise import chi2_kernel
from datetime import datetime
from sklearn.metrics import confusion_matrix
start=datetime.now()
# Create filter bank
from fbCreate import fbCreate
# CAMBIAR PARAMETROS
fb = fbCreate()

# Obtain concatenated matrices of random pixels
folders=os.listdir("./data2")
folders.sort()
del folders[0]
n=15; #number of train and test images
tam=70 #size of squared images
num_pix=tam*tam #number of selected pixels per image
train=np.array([]).reshape(tam,0)
test=np.array([]).reshape(tam,0)
label=[]

for i in folders:
    path=os.path.join('./data2',i)
    ran_files=random.sample(os.listdir(path),n*2)
    ims_selec=np.array([]).reshape(tam,0)
    for j in ran_files:
        im=io.imread(os.path.join('./data2',i,j))
        mn=np.size(im)
        im=np.reshape(im,(mn,1))
        ran_pix=random.sample(range(1,mn),num_pix)
        selec_pix=np.reshape(im[ran_pix],[tam, tam])
        ims_selec=np.hstack([ims_selec, selec_pix])
    train=np.hstack([train, ims_selec[:,0:n*tam]])
    test=np.hstack([test,ims_selec[:,n*tam:]])
    label=np.hstack([label, [i[1:3]]*n])

# Apply filterbank to train images
filterResponses_train = fbRun(fb,train)
# Retorna n celdas (n=numero filtros), en cada celda estan todas las imagenes concatenadas filtradas por el filtro n

# compute textons from filtered images
k=len(folders); # number of clusters
map, textons = computeTextons(filterResponses_train, k)

# Apply filter bank to test images
filterResponses_test = fbRun(fb,test)

# Label test and train images with textons
tmmapTest=assignTextons(filterResponses_test,textons.transpose())
tmmapTrain=assignTextons(filterResponses_train,textons.transpose())

#Histogram function
def histc(X, bins):
    import numpy as np
    map_to_bins = np.digitize(X,bins)
    r = np.zeros(bins.shape)
    for i in map_to_bins:
        r[i-1] += 1
    return np.array(r)

# Apply histograms to train and test
train_div=np.hsplit(tmmapTrain,len(folders)*n)
train_histo=[]
for l in train_div:
    h=histc(l.flatten(),np.arange(k))/l.size
    train_histo=np.hstack([train_histo,h])

test_div=np.hsplit(tmmapTest,len(folders)*n)
test_histo=[]
for l in test_div:
    h=histc(l.flatten(),np.arange(k))/l.size
    test_histo=np.hstack([test_histo,h])

train_histo=np.split(train_histo,k*n)
test_histo=np.split(test_histo,k*n)

#Metric functions
#Chi-squared distance metric
def distchi(x,y):
	import numpy as np
	np.seterr(divide='ignore', invalid='ignore')
	d=np.sum(((x-y)**2)/(x+y)) 
	return d
#Intersection kernel metric
def inter(x,y):
        import numpy as np
        min=np.minimum(x,y)
        d=1-np.sum(min)
        return d
#For euclidean metric use euclidean as parameter in metric
#KNN - con chi2
neigh= KNeighborsClassifier(n_neighbors=50,metric=distchi)
neigh=neigh.fit(train_histo,label)
resultado=neigh.predict(test_histo)
aca= accuracy_score(label,resultado)
c=confusion_matrix(label,resultado)

#RandomForest
clf = RandomForestClassifier(n_estimators=30, max_features=0.5)
clf.fit(train_histo,label)
resultado2=clf.predict(test_histo)
aca2= accuracy_score(label,resultado2)

print datetime.now() - start
print(aca)
print(aca2)