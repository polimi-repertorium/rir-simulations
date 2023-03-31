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
[x, y, z, spherical_mic] = get_eigemike_pos();

% containers
utils = utilsContainer;
plotcontainer = plotfunctionsContainer;
%RT60 = RT60functionsContainer;

%% read json file
config = utils.read_json(file_path);
plot = config.plot;

%% room configuration
ULA_pos = config.ULA.position;
%n_mic_ULA = size(ULA); ?? Ask for it
%n_mic_ULA = n_mic(1);
% configurration file in order on how we do need it

n_ULA = config.n_ULA;
n_mic_ULA = config.ULA.n_mic;
angle = config.ULA.angle;

dim_pos = config.ULA.dim_pos;
mic_array = zeros(n_mic_ULA*n_ULA, 3);
step = config.ULA.step;

%% positioning the ULA according to axes and rotation
for mic = 1:n_ULA
    if dim_pos(mic) == 1
        % the ULA will be positionated on the x axes
        [x_vet, y_vet] = utils.rotate(ULA_pos, n_mic_ULA, mic, step, dim_pos(mic));
    else
        % the ULA will be positionated on the y axes
        [y_vet, x_vet] = utils.rotate(ULA_pos, n_mic_ULA, mic, step, dim_pos(mic));
    end
    z_vet = ULA_pos(mic, 3).* ones(1, n_mic_ULA);

    % the ULA will be rotate of x degree, defined by the variable angle
    Vr = utils.rotation(x_vet, y_vet, z_vet, angle(mic), plot);
    mic_array(n_mic_ULA*mic-(n_mic_ULA-1):n_mic_ULA*mic, :) = Vr;
end

%% plot the room configurations
source_pos = config.source.position;
sphere_pos = config.sphere.position;
room_dim = config.room.dimension;

%% plot room configuration (optional)
if plot == 1
    % the room configuration will be plotted (make function)
     figure;
     scatter3(mic_array(:,1), mic_array(:,2), mic_array(:,3), 'filled');
     hold on;
     xlim([0, room_dim(1)])
     ylim([0, room_dim(2)])
     zlim([0, room_dim(3)])
     scatter3(source_pos(:, 1), source_pos(:, 2), source_pos(:, 3), 'filled');
     hold all;
     scatter3(sphere_pos(:, 1), sphere_pos(:, 2), sphere_pos(:, 3), 'filled');
     legend('Mic positions', 'Source position', 'Sphere position');

     % save the image
end

%% RIR generation (for ULA)
c = config.c;
procFs = config.procFs;
beta = config.room.beta;
order = config.room.order;
cut_off = config.cut_off_HP;

% nsample 
nsample = double((beta * 1.5 * procFs));

% add the if for the type of mic
h_rir = rir_generator(c, procFs, mic_array, source_pos, room_dim, beta, nsample, 'omnidirectional', order, 3, [0 0], false);
h_rir = highpass(h_rir', cut_off, procFs)';
% save the RIR as SOFA file format

% option to plot and save the rir
if plot == 1
    for mic = 1:length(mic_array)
        plotcontainer.plot_rir(mic, h_rir, nsample, procFs)
    end
end


% save all of them with the sofa format
% maybe would make ssense to calculate how fast is the generation of the parfor and using the build function of generate RIR for one then one

% generate smir for spehrical mics -> parfor, filter, save all of them sofa format
% we need to save the only in time

% if I can give a time for a realistic case, that would be amazing!








