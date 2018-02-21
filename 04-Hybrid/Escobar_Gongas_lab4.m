%First part: Gaussian pyramid
% Read images and convert them to grayscale
im1=imread('.\images\Imagen2.jpg');
im1=rgb2gray(im1);
im2=imread('.\images\Imagen1.jpg');
im2=rgb2gray(im2);
tam=size(im2);
im1=imresize(im1,tam);
%A gaussian filter is created
filtro=fspecial('gaussian',[30 30], 20);
%The filter is applied to extract low frequencies from im1
filtrada1= imfilter(im1,filtro);
%Another gaussian filter is created
filtro2=fspecial('gaussian',[50 50], 50);
%The high frequencies from im2 are extracted
filtrada2=im2-imfilter(im2,filtro2);
%Both images are added to create the hybrid image
final1=filtrada2+filtrada1;

%Reduction with gaussian pyramid
final2=impyramid(final1,'reduce');
final3=impyramid(final2,'reduce');
final4=impyramid(final3,'reduce');
final5=impyramid(final4,'reduce');

%put all pyramid results with the same height
final2=[zeros(size(final2));final2];
final3=[zeros(964-size(final3,1),size(final3,2));final3];
final4=[zeros(964-size(final4,1),size(final4,2));final4];
final5=[zeros(964-size(final5,1),size(final5,2));final5];

%Contatenate pyramid
piramide=cat(2,final1,final2,final3,final4,final5);
figure
imshow(piramide)
%%
%Part 2: Blended Image formation
% Read images and convert them to grayscale
im1=imread('.\images\Imagen3.jpg');
im2=imread('.\images\Imagen4.jpg');
im1=rgb2gray(im1);
im2=rgb2gray(im2);
% Vector with Laplacian images from pyramid 
l={};
% Conncatenated halves ofimages
imagen= cat(2,im1,im2);
% Reduction of image with gaussian pyramid
for i=1:30
peque=impyramid(imagen,'reduce');
resta=imresize(peque,size(imagen));
l{i}={imagen-resta};
imagen=peque;
end
% Laplacian pyramid reconstruction: addition of the corresponding Laplacian pyramid  
for i=30:-1:1
grande=impyramid(peque,'expand');
grande=imresize(grande,size(cell2mat(l{i})));
grande=grande+ cell2mat(l{i});
peque=grande;
end
figure
imshow(peque)