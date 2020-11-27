function out1 = fmriqa_process_series(varargin)
% fmriqa_process_series	- analyze ROI in multiple time-series
%--------------------------------------------------------------------------------
% Input(s): 	varargin - see usage
% Output(s):	out1    - output structure (see code)
% Usage:	out1 = fmriqa_process_series(34,'Gutalin',118); % read series info from excel file
%               out1 = fmriqa_process_series([pathname filesep 'im'],n_slice,n_slices,n_skip, options); % read DICOM series 
%               out1 = fmriqa_process_series('D:\MRI\mp_leo',n_slice,n_slices,N_skip,matrix_size,dir_list);
%               out1 = fmriqa_process_series(5,10,5); % for interactive definition of ROIs
%               dir_list is vector of runs/scans: e.g.: fmriqa_process_series('D:\MRI\mp_leo',10,17,0,64,16);
% Called by:    none
% Calls:        fmriqa_roi_series, fmriqa_read_series_list, fmriqa_read_slice_bruker_2dseq, fmriqa_read_slice_dicom_series, fmriqa_process_series_output
% 
% Written by Igor Kagan					 
% igor at vis.caltech.edu
% http://igoresha.virtualave.net
%
% History of changes
% 12.12.06	wrote it
%
% See also FMRIQA_ROI_SERIES, FMRIQA_RROI.
%--------------------------------------------------------------------------------


% default settings
custom_info = '';
bruker_2dseq = 0;

settings.monkey = '';
settings.default_intensity_range = 25; % 200 for monkeys
settings.trial_time = 12+10+5+3; %s


options.motion_processing 	= 1;
options.add_behavioral_markers 	= 0;
options.plot_cftc_and_md 	= 0; % plot central freq. and motion detection signals
options.plot_mc			= 0; % plot motion correction parameters

if isstruct(varargin{nargin}), % take care of options added in the end
        options = varargin{nargin};
        narg = nargin - 1;
else
        narg = nargin;
        
end

if narg < 1,
        mode = 'txt';
        interactive = 0;
        
        % read series data from txt filelist
        [filelistname, filelistpath] = uigetfile('*.*', 'Please select series filelist to process');
        if filelistname == 0, return; end;
        
        ser = fmriqa_read_series_list([pathname filename]);
        
elseif narg == 4 & isstr(varargin{1}), 
        
        interactive = 0;
        % process all series in the directory with same parameters
        
        dirname		= varargin{1};	% directory to process
        n_slice 	= varargin{2};	% 
        n_slices 	= varargin{3};	% 
        n_skip 		= varargin{4};	% 
        
        ser = fmriqa_read_series_list(dirname, n_slice, n_slices, n_skip);
        
elseif narg == 6 | narg == 7 % & length(varargin{6}) > 1, 
        
        interactive = 0;
        bruker_2dseq = 1;
        % process all Bruker 2dseq in multiple directories
        
        dirname		= varargin{1};	% base directory to process
        n_slice 	= varargin{2};	% 
        n_slices 	= varargin{3};	% 
        n_skip 		= varargin{4};	%  
        matrix_size	= varargin{5};	% 
        dir_list 	= varargin{6};  % 
        
        if narg == 7,
                reco_dir 	= varargin{7};	
        else
                reco_dir 	= '1';
        end
        
        ser = fmriqa_read_series_list(dirname, n_slice, n_slices, n_skip, matrix_size, dir_list, reco_dir);
        
        
elseif isstr(varargin{2}),
        
        interactive = 0;
        
        % read series data from excel (the appropriate excel file should be open)
        
        if narg ~= 3,
                error('number of inputs in excel mode should be 3: N, Topic, ro (row offset, not including first row)');
        end
        
        N 	= varargin{1};	% Number of series to process
        Topic 	= varargin{2};	% sheet name (e.g. 'Gutalin')
        ro	= varargin{3}; 	% row offset	
        ser = fmriqa_read_series_list(N,Topic,ro);
        
        
else 
        interactive = 1;	
        
end


if interactive
        
        if narg < 3,
                error('number of inputs in interactive mode should be 3 or 4 or 5: n_slice, n_slices, n_skip (dummy volumes for T1 sat.), matrix_size for reading Bruker 2dseq, custom_info (optional)');
        end	
        
        matrix_size = 0;
        
        n_slice 	= varargin{1};
        n_slices 	= varargin{2};
        n_skip 		= varargin{3};
        
        if narg == 4 
                if isstr(varargin{4}),
                        custom_info = varargin{4} ;
                else
                        matrix_size = varargin{4};
                end
        end
        
        if narg == 5
                matrix_size = varargin{4};
                custom_info = varargin{5} ;
        end
        
        if matrix_size,	% read Bruker 2dseq
                [I,info] = fmriqa_read_slice_bruker_2dseq(n_slice,n_slices,matrix_size);
        else		% read DICOM series		
                [I,info] = fmriqa_read_slice_dicom_series(n_slice,n_slices);
        end
        
        if findstr(info, 'Redrik')
                settings.monkey = 'RE';
        elseif findstr(info, 'Gutalin')
                settings.monkey = 'GU';
        elseif findstr(info, 'Florian')
                settings.monkey = 'FL';
         elseif findstr(info, 'Hanuman')
                settings.monkey = 'HA';               
        end
        
        [out1] = fmriqa_roi_series(I,n_skip,info,custom_info,interactive, settings, options);
        
else
        
        for i = 1:size(ser,2)
                
                disp(['Processing series ' ser(i).pathname]);
                
                if ~bruker_2dseq,
                        [I,info] = fmriqa_read_slice_dicom_series(ser(i).n_slice,ser(i).n_slices,ser(i).pathname,1);
                else
                        [I,info] = fmriqa_read_slice_bruker_2dseq(ser(i).n_slice,ser(i).n_slices,ser(i).matrix_size,ser(i).pathname,1);
                end
                
                
                info = [info sprintf('\n') custom_info];
                
                
                if findstr(info, 'Redrik')
                        settings.monkey = 'RE';
                elseif findstr(info, 'Gutalin')
                        settings.monkey = 'GU';
                elseif findstr(info, 'Florian')
                        settings.monkey = 'FL';
                elseif findstr(info, 'Hanuman')
                        settings.monkey = 'HA';
                end
                
                
                out1(i) = fmriqa_roi_series(I,ser(i).n_skip,info,custom_info,0, settings, options);
                if 0, close(gcf); end
                clear I
                % pack;
                
        end
        
end

fmriqa_process_series_output(out1);

if 1 && ~interactive,
        hf = figure('Name','Summary figure','Position',[360 311 856 823]);
        offset = 0;
        for i=1:size(ser,2),
                plot(offset+[1:length(out1(i).roi_timecourse)],out1(i).roi_timecourse); hold on;
                offset = offset + length(out1(i).roi_timecourse);
        end
end

