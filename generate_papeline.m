clear;
close all;
clc;

addpath('configurations')
addpath('src/lib')
addpath('src/SMIR-Generator/')
addpath('src/RIR-Generator/')

fname = 'configuration.json';
file_path  = fullfile("configurations/",fname);

% TODO: Mic need to/4e added as angles to the JSON file
[x, y, z, mic] = get_eigemike_pos();

% containers
utils = utilsContainer;
plotcontainer = plotfunctionsContainer;
%RT60 = RT60functionsContainer;

%% read json file
config = utils.read_json(file_path);

%% room configuration
ULA_pos = config.ULA.position;
%n_mic_ULA = size(ULA); ?? Ask for it
%n_mic_ULA = n_mic(1);

n_ULA = config.n_ULA;
n_mic_ULA = config.ULA.n_mic;

dim_rot = config.ULA.dim_rotation;
mic_array = zeros(n_mic_ULA*n_ULA, 3);
step = config.ULA.step;


for mic = 1:n_ULA
    if dim_rot(mic) == 0
        % turn respect to x
        x_vet = ULA_pos(mic, 1):step:(ULA_pos(mic, 1)+(step*(n_mic_ULA-1))); %% need to be a function to don't copy and paste the code
        y_vet = ULA_pos(mic, 2).* ones(1, n_mic_ULA);
    else
        % turn respect to y
        x_vet = ULA_pos(mic, 1).* ones(1, n_mic_ULA);
        y_vet = ULA_pos(mic, 2):step:(ULA_pos(mic, 2)+(step*(n_mic_ULA-1)));
    end
    z_vet = ULA_pos(mic, 3).* ones(1, n_mic_ULA);
    Vr = rotation(x_vet, y_vet, z_vet, config.ULA.angle);
    mic_array(n_mic_ULA*mic-(n_mic_ULA-1):n_mic_ULA*mic, :) = Vr;
end








