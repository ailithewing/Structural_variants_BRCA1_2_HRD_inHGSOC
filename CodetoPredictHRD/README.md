# Predicting HRD from WGS using the HRDetect framework

This implementation of the HRDetect pipeline is intended for RESEARCH USE ONLY and NOT FOR THE PURPOSE OF INFORMING CLINICAL DECISION-MAKING.

This code to implement [HRDetect](https://www.nature.com/articles/nm.4292) builds upon a pipeline developed by Eric Zhao (https://github.com/eyzhao/hrdetect-pipeline). If you use this code please cite his work:

[Zhao EY, Shen Y, Pleasance E, ... Jones SJM, Homologous Recombination Deficiency and Platinum-Based Therapy Outcomes in Advanced Breast Cancer. Clinical Cancer Research. 2017 Dec 15;23(24):7521-7530](https://pubmed.ncbi.nlm.nih.gov/29246904/)


Some of the scripts and dependencies have been altered for use with GRCh38.

The new dependencies can be installed as a conda environment using hrdetect_environ.yml and the new versions of the scripts are included in the scripts directory. There are minor additional edits to the scripts defining indel microhomology, conducting signature fitting and calculating the HRDIndex to maximise concordance with the results originally reported by the HRDetect authors. 




