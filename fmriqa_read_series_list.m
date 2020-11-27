function ser = fmriqa_read_series_list(varargin)
% fmriqa_read_series_list	- read series list in different formats
%--------------------------------------------------------------------------------
% Input(s): 	varargin        - see usage
% Output(s):	ser             - ser structure (see code)
% Usage:	ser = fmriqa_read_series_list(4,Gutalin,2,0);
% Called by:    fmriqa_process_series
% Calls:        none
% 
% Written by Igor Kagan					 
% igor at vis.caltech.edu
% http://igoresha.virtualave.net
%
% History of changes
% 12.12.06	wrote it
%
% See also FMRIQA_PROCESS_SERIES.
%--------------------------------------------------------------------------------

if nargin == 1, 	% get series data from txt file 

	serieslist = varargin{1};

elseif nargin == 4,	% process all series in directory with same parameters

	dirname		= varargin{1};	% directory to process
	n_slice 	= varargin{2};	% 
	n_slices 	= varargin{3};	% 
	n_skip 		= varargin{4};	%

	cd(dirname);

	d = dir;

	k = 0;
	for i=3:size(d,1),

		if d(i).isdir == 1 && ~strcmp(d(i).name,'anat') && ~strcmp(d(i).name(1:3),'ani')
                        if exist([d(i).name filesep 'im0001'],'file') || exist([d(i).name filesep 'im00001'],'file') || exist([d(i).name filesep 'im000001'],'file'),
                                k = k + 1;
                                ser(k).pathname		= [dirname filesep d(i).name];
                                ser(k).n_slice		= n_slice;
                                ser(k).n_slices		= n_slices;
                                ser(k).n_skip		= n_skip;
                                
                                
                        elseif ~isempty(dir([d(i).name filesep '*.dcm']));
                                k = k + 1;
                                ser(k).pathname		= [dirname filesep d(i).name];
                                ser(k).n_slice		= n_slice;
                                ser(k).n_slices		= n_slices;
                                ser(k).n_skip		= n_skip; 
				
			elseif exist([d(i).name filesep 'MRIm0001'],'file') || exist([d(i).name filesep 'MRIm00001'],'file') || exist([d(i).name filesep 'MRIm000001'],'file'),
				
				k = k + 1;
                                ser(k).pathname		= [dirname filesep d(i).name];
                                ser(k).n_slice		= n_slice;
                                ser(k).n_slices		= n_slices;
                                ser(k).n_skip		= n_skip;
                            
                            
                        end
		end

	end

elseif nargin == 6 || nargin == 7,	% process all Bruker 2dseq in multiple directories

	dirname		= varargin{1};	% base directory to process
	n_slice 	= varargin{2};	% 
	n_slices 	= varargin{3};	% 
	n_skip 		= varargin{4};	%
	matrix_size	= varargin{5};	%
	dir_list	= varargin{6};	%

	if nargin == 7,
		reco_dir 	= varargin{7};	
	else
		reco_dir 	= '1';
	end

	for k=1:length(dir_list),

		ser(k).pathname		= [dirname filesep num2str(dir_list(k)) filesep 'pdata' filesep reco_dir filesep];
		ser(k).n_slice		= n_slice;
		ser(k).n_slices		= n_slices;
		ser(k).n_skip		= n_skip;
		ser(k).matrix_size	= matrix_size;

	end


else			% Get data from Excel table ScanSeriesLog.xls | "Topic"


	N 	= varargin{1};		% total number of series
	Topic 	= varargin{2};		% excel sheet name
	ro 	= varargin{3};		% row offset (number of the Excel row of the first series)
	

	channel = ddeinit('Excel',Topic);
	format = [1 1];


	for i=1:N	
		ser(i).pathname		=	 (ddereq(channel, ['r',num2str(i-1+ro),'c1:r',num2str(i-1+ro),'c1'],format));
		ser(i).pathname 	=	 ser(i).pathname(1:end-1);

		ser(i).n_slice	= str2num(ddereq(channel, ['r',num2str(i-1+ro),'c2:r',num2str(i-1+ro),'c2'],format));
		ser(i).n_slices	= str2num(ddereq(channel, ['r',num2str(i-1+ro),'c3:r',num2str(i-1+ro),'c3'],format));
		ser(i).n_skip	= str2num(ddereq(channel, ['r',num2str(i-1+ro),'c4:r',num2str(i-1+ro),'c4'],format));
	end

	rc = ddeterm(channel);




end
