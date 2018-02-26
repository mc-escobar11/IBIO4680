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

# Create filter bank
from fbCreate import fbCreate
# CAMBIAR PARAMETROS
fb = fbCreate()

# Obtain concatenated matrices of random pixels
folders=os.listdir("./data2")
del folders[0]
n=10; #number of train and test images
num_pix=100 #number of selected pixels per image
tam=[round(num_pix/10),10]
train=np.array([]).reshape(10,0)
test=np.array([]).reshape(10,0)
label=[]

for i in folders:
    path=os.path.join('./data2',i)
    ran_files=random.sample(os.listdir(path),n*2)
    ims_selec=np.array([]).reshape(10,0)
    for j in ran_files:
        im=io.imread(os.path.join('./data2',i,j))
        mn=np.size(im)
        im=np.reshape(im,(mn,1))
        ran_pix=random.sample(range(1,mn),num_pix)
        selec_pix=np.reshape(im[ran_pix],tam)
        ims_selec=np.hstack([ims_selec, selec_pix])
    train=np.hstack([train, ims_selec[:,0:n*tam[1]]])
    test=np.hstack([test,ims_selec[:,n*tam[1]:]])
    label=np.hstack([label, [i[1:3]]*n])

# Apply filterbank to train images
filterResponses_train = fbRun(fb,train)
# Retorna n celdas (n=numero filtros), en cada celda estan todas las imagenes concatenadas filtradas por el filtro n

# compute textons from filtered images
k=len(folders); # number of clusters
map, textons = computeTextons(filterResponses_train, k) #Retorna

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

#KNN - con histograma
#hacer lo de chi2_kernel
#neigh= KNeighborsClassifier()
#neigh.fit(train_histo,label)
#resultado=neigh.predict(test_histo)
#aca= accuracy_score(label,resultado)
#KNN - con interseccion
neigh= KNeighborsClassifier(n_neighbors=25)
c2train= chi2_kernel(train_histo)
c2test=chi2_kernel(test_histo)
neigh.fit(c2train,label)
resultado=neigh.predict(c2test)
aca= accuracy_score(label,resultado)

#RandomForest
clf = RandomForestClassifier(max_depth=25, random_state=0)
clf.fit(train_histo,label)
resultado2=clf.predict(test_histo)
aca2= accuracy_score(label,resultado2)

#NOS FALTA: probar con diferentes size de ventana y con dif parametros para knn y random forest Y la ctdad de imagenes que se usan
