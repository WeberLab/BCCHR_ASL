#!python

import argparse
import nibabel as nib
from nibabel.viewers import OrthoSlicer3D

import matplotlib
matplotlib.use('TkAgg')
from matplotlib import pylab as plt
import numpy as np

# Initialize parser and parse arguments
parser = argparse.ArgumentParser()
parser.add_argument(
	"-pw",
	type=str,
	help="PW file name (full path)",
	required=True
)
parser.add_argument(
	"-pd",
	type=str,
	help="PD file name (full path)",
	required=True
)
parser.add_argument(
	"-o",
	type=str,
	help="save file name (full path)",
	required=True
)

args = parser.parse_args()


SHOW = True

# Change filepath
PW_filename = args.pw
PD_filename = args.pd
save_file = args.o

# Load NIFTI
PD_data = nib.load(PD_filename)
PW_data = nib.load(PW_filename)

# Get data from NIFTI
PD = PD_data.get_fdata()
PW = PW_data.get_fdata()

# For debug only, show NiFTi images
if SHOW:
	fig, (ax1, ax2) = plt.subplots(1,2, figsize = (12, 6))
	ax1.imshow(PD[PD.shape[0]//2])
	ax1.set_title('PD')
	ax2.imshow(PW[PW.shape[0]//2])
	ax2.set_title('PW')

	plt.show()

# Saturation time 
SaturationTime = 2
# Relaxation time of tissue
T1t = 1.2
#Post labeling delay
PLD = 2.025
# T1 of blood
T1b = 1.89
# Labeling duration
LabelDuration = 1.450
# Partition coefficient (whole brain average)
Lambda = 0.9
# Labeling efficiency (average of inversion efficiency and background efficiency)
Epsilon = 0.6
# Number of excitations for PW
NEX = 3
# Scaling factor of PW sequence
ScalingFactor = 32

# Initialize CBF matrix to zeros
cbf = np.zeros(PW.shape)

# Quantification of CBF
cbf_num = 6000*Lambda*(1-np.exp(-SaturationTime/T1t))*np.exp(PLD/T1b)
cbf_den = 2*T1b*(1-np.exp(-LabelDuration/T1b))*Epsilon*NEX
SF = PW/(ScalingFactor*PD)
cbf = cbf_num/cbf_den*SF

# Threshold non-physical values
cbf = np.nan_to_num(cbf)
cbf[cbf<0] = 0
cbf[cbf>300] = 300

# Save as NiFTi file
img = nib.Nifti1Image(cbf, PW_data.affine, PW_data.header)
nib.save(img, save_file)

# Show CBF map
# Will generate error, please ignore
OrthoSlicer3D(cbf).show()
