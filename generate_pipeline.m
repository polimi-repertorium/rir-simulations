clear;
close all;
clc;

% add path
addpath('configurations')
addpath('src/lib')
addpath('src/SMIR-Generator/')
addpath('src/RIR-Generator/')
addpath('src/lib/SOFAtoolbox')

% make dir for saving SOFA files
mkdir(SOFAdbPath)
SOFAstart;

% configuration file
fname = 'configuration.json';
file_path = fullfile("configurations/",fname);

% containers
utils = utilsContainer;
plotcontainer = plotfunctionsContainer;

%% read json file
% read JSON file and save data into variables
config = utils.read_json(file_path);
plot = config.plot;
c = config.c;
procFs = config.procFs;
cut_off = config.cut_off_HP;
K = config.K;
N_harm = config.N_harm;

% ULA configuration
ULA_pos = config.ULA.position;
ULA_n = size(config.ULA.position, 1);
ULA_n_mic = config.ULA.n_mic;
ULA_angle = config.ULA.angle;
ULA_dim_pos = config.ULA.dim_pos;
ULA_step = config.ULA.step;

% source configuration
src_pos = config.source.position;
src_type = config.source.src_type;

% spherical mic
sph_pos = config.sphere.position;
sph_type = config.sphere.type; 
sph_radius = config.sphere.radius;

% room configuration
room_dim = config.room.dimension;
order = config.room.order;
beta = config.room.beta;

% nsample 
nsample = int64((beta * 1.5 * procFs));

%% ROOM Configuration 
% positioning the ULA according to axes and rotation
for mic = 1:ULA_n
    if ULA_dim_pos(mic) == 1
        % the ULA will be positionated on the x axes
        [x_vet, y_vet] = utils.rotate(ULA_pos, ULA_n_mic, mic, ULA_step, ULA_dim_pos(mic));
    else
        % the ULA will be positionated on the y axes
        [y_vet, x_vet] = utils.rotate(ULA_pos, ULA_n_mic, mic, ULA_step, ULA_dim_pos(mic));
    end
    z_vet = ULA_pos(mic, 3).* ones(1, ULA_n_mic);

    % the ULA will be rotate of x degree, defined by the variable angle
    Vr = utils.rotation(x_vet, y_vet, z_vet, ULA_angle(mic), plot);
    mic_array(ULA_n_mic*mic-(ULA_n_mic-1):ULA_n_mic*mic, :) = Vr;
end

% optional plot for room configuration
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
     scatter3(sph_pos(:, 1), sph_pos(:, 2), sph_pos(:, 3), 'filled');
     legend('Mic positions', 'Source position', 'Sphere position');
     % save the image
end

%% RIR generation (for ULA, mic arrray)
mic_array = ULA_pos;

% generate RIR for mics arrays
h_rir = rir_generator(c, procFs, mic_array, src_pos, room_dim, beta, nsample, 'omnidirectional', order, 3, [0 0], false);
% highpass filter
h_rir = highpass(h_rir', cut_off, procFs)';

for mic = 1:ULA_n
    %IR = h_rir(:, (ULA_n_mic*mic-(ULA_n_mic-1):ULA_n_mic*mic));
    IR = h_rir((ULA_n_mic*mic-(ULA_n_mic-1):ULA_n_mic*mic), :);
    %mic_pos = mic_array(ULA_n_mic*mic-(ULA_n_mic-1):ULA_n_mic*mic, :);
    mic_pos = ULA_pos(mic, :);
    disp(mic_pos);
    receiver_pos = mic_array(ULA_n_mic*mic-(ULA_n_mic-1):ULA_n_mic*mic, :);
    full_path_filename = fullfile(SOFAdbPath);
    writeSOFA(IR, nsample, mic_pos, receiver_pos, full_path_filename)
end


% rir plot (optional)
if plot == 1
    for mic = 1:size(mic_array, 1)
        plotcontainer.plot_rir(mic, h_rir, nsample, procFs)
    end
end


%% SMIR generation 
sph_n_mic = size(config.sphere.position, 1);
[x, y, z, sph_mic] = get_eigemike_pos();
mic_pos_cart = [x, y, z];

[src_ang(:, 1),src_ang(:, 2)] = mycart2sph(sph_pos(:, 1)-src_pos(1),sph_pos(:, 2)-src_pos(2),sph_pos(:, 3)-src_pos(3)); % Towards the receiver

for mic = 1:sph_n_mic
    [h_smir, H_smir, beta_hat] = smir_generator(c, ...
        procFs, ...
        sph_pos(mic, :), ...
        src_pos, ...
        room_dim, ...
        beta, ...
        sph_type, ...
        sph_radius, ...
        sph_mic, ...
        N_harm, ...
        double(nsample), ...
        K, ...
        order, ...
        0, ...
        0, ...
        src_type, ...
        src_ang(mic, :));
    
    
    h_smir = highpass(h_smir', cut_off, procFs)';
    
    IR = h_smir;
    full_path_filename = fullfile(SOFAdbPath);
    writeSOFA(IR, nsample, mic_pos_cart(mic, :), sph_pos(mic, :), full_path_filename)
end













