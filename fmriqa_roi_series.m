function [out1] = fmriqa_roi_series(I,n_skip,info,custom_info,interactive, settings, options)
% fmriqa_roi_series	- analyze ROI in time-series
%--------------------------------------------------------------------------------
% Input(s): 	I       - image
% Output(s):	out1    - output structure (see code)
% Usage:	out1(i) = fmriqa_roi_series(I,ser(i).n_skip,info,custom_info,0, settings, options);
% Called by:    fmriqa_process_series
% Calls:        fmriqa_rroi, fmriqa_two_roi_snr, fmriqa_roi_tc_stats
%
% Written by Igor Kagan					 
% igor at vis.caltech.edu
% http://igoresha.virtualave.net
%
% History of changes
% 12.12.06	wrote it
%
% See also FMRIQA_PROCESS_SERIES, FMRIQA_ROI.
%--------------------------------------------------------------------------------
if nargin < 2
        n_skip = 0;
end


if nargin < 3
        info = ' ';
end

if nargin < 4
        custom_info = '';
end

if nargin < 5
        interactive = 1;
end

if nargin < 6
        settings.default_intensity_range = 200;
        settings.monkey = '';
end

if nargin < 7
        options.motion_processing 	= 0;
        options.add_behavioral_markers 	= 0;
        options.plot_cftc_and_md 	= 0; % plot central freq. and motion detection signals
        options.plot_mc			= 0; % motion correction parameters
end


% Defaults:

TR = 1000; % ms

if options.motion_processing & options.plot_cftc_and_md & options.plot_mc
        n_subplots = 7;
elseif (options.motion_processing & options.plot_cftc_and_md) | (options.motion_processing & options.plot_mc)
        n_subplots = 6;
elseif options.motion_processing,
        n_subplots = 5;
else
        n_subplots = 4;
end

n_subplot = 1;

% define roi on first image
hf = figure('Name',info,'Position',[50 50 800 1100]);
subplot(n_subplots,1,n_subplot);
n_subplot = n_subplot + 1;
set(gca,'Tag','image');


n_images = size(I,3);
matrix_size = size(I,1);

% if matrix_size > 256 % MOSAIC DICOM, 3T
% 	
% 	switch matrix_size
% 		
% 		
% 		case 400 % (80x5)
% 			% 
% 		otherwise
% 			
% 			% meanwhile choose slice 16: 6x6 => 4th column, 3d row
% 			I = I(64*3:64*3+64,64*2:64*2+64,:);
% 			matrix_size = 64;
% 			
% 	end
% 	TR = 2000; % ms
% 	
% end

imshow(I(:,:,n_skip+1),[]);

ht = title([custom_info '  ' info ' | ' num2str(matrix_size) 'x' num2str(matrix_size) ' im #' num2str(n_skip+1)],'interpreter','none');


if interactive
        [roi_image,rect] = fmriqa_rroi;
else
        if matrix_size == 128,
                rect = [40 40 48 48];
                % rect = [40 25 48 48];
                % rect = [50 80 28 28];
                % rect = [50 50 28 28];
                % rect = [55 45 28 28];
        elseif matrix_size == 64,
                rect = [20 20 24 24];
                % rect = [20 13 24 24];
        elseif matrix_size == 96,
                rect = [30 30 36 36];
        end
        
        [roi_image,rect] = fmriqa_rroi('new_roi_noninteractive',I(:,:,1),rect);
        
end

% rect: [XMIN YMIN WIDTH HEIGHT]
roi_x = [rect(1) rect(1)+rect(3) rect(1)+rect(3) rect(1) rect(1)]; % clockwise
roi_y = [rect(2) rect(2) rect(2)+rect(4) rect(2)+rect(4) rect(2)];
text(rect(1)+10,rect(2)+10,'roi-1','Color','b','FontSize',7);

h_roi(1)=line(roi_x,roi_y,'Color','b','LineWidth',0.5);

