import requests    
import tarfile
import os
import cv2
import scipy.io
import matplotlib.pyplot as plt
from random import *
import numpy as np
from imutils import build_montages
from skimage.color import label2rgb
from subprocess import call
import timeit
import pickle
import ipdb


if not os.path.isdir(os.path.join(os.getcwd(),'BSR')):
    url='http://www.eecs.berkeley.edu/Research/Projects/CS/vision/grouping/BSR/BSR_bsds500.tgz'
    r=requests.get(url,allow_redirects=True)
    open('Dataset.tgz','wb').write(r.content)
    tar=tarfile.open("Dataset.tgz","r")
    tar.extractall()
    tar.close

start = timeit.timeit()

os.chdir("BSR/BSDS500/data/images/test/")
lista=os.listdir(".")
x=sample(lista,6)
os.chdir(os.path.expanduser("~"))
if os.path.isdir(os.path.join(os.getcwd(),'cortadas')):
    call(['rm', '-r','cortadas'])
os.mkdir("cortadas")

imorig=[]
imseg=[]
imbound=[]
dic={}
dic.setdefault('Original',[])
dic.setdefault('Seg',[])
dic.setdefault('Bound',[])
for i in x:
    im=cv2.imread(os.path.join("BSR/BSDS500/data/images/test/", i))
    imc=cv2.resize(im,(256,256))
    cv2.imwrite(os.path.join("cortadas/",i),imc)
    mat=i.replace("jpg","mat")
    f= scipy.io.loadmat(os.path.join("BSR/BSDS500/data/groundTruth/test/",mat))
    ground=f['groundTruth']
    seg=ground[0][0][0][0][0]
    boun=ground[0][0][0][0][1]
    seg=cv2.resize(seg,(256,256))
    boun=cv2.resize(boun,(256,256))
    imc= cv2.cvtColor(imc,cv2.COLOR_BGR2RGB)
    seg=np.round((seg - np.min(seg))*255/(np.max(seg)-np.min(seg)))
    boun=np.round((boun - np.min(boun))*255/(np.max(boun)-np.min(boun)))
    seg=cv2.applyColorMap(np.uint8(seg),cv2.COLORMAP_JET)
    boun=cv2.applyColorMap(np.uint8(boun),cv2.COLORMAP_BONE)
    imorig.append(imc)
    imseg.append(seg)
    imbound.append(boun)
    dic['Original'].append(imc)
    dic['Seg'].append(seg)
    dic['Bound'].append(boun)
#ipdb.set_trace()
todas=np.concatenate((imorig,imseg,imbound),axis=0)
pickle.dump(dic, open("diccionario.p", "wb"))
montages=build_montages(todas,(200,200),(6,3))
for montage in montages:
    plt.axis("off")
    plt.imshow(montage)
    plt.show()
end = timeit.timeit()
print(end)

