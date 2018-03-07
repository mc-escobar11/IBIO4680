nombre='BSDS_tiny\24063.jpg';
clusters=3;
rgbImage=imread(nombre);
segm=segmentByClustering( rgbImage, 'rgb', 'kmeans', clusters);

path_gt=strcat('BSDS_tiny\24063.mat');
metric=label_ratio(path_gt,segm );
toc
subplot(1,3,1)
imagesc(rgbImage)
title('Original image')
axis off
subplot(1,3,2)
imagesc(segm)
title('Segmented by kmeans in rgb space')
axis off
subplot(1,3,3)
gt=load(path_gt);
imagesc(gt.groundTruth{1}.Segmentation)
title('Groundtruth')
axis off
