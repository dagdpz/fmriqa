function fmriqa_int2int32_2dseq(pathname,matrix_size,n_slices,verbose);

ini_dir = pwd;
if nargin < 1,

	% select path of series
	[filename, pathname] = uigetfile({'*'}, 'Please select 2dseq file');
	if filename == 0, return; end;	
end
if nargin < 2,
        matrix_size = 128;
end
if nargin < 3,
        n_slices = 1;
end
if nargin < 4,
        verbose = 1;
end

% SET THIS
n_bytes = 2; 
data_type = 'short';

cd(pathname);

d = dir('2dseq')
filesize = d.bytes;
image_size = matrix_size^2;
n_images = filesize/(matrix_size^2*n_bytes*n_slices);

info = [pathname '2dseq: ' num2str(n_slices) ' ' num2str(n_images) ' images'];

fid=fopen('2dseq','r'); 

if verbose
	disp(['Reading images in ' pathname]);
end
tic;
data = fread(fid,inf,data_type);
elapsed_time = toc;
if verbose
	disp(['Read 2dseq in ' num2str(elapsed_time) ' sec']);
end
fclose(fid);

[status, message] = movefile('2dseq','2dseq.16');
if ~status,
        disp(message);
        return;
end
        
       
if verbose
	disp(['Writing int32 2dseq ' pathname]);
end
tic;
fid1 = fopen('2dseq','wb');
fwrite(fid1,data,'int');
elapsed_time = toc;
if verbose
	disp(['Wrote int32 2dseq in ' num2str(elapsed_time) ' sec']);
end



fclose(fid1);




% --- 2dseq.im


d = dir('2dseq.im');
filesize = d.bytes;
image_size = matrix_size^2;
n_images = filesize/(matrix_size^2*n_bytes*n_slices);

info = [pathname '2dseq.im: ' num2str(n_slices) ' ' num2str(n_images) ' images'];

fid=fopen('2dseq.im','r'); 

if verbose
	disp(['Reading images in ' pathname]);
end
tic;
data = fread(fid,inf,data_type);
elapsed_time = toc;
if verbose
	disp(['Read 2dseq.im in ' num2str(elapsed_time) ' sec']);
end
fclose(fid);

[status, message] = movefile('2dseq.im','2dseq.im.16');
if ~status,
        disp(message);
        return;
end
        
       
if verbose
	disp(['Wrting int32 2dseq.im ' pathname]);
end
tic;
fid1 = fopen('2dseq.im','wb');
fwrite(fid1,data,'int');
elapsed_time = toc;
if verbose
	disp(['Wrote int32 2dseq.im in ' num2str(elapsed_time) ' sec']);
end



fclose(fid1);
cd(ini_dir);



