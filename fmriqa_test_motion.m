function fmriqa_test_motion(pathname)
% fmriqa_test_motion	- test fmriqa_find_motion
%--------------------------------------------------------------------------------
% Input(s): 	pathname
% Output(s):	none
% Usage:	fmriqa_test_motion;
% Called by:    none
% Calls:        fmriqa_read_dicom_series, fmriqa_roi_series
%
% Written by Igor Kagan					 
% igor at vis.caltech.edu
% http://igoresha.virtualave.net
%
% History of changes
% 12.12.06	wrote it
%
% See also FMRIQA_FIND_MOTION.
%--------------------------------------------------------------------------------

if nargin <1
        pathname = uigetdir;
end

% these hardcoded settings should be inputs...
n_slice = 5;
n_slices = 10;
n_skip = 5;

[I,info] = fmriqa_read_dicom_series(n_slice,n_slices,pathname,1);
[out1] = fmriqa_roi_series(I,n_skip,info,'', 0);

