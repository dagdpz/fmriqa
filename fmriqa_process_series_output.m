function fmriqa_process_series_output(in1);
% fmriqa_process_series_output	- display output of fmriqa_process_series
%--------------------------------------------------------------------------------
% Input(s): 	in1
% Output(s):	none
% Usage:	fmriqa_process_series_output(in1);
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
% See also PROCESS_SERIES.
%--------------------------------------------------------------------------------

n_series = size(in1,2);

for i = 1:n_series,
	disp(sprintf('%0.3f\t%0.3f',in1(i).roi_tc_rmsd,in1(i).roi_tc_p2p));
end


