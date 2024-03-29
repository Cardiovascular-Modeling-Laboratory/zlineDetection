# ZlineDetection

Quantify z-line architecture in images of striated muscles. 

## Reference This Work
Morris, Tessa Altair, et al. "Striated myocyte structural integrity: Automated analysis of sarcomeric z-discs." PLOS Computational Biology 16.3 (2020): e1007676.

## Getting Started

1. Download and open zlineDetection in MATLAB.
2. To open zlineDetection GUI and initialize analysis, type the following in the MATLAB command line
```
zlineDetection
```
3. See userGuide.pdf for more information. 

Note: If you encounter the error saying "'CONCRT140.dll' required", it's because the run-time component is missing from the system. Install [Visual C++ Redistributable Packages](https://docs.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170) for Windows should resolve this issue. 

## System Requirements

MATLAB Version >= 9.5 

Image Processing Toolbox Version 10.3

Statistics and Machine Learning Toolbox Version 11.4

To check the version of MATLAB and which Toolboxes you have installed, type the following in the MATLAB command line:
```
ver
```

## Versioning

| Version  | Date | Update Description |
|---|---|---|
| 1.2.002 | Aug 24, 2020 | Fixed bug so that the Excel summary sheet now has the correct number of coverslips per condition | 
| 1.2.001 | Jan 15, 2020 | Added functions to save video frames as separate .tifs and a function that can summarize the video data. The user guide has also been updated with instructions to analyze videos, and descriptions of where the results of measuring the sarcomere length can be found |
| 1.1.001 | Jan 15, 2020 | Added sarcomere length (distance) calculation for each image. Summary for each coverslip has not been implemented. |
| 1.0.004 | Jan 15, 2020 | Implemented semantic versioning. Change x-spacing of dots in dot plots. Enhance filenames comparison. |
| 1.0.003 | Oct 30, 2019 | Fixed bugs so post analysis, multiple runs can be combined. |
| 1.0.002 | Oct 27, 2019 | Added script to manually remove regions of the background, which were missed by the background substraction. |
| 1.0.001  |   |   |

ZlineDetection uses semantic versioning where the version number follows the convention <Major>.<Minor>.<Patch>.
Major Release: new features break backwards compatibility/current features
Minor Release: features don’t break any existing features and are compatible with old versions.
Patch Release: bug/patch fixes



## Authors

## License

## Acknowledgments