if 0 % SNR
        out_snr = fmriqa_two_roi_snr(I(:,:,n_skip+1),interactive);
        text(matrix_size + matrix_size/2,1,['SNR: ' num2str(out_snr.snr,2)],'Color',[0 0.5 0.5],'FontSize',12);
end

drawnow;


ROI = zeros(size(roi_image,1), size(roi_image,2),n_images);

for i = 1:n_images,
        
        [roi_image,rect] = imcrop(I(:,:,i),rect);
        ROI(:,:,i) = roi_image;
end



ROI_timecourse(1:n_images) = mean(mean(ROI));

if n_skip,
        ROI_timecourse = ROI_timecourse(n_skip+1:end);
end

out1 = fmriqa_roi_tc_stats(ROI_timecourse);


subplot(n_subplots,1,n_subplot);
n_subplot = n_subplot + 1;

plot(ROI_timecourse); hold on

if interactive
        disp(['RMSD ', num2str(out1.roi_tc_rmsd), '  P2P ', num2str(out1.roi_tc_p2p)]);
end

title(['RMSD ', num2str(out1.roi_tc_rmsd), '  P2P ', num2str(out1.roi_tc_p2p)]);
set(gca,'XTickLabel',[]);

out1.roi_timecourse = ROI_timecourse;
out1.info = info;
out1.custom_info = custom_info;


if 1
        
        % low-pass filter
        Wn = 0.1;   % cutoff freq. 1 - 0.5 Hz, 0.1 - 0.05 Hz
        [b,a] = cheby1(9,0.1,Wn);
        ROI_timecourse_drift = filtfilt(b,a,ROI_timecourse);
        
        plot(ROI_timecourse_drift,'r');
        
        if 1
                subplot(n_subplots,1,n_subplot);
                n_subplot = n_subplot + 1;
                ROI_timecourse_nodrift = ROI_timecourse - ROI_timecourse_drift;
                stableROI = ROI_timecourse_nodrift + out1.roi_tc_mean;
                plot(stableROI);
                Ylim = get(gca,'Ylim');
                set(gca,'Ylim',[Ylim(1) Ylim(2)]);
                
                out1_nodrift = fmriqa_roi_tc_stats(stableROI);
                title(['filtered at ' num2str(Wn*0.5) 'Hz: RMSD ', num2str(out1_nodrift.roi_tc_rmsd), '  P2P ', num2str(out1_nodrift.roi_tc_p2p)]);
                set(gca,'XTickLabel',[]);
        end
        
end


