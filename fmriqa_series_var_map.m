function [out1] = fmriqa_series_var_map(I,n_skip,mask,interactive_roi,interactive_snr,info,custom_info)
% fmriqa_series_var_map 	- analyze image series statistics
%--------------------------------------------------------------------------------
% Input(s): 	I       - image
% Output(s):	out1    - output structure (see code)
% Usage:	[out1] = fmriqa_series_var_map(I,n_skip,mask,interactive,info,custom_info);
% Called by:    none
% Calls:        none
%
% Written by Igor Kagan
% igor at vis.caltech.edu
% http://igoresha.virtualave.net
%
% History of changes
% 12.12.06	wrote it (IK)
% 05.08.18	updated
%
% See also FMRIQA_ROI_SERIES.
%--------------------------------------------------------------------------------

if nargin < 2
    n_skip = 0;
end

if nargin < 3
    mask = 0;
end

if nargin < 4
    interactive_roi = 0;
end

if nargin < 5
    interactive_snr = 0;
end

if nargin < 6
    info = ' ';
end

if nargin < 7
    custom_info = '';
end


cmap = 'jet';
FS = 7;

% define roi on first image
hf = figure('Name',info,'Position',[100 100 1200 1000]);


ha1 = subplot(2,3,1);
imshow(I(:,:,1),[]);
n_images = size(I,3);
matrix_size = size(I,1);
ms = size(I(:,:,1));

colormap(ha1,cmap);

if n_skip,
    info = [info ' ' num2str(n_skip) ' skipped '];
end

ht = title([custom_info '  ' info ' | ' num2str(matrix_size) 'x' num2str(matrix_size)],'interpreter','none','FontSize',FS);
set(ht,'LineWidth',5,'Position',[matrix_size -matrix_size/10 0]);
hc1 = colorbar('horiz');

if interactive_roi
    [roi_image,rect] = fmriqa_rroi;

    % rect: [XMIN YMIN WIDTH HEIGHT]
    roi_x = [rect(1) rect(1)+rect(3) rect(1)+rect(3) rect(1) rect(1)]; % clockwise
    roi_y = [rect(2) rect(2) rect(2)+rect(4) rect(2)+rect(4) rect(2)];
    text(rect(1)+10,rect(2)+10,'roi-1','Color','b','FontSize',7);

    h_roi(1)=line(roi_x,roi_y,'Color','b','LineWidth',0.5);

    drawnow;


    ROI = zeros(size(roi_image,1), size(roi_image,2),n_images);

    for i = 1:n_images,

        [roi_image,rect] = imcrop(I(:,:,i),rect);
        ROI(:,:,i) = roi_image;
    end

    I = ROI;
    clear ROI;

    ms = size(I(:,:,1));

end


if mask,

    ha2 = subplot(2,3,2);

    if 0, % 3D mask

        I = I.*(I>mask);

    else % 2D mask

        [k_mask] = find(I(:,:,1) > mask); 		% object
        [k_nomask] = find(I(:,:,1) <= mask);		% background

        I(ind2sub(ms,k_nomask)) = 0;
    end

    imshow(I(:,:,1),[]);
    ht = xlabel(['Masked with threshold  ' num2str(mask)],'interpreter','none');
    hc2 = colorbar('horiz');

end


if n_skip,
    I = I(:,:,n_skip+1:end);
end



mean_vox 	= mean(I,3);
std_vox 	= ig_std(I,3);
rmsd_vox 	= std_vox./(mean_vox/100+eps);
snr_vox 	= mean_vox./(std_vox);
snr_vox(isnan(snr_vox))=0;
snr_vox(isinf(snr_vox))=0;
prctile99 = prctile(snr_vox(:),99);
snr_vox(snr_vox>prctile99)=prctile99;


if mask
    mean_vox(ind2sub(ms,k_nomask)) = 0;
    std_vox(ind2sub(ms,k_nomask)) = 0;
    rmsd_vox(ind2sub(ms,k_nomask)) = 0;
    snr_vox(ind2sub(ms,k_nomask)) = 0;

    mean_rmsd = mean(mean(rmsd_vox(ind2sub(ms,k_mask))));
    mean_snr = mean(mean(snr_vox(ind2sub(ms,k_mask))));
else
    mean_rmsd 	= mean(mean(rmsd_vox));
    mean_snr        = mean(mean(snr_vox));
end

ha3 = subplot(2,3,3);
imshow(mean_vox,[]);
colormap(ha3,cmap);
hc3 = colorbar('horiz');
title(['MEAN per voxel (over time)'],'FontSize',FS);


ha4 = subplot(2,3,4);
if sum(sum(std_vox)), imshow(std_vox,[]); end;
colormap(ha4,cmap);
hc4 = colorbar('horiz');
title(['STD per voxel (over time)'],'FontSize',FS);

ha5 = subplot(2,3,5);
if sum(sum(std_vox)), imshow(rmsd_vox,[]); end;
colormap(ha5,cmap);
hc5 = colorbar('horiz');
title(['RMSD per voxel, mean RMSD ' num2str(mean_rmsd,2) ' %'],'FontSize',FS);

ha6 = subplot(2,3,6);
if sum(sum(std_vox)), imshow(snr_vox,[]); end;
colormap(ha6,cmap);
hc6 = colorbar('horiz');
title(['SNR per voxel (over time), mean SNR ' num2str(mean_snr,2) ' %'],'FontSize',FS);

out1 = [];

%u1 = uicontextmenu;
%u11 = uimenu(u1,'Label','SNR','Separator','off','Callback');

if 0 % k-space

    ha2 = subplot(2,3,2);

    ks_mean_vox = fftshift(ifft(fftshift(mean_vox)));
    imshow(real(ks_mean_vox),[]);
    colormap(ha2,cmap);
    hc2 = colorbar('horiz');
    title(['k-space MEAN per voxel'],'FontSize',FS);

end


set(gcf,'CurrentAxes',ha1);


if interactive_snr > -1, % SNR
    out_snr = fmriqa_two_roi_snr(I(:,:,1),interactive_snr);
    % text(matrix_size + matrix_size/2,1,['SNR: ' num2str(out_snr.snr,2)],'Color',[0 0.5 0.5],'FontSize',12);
else
    out_snr.std2 = 1;
end


if 1 % SNR map per voxel

    ha2 = subplot(2,3,2);

    imshow(mean_vox/out_snr.std2,[]);
    colormap(ha2,cmap);
    hc2 = colorbar('horiz');
    title(['SNR map (mean_{vox}/std_{roi2})'],'FontSize',FS);

end

set([ha1 ha2 ha3 ha4 ha5 ha6]','tickdir','out','layer','top','xcolor','y','Xgrid','on','Ygrid','on','FontSize',7);

	




