#!/bin/bash

fslroi chi.nii.gz chi_echo3-5 2 3
fslmaths chi_echo3-5 -Tmean chi_echo3-5_avg
meanchi=$(fslstats chi_echo3-5_avg.nii.gz -l 0.15 -M)
volchi=$(fslstats chi_echo3-5_avg.nii.gz -l 0.15 -V)

echo "Mean chi value above 0.15ppm is $meanchi"
echo "
Number of Voxels and Volume (respectively) above 0.15ppm is $volchi"
