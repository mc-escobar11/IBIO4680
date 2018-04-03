function segmentation = segmentByClustering( rgbImage, featureSpace, clusteringMethod, numberOfClusters)
if strcmp(clusteringMethod,'hierarchical')
    
    rgbImage=imresize(rgbImage,0.5);
    
    [m,n,d]=size(rgbImage);
    
else
    
    [m,n,d]=size(rgbImage);
    
end

features=zeros(m,n);

switch featureSpace
    case 'rgb'
        for i=1:n
            for j=1:m
                feat=[rgbImage(j,i,1),rgbImage(j,i,2),rgbImage(j,i,3)];
                features(j,i)=mean(feat);
            end
        end
    case 'lab'
        labImage=rgb2lab(rgbImage);
        for i=1:n
            for j=1:m
                feat=[ labImage(j,i,1)/100, (labImage(j,i,2)+128)/255, (labImage(j,i,3)+128)/255];
                features(j,i)=mean(feat);
            end
        end
    case 'hsv'
        hsvImage=rgb2hsv(rgbImage);
        for i=1:n
            for j=1:m
                feat=[ hsvImage(j,i,1), (hsvImage(j,i,2)+128)/255, (hsvImage(j,i,3)+128)/255];
                features(j,i)=mean(feat);
            end
        end
    case 'rgb+xy'
        for i=1:n
            for j=1:m
                feat=[rgbImage(j,i,1),rgbImage(j,i,2),rgbImage(j,i,3),j*127.5000/m,i*127.5000/n];
                features(j,i)=mean(feat);
            end
        end
    case 'lab+xy'
        labImage=rgb2lab(rgbImage);
        for i=1:n
            for j=1:m
                feat=[ labImage(j,i,1)/100, (labImage(j,i,2)+128)/255, (labImage(j,i,3)+128)/255,j/m,i/n];
                features(j,i)=mean(feat(1:3))*0.8+mean(feat(4:5))*0.2;
            end
        end
    case 'hsv+xy'
        hsvImage=rgb2hsv(rgbImage);
        for i=1:n
            for j=1:m
                feat=[ hsvImage(j,i,1)*255, hsvImage(j,i,2)+128, hsvImage(j,i,3)+128,j*127.5/m,i*127.5/n];
                features(j,i)=mean(feat(1:3))*0.8+mean(feat(4:5))*0.2;
            end
        end
end
switch clusteringMethod
    
    case 'kmeans'
        f=reshape(features,[numel(features),1]);
        IDX=kmeans(f,numberOfClusters,'Replicates',5);
        segmentation=reshape(IDX,[m,n]);
    case 'gmm'
        datos=reshape(features,[numel(features),1]);
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
        se=strel('diamond',10);
        dilat=imdilate(grad,se);        
        grad=dilat;
        h=1;
        k=10000;
        while k>numberOfClusters
            mins_suppr=imhmin(grad,h);
            L=watershed(mins_suppr);
            a=bwconncomp(L);
            k=a.NumObjects;
            h=h+1;
        end
        
        segmentation=L+1;
        
        
    case 'hierarchical'
        f=reshape(features,[numel(features),1]);
        tree=linkage(f);
        seg=cluster(tree,'maxclust',numberOfClusters);
        segmentation=reshape(seg,[size(rgbImage,1),size(rgbImage,2)]);
        segmentation=resizem(segmentation,2);
        segmentation=segmentation(1:321,1:481);
end



end


