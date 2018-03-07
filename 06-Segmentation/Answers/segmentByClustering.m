%This function segments and image taking into account the feature space,
%the clustering method and the number of clusters
function segmentation = segmentByClustering( rgbImage, featureSpace, clusteringMethod, numberOfClusters)
[m,n,d]=size(rgbImage);
features=zeros(m,n);
datos=[];
switch featureSpace
    case 'rgb'
        for i=1:n
            for j=1:m
                feat=[rgbImage(j,i,1),rgbImage(j,i,2),rgbImage(j,i,3)];
                features(j,i)=mean(feat);
                datos=[datos;feat];
            end
        end
    case 'lab'
        labImage=rgb2lab(rgbImage);
        for i=1:n
            for j=1:m
                feat=[ labImage(j,i,1)/100, (labImage(j,i,2)+128)/255, (labImage(j,i,3)+128)/255];
                features(j,i)=mean(feat);
                datos=[datos;feat];
            end
        end
    case 'hsv'
        hsvImage=rgb2hsv(rgbImage);
        for i=1:n
            for j=1:m
                feat=[ hsvImage(j,i,1), hsvImage(j,i,2)+128, hsvImage(j,i,3)+128];
                features(j,i)=mean(feat);
                datos=[datos;feat];
            end
        end
    case 'rgb+xy'
        for i=1:n
            for j=1:m
                feat=[rgbImage(j,i,1),rgbImage(j,i,2),rgbImage(j,i,3),j*127.5000/m,i*127.5000/n];
                features(j,i)=mean(feat);
                datos=[datos;feat];
            end
        end
    case 'lab+xy'
        labImage=rgb2lab(rgbImage);
        for i=1:n
            for j=1:m
                feat=[ labImage(j,i,1)/100, (labImage(j,i,2)+128)/255, (labImage(j,i,3)+128)/255,j/m,i/n];
                features(j,i)=mean(feat(1:3))*0.8+mean(feat(4:5))*0.2;
                datos=[datos;feat];
            end
        end
    case 'hsv+xy'
        hsvImage=rgb2hsv(rgbImage);
        for i=1:n
            for j=1:m
                feat=[ hsvImage(j,i,1), hsvImage(j,i,2)+128, hsvImage(j,i,3)+128,j*127.5/m,i*127.5/n];
                features(j,i)=mean(feat(1:3))*0.8+mean(feat(4:5))*0.2;
                datos=[datos;feat];
            end
        end
end
datos=double(datos);
switch clusteringMethod
    case 'kmeans'
        IDX=kmeans(datos,numberOfClusters,'Replicates',5);
        segmentation=reshape(IDX,[m,n]);
    case 'gmm'
        GMModel = fitgmdist(datos,numberOfClusters);
        idx = cluster(GMModel,datos);
        segmentation=reshape(idx,[m,n]);
    case 'watershed'
        im=features;
        fh=fspecial('sobel');
        fv=fh';
        imh=imfilter(double(im),fh,'replicate');
        imv=imfilter(double(im),fv,'replicate');
        grad=sqrt(imh.^2+imv.^2);
        grad=grad/max((max(grad)));
        grad=grad*255;
        numberOfClusters=8;
        h=1;
        k=10000;
        while k>numberOfClusters
            mins_suppr=imhmin(grad,h);
            L=watershed(mins_suppr);
            a=bwconncomp(L);
            k=a.NumObjects;
            h=h+1;
        end
        
        marker=imextendedmin(grad,h);
        new_grad=imimposemin(grad,marker);
        segmentation=watershed(new_grad);
    case 'hierarchical'
        f=reshape(features,[numel(features),1]);
        tree=linkage(f);
        
        seg=cluster(tree,'maxclust',numberOfClusters);
        segmentation=reshape(seg,[size(rgbImage,1),size(rgbImage,2)]);
        
end

end

