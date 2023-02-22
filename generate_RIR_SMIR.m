addpath('configurations')
addpath('src')
addpath('./src/lib')
addpath('./src/SMIR-Generator/')
addpath('./src/RIR-Generator/')
addpath('rir-simulations/generate_RIR_SMIR.m')

fname = 'nextwall_y.json';
file_path  = fullfile("configurations/",fname);

% TODO: Mic need to/4e added as angles to the JSON file
mic = [pi/4 pi/4; pi/2 pi/4];

% containers
utils = utilsContainer;
plotcontainer = plotfunctionsContainer;
RT60 = RT60functionsContainer;

%% read json file
config = utils.read_json(file_path);
display(config)

%% generate rir with SMIR-Generator
[src_ang(1),src_ang(2)] = mycart2sph(config.sphere.location(1)-config.source.location(1),config.sphere.location(2)-config.source.location(2),config.sphere.location(3)-config.source.location(3)); % Towards the receiver
[mic_pos(:,1), mic_pos(:,2), mic_pos(:,3)] = mysph2cart(mic(:,1),mic(:,2),config.sphere.radius); % Microphone positions relative to centre of array ("sphLocation")
 mic_pos = mic_pos + repmat(config.sphere.location,size(mic,1),1);

 % plot room 
plotcontainer.plot_room(mic_pos, config.sphere.location, config.source.location, config.room.dimension)

[h_smir, H_smir, beta_hat] = smir_generator(config.c, ...
        config.procFs, ...
        config.sphere.location, ...
        config.source.location, ... 
        config.room.dimension, ...
        config.room.beta(1), ...
        config.sphere.type, ...
        config.sphere.radius, ...
        mic, ...
        config.N_harm, ...
        config.nsample, ...
        config.K, ...
        config.room.order, ...
        0, ...
        0, ...
        config.source.src_type, ...
        src_ang);


h_rir = 4*pi*rir_generator(config.c, config.procFs, mic_pos, config.source.location, config.room.dimension, config.room.beta, config.nsample, 'omnidirectional', config.room.order, 3, [0 0], false);
H_rir = fft(h_rir, [], 2);

% compare rir from RIR-Generator and SMIR-Generator (2 mics)
mic_to_plot = 1;
plotcontainer.compare_rir(mic_to_plot, h_rir, h_smir, H_rir, H_smir, config.sphere.K, config.nsample, config.procFs)

mic_to_plot = 2;
plotcontainer.compare_rir(mic_to_plot, h_rir, h_smir, H_rir, H_smir, config.sphere.K, config.nsample, config.procFs)

%% estimate RT60
ECD_region = [-5,-25];
plot_ok=1;

T60_smir = RT60.Estimate_RT60(h_smir,config.procFs,ECD_region,plot_ok);
fprintf("T60 estimated (smir): %s\n", T60_smir)

T60_rir = RT60.Estimate_RT60(h_rir,config.procFs,ECD_region,plot_ok);
fprintf("T60 estimated (rir): %s\n", T60_rir)

if isscalar(config.room.beta)
    beta = config.room.beta;
    fprintf("T60 given as input: %f\n", beta)
else
    fprintf("Only coefficientes have been given as input.\n")
end

if ~isscalar(config.room.beta)
    RT60_sab = RT60.sabine_formula(config.room.dimension, config.room.beta);
    fprintf("T60 using sabine formula (beta given as coefficients): %f\n", RT60_sab)
end

%% room mode
Nx = 0;
Ny = 1;
Nz = 0;
freq = utils.room_mode(config.c, config.room.dimension, Nx, Ny, Nz);
fprintf("Freq a mode Nx, Ny, Nx: %i,%i,%i\n", Nx, Ny, Nz);

H_rir = fft(h_rir, [], 2);
plotcontainer.plot_frequency_RIR(H_rir, config.procFs, config.nsample)
