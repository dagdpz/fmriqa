function fmriqa_run_qa(run_path,n_slice,n_slices,n_skip, chan,analyze_tc,force_not_mosaic)
% fmriqa_run_qa('D:\MRI\Curius\20130130\uncombined\0007',[],23,4,'Rx1'); 
% fmriqa_run_qa('D:\MRI\Curius\20130201\uncombined\0024',[],23,4,''); % mosaic
% fmriqa_run_qa('D:\MRI\Curius\20130201\uncombined\0024',[],23,4,'all'); % all channels one-by-one
% fmriqa_run_qa('/data/RECON/TEST_20130226/epi_00001/f.nii',10,30,0);
% fmriqa_run_qa('X:\MRI\Human\Action Selection\Blocked\ADAS\20141120\run01',10,36,4)

if nargin < 5,
	chan = {''}; % all channels, mosaic
elseif strcmpi(chan,'all'),
	chan = {'Rx1' 'Rx2' 'Rx3' 'Rx4'}; % 4-channel coil
else
	chan = {chan}; % separate channel
end

if nargin < 6,
	analyze_tc = 0;
end

if nargin < 7,
	force_not_mosaic = 0;
end

ori_dir = pwd;


if ~isempty(findstr(run_path,'.nii')),
    
    [out,pixdim,rotate,dtype] = fmriqa_readnifti(run_path);
    n_slices = size(out,3);
    
    if isempty(n_slice), % look at all slices
        % need Y:\Sources\NeuroElf_v11_7521\add_dag_ne_pipeline
       
        I = packmosaic(permute(out,[2 1 3 4]),3);
        I = flipud(I(:,:,n_skip+1:end));
        info = [run_path num2str(n_slices) 'slices: ' num2str(size(out,4)-n_skip) ' images'];
         
    else % specific slice
        I = permute(squeeze(out(:,:,n_slice,n_skip+1:end)),[2 1 3]);
        I = flipdim(I,1);
        info = [run_path ' sl. ' num2str(n_slice) ' of ' num2str(n_slices) ': ' num2str(size(out,4)-n_skip) ' images'];
    end
    [out1] = fmriqa_series_var_map(I,n_skip,0,0,0,info,'');

    saveas(gcf, [run_path '_fmriqa.pdf'], 'pdf');
    
elseif ~isempty(findstr(run_path,'.vtc')),
    
    vtc = xff(run_path);
    
    if isempty(n_slice), % look at all slices
        % need Y:\Sources\NeuroElf_v11_7521\add_dag_ne_pipeline
       
        I = packmosaic(permute(vtc.VTCData,[2 4 3 1]),3);
        I = I(:,:,n_skip+1:end);
        info = [run_path num2str(n_slices) 'slices: ' num2str(vtc.NrOfVolumes-n_skip) ' images'];
         
    else % specific slice
        
    end
    [out1] = fmriqa_series_var_map(I,n_skip,0,0,-1,info,'');

    saveas(gcf, [run_path '_fmriqa.pdf'], 'pdf');    

else
    cd(run_path);

    for k=1:length(chan),

        [I,info] = fmriqa_read_slice_dicom_series(n_slice,n_slices,run_path,1,chan{k},force_not_mosaic);
        [out1] = fmriqa_series_var_map(I,n_skip,0,0,0,info,chan{k});

        run_name = [strrep(run_path, filesep, '_') '_' chan{k}];
        run_name = strrep(run_name, ':', '');
        saveas(gcf, [run_name '.pdf'], 'pdf');

    end
end

if analyze_tc,
	[out1] = fmriqa_roi_series(I,n_skip,info,'',1);
end
	


		
cd(ori_dir);