# Methodology

This repository implements a MATLAB-based workflow for analyzing lightning activity using observations from the Tropical Rainfall Measuring Mission (TRMM) Lightning Imaging Sensor (LIS).

## Workflow

1. Load yearly TRMM LIS Level-2 MATLAB files.
2. Extract acquisition dates from filenames.
3. Classify observations into Active and Break monsoon spells.
4. Filter observations over the Indian region.
5. Bin lightning observations into 1° × 1° spatial grids.
6. Compute lightning occurrence and mean physical parameters.
7. Apply Gaussian smoothing to improve spatial visualization.
8. Generate comparative spatial maps for Active and Break monsoon periods.

The workflow was developed for research and educational purposes and demonstrates a complete satellite data processing pipeline using MATLAB.
