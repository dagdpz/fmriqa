function [I,info] = fmriqa_read_dicom_series(n_slices,pathname,verbose);
% fmriqa_read_slice_dicom_series	- read all slices from dicom series
%--------------------------------------------------------------------------------
% Input(s): 	varargin        - see usage
% Output(s):	ser             - ser structure (see code)
% Usage:	[I,info] = fmriqa_read_dicom_series(n_slices,pathname,1);
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
% See also FMRIQA_PROCESS_SERIES.
%--------------------------------------------------------------------------------
warning off Images:genericDICOM

ini_dir = pwd;
if nargin < 2,
        
        % select path of series
        [filename, pathname] = uigetfile({'im*;*.dcm;MRIm*'}, 'Please select first file in the series');
        if filename == 0, return; end;	
end

if nargin < 3,
        verbose = 1;
end

cd(pathname);

filenames = dir('im*');
if isempty(filenames)
        filenames = dir('*.dcm');
end
if isempty(filenames)
	filenames = dir('MRIm*');
end

n_images = size(filenames,1);

if 0 % re-sort BV-renamed dicom files in the correct order, if they were renamed by BV wth unequal number of char. in the name
        for i = 1:n_images,
                
                dot_idx = findstr(filenames(i).name,'.');
                dash_idx = findstr(filenames(i).name,'-');
                dash_idx = dash_idx(end);
                str = filenames(i).name(dash_idx+1 : dot_idx-1);
                num(i) = str2num(str);
        end
        [dummy,idx] = sort(num);
        filenames = filenames(idx);
        
end % of re-sort BV-renamed dicom

% read first image
info = dicominfo(filenames(1).name);
I1 = dicomread(info);


if info.Width <= 256, % NOT MOSAIC DICOM from TRIO, where each image - one composite volume
        
        n_images = n_images/n_slices;
        filenames = filenames(n_slice:n_slices:end,:);
        
end


I = zeros(size(I1,1), size(I1,2),n_images);

if verbose
        disp(['Reading images in ' pathname]);
end

tic;
for i = 1:n_images,
        info = dicominfo(filenames(i).name);
        I1 = dicomread(info);
        I(:,:,i) = I1;
end
elapsed_time = toc;

if verbose & info.Width <= 256
        disp(['Read slice ' num2str(n_slice) ', ' num2str(n_images),' images in ' num2str(elapsed_time) ' sec']);
else
        disp(['Read ALL MOSAIC slices, ', num2str(n_images),' images in ' num2str(elapsed_time) ' sec']);        
end




cd(ini_dir);

info = [pathname ' sl. ' num2str(n_slice) ' of ' num2str(n_slices) ': ' num2str(n_images) ' images'];


