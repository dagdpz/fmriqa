function fmriqa_session_qa(session_path,n_slice,n_slices,n_skip, runs, type)
% fmriqa_session_qa('D:\MRI\Curius\20121130',5,23,4)
% fmriqa_session_qa('Z:\MRI\Curius\20140417_rest',10,30,4,[],'*tf.fmr')

if nargin < 5,
	runs = [];
end

if nargin < 6,
	type = '*.dcm';
end

ori_dir = pwd;
cd(session_path);

d = dir('run*');
dir_idx = find([d.isdir]);
d = d(dir_idx);
n_runs = length(d);

slash_idx = strfind(session_path,filesep);
name = [session_path(slash_idx(end-1)+1:slash_idx(end)-1) session_path(slash_idx(end)+1:end)];

for k = 1:n_runs
	
	if isempty(runs) || ~isempty(find(runs==k)),
		
		run_name = ['run' num2str(k,'%02d')];
		if strcmp(type,'*.dcm'),
			[I,info] = fmriqa_read_slice_dicom_series(n_slice,n_slices,[session_path filesep run_name],1);
		else
			% read fmr to "mosaic" 3D matrix
			fmr_name = dir([session_path filesep run_name filesep type]);
			I = ne_fmr_to_3Dmosaic([session_path filesep run_name filesep fmr_name.name]);
			I = I(:,:,n_skip+1:end);
			n_images = size(I,3);
			info = [fmr_name.name ' sl. ' num2str(n_slice) ' of ' num2str(n_slices) ': ' num2str(n_images) ' images'];

			
		end
		[out1] = fmriqa_series_var_map(I,n_skip,0,0,0,info,'');
		saveas(gcf, [name '_' run_name '_' strrep(type,'*','') '.pdf'], 'pdf');
		
		if 0,
			[out1] = fmriqa_roi_series(I,n_skip,info,'',1)
		end
		
	end
	
end


cd(ori_dir);