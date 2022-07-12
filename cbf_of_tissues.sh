#!/bin/bash

if [ $# -lt 2 ]; then
    # TODO: print usage
    echo "This script requires eight arugments in this order:
outpath: full path of where to put output files
PD path: full path of where the PD file is
T2 path: full path and filename of dHCP T2_restore.nii.gz file
mask: full path and filename of the mask file
tissue labels: full path and filename of tissue labels
CBF: full path and filename of CBF file
subid: Subject ID
sesid: Session ID (hardcoded to be session1 atm)
So for example:
cbf_of_tissues.sh /some/out/path /the/path/to/PD.nii.gz /the/path/to/the/mask.nii.gz /the/path/to/the/tissuelabels.nii.gz /the/path/to/CBF.nii.gz subjectid session1"
    exit 1
fi

out=$1
pd=$2
t2=$3
mask=$4
seg=$5
CBF=$6
subid=$7
sesid=$8

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

fslmaths ${out}/mask_warped_in_pd.nii.gz -thr 1 -bin ${out}/mask_warped_in_pd_binary


echo "Registering Tissue Masks to PD
"

maindir=$PWD
cd $maindir

maskdir=${maindir}/derivatives/dhcp/sub-${subid}/ses-${sesid}/masks

mask_resample=${maskdir}/csf.nii.gz
flirt -in ${maskdir}/csf.nii.gz -ref ${t2} -out ${mask_resample} -applyxfm

moving=${mask_resample}
antsApplyTransforms \
  -d 3 \
  -i $moving \
  -r $fixed \
  -t [${mat}, 1] \
  -o ${out}/csf_in_pd.nii.gz

fslmaths ${out}/csf_in_pd.nii.gz -thr 0.5 -bin ${out}/csf_in_pd

mask_resample=${maskdir}/cortgreymatter.nii.gz
flirt -in ${maskdir}/cortgreymatter.nii.gz -ref ${t2} -out ${mask_resample} -applyxfm

moving=${mask_resample}
antsApplyTransforms \
  -d 3 \
  -i $moving \
  -r $fixed \
  -t [${mat}, 1] \
  -o ${out}/cortgreymatter_in_pd.nii.gz

fslmaths ${out}/cortgreymatter_in_pd.nii.gz -thr 0.5 -bin ${out}/cortgreymatter_in_pd

mask_resample=${maskdir}/whitematter.nii.gz
flirt -in ${maskdir}/whitematter.nii.gz -ref ${t2} -out ${mask_resample} -applyxfm

moving=${mask_resample}
antsApplyTransforms \
  -d 3 \
  -i $moving \
  -r $fixed \
  -t [${mat}, 1] \
  -o ${out}/whitematter_in_pd.nii.gz

fslmaths ${out}/whitematter_in_pd.nii.gz -thr 0.5 -bin ${out}/whitematter_in_pd

mask_resample=${maskdir}/background.nii.gz
flirt -in ${maskdir}/background.nii.gz -ref ${t2} -out ${mask_resample} -applyxfm

moving=${mask_resample}
antsApplyTransforms \
  -d 3 \
  -i $moving \
  -r $fixed \
  -t [${mat}, 1] \
  -o ${out}/background_in_pd.nii.gz

fslmaths ${out}/background_in_pd.nii.gz -thr 0.5 -bin ${out}/background_in_pd

mask_resample=${maskdir}/vent.nii.gz
flirt -in ${maskdir}/vent.nii.gz -ref ${t2} -out ${mask_resample} -applyxfm

moving=${mask_resample}
antsApplyTransforms \
  -d 3 \
  -i $moving \
  -r $fixed \
  -t [${mat}, 1] \
  -o ${out}/vent_in_pd.nii.gz

fslmaths ${out}/vent_in_pd.nii.gz -thr 0.5 -bin ${out}/vent_in_pd

mask_resample=${maskdir}/cerebellum.nii.gz
flirt -in ${maskdir}/cerebellum.nii.gz -ref ${t2} -out ${mask_resample} -applyxfm

moving=${mask_resample}
antsApplyTransforms \
  -d 3 \
  -i $moving \
  -r $fixed \
  -t [${mat}, 1] \
  -o ${out}/cerebellum_in_pd.nii.gz

fslmaths ${out}/cerebellum_in_pd.nii.gz -thr 0.5 -bin ${out}/cerebellum_in_pd

mask_resample=${maskdir}/deepgrey.nii.gz
flirt -in ${maskdir}/deepgrey.nii.gz -ref ${t2} -out ${mask_resample} -applyxfm

moving=${mask_resample}
antsApplyTransforms \
  -d 3 \
  -i $moving \
  -r $fixed \
  -t [${mat}, 1] \
  -o ${out}/deepgrey_in_pd.nii.gz

fslmaths ${out}/deepgrey_in_pd.nii.gz -thr 0.5 -bin ${out}/deepgrey_in_pd

mask_resample=${maskdir}/brainstem.nii.gz
flirt -in ${maskdir}/brainstem.nii.gz -ref ${t2} -out ${mask_resample} -applyxfm

moving=${mask_resample}
antsApplyTransforms \
  -d 3 \
  -i $moving \
  -r $fixed \
  -t [${mat}, 1] \
  -o ${out}/brainstem_in_pd.nii.gz

fslmaths ${out}/brainstem_in_pd.nii.gz -thr 0.5 -bin ${out}/brainstem_in_pd

mask_resample=${maskdir}/hipandamyg.nii.gz
flirt -in ${maskdir}/hipandamyg.nii.gz -ref ${t2} -out ${mask_resample} -applyxfm

moving=${mask_resample}
antsApplyTransforms \
  -d 3 \
  -i $moving \
  -r $fixed \
  -t [${mat}, 1] \
  -o ${out}/hipandamyg_in_pd.nii.gz

fslmaths ${out}/hipandamyg_in_pd.nii.gz -thr 0.5 -bin ${out}/hipandamyg_in_pd

