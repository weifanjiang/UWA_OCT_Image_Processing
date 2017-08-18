# UWA_OCT_Image_Processing


This repository contains programs, data and experimental results I developed while internshiping at the Optical and Biomedical Engineering Labortory (OBEL) of the University of Western Australia in summer 2017.

Following programs are writted by me:

	Before_Segmentation.m: pre-process an OCT B-scan, including denoising
		and enhancement.

	Gradient_Segmentation.m: using gradient-based method to find vessels
		from the OCT image.

	Snake.m: using active contour model algorithm (also called snake) to
		find vessels from the OCT image.

	Surface_Detection_With_Snake.m: using active contour model algorithm
		(also called snake) to find the upper surface of the OCT image.

	This function is written by Dr. Peijun Gong from OBEL:

	Preprocessing_PG.m: extract a B-scan from a 3D OCT model and calls
		functions from above to further process each B-scan.

These data are also provided by Dr.Peijun Gong:

	2016_05_31_Eye_2_Location_3_1_3D
	2016_11_08_Eye_1_Location_1_Model3D
	2017_07_04_eye2_scan_3_FOV_adjusted

And the result of testing functions I developed with each data Dr.Gong provided are inside the "Experimenal_Result" folder.


Weifan Jiang
University of Washington
8.18.2018
