
clear;
warning off 
addpath(genpath(cd));

Original_image_dir  =    'Image/color/';
fpath = fullfile(Original_image_dir, '*.bmp');

im_dir  = dir(fpath);
im_num = length(im_dir);
%  nSig = [10 10 10];
nSig = [30 30 30];
% nSig = [50 50 50];
 
strname  = 'laplace';
% strname  = 'geman';
% strname  = 'WeightedLp';
% strname  = 'nnm';
gamma    = 0.4;  
%  gamma should set different values according to the Gaussian noise and nonconvex function
% please refer to our paper
Dataname = 'Color';

 Output_dir    =   ['Results\',Dataname,'_Denoising_results\',strname, '_nsig_',num2str(nSig(1))];
 mkdir(Output_dir);   
filename  = [strname,'_',num2str(nSig(1))];
fn_txt     =   strcat( filename, '_Results.txt' ); 
fid        =   fopen( fullfile(Output_dir, fn_txt), 'a+');
dat = date;
fprintf(fid,strcat('\r\n\r\n',dat,'\r\n'));
fprintf(fid,['Method: ' strname, '|gamma =' num2str(gamma) '\n']);
for i = 1:im_num
    Par        = QuaternionSetParameter(nSig,strname,gamma);
    Par.Output_dir = Output_dir;
    Par.image  = i;
    Par.nSig0  = nSig;    
    O_Img      = imread(fullfile(Original_image_dir, im_dir(i).name));
    Par.I      = double( O_Img);
    maxP       = max(Par.I(:));
    S          = regexp(im_dir(i).name, '\.', 'split');
    [h, w, ch] = size(Par.I);
    Par.nim    = zeros(size(Par.I));
    Par.ImgName =   im_dir(i).name;
    randn('seed',0);
    Par.nim = Par.I + Par.nSig0(1) * randn(size(Par.I));
    
    %%
    fprintf('%s :\n',im_dir(i).name);
    PSNR      =   csnr( Par.I, Par.nim, 0, 0 );
    SSIM      =  cal_ssim( Par.I, Par.nim, 0, 0 );
    FSIM      = FeatureSIM( Par.I, Par.nim);
    fprintf('The initial value of PSNR = %2.3f, SSIM = %2.3f, FSIM = %2.3f \n', PSNR,SSIM, FSIM); 
     
  
    [im_out, Par] = QLRMA_Denoising( Par.nim, Par.I, Par );
    im_out(im_out>255)=255;
    im_out(im_out<0)=0;

    Par.PSNR(Par.Iter, Par.image)  =   csnr( Par.I, im_out, 0, 0 );
    Par.SSIM(Par.Iter, Par.image)  =  cal_ssim( Par.I, im_out, 0, 0 );
    fprintf('%s : PSNR = %2.4f, SSIM = %2.4f \n',im_dir(i).name, Par.PSNR(Par.Iter, Par.image),Par.SSIM(Par.Iter, Par.image)     );
    Re_Img{1,i}   = im_out;
    Re_PSNR(1,i)  = Par.PSNR(Par.Iter, Par.image);
    Re_SSIM(1,i)  = Par.SSIM(Par.Iter, Par.image);
    Re_FSIM(1,i)  = Par.FSIM(Par.Iter, Par.image) ;
end
fclose all