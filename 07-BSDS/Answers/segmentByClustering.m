function segmentation = segmentByClustering( rgbImage, featureSpace, clusteringMethod, numberOfClusters)
[m,n,d]=size(rgbImage);
features=zeros(m,n);
switch featureSpace
    case 'rgb'
        for i=1:m
            for j=1:n
                feat=[rgbImage(i,j,1),rgbImage(i,j,2),rgbImage(i,j,3)];
                features(i,j)=mean(feat);
            end
        end
    case 'lab'
        labImage=rgb2lab(rgbImage);
        for i=1:m
            for j=1:n
                feat=[ labImage(i,j,1)/100, (labImage(i,j,2)+128)/255, (labImage(i,j,3)+128)/255];
                features(i,j)=mean(feat);
            end
        end
    case 'hsv'
        hsvImage=rgb2hsv(rgbImage);
        for i=1:m
            for j=1:n
                feat=[ hsvImage(i,j,1), hsvImage(i,j,2)+128, hsvImage(i,j,3)+128];
                features(i,j)=mean(feat);
            end
        end
    case 'rgb+xy'
        for i=1:m
            for j=1:n
                feat=[rgbImage(i,j,1)/255,rgbImage(i,j,2)/255,rgbImage(i,j,3)/255,i/m,j/n];
                features(i,j)=mean(feat(1:3))*0.8+mean(feat(4:5))*0.2;
            end
        end
    case 'lab+xy'
        labImage=rgb2lab(rgbImage);
        for i=1:m
            for j=1:n
                feat=[ labImage(i,j,1)/100, (labImage(i,j,2)+128)/255, (labImage(i,j,3)+128)/255,i/m,j/n];
                features(i,j)=mean(feat(1:3))*0.8+mean(feat(4:5))*0.2;
            end
        end
    case 'hsv+xy'
        hsvImage=rgb2hsv(rgbImage);
        for i=1:m
            for j=1:n
                feat=[ hsvImage(i,j,1), hsvImage(i,j,2), hsvImage(i,j,3),i/m,j/n];
                features(i,j)=mean(feat(1:3))*0.8+mean(feat(4:5))*0.2;
            end
        end
end

switch clusteringMethod
    case 'kmeans'
        f=reshape(features,[numel(features),1]);
        IDX=kmeans(f,numberOfClusters,'Replicates',5);
        segmentation=reshape(IDX,[m,n]);
    case 'gmm'
        f=reshape(features,[numel(features),1]);
        GMModel = fitgmdist(f,numberOfClusters);
        idx = cluster(GMModel,f);
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
        numberOfClusters=5;
        h=1;
        k=10000;
        while k>numberOfClusters
            mins_suppr=imhmin(grad,h);
            %bwmins=imregionalmin(mins_suppr);
            L=watershed(mins_suppr);
            a=bwconncomp(L);
            k=a.NumObjects;
            %k=length(unique(L));
            h=h+1;
        end
        
        segmentation=L;
        
        
        
end

end

