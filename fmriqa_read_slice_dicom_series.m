function [I,info] = fmriqa_read_slice_dicom_series(n_slice,n_slices,pathname,verbose,chan,force_not_mosaic)
% fmriqa_read_slice_dicom_series	- read one slice from dicom series
%--------------------------------------------------------------------------------
% Input(s): 	varargin        - see usage
% Output(s):	ser             - ser structure (see code)
% Usage:	[I,info] = fmriqa_read_slice_dicom_series(ser(i).n_slice,ser(i).n_slices,ser(i).pathname,1);
% Called by:    fmriqa_process_series
% Calls:        none
% 
% Written by Igor Kagan					 
% igor at vis.caltech.edu
% http://igoresha.virtualave.net
%
% History of changes
% 12.12.06	wrote it
% 05.08.18	updated MOSAIC_DIM
%
% See also PROCESS_SERIES.
%--------------------------------------------------------------------------------
warning off Images:genericDICOM

ini_dir = pwd;
if nargin < 3,
        
        % select path of series
        [filename, pathname] = uigetfile({'im*;*.dcm;MRIm*'}, 'Please select first file in the series');
        if filename == 0, return; end;	
end

if nargin < 4,
        verbose = 1;
end

if nargin < 5,
	chan = ''; % all channels or individual channel for the Rx coil?
end

if nargin < 6,
	force_not_mosaic = 0;
end


MOSAIC_DIM = 300; % images with size < MOSAIC_DIM will be considered non-mosaic

cd(pathname);

filenames = dir(['im' chan '*']);
if isempty(filenames)
        filenames = dir(['*' chan '.dcm']);
end
if isempty(filenames)
        filenames = dir(['*' chan '.ima']);
end
if isempty(filenames)
	filenames = dir(['MRIm' chan '*']);
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

n_slices_mosaic = 0;
if info.Width <= MOSAIC_DIM || force_not_mosaic, % NOT MOSAIC DICOM from TRIO, where each image - one composite volume
        
	if isempty(n_slice) % read all slices, combine in mosaic
		n_slices_mosaic = ceil(sqrt(n_slices));
		n_images = n_images/n_slices;
	else % read only one slice
		
		n_images = n_images/n_slices;
		filenames = filenames(n_slice:n_slices:end,:);
	end
        
end

if verbose
        disp(['Reading images in ' pathname]);
end

tic;
if n_slices_mosaic,
	k = 1;
	I = zeros(size(I1,1)*n_slices_mosaic, size(I1,2)*n_slices_mosaic,n_images);
	s1 = size(I1,1);
	s2 = size(I1,2);
	
	for i = 1:n_images,
		
		row_mosaic = 1;
		col_mosaic = 1;
		for s = 1:n_slices
			info = dicominfo(filenames(k).name);
			I1 = dicomread(info);
			I( (row_mosaic-1)*s1+1:row_mosaic*s1 , (col_mosaic-1)*s2+1:col_mosaic*s2 , i ) = I1;
			col_mosaic = col_mosaic + 1;
			if col_mosaic>n_slices_mosaic,
				col_mosaic = 1;
				row_mosaic = row_mosaic + 1;
			end
			k = k+1;
		end
	end
	
else
	I = zeros(size(I1,1), size(I1,2),n_images);
	for i = 1:n_images,
		info = dicominfo(filenames(i).name);
		I1 = dicomread(info);
		I(:,:,i) = I1;
	end
end

elapsed_time = toc;

if verbose && (info.Width <= MOSAIC_DIM || force_not_mosaic) && ~n_slices_mosaic,
	disp(['Read slice ' num2str(n_slice) ', ' num2str(n_images),' images in ' num2str(elapsed_time) ' sec']);
elseif n_slices_mosaic,
        disp(['Read all slices and created MOSAIC, using ' num2str(n_images),' images in ' num2str(elapsed_time) ' sec']);
else
        disp(['Read ALL MOSAIC slices, ', num2str(n_images),' images in ' num2str(elapsed_time) ' sec']);        
end




cd(ini_dir);

info = [pathname ' sl. ' num2str(n_slice) ' of ' num2str(n_slices) ': ' num2str(n_images) ' images'];


