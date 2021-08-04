# BCCHR_ASL

Calculates CBF values based on the PD and PW files from the BCCHR scanner (3T GE750)

You will likely want to clone this folder into some kind of Scripts folder, and then add this folder to your ~/.bashrc PATH

## cbf_of_grey.sh

This bash script uses six arguments to calculate the CBF value in grey matter based on the grey matter mask created from the dHCP Anatomical Pipeline

You may need to make the cbf_of_grey.sh file executable: ```chmod +x cbf_of_grey.sh```

