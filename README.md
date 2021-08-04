# BCCHR_ASL

Calculates CBF values based on the PD and PW files from the BCCHR scanner (3T GE750)

You will likely want to clone this folder into some kind of Scripts folder, and then add this folder to your ~/.bashrc PATH

## CBF_quantification.py

This script...

You may need to make CBF_quantification.py exetuable: ```chmod +x CBF_quantification.py```

## cbf_of_grey.sh

This bash script uses six arguments to calculate the CBF value in grey matter based on the grey matter mask created from the dHCP Anatomical Pipeline

You may need to make the cbf_of_grey.sh file executable: ```chmod +x cbf_of_grey.sh```

Next, typing ```cbf_of_grey.sh``` and pressing enter should give you the instructions you need

Example run (assumes you are in the main BIDS directory):

```cbf_of_grey.sh derivatives/asl/sub-AMWCER01 sub-AMWCER01/perf/sub-AMWCER01_run-01_asl.nii.gz derivatives/dhcp_anat/sub-AMWCER01/sub-AMWCER01_ses-session1_T2w_restore.nii.gz derivatives/dhcp_anat/sub-AMWCER01/sub-AMWCER01_ses-session1_brainmask_drawem.nii.gz derivatives/dhcp_anat/sub-AMWCER01/sub-AMWCER01_ses-session1_drawem_tissue_labels.nii.gz derivatives/asl/sub-AMWCER01/CBF.nii.gz```
