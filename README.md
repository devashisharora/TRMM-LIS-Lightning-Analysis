# TRMM-LIS Lightning Activity Analysis

MATLAB implementation for processing and analyzing TRMM Lightning Imaging Sensor (LIS) observations over the Indian region during Active and Break phases of the Indian Summer Monsoon.

## Description

This project processes TRMM LIS Level-2 satellite observations from 1999–2013 to investigate the spatial distribution of lightning activity over India.

The workflow includes:

- Extraction of observation dates from TRMM filenames
- Classification into Active and Break monsoon spells
- Spatial filtering over the Indian region
- 1° × 1° spatial binning
- Computation of mean lightning parameters
- Gaussian smoothing
- Spatial visualization of the processed results

## Parameters

- Lightning Activity
- Lightning Radiance
- Delta Time
- Lightning Area
- Lightning Child Events
- Lightning Duration

## Requirements

- MATLAB
- TRMM LIS Level-2 data
- coastline.mat

## Data

The satellite dataset used during this work is not included in this repository due to data sharing restrictions(by ISRO).

Only the analysis scripts are provided.

## Author

Devashish Arora

National Institute of Technology Rourkela
