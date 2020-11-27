function [I,info] = fmriqa_plot_2dseq(n_slice,n_slices,n_vol,matrix_size,fullname,data_type,verbose);
% fmriqa_plot_2dseq	- plots data from Bruker 2dseq file
%--------------------------------------------------------------------------------
% Input(s): 	
%               n_slice
%               n_slices
%               n_vol
%               matrix_size
%               fullname
%               verbose (optional)
% Output(s):	I       - image series
%               info    - info (what was read)
% Usage:	fmriqa_plot_2dseq(1,1,[1:5],128,'D:\MRI\Tests\20070719P.Ix1\8\pdata\1\2dseq','ushort',1);
% Called by:    fmriqa_process_series
% Calls:        none
% 
% Written by Igor Kagan					 
% igor at vis.caltech.edu
% http://igoresha.virtualave.net
%
% History of changes
% 12.12.06	wrote it
%
% See also PROCESS_SERIES.
%--------------------------------------------------------------------------------
ini_dir = pwd;
if nargin < 5,
        
        % select path of series
        [filename, pathname] = uigetfile({'*'}, 'Please select 2dseq file');
        fullname = [pathname filesep filename];
        if filename == 0, return; end;	
end
if nargin < 6,
        data_type = 'ushort';
end
if nargin < 7,
        verbose = 1;
end

switch data_type
        case 'ushort'
                n_bytes = 2;
        case 'short'
                n_bytes = 2;
        case 'int32'
                n_bytes = 4;
        case 'float'
                n_bytes = 4;
end
                

d = dir(fullname);
filesize = d.bytes;
image_size = matrix_size^2;
n_images = filesize/(matrix_size^2*n_bytes*n_slices); % number of volumes

fid=fopen(fullname,'r'); 


if verbose
        disp(['Reading images in ' fullname]);
end

tic;
if ischar(n_vol), % 'all': read all volumes, one specific slice
        for i = 1:n_images,
                vol_offset 	= n_bytes*n_slices*image_size*(i-1);	  
                slice_offset 	= n_bytes*image_size*(n_slice-1);  
                fseek(fid,vol_offset+slice_offset,'bof');
                I(:,:,i) = reshape(fread(fid,image_size,data_type),matrix_size,matrix_size)';
        end
        textout = ['all ' num2str(n_images) ' volumes, slice ' num2str(n_slice) ' of ' num2str(n_slices)];
elseif length(n_vol)>1, % read one or several volumes, one specific slice
        for i = n_vol,
                vol_offset 	= n_bytes*n_slices*image_size*(i-1);	  
                slice_offset 	= n_bytes*image_size*(n_slice-1);  
                fseek(fid,vol_offset+slice_offset,'bof');
                I(:,:,i) = reshape(fread(fid,image_size,data_type),matrix_size,matrix_size)';
        end
        textout = [mat2str(n_vol) ' volumes, slice ' num2str(n_slice) ' of ' num2str(n_slices)];
elseif length(n_slice)>1, % read specific volume, one or several slices
        vol_offset 	= n_bytes*n_slices*image_size*(n_vol-1);
        for i=n_slice,
                slice_offset 	= n_bytes*image_size*(i-1);  
                fseek(fid,vol_offset+slice_offset,'bof');
                I(:,:,i) = reshape(fread(fid,image_size,data_type),matrix_size,matrix_size)';
        end
        textout = [num2str(n_vol) ' volume, slices ' mat2str(n_slice) ' of ' num2str(n_slices)];
else
        disp('Unknown combination of input parameters - exiting.');
        fclose(fid);
        return;
end
        
elapsed_time = toc;

if verbose
        disp(['Read slice ' num2str(n_slice) ', ' num2str(n_images),' images in ' num2str(elapsed_time) ' sec']);
end

fclose(fid);

info = [fullname ' | ' textout];

% plot 
hf = figure('Name',info,'Position',[50 50 1000 1000]);
n_panels = size(I,3);

ns = sqrt(n_panels);
if mod(ns,1)==0,
        n_rows = ns;
        n_cols = ns;
else
        n_cols = round(ns);
        n_rows = ceil(ns);
end

for k = 1:n_panels
        subplot(n_rows, n_cols, k);
        imshow(I(:,:,k),[]);
        axis off;
        title(num2str(k));
end

mlabel('','',info,'Interperter','none');
