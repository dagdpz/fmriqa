function cf_tc = fmriqa_read_cftc(filename);
% fmriqa_read_cftc 	- read central frequency time-course from *.dat file

r = dlmread(filename);
cf_tc.x = r(:,1);
cf_tc.y = r(:,2);
