function [motionperiods] = fmriqa_find_motion(ROI_timecourse, ROI_timecourse_drift, stableROI, settings)    
% fmriqa_find_motion	- find periods contaminated by subject motion in time-series
%--------------------------------------------------------------------------------
% Input(s): 	ROI_timecourse
%               ROI_timecourse_drift
%               stableROI
%               settings
% Output(s):	motionperiods    - motionperiods
% Usage:	[motionperiods] = fmriqa_find_motion(ROI_timecourse, ROI_timecourse_drift, stableROI, settings);
% Called by:    fmriqa_roi_series
% Calls:        subfunction
%
% Written by Asha Iyer and Igor Kagan					 
% igor at vis.caltech.edu
% http://igoresha.virtualave.net
%
% History of changes
% 12.12.06	wrote it
%
% See also FMRIQA_ROI_SERIES.
%--------------------------------------------------------------------------------


% % %% Filter the epi signal (low-pass filter options) to get a cleaner trace.
% % %% Plot filter epi.
% % 
% % %filt = [1 4 6 4 1]./sum(filt);
flen=13; % filter length for calculating running ave (samples)
rav=ones(1,flen)./flen;
blur_filt = rav;
% % % % epi = clean_convolve (ROI_timecourse, blur_filt);
% % % 
% % % 
% % % %[B, A] = cheby2 ( 1,3, 0.06);		% Tiefpa�filter 2.Ordn. 60Hz
% % % %epi=filtfilt(B,A,epi);
% % 
% % diff_filt = [-1 0 1];
% % filt = conv (blur_filt, diff_filt);
% % %d_epi = clean_convolve (ROI_timecourse, filt);


%% Take diff of epi signal and filter it to get a smoother derivative
%% trace.
epi = ROI_timecourse;
d_epi = diff(epi);

plot(d_epi); hold on;

% [B, A] = cheby2 ( 2,20, 0.06);	
% d_epi=filtfilt(B,A,d_epi);
d_epi = clean_convolve(abs(d_epi), blur_filt);
%d_epi = clean_convolve (d_epi, blur_filt);

plot(d_epi,'k'); hold on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Detect Events via Velocity:
prctile_thresh = 65;  % larger threshold includes more of the full range  98
stdev_thresh = 1;  % larger includes more as ok                        .90      

vthresh = pick_thresh(d_epi, prctile_thresh, stdev_thresh);
tV = vthresh(2);

VV(1:length(d_epi))=nan;
VVo=find(d_epi>tV);
VVu=find(d_epi<-tV);
VV(VVo)=tV;
VV(VVu)=-tV;

line([1 length(d_epi)],[tV tV],'Color','g');

nomotion(1:length(d_epi))=nan;
okinds = find(d_epi<tV & d_epi>-tV);
nomotion(okinds) = tV;

nomotioninds = find(~isnan(nomotion));


breaks = find((diff(nomotioninds))>1);
stops = nomotioninds(breaks);
starts = nomotioninds(breaks+1);


if stops(1)<starts(1)
        starts = [nomotioninds(1) starts];
end

if starts(end)>stops(end)
        stops = [stops nomotioninds(end)];
end





plot(nomotion, 'm');
%%%%plot(d_epi,'k');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define starts and stops of ok periods; throw out periods that are
%% shorter than 2 seconds
minperlength = 0;  %15;



if length(starts)~=length(stops)
        error('mismatched periods')
else
        perplot(1:length(epi))=nan;
        p = 1;
        
        for i = 1:length(starts)
                if stops(i)-starts(i)>minperlength
                        periods(p,:) = [starts(i)+1 stops(i)-1];
                        perplot(starts(i)+1:stops(i)-1)= tV;
                        p = p+1;
                else
                        periods(p,:) = [starts(i) stops(i)];
                        perplot(starts(i):stops(i))= tV;
                        p = p+1;
                end
                
        end
end

m = 1;
for i = 1:size(periods,1)
        if i==1
                if periods(i) > 1
                        motionperiods(m,:) = [1 periods(i,1)];
                        m = m + 1;
                end
        else       
                motionperiods(m,:) = [periods(i-1,2) periods(i,1)];
                m = m + 1;
        end
end


if periods(size(periods,1),2) < length(perplot)
        motionperiods(m,:) = [periods(size(periods,1),2) length(perplot)];
        
end  


%%%%  For a purely adaptive relative detection based on velocity, use just
%%%%  velocity criteria.  Otherwise, also use absolute change in intensity.
if 1
        
        %         intens_thresh = .05;
        switch settings.monkey
                case 'RE'
                        intense_range = 160;
                case 'GU'
                        intense_range = 115;
                case 'FL'
                        intense_range = 115;
                case 'HA'
                        intense_range = 160;                                
                case ''
                        intense_range = settings.default_intensity_range;
        end
        newinds = [];
        for m = 1:size(motionperiods,1)
                spike = stableROI(motionperiods(m,1):motionperiods(m,2));  %  or should spike be taken from epi?
                
                %                 if m == 1
                %                         bl = ROI_timecourse_drift(1:motionperiods(m,2));
                %                 else
                %                         bl = ROI_timecourse_drift(motionperiods(m-1,2):motionperiods(m,2));
                %                 end
                
                %                 % option 1: works well with Redrik, but doesn't catch a lot
                %                 % of Gutalin's motion
                %                 intens_base = mean(bl);
                %                 tDtop = intens_base + intens_thresh * intens_base;
                %                 tDbottom = intens_base - intens_thresh * intens_base;
                % %                 if ~isempty(find(spike < tDbottom | spike > tDtop))
                % %                         newinds = [newinds m];
                % %                 end
                %                 % option 2:
                
                if (max(spike)- min(spike))> intense_range  
                        newinds = [newinds m];
                end
        end
        
        motionperiods = motionperiods(newinds, :);
        
end

DD = ones(1,length(epi));
for m = 1:size(motionperiods,1)
        DD(motionperiods(m,1):motionperiods(m,2)) = nan;
end


plot(DD, 'r','LineWidth',2);

%% Return the amount of the run that was included as acceptable

usable = length(find(~isnan(perplot)))/length(perplot) *100;
usableDD = length(find(~isnan(DD)))/length(DD) *100;
title([ num2str(usable,3) '%-->' num2str(usableDD,3) '% of run contains acceptably minimal motion'])



function y = clean_convolve (x,filt)

npad = (length(filt) - 1)/2;

lpad = ones(1,npad)*mean(x(1:npad));
rpad = ones(1,npad)*mean(x((npad+1:end):end));

padx = [lpad x rpad];

y = convn(padx, filt, 'valid');

if length(x) ~= length(y)
        error('convolution gone bad...')
end

function t = pick_thresh(velocity, prctile_thresh, stdev_thresh)

prctile_cutoff = prctile(velocity, prctile_thresh);
vel_cutoff = velocity(velocity < prctile_cutoff);

vel_stdev = std(vel_cutoff);
vel_mean = mean(vel_cutoff);

t = vel_mean + vel_stdev * [-stdev_thresh stdev_thresh];
