clear;
close all;
clc;

% add path
addpath('configurations')
addpath('src/lib')
addpath('src/SMIR-Generator/')
addpath('src/RIR-Generator/')
addpath('src/lib/SOFAtoolbox')

config_dir = "configurations";
plot_dir = "plots";

% make dir for saving SOFA files
mkdir(SOFAdbPath)
SOFAstart;

% make dir to save configurations used
JSON_out = fullfile(config_dir, "RIR_generated");
mkdir(JSON_out);

% make fir to save RIR generated by RIR generator
RIR_plot = fullfile(plot_dir, "RIR_plot");
mkdir(RIR_plot);

% make dir to save room configurations
room_config_plot = fullfile(plot_dir, "room");
mkdir(room_config_plot);

% configuration file
fname = 'configuration.json';
file_path = fullfile("configurations/",fname);

% containers
utils = utilsContainer;
plotcontainer = plotfunctionsContainer;
JSONio = JSONContainer;

%% read json file
config = JSONio.read_json(file_path);
plot = config.plot;
c = config.c;
procFs = config.procFs;
cut_off = config.cut_off_HP;
K = config.K;
N_harm = config.N_harm;

% source configuration
src_pos = config.source.position;
src_type = config.source.src_type;

% room configuration
room_dim = config.room.dimension;
order = config.room.order;
beta = config.room.beta;

% ULA configuration
ULA_pos = config.ULA.position;
ULA_n = size(config.ULA.position, 1);
ULA_n_mic = config.ULA.n_mic;
ULA_angle = config.ULA.angle;
ULA_step = config.ULA.step;

% spherical microphone array (SMA)
SMA_pos = config.SMA.position;
SMA_type = config.SMA.type; 
SMA_radius = config.SMA.radius;

% nsample 
nsample = int64(beta * 1.5 * procFs);

%% ROOM Configuration 
% positioning the ULA according to axes and rotation
for mic = 1:ULA_n
     % the ULA will be positionated on the x axes
    [x_vet, y_vet] = utils.rotate(ULA_pos, ULA_n_mic, mic, ULA_step);
    z_vet = ULA_pos(mic, 3).* ones(1, ULA_n_mic);

    % the ULA will be rotate of x degree, defined by the variable angle
    Vr = utils.rotation(x_vet, y_vet, z_vet, ULA_angle(mic), plot);
    mic_array(ULA_n_mic*mic-(ULA_n_mic-1):ULA_n_mic*mic, :) = Vr;
end

% optional plot for room configuration
if plot == 1
    save_plot_path = fullfile(room_config_plot, "test.png");
    plotcontainer.plot_room(mic_array, SMA_pos, src_pos, room_dim, save_plot_path)
end

%% RIR generation (for ULA, mic arrra)
parfor source = 1:size(src_pos, 1)
    % generate RIR for mics arrays
    h_rir = rir_generator(c, procFs, mic_array, src_pos(source, :), room_dim, beta, nsample, 'omnidirectional', order, 3, [0 0], false);
    % highpass filter
    h_rir = highpass(h_rir', cut_off, procFs)';


    for mic = 1:ULA_n
        %IR = h_rir(:, (ULA_n_mic*mic-(ULA_n_mic-1):ULA_n_mic*mic));
        IR = h_rir((ULA_n_mic*mic-(ULA_n_mic-1):ULA_n_mic*mic), :);
        %mic_pos = mic_array(ULA_n_mic*mic-(ULA_n_mic-1):ULA_n_mic*mic, :);
        mic_pos = ULA_pos(mic, :);
        receiver_pos = mic_array(ULA_n_mic*mic-(ULA_n_mic-1):ULA_n_mic*mic, :);
        full_path_filename = fullfile(SOFAdbPath);
        writeSOFA(IR, nsample, mic_pos, receiver_pos, full_path_filename)
    end

    % rir plot
    if plot == 1
        for mic = 1:size(mic_array, 1)
            RIR_plot_path = fullfile(RIR_plot, strcat("RIR_test_source_", int2str(source), "_mic_", int2str(mic), ".png"));
            plotcontainer.plot_rir(mic, h_rir, double(nsample), procFs, RIR_plot_path)
        end
    end

    %% SMIR generation
    SMA_n_mic = size(SMA_pos, 1);
    [x, y, z, SMA_mic] = get_eigemike_pos();
    mic_pos_cart = [x, y, z];

    %[src_tmp(:, 1), src_tmp(start:stop, 2)] = mycart2sph(SMA_pos(:, 1)-src_pos(source, 1),SMA_pos(:, 2)-src_pos(source, 2),SMA_pos(:, 3)-src_pos(source, 3)); % Towards the receiver
    [src_ang_1, src_ang_2] = mycart2sph(SMA_pos(:, 1)-src_pos(source, 1),SMA_pos(:, 2)-src_pos(source, 2),SMA_pos(:, 3)-src_pos(source, 3)); % Towards the receiver
    src_ang = [src_ang_1, src_ang_2];

    for mic = 1:SMA_n_mic
        [h_smir, H_smir, beta_hat] = smir_generator(c, ...
            procFs, ...
            SMA_pos(mic, :), ...
            src_pos(source, :), ...
            room_dim, ...
            beta, ...
            SMA_type, ...
            SMA_radius, ...
            SMA_mic, ...
            N_harm, ...
            double(nsample), ...
            K, ...
            order, ...
            0, ...
            0, ...
            src_type(source), ...
            src_ang(mic, :));


        h_smir = highpass(h_smir', cut_off, procFs)';  

        % smir plot
        if plot == 1
            for mic_plot = 1:size(SMA_mic, 1)
                RIR_plot_path = fullfile(RIR_plot, strcat("SMIR_test_source_", int2str(source), "_mic_", int2str(mic_plot), ".png"));
                plotcontainer.plot_rir(mic_plot, h_smir, double(nsample), procFs, RIR_plot_path)
            end
        end

        IR = h_smir;
        full_path_filename = fullfile(SOFAdbPath);
        writeSOFA(IR, nsample, mic_pos_cart(mic, :), SMA_pos(mic, :), full_path_filename)
    end
end

% save JSON file for the RIRs and SMIRs generated
file_JSON_path = fullfile(JSON_out, config.output_config_filename);
JSONio.write_json(config, file_JSON_path);












