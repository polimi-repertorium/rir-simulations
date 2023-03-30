clear;
close all;
clc;

addpath('configurations');
addpath('src/lib');
addpath('src/SMIR-Generator/');
addpath('src/RIR-Generator/');

test = true;
cut_off = 30;


folder_ext = 'filter';
% mkdir folders
room_config_folder = fullfile('png/rooms', folder_ext);
plot_folder = fullfile('png/plots', folder_ext);
RIR_folder = fullfile('png/RIR', folder_ext);
T60_folder = fullfile('png/T60', folder_ext);
csv_folder = fullfile('results_csv', folder_ext);

mkdir(csv_folder)
mkdir(plot_folder)
mkdir(room_config_folder)
mkdir(RIR_folder)
mkdir(T60_folder)

room = 'medium1';
extension = '_HP';
filename = strcat('order_time_', room);
config_fname = strcat(filename, '.json');
file_path  = fullfile("configurations/",config_fname);


% TODO: Mic need to/4e added as angles to the JSON file
mic = [pi/4 pi/4];

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
%fprintf("Nsample: %d", nsample)

%% plot room 
%plotcontainer.plot_room(mic_pos, config.sphere.location, config.source.location, config.room.dimension)
%room_filename_path = fullfile(room_config_folder, strcat(filename, extension, '.png'));
%saveas(gcf,room_filename_path);

%% initialization of results array
if test == false
    order_tested = [10, 20, 30];
else
    order_tested = [6];
end
results = zeros(length(order_tested),6);

for order = 1:length(order_tested)
    %adding order
    results(order,1) = order_tested(order);
    
    t_smir_start = tic;
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
            order_tested(order), ...
            0, ...
            0, ...
            config.source.src_type, ...
            src_ang);

    t_smir_end = toc(t_smir_start);
    
    % timing
    results(order,2) = t_smir_end;

    % rir generation
    h_rir = 4*pi*rir_generator(config.c, config.procFs, mic_pos, config.source.location, config.room.dimension, config.room.beta, nsample, 'omnidirectional', order_tested(order), 3, [0 0], false);
    
    err = utils.rir_error(h_rir,  h_smir);
    results(order,3) = err;

    %create plots and save them as pics into folder
    H_rir = fft(h_rir, [], 2);

    
    %% apply filter 30 Hzto the rir generated
    procFs = config.procFs;

    %filter in time
    h_smir_filtered = highpass(h_smir', cut_off, procFs)';
    h_rir_filtered = highpass(h_rir', cut_off, procFs)';
    
    %filter in frequency
    H_rir_filtered = highpass(H_rir', cut_off, procFs)';
    H_smir_filtered = highpass(H_smir', cut_off, procFs)';
    
    
    %% plot
    % compare rir and smir
    plotcontainer.compare_rir(1, h_rir, h_smir, H_rir, H_smir, config.K, nsample, config.procFs)
    RIR_filename_path = fullfile(RIR_folder, strcat(filename, extension, '_order_', string(order_tested(order)), '.png'));
    saveas(gcf,RIR_filename_path);

    % compare rir and smir filtered
    plotcontainer.compare_rir(1, h_rir_filtered, h_smir_filtered, H_rir_filtered, H_smir_filtered, config.K, nsample, config.procFs)
    RIR_filename_path = fullfile(RIR_folder, strcat(filename, extension, '_order_', string(order_tested(order)), '_filtered.png'));
    saveas(gcf,RIR_filename_path);
    %% T60 estimation
    h_smir = h_smir_filtered;
    h_rir = h_rir_filtered;
    H_smir = H_smir_filtered;
    H_rir = H_rir_filtered;
    
    % T60 SMIR estimation 
    plot_ok=1;
    T60_smir = Estimate_T60(h_smir, config.procFs, plot_ok);
    T60_plot_path = fullfile(T60_folder, strcat(filename, extension, '_smir_order_', string(order_tested(order)), '.png'));
    saveas(gcf,T60_plot_path);
    results(order,4) = T60_smir;

    % T60 RIR estimation 
    plot_ok=1;
    T60_rir = Estimate_T60(h_rir, config.procFs, plot_ok);
    T60_plot_path = fullfile(T60_folder, strcat(filename, extension, '_rir_order_', string(order_tested(order)), '.png'));
    saveas(gcf,T60_plot_path);
    results(order,5) = T60_rir;

    % rir_error
    results(order,6) = utils.rir_error(T60_smir, T60_rir);
end 

%% save csv file
res_table = array2table(results, "VariableNames",["Order","Time","Error","T60_smir","T60_rir","T60_err"]);
full_file_path = fullfile(csv_folder, strcat('order_time_', room, '_', extension, '.csv'));
writetable(res_table,full_file_path);


%% plot
% order vs time plot
figure;
plot(res_table.("Order"), res_table.("Time"));
title("Order vs Time");
xlabel("Order")
ylabel("Time (s)")
set(gca,'xtick',0:config.room.max_order)
ylim([0 900])
filename_path = fullfile(plot_folder, strcat('order_vs_time_', room, '_', extension, '.png'));
saveas(gcf,filename_path)


% order vs error
figure;
plot(res_table.("Order"), res_table.("Error"));
title("Order vs Error");
xlabel("Order")
ylabel("Error SMIR / RIR (dB)")
set(gca,'xtick',1:config.room.max_order)
ylim([-40 -20])
filename_path = fullfile(plot_folder,strcat('order_vs_error_', room, '_', extension, '.png'));
saveas(gcf,filename_path)

