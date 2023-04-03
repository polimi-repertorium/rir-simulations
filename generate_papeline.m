clear;
close all;
clc;


addpath('configurations')
addpath('src/lib')
addpath('src/SMIR-Generator/')
addpath('src/RIR-Generator/')
addpath('src/lib/SOFAtoolbox')

% make dir
mkdir(SOFAdbPath)

SOFAstart;
fname = 'configuration.json';
file_path = fullfile("configurations/",fname);

% containers
utils = utilsContainer;
plotcontainer = plotfunctionsContainer;

%% read json file
config = utils.read_json(file_path);
plot = config.plot;

%% room configuration
ULA_pos = config.ULA.position;

n_ULA = size(config.ULA.position, 1);
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
src_pos = config.source.position;
sphere_pos = config.sphere.position;
room_dim = config.room.dimension;


if plot == 1
    % the room configuration will be plotted (make function)
     figure;
     scatter3(mic_array(:,1), mic_array(:,2), mic_array(:,3), 'filled');
     hold on;
     xlim([0, room_dim(1)])
     ylim([0, room_dim(2)])
     zlim([0, room_dim(3)])
     scatter3(src_pos(:, 1), src_pos(:, 2), src_pos(:, 3), 'filled');
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

% generate RIR for mics arrays
h_rir = rir_generator(c, procFs, mic_array, src_pos, room_dim, beta, nsample, 'omnidirectional', order, 3, [0 0], false);
% highpass filter
h_rir = highpass(h_rir', cut_off, procFs);

for mic = 1:n_ULA
    IR = h_rir(:, (n_mic_ULA*mic-(n_mic_ULA-1):n_mic_ULA*mic));
    mic_pos = mic_array(n_mic_ULA*mic-(n_mic_ULA-1):n_mic_ULA*mic, :);
    
    full_path_filename = fullfile(SOFAdbPath);
    writeSOFA(IR, nsample, mic_pos, full_path_filename)
end

%% load SOFA file
Obj = SOFAload(full_path_filename);
disp('object loaded')
IR_taken = Obj.Data.IR;
plotcontainer.plot_rir(1, IR_taken, nsample, procFs)

% option to plot and the rir
if plot == 1
    for mic = 1:size(mic_array, 1)
        plotcontainer.plot_rir(mic, h_rir', nsample, procFs)
    end
end

% save all of them with the sofa format
% maybe would make sense to calculate how fast is the generation of the parfor and using the build function of generate RIR for one then one

%% SMIR generation 
n_mic_sphere = size(config.sphere.position, 1);
[x, y, z, spherical_mic] = get_eigemike_pos();
sphere_pos = config.sphere.position;
sphere_type = config.sphere.type; 
sphere_radius = config.sphere.radius;
src_type = config.source.src_type;
K = config.K;
N_harm = config.N_harm;

[src_ang(:, 1),src_ang(:, 2)] = mycart2sph(sphere_pos(:, 1)-src_pos(1),sphere_pos(:, 2)-src_pos(2),sphere_pos(:, 3)-src_pos(3)); % Towards the receiver

parfor mic = 1:n_mic_sphere
    [h_smir, H_smir, beta_hat] = smir_generator(c, ...
        procFs, ...
        sphere_pos(mic, :), ...
        src_pos, ...
        room_dim, ...
        beta, ...
        sphere_type, ...
        sphere_radius, ...
        spherical_mic, ...
        N_harm, ...
        nsample, ...
        K, ...
        order, ...
        0, ...
        0, ...
        src_type, ...
        src_ang(mic, :));
    h_smir = highpass(h_smir', cut_off, procFs)'
    %save all of them sofa format
end













