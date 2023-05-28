# RIR-SIMULATIONS
Repositiory for Room Impulse Response (RIR) simulations of controlled rooms with Uniform Linear Array (ULA) and Spherical Microphone Array (SMA).

The repository is based on: 
- [RIR_Generator](https://github.com/ehabets/RIR-Generator)
- [SMIR_Generator](https://github.com/ehabets/SMIR-Generator)

## RIR generation pipeline
The following image shows the general RIR generation pipeline for the devised RIR simulation framework.
![pipeline](imgs/pipeline.png "pipeline")

## Folder structure
```
rir-simulations
├── src                       # source code folder
│   ├── lib           		  # utils functions folder
│   └──   ├── ..
├── configurations   		  # folder with JSON files
│   ├── configuration.json    # JSON file for simulation parameter setting
├── imgs                      # image folder
│   ├── ...           		
├── README.md
└── LICENSE
```

## Setup

The file [generate_pipeline.m](/generate_pipeline.m) contains an example of a complete RIR simulation. 

This script generates the desidered RIR according to the configuration defined in [configuration.json](/configurations/configuration.json) file.

In order to be able to run the script, it is necessary to compile mex-function in MATLAB. 

```
mex -setup C++
mex rir_generator.cpp rir_generator_core.cpp 
mex smir_generator_loop.cpp
```

For more information, refer to [RIR_Generator](https://github.com/ehabets/RIR-Generator) and [SMIR_Generator](https://github.com/ehabets/SMIR-Generator). 

The script can be run using the following command: 
```
matlab -batch generate_pipeline
```

## References 
1. J.B. Allen and D.A. Berkley, "Image method for efficiently simulating small-room acoustics," Journal Acoustic Society of America, 65(4), April 1979, p 943.

2. D. P. Jarrett, E. A. P. Habets, M. R. P. Thomas and P. A. Naylor, "Rigid sphere room impulse response simulation: algorithm and applications," Journal of the Acoustical Society of America, Volume 132, Issue 3, pp. 1462-1472, 2012.

3. Majdak, P., Zotter, F., Brinkmann, F., De Muynke, J., Mihocic, M., & Noisternig, M. (2022). Spatially oriented format for acoustics 2.1: Introduction and recent advances. Journal of the Audio Engineering Society, 70(7/8), 565-584.
