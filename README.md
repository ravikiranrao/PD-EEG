# Examining Emotion Perception in Parkinson's Disease Patients using EEG Signals

This is the official GitHub repository for the paper "Examining Emotion Perception in Parkinson's Disease Patients using EEG Signals".

While Parkinson's disease (PD) is typically characterized by motor disorder, there is evidence of diminished emotion perception in PD patients. This study employs Electroencephalography (EEG) to examine emotion perception in PD vs Normal Control (NC) subjects. Employing multiple descriptors with machine learning and deep learning frameworks, we investigate (a) dimensional and categorical emotion recognition with class-specific EEG data, and (b) discriminability between the PD and NC classes. Our results reveal that PD patients comprehend arousal better than valence, and among specific emotions, _fear_ less accurately and _sadness_ most accurately. Deficits in emotion perception are confirmed by emotion-wise misclassifications, where opposite valence emotions are mislabeled with PD data. Also, near-perfect recognition of the PD and NC classes is achieved with EEG, conveying that emotional neural responses can effectively be used for PD diagnosis and treatment vis-à-vis self reports and expert assessments.

## Overview
![Overview](./images/EEG_overview.png)
Our pipeline involves (a) EEG pre-processing and extraction of features such as spectral power vectors (SPV) and common spatial patterns (CSP), (b) feeding of these features or derived representations such as EEG images and movies to machine and deep learning frameworks to perform (i) dimensional and discrete emotion recognition, and (ii) PD vs NC classification.

