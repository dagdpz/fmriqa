function fmriqa_roi_dicom_series_memeff
% fmriqa_roi_dicom_series_memeff	- read one slice from dicom series, memory efficient way
%--------------------------------------------------------------------------------
% Input(s): 	none
% Output(s):	none
% Usage:	fmriqa_roi_dicom_series_memeff;
% Called by:    none
% Calls:        none
% 
% Written by Igor Kagan					 
% igor at vis.caltech.edu
% http://igoresha.virtualave.net
%
% History of changes
% 12.12.06	wrote it
%
% See also FMRIQA_PROCESS_SERIES, FMRIQA_READ_SLICE_DICOM_SERIES.
%--------------------------------------------------------------------------------

% open first image in series
[filename, pathname] = uigetfile('*.*', 'Please select first files in the series');
if filename == 0, return; end;
ini_dir = pwd;
cd(pathname);

% read first image
info = dicominfo(filename);
I = dicomread(info);


% define roi on first image
figure
imshow(I,[]);

[roi_image,rect] = fmriqa_rroi;
% rect: [XMIN YMIN WIDTH HEIGHT]
roi_x = [rect(1) rect(1)+rect(3) rect(1)+rect(3) rect(1) rect(1)]; % clockwise 
roi_y = [rect(2) rect(2) rect(2)+rect(4) rect(2)+rect(4) rect(2)];
text(rect(1)+10,rect(2)+10,'roi-1','Color','b','FontSize',7);

h_roi(1)=line(roi_x,roi_y,'Color','b','LineWidth',0.5);

drawnow;

% find all images in dir
d = dir('*');
tempstr = {d.name}; 
filenames = char(tempstr(3:end)');
n_images = size(filenames,1);

n_slices = 16;
n_slice = 1;
n_images = n_images/n_slices;
filenames = filenames(n_slice:n_slices:end,:);

ROI = zeros(size(roi_image,1), size(roi_image,2),n_images);

for i = 1:n_images,
        %I = peaks(128) + rand(128,128);
        info = dicominfo(filenames(i,:));
        I = dicomread(info);
        [roi_image,rect] = imcrop(I,rect);
        ROI(:,:,i) = roi_image;
end



ROI_timecourse(1:n_images) = mean(mean(ROI));
ROI_mean    = mean(ROI_timecourse);
ROI_std     = std(ROI_timecourse);

figure;
plot(ROI_timecourse);

cd(ini_dir);