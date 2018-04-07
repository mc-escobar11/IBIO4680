function [ ACA conf ] = classification( model )
testDir='data/imageNet200/test';

classes2=dir(testDir);
classes2=classes2(3:end);
classes2=struct2cell(classes2);
classes2=classes2(1,:);

load(model) ;
predict={};
annot={};

for i = 1:length(classes2)
    ims = dir(fullfile(testDir,classes2{i},'*.JPEG'))';
    for j=1:length(ims)
        annot={annot{:}, classes2{i}};
        im=imread(ims(j).name);
        label = model.classify(model, im) ;
        predict={predict{:}, label};
    end
end

conf=confusionmat(annot,predict);
conf_n=conf/100;
ACA=mean(diag(conf_n))*100;

end

