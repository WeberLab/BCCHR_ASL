#!/bin/bash

if [ $# -lt 2 ]; then
    # TODO: print usage
    echo "This script requires six arugments in this order:
outpath: full path of where to put output files
PD path: full path of where the PD file is
T2 path: full path and filename of dHCP T2_restore.nii.gz file
mask: full path and filename of the mask file
tissue labels: full path and filename of tissue labels
CBF: full path and filename of CBF file
So for example:
cbf_of_grey.sh /some/out/path /the/path/to/PD.nii.gz /the/path/to/the/mask.nii.gz /the/path/to/the/tissuelabels.nii.gz /the/path/to/CBF.nii.gz"
    exit 1
fi

out=$1
pd=$2
t2=$3
mask=$4
seg=$5
CBF=$6

t2_in_pd=${out}/t2_warped_in_pd.nii.gz
mask_in_pd=${out}/mask_warped_in_pd.nii.gz
pd_in_t2=${out}/pd_warped_in_t2.nii.gz

fixed=${t2}
moving=${pd}

# register PD to T2

echo "
Registering PD to T2
"
antsRegistration --dimensionality 3 \
--float 0 \
--output [${out}/pd_to_t2,${pd_in_t2}] \
--interpolation Linear \
--winsorize-image-intensities [0.005,0.995] \
--use-histogram-matching 0 \
--initial-moving-transform [$fixed,$moving,1] \
--transform Rigid[0.1] \
--metric MI[$fixed,$moving,1,32,Regular,0.25] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox \
--transform Affine[0.1] \
--metric MI[$fixed,$moving,1,32,Regular,0.25] \
--convergence [1000x500x250x100,1e-6,10] \
--shrink-factors 8x4x2x1 \
--smoothing-sigmas 3x2x1x0vox


# use above transfroms to warp mask to echo also
fixed=${pd}
moving=${t2}
mat=${out}/pd_to_t20GenericAffine.mat

#########################################################
# transform with .mat
#########################################################

echo "Inverting Registration
"
antsApplyTransforms \
-d 3 \
-i $moving \
-r $fixed \
-t [${mat}, 1] \
-o ${t2_in_pd}

echo "Registering Mask to PD
"
mask_resample=${out}/mask_resampled.nii.gz
flirt -in ${mask} -ref ${t2} -out ${mask_resample} -applyxfm

moving=${mask_resample}
antsApplyTransforms \
  -d 3 \
  -i $moving \
  -r $fixed \
  -t [${mat}, 1] \
  -o ${mask_in_pd}

fslmaths mask_warped_in_pd.nii.gz -thr 1 -bin mask_warped_in_pd_binary

echo "Creating GM Mask
"
fslmaths $seg -thr 2 -uthr 2 -bin ${out}/gm_cort

echo "Registering GM to PD
"
mask_resample=${out}/gm_cort_resampled.nii.gz
flirt -in ${out}/gm_cort.nii.gz -ref ${t2} -out ${mask_resample} -applyxfm

moving=${mask_resample}
antsApplyTransforms \
  -d 3 \
  -i $moving \
  -r $fixed \
  -t [${mat}, 1] \
  -o ${out}/gm_in_pd.nii.gz

fslmaths ${out}/gm_in_pd.nii.gz -thr 0.5 -bin ${out}/gm_in_pd

cbfvalue=$(fslstats ${CBF} -k ${out}/gm_in_pd.nii.gz -M)
echo "The CBF of greymatter is ${cbfvalue}"