function [roi_image,rect] = fmriqa_rroi(action,varargin)
% fmriqa_rroi                  -       define rectangular roi
%--------------------------------------------------------------------------------
% Input(s): 	action          
%               varargin
% Output(s):	roi_image
%               rect
% Usage:	[roi_image,rect] = fmriqa_rroi('new_roi_noninteractive',I(:,:,1),rect);
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
% See also FMRIQA_ROI_SERIES.
%--------------------------------------------------------------------------------

if nargin < 1,
        action = 'default';
end

roi_image = [];
rect = [];

switch lower(action)
        
        case 'default'
                action = 'new_roi';
                [roi_image,rect] = fmriqa_rroi('new_roi');
        case 'new_roi'
                [roi_image,rect] = imcrop;
        case 'new_roi_noninteractive'
                I = varargin{1};
                rect = varargin{2};
                [roi_image,rect] = imcrop(I,rect);
                
        otherwise
                disp(['Unknown action: ' action]);
end


