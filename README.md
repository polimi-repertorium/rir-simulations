# RIR-SIMULATIONS
Repositiory for RIR simulations of controlled room acoustics with ULA and SMA.

## Simulation pipeline
The following image depicts the general pipeline for the desired RIR simulation framework.
![pipeline](imgs/pipeline.png "pipeline")


## Folder structure
```
rir-simulations
├── src                     			# source code folder
│   ├── lib           		# utils functions folder
│   └──   ├── ...
├── configurations   					# folder with JSON files
│   ├── x.json           		# JSON file for simulation parameter setting
├── imgs
│   ├── ...           		# image folder
├── README.md
└── LICENSE
```

## TODO list
- [x] Block scheme pipeline
- [ ] RIR & SMIR generators
- [ ] Read room setting from JSON file
- [ ] Mics on nodal lines of the room
- [ ] Comparison between input T60 and estimated T60 from the computed RIR
