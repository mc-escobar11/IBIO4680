function [ metric] = label_ratio( file,segm )
segm=double(segm);
gt=load(file);
num_gt=length(gt.groundTruth);
final_ratio=zeros(1,num_gt);
labels_segm=max(max(segm));
for j=1:num_gt
    vdad=gt.groundTruth{j}.Segmentation;
    labels=max(max(vdad));
    ratio=zeros(1,labels);
    for i=1:labels
        mascara=vdad==i;
        masc_segm=mascara.*segm;
        Ncount=histc(masc_segm,unique(masc_segm));
       % if(size(Ncount,1)==1)
        %    num_segm=sum(Ncount(1,:));
        %else
            num_segm=sum(Ncount(2,:));
        %end
        num_gt=length(mascara(mascara==1));
        ratio(i)=num_segm/num_gt;
    end
    ratio2=zeros(1,labels_segm);
    for k=1:labels_segm
        mascara= segm== k;
        vdad=double(vdad);
        masc_segm=mascara.*vdad;
        Ncount=histc(masc_segm,unique(masc_segm));
        if(size(Ncount,1)==1)
            num_segm=sum(Ncount(1,:));
        else
            num_segm=sum(Ncount(2,:));
        end
        num_gt=length(mascara(mascara==1));
        ratio2(k)=num_segm/num_gt;
    end
    f_ratio1=mean(ratio,'double');
    f_ratio2=mean(ratio2,'double');
    final_ratio(j)=mean([f_ratio1,f_ratio2]);
end
metric=mean(final_ratio,'double');
end

