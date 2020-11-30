function out1 = fmriqa_two_roi_snr(I,interactive)
% fmriqa_two_roi_snr	- estimate SNR in predefined ROIs 
%--------------------------------------------------------------------------------
% Input(s): 	I       - image
% Output(s):	out1    - output structure (see code)
% Usage:	out1 = fmriqa_two_roi_snr(I)
% Called by:    fmriqa_roi_series
%
% Written by Igor Kagan					 
% igor at vis.caltech.edu
% http://igoresha.virtualave.net
%
% History of changes
% 12.12.06	wrote it
%
% See also FMRIQA_ROI_SERIES, FMRIQA_ROI.
%--------------------------------------------------------------------------------

if nargin < 2,
        interactive = 0;
end

matrix_size = size(I,1);

if matrix_size < 64,
    matrix_size = 64;
end

switch matrix_size
	case 128,
		rect1 = [50 50 28 28];
		rect2 = [1 50 7 7];
		
	case 64,
		rect1 = [25 25 14 14];
		rect2 = [1 1 5 5];
		
	case 86,
		
		rect1 = [30 30 26 26];
		rect2 = [2 2 6 6];
		
	case 320, % mosaic 64x64x5
		center = matrix_size/2;
		rect1 = [center-20 center-20 40 40];
		rect2 = [center-39 center-39 10 10];
		
	case 384, % mosaic 64x64x6
		center = matrix_size/2 - 32;
		rect1 = [center-20 center-20 40 40];
		rect2 = [center-30 center-30 10 10];
		
	case 400, % mosaic 80x80x5
		center = matrix_size/2;
		rect1 = [center-20 center-20 40 40];
		rect2 = [center-39 center-39 10 10];
		
	case 480, % mosaic 80x80x6
		center = matrix_size/2 - 40;
		rect1 = [center-20 center-20 40 40];
		rect2 = [center-39 center-39 5 5];
        
		
	case 624, % mosaic 104x104x6
		center = matrix_size/2 - 52;
		rect1 = [center-20 center-20 40 40];
		rect2 = [center-51 center-51 10 10];
		
	case 768, % mosaic 96x96x8
		center = matrix_size/2 - 48;
		rect1 = [center-20 center-20 40 40];
		rect2 = [center-47 center-47 10 10];
		
	otherwise
		rect1 = [20 20 40 40];
		rect2 = [1 76 4 4];
		center = matrix_size/2 - 52;
		rect1 = [center-20 center-20 40 40];
		rect2 = [center-51 center-51 10 10];
end

if interactive
        [roi_image1,rect1] = fmriqa_rroi;
        [roi_image2,rect2] = fmriqa_rroi;        
else     
        [roi_image1,rect1] = fmriqa_rroi('new_roi_noninteractive',I,rect1);
        [roi_image2,rect2] = fmriqa_rroi('new_roi_noninteractive',I,rect2);
end

plot_roi(rect1,'r','1');
plot_roi(rect2,'g','2');

%mean1 = mean(mean(roi_image1));
mean1 = mean(reshape(roi_image1,size(roi_image1,1)*size(roi_image1,2),1));
mean2 = mean(reshape(roi_image2,size(roi_image2,1)*size(roi_image2,2),1));

%std1 = std(std(roi_image1));
std1 = std(reshape(roi_image1,size(roi_image1,1)*size(roi_image1,2),1));
std2 = std(reshape(roi_image2,size(roi_image2,1)*size(roi_image2,2),1));
% roi_image2
% std2

out1.mean1      = mean1;
out1.mean2      = mean2;
out1.std1       = std1;
out1.std2       = std2;
out1.snr        = mean1/std2;

% text(matrix_size + matrix_size/2,1,['SNR: ' num2str(out1.snr,2)],'Color',[0 0.5 0.5],'FontSize',12);
ylabel(['SNR: ' num2str(out1.snr,2)],'Color',[0 0.5 0.5],'FontSize',12);

function plot_roi(rect,color,textout)
roi_x = [rect(1) rect(1)+rect(3) rect(1)+rect(3) rect(1) rect(1)]; % clockwise 
roi_y = [rect(2) rect(2) rect(2)+rect(4) rect(2)+rect(4) rect(2)];
text(rect(1)+10,rect(2)+10,textout,'Color',color,'FontSize',7);

h_roi(1)=line(roi_x,roi_y,'Color',color,'LineWidth',0.5);

