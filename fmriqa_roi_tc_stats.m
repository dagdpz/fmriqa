function out1 = fmriqa_roi_tc_stats(ROI_timecourse)
% fmriqa_roi_tc_stats	- ROI timecourse statistics
%--------------------------------------------------------------------------------
% Input(s): 	ROI_timecourse
% Output(s):	out1            - out1 structure (see code)
% Usage:	out1 = fmriqa_roi_tc_stats(ROI_timecourse);
% Called by:    fmriqa_roi_series
% Calls:        none
% 
% Written by Igor Kagan					 
% igor at vis.caltech.edu
% http://igoresha.virtualave.net
%
% History of changes
% 12.12.06	wrote it
%
% See also ROI_SERIES.
%--------------------------------------------------------------------------------
ROI_mean    = mean(ROI_timecourse);
ROI_std     = std(ROI_timecourse);
ROI_max     = max(ROI_timecourse);
ROI_min     = min(ROI_timecourse);

RMSD = ROI_std/(ROI_mean/100);
P2P   = (ROI_max - ROI_min)/ROI_min;


out1.roi_tc_mean   = ROI_mean;
out1.roi_tc_std    = ROI_std;
out1.roi_tc_max    = ROI_max;
out1.roi_tc_min    = ROI_min;
out1.roi_tc_rmsd   = RMSD;
out1.roi_tc_p2p    = P2P;