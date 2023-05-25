# RIR-SIMULATIONS
Repositiory for Room Impulse Response (RIR) simulations of controlled room acoustics with Uniform Linear Array (ULA) and Spherical Microphone Array (SMA).

The repository is based on: 
- [RIR_Generatorr](https://github.com/ehabets/RIR-Generator)
- [SMIR_Generatorr](https://github.com/ehabets/SMIR-Generator)

## Simulation pipeline
The following image depicts the general pipeline for the devised RIR simulation framework.
![pipeline](imgs/pipeline.png "pipeline")

## Folder structure
```
rir-simulations
├── src                         # source code folder
│   ├── lib           		# utils functions folder
│   └──   ├── ...
├── configurations   		# folder with JSON files
│   ├── x.json           	# JSON file for simulation parameter setting
├── imgs                        # image folder
│   ├── ...           		
├── README.md
└── LICENSE
```

## Usage

The file [generate_pipeline.m](/generate_pipeline.m) contains a complete example of simulation examples. 
This script computes the desider RIR using the setup defined in [configuration.json](/configurations/configuration.json) file.
