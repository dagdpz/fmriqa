function [I,info] = fmriqa_read_slice_bruker_2dseq(n_slice,n_slices,matrix_size,pathname,verbose);
% fmriqa_read_slice_bruker_2dseq	- read one slice from Bruker 2dseq file
%--------------------------------------------------------------------------------
% Input(s): 	n_slice
%               n_slices
%               matrix_size
%               pathname
%               verbose (optional)
% Output(s):	I       - image series
%               info    - info (what was read)
% Usage:	[I,info] = fmriqa_read_slice_bruker_2dseq(ser(i).n_slice,ser(i).n_slices,ser(i).matrix_size,ser(i).pathname,1);
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
if nargin < 4,
        
        % select path of series
        [filename, pathname] = uigetfile({'*'}, 'Please select 2dseq file');
        if filename == 0, return; end;	
end

if nargin < 5,
        verbose = 1;
end

cd(pathname);

d = dir('2dseq');
filesize = d.bytes;
image_size = matrix_size^2;
n_images = filesize/(matrix_size^2*2*n_slices);

fid=fopen('2dseq','r'); 

I = zeros(matrix_size,matrix_size,n_images);

if verbose
        disp(['Reading images in ' pathname]);
end

tic;
for i = 1:n_images,
        vol_offset 	= 2*n_slices*image_size*(i-1);	  
        slice_offset 	= 2*image_size*(n_slice-1);  
        fseek(fid,vol_offset+slice_offset,'bof');
        I(:,:,i) = reshape(fread(fid,image_size,'ushort'),matrix_size,matrix_size)';
end
elapsed_time = toc;

if verbose
        disp(['Read slice ' num2str(n_slice) ', ' num2str(n_images),' images in ' num2str(elapsed_time) ' sec']);
end

fclose(fid);
cd(ini_dir);

info = [pathname ' sl. ' num2str(n_slice) ' of ' num2str(n_slices) ': ' num2str(n_images) ' images'];


