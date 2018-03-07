%Function for the evaluation metric
function [ metric] = label_ratio( file,segm )
gt=load(file);
num_gt=length(gt.groundTruth);
final_ratio=zeros(1,num_gt);
for j=1:num_gt
    vdad=gt.groundTruth{j}.Segmentation;
    labels=max(max(vdad));
    ratio=zeros(1,labels);
    for i=1:labels
        mascara=vdad==i;
        masc_segm=mascara.*segm;
        Ncount=histc(masc_segm,unique(masc_segm));
        num_segm=sum(Ncount(2,:));
        num_gt=length(mascara(mascara==1));
        ratio(i)=num_segm/num_gt;
    end
    final_ratio(j)=mean(ratio);
end
metric=mean(final_ratio);
end

