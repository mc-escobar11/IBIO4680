path=dir('BSDS500\data\images\test\*.jpg');
mkdir('calc\lab')
clusters=2:10;
segs=cell(1,length(clusters));
for i=1:length(path)
    
    for j = 1: length(clusters)
        disp(strcat('procesando imagen',num2str(i),'para el cluster',num2str(j)))
        full_path=strcat('bench_fast\data\images\',path(i).name);
        rgbImage=imread(full_path);
        segm=segmentByClustering( rgbImage, 'lab', 'kmeans', clusters(j));
        segs{j}=segm;
    end
    name_cell=path(i).name;
    name_cell(end-3:end)='.mat';
    full_path=strcat('calc\lab\',name_cell);
    save(full_path,'segs')
end
%%
imgDir = 'BSDS500\data\images\test\';
gtDir = 'BSDS500\data\groundTruth\test\';
inDir = '\BSDS500\ucm2';
outDir = 'eval_gmm';
mkdir(outDir);
nthresh = 30;

tic;
allBench_fast(imgDir, gtDir, inDir, outDir, nthresh);
toc;
plot_eval(outDir)