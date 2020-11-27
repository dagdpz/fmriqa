function out1 = fmriqa_vol2imn(vol, n_slices, n_skip_vol)

out1 = n_skip_vol*n_slices + vol*n_slices - n_slices + 1;
