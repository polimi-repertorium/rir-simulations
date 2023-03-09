clear;
close all;
clc;
addpath('rir-simulations/configurations');
addpath('rir-simulations/src/lib');
addpath('rir-simulations/src/SMIR-Generator/');
addpath('rir-simulations/src/RIR-Generator/');

% mkdir folders
room_config_folder = ('rir-simulations/png/rooms');
plot_folder = ('rir-simulations/png/plots');
RIR_folder = ('rir-simulations/png/RIR');
T60_folder = ('rir-simulations/png/T60');
csv_folder = ('rir-simulations/results_csv');

mkdir(csv_folder)
mkdir(plot_folder)
mkdir(room_config_folder)
mkdir(RIR_folder)
mkdir(T60_folder)

room = 'medium1';
filename = strcat('multiple_mics_', room);
config_fname = strcat(filename, '.json');
file_path  = fullfile("configurations/",config_fname);

% TODO: Mic need to/4e added as angles to the JSON file
[x, y, z, mic] = get_eigemike_pos();
% mic = [pi/4 pi/4; pi/4 pi/4];

% containers
utils = utilsContainer;
plotcontainer = plotfunctionsContainer;

%% read json file
config = utils.read_json(file_path);

%% generate rir with SMIR-Generator
[src_ang(1),src_ang(2)] = mycart2sph(config.sphere.location(1)-config.source.location(1),config.sphere.location(2)-config.source.location(2),config.sphere.location(3)-config.source.location(3)); % Towards the receiver

[mic_pos(:,1), mic_pos(:,2), mic_pos(:,3)] = mysph2cart(mic(:,1),mic(:,2),config.sphere.radius); % Microphone positions relative to centre of array ("sphLocation")
 mic_pos = mic_pos + repmat(config.sphere.location,size(mic,1),1);

nsample = sprintf("%d", (config.room.beta * 1.5 * config.procFs));
nsample = double(nsample);
fprintf("Nsample: %d", nsample)


%% setting ULA mics (always same value, need to be changed)
ULA_n_mic = 64;
ULA=[config.ULA.position(1)*ones(ULA_n_mic,1), config.ULA.position(2)*ones(ULA_n_mic,1), config.ULA.position(3)*ones(ULA_n_mic,1)];

t_ULA_start = tic;
for i = 1:ULA_n_mic
    h_rir = rir_generator(config.c, config.procFs, mic_pos, config.source.location, config.room.dimension, config.room.beta, nsample, 'omnidirectional', config.room.order, 3, [0 0], false);
end
t_ULA_end = toc(t_ULA_start);
disp(t_ULA_end)

%%
SPHERE_mic_max = 3;
results = zeros(SPHERE_mic_max,2);

for n_mic = 1:SPHERE_mic_max
    results(n_mic, 1) = n_mic;
    t_smir_start = tic;
    for sphere = 1:n_mic
        fprintf("n_mic: %d; sphere: %d\n", n_mic, sphere)
        [h_smir, H_smir, beta_hat] = smir_generator(config.c, ...
            config.procFs, ...
            config.sphere.location, ...
            config.source.location, ...
            config.room.dimension, ...
            config.room.beta, ...
            config.sphere.type, ...
            config.sphere.radius, ...
            mic, ...
            config.N_harm, ...
            nsample, ...
            config.K, ...
            config.room.order, ...
            0, ...
            0, ...
            config.source.src_type, ...
            src_ang);
    end
    t_smir_end = toc(t_smir_start);
        
    % timing
    results(n_mic,2) = t_smir_end + t_ULA_end;
end


%% save csv file
res_table = array2table(results, "VariableNames",["Multiple_mics","Time"]);
full_file_path = fullfile(csv_folder, strcat('multiple_mics_', room, '.csv'));
writetable(res_table,full_file_path);

%% plot
% harmonics vs time plot
figure;
plot(res_table.("Multiple_mics"), res_table.("Time"));
title("Multiple mics vs Time");
xlabel("Multiple mics")
ylabel("Time (s)")
set(gca,'xtick',1:20)
ylim([160 250])
filename_path = fullfile(plot_folder, strcat('multiple_mics_', room, '.png'));
saveas(gcf,filename_path)