% slash_idx = findstr(info,'\');
slash_idx = findstr(info,filesep);
session_path = info(1:slash_idx(end));
[pathname,filename,ext] = fileparts(session_path(1:end-1));
run_name = info(slash_idx(end)+1:slash_idx(end)+4); %!!! only 9 runs per day are allowed for this very important reason !!!
% save([pathname filesep run_name '_timecourse.mat'],'ROI_timecourse','ROI_timecourse_nodrift', '-mat');


if options.motion_processing,  % monkey/human motion processing
        subplot(n_subplots,1,n_subplot);
        n_subplot = n_subplot + 1;
        motion_periods = fmriqa_find_motion(ROI_timecourse, ROI_timecourse_drift, stableROI, settings);
        %find_motion_new(ROI_timecourse, ROI_timecourse_drift, stableROI, monkey);
        
        save([pathname filesep run_name '_motion.mat'],'motion_periods','-mat');
        
        
        if options.add_behavioral_markers,	% add behavioral markers from protocols
                % all im* should be in im by this time
                ini_dir = pwd;
                cd(info(1:slash_idx(end-1)));
                
                ivent_matfile = dir(['*' run_name '.mat']);
                if length(ivent_matfile)==1,
                        ivent_settings = load(ivent_matfile.name);
                        TR = ivent_settings.settings.TR; % fix(ivent_settings.settings.TR/1000)*1000;
                end
                
                if exist([info(1:slash_idx(end-1)) filesep 'prtrtc']) ~= 7,
                        cd(['prtrtc_special_timing' filesep 'beforemotionremoved']);
                else
                        cd(['prtrtc' filesep 'beforemotionremoved']);
                end
                
                d = dir(['*' run_name '*foravg.prt']);
                
                if length(d)==1,
                        disp(['Found ' d.name ' in ' info(1:slash_idx(end-1))]);
                        
                        prtpreds = read_prt(d.name, 1, 0);
                        
                        i1 = strmatch('fix_dir_',{prtpreds.name});
                        i2 = strmatch('mem_',{prtpreds.name});
                        i3 = strmatch('rew',{prtpreds.name});
                        
                        onset = []; offset = [];
                        for i = 1:length(i1)
                                onset = [onset prtpreds(i1(i)).onset];
                                offset = [offset prtpreds(i1(i)).offset];
                        end
                        i1_onset = onset./TR;
                        i1_offset = offset./TR;
                        
                        onset = []; offset = [];
                        for i = 1:length(i2)
                                onset = [onset prtpreds(i2(i)).onset];
                                offset = [offset prtpreds(i2(i)).offset];
                        end
                        i2_onset = onset/TR;
                        i2_offset = offset/TR;
                        
                        onset = []; offset = [];
                        for i = 1:length(i3)
                                onset = [onset prtpreds(i3(i)).onset];
                                offset = [offset prtpreds(i3(i)).offset];
                        end
                        i3_onset = onset./TR;
                        i3_offset = offset./TR;
                        
                        hold on;
                        ylim = get(gca,'Ylim');
                        
                        if ~isempty(i1) & ~isempty(i1_onset)
                                plot(i1_offset,ylim(1),'rv');
                        end
                        if ~isempty(i2) & ~isempty(i2_onset)
                                plot(i2_offset,ylim(1),'bv');
                        end
                        if ~isempty(i3) & ~isempty(i3_onset)
                                plot(i3_onset,ylim(1),'bd','MarkerFaceColor',[0 0 1]);
                        end
                        
                end
                
                cd(ini_dir);
                set(gca,'XTickLabel',[]);
        end
        
        
end

cd(pathname);

if options.plot_cftc_and_md,
        Xlim = get(gca,'Xlim');
        
        % This is cf_tc plot and MD plot
        subplot(n_subplots,1,n_subplot)
        n_subplot = n_subplot + 1;
        
        
        
        
        d = dir(['*' run_name '_channels.mat']);
        if length(d)==1,
                load(d.name,'-mat');
                md = data(:,2);
                plot([Xlim(1):0.001:Xlim(1)+0.001*(length(md)-1)]/(TR/1000),md,'Color',[0.5020         0    1.0000]); hold on;
                
                if size(data,2) >= 7,
                        lickdata = data(:,7);
                        plot([Xlim(1):0.001:Xlim(1)+0.001*(length(lickdata)-1)]/(TR/1000),-lickdata,'Color',[0         0.8    1.0000]); hold on;
                end
        end
        
        
        
        if exist([run_name '.dat']) == 2,
                cf_tc = fmriqa_read_cftc([run_name '.dat']);
                plot(cf_tc.x(n_skip+1:end)-n_skip+1,cf_tc.y(n_skip+1:end),'k');
        end
        
        set(gca,'Xlim',[Xlim(1) Xlim(1) + 0.001*(length(md)-1)]/(TR/1000));
        
end


if options.plot_mc, % MC files should be copied to session root
        
        subplot(n_subplots,1,n_subplot)
        n_subplot = n_subplot + 1;
        
    
        d = dir(['*' run_name '*_3DMC.rtc']);
        if length(d)==1,
                [nline]=plot_MC_onefile(d.name,0);
                plot(nline);
                legend('X t','Y t','Z t','X r','Y r','Z r',0);
        end
        
        
end


% This is full scale roi time-course
subplot(n_subplots,1,n_subplot)
n_subplot = n_subplot + 1;
plot(ROI_timecourse);
Ylim = get(gca,'Ylim');
set(gca,'Ylim',[0 Ylim(2)]);
xlabel('volume');

drawnow;



