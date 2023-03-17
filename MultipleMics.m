clear;
close all;
clc;
addpath('configurations');
addpath('src/lib');
addpath('src/SMIR-Generator/');
addpath('src/RIR-Generator/');

% mkdir folders
room_config_folder = ('png/rooms');
plot_folder = ('png/plots');
RIR_folder = ('png/RIR');
T60_folder = ('png/T60');
csv_folder = ('results_csv');

mkdir(csv_folder)
mkdir(plot_folder)
mkdir(room_config_folder)
mkdir(RIR_folder)
mkdir(T60_folder)

room = 'big1';
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

c = config.c;
procFs = config.procFs;
source_location = config.source.location;
room_dimension = config.room.dimension;
room_beta = config.room.beta;
room_order = config.room.order;

t_ULA_start = tic;
parfor i = 1:ULA_n_mic
    h_rir = rir_generator(c, procFs, mic_pos, source_location, room_dimension, room_beta, nsample, 'omnidirectional', room_order, 3, [0 0], false);
end
t_ULA_end = toc(t_ULA_start);
disp(t_ULA_end)

%%
SPHERE_mic_max = 10;
results = zeros(SPHERE_mic_max,2);

sphere_location = config.sphere.location;
sphere_type = config.sphere.type;
sphere_radius = config.sphere.radius;
N_harm = config.N_harm;
K = config.K;
src_type = config.source.src_type;

for n_mic = 1:SPHERE_mic_max
    t_smir_start = tic;
    results(n_mic, 1) = n_mic;
    parfor sphere = 1:n_mic
        fprintf("n_mic: %d; sphere: %d\n", n_mic, sphere)
        [h_smir, H_smir, beta_hat] = smir_generator(c, ...
            procFs, ...
            sphere_location, ...
            source_location, ...
            room_dimension, ...
            room_beta, ...
            sphere_type, ...
            sphere_radius, ...
            mic, ...
            N_harm, ...
            nsample, ...
            K, ...
            room_order, ...
            0, ...
            0, ...
            src_type, ...
            src_ang);
    end  
    t_smir_end = toc(t_smir_start);
    % timing
    results(n_mic,2) = t_smir_end + t_ULA_end;
end


%% save csv file
res_table = array2table(results, "VariableNames",["Multiple_mics","Time"]);
full_file_path = fullfile(csv_folder, strcat('multiple_mics_par_', room, '.csv'));
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
filename_path = fullfile(plot_folder, strcat('multiple_mics_par_', room, '.png'));
saveas(gcf,filename_path)
