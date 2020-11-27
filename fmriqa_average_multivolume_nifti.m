function fmriqa_average_multivolume_nifti(fullpath)


msg = sprintf('\n image read: %s',fullpath); disp(msg);    
nii = load_nii(fullpath);
F = nii.img;


AV=mean(F,4);


ResX=nii.hdr.dime.pixdim(2);
ResY=nii.hdr.dime.pixdim(3);
ResZ=nii.hdr.dime.pixdim(4);

voxel_size =[ ResX ResY ResZ ];
origin = [ 0 0 0 ];
datatype = 16;
nii_out = make_nii( AV , voxel_size , origin , datatype );

save_nii(nii_out,[fullpath(1:end-4) '_ave' '.nii']);
disp(sprintf('saved %s', [fullpath(1:end-4) '_ave' '.nii']));
