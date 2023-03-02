addpath('rir-simulations/configurations');
addpath('rir-simulations/src/lib');
addpath('rir-simulations/src/SMIR-Generator/');
addpath('rir-simulations/src/RIR-Generator/');

% mkdir folders
room_config_folder = ('rir-simulations/png/rooms');
plot_folder = ('rir-simulations/png/plots');
RIR_folder = ('rir-simulations/png/RIR');
csv_folder = ('rir-simulations/results_csv');
mkdir(csv_folder)
mkdir(plot_folder)
mkdir(room_config_folder)
mkdir(RIR_folder)

room = 'medium1';
filename = strcat('order_time_', room);
config_fname = strcat(filename, '.json');
file_path  = fullfile("configurations/",config_fname);

% TODO: Mic need to/4e added as angles to the JSON file
mic = [pi/4 pi/4];

% containers
utils = utilsContainer;
plotcontainer = plotfunctionsContainer;
RT60 = RT60functionsContainer;

%% read json file
config = utils.read_json(file_path);


%% generate rir with SMIR-Generator
[src_ang(1),src_ang(2)] = mycart2sph(config.sphere.location(1)-config.source.location(1),config.sphere.location(2)-config.source.location(2),config.sphere.location(3)-config.source.location(3)); % Towards the receiver
[mic_pos(:,1), mic_pos(:,2), mic_pos(:,3)] = mysph2cart(mic(:,1),mic(:,2),config.sphere.radius); % Microphone positions relative to centre of array ("sphLocation")
 mic_pos = mic_pos + repmat(config.sphere.location,size(mic,1),1);

 % plot room 
plotcontainer.plot_room(mic_pos, config.sphere.location, config.source.location, config.room.dimension)
room_filename_path = fullfile(room_config_folder, strcat(filename, '.png'));
saveas(gcf,room_filename_path);

% initialization of results arrays
results = zeros(config.room.max_order,3);

for order = 0:config.room.max_order
    %adding order
    results(order+1,1) = order;
    
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
            config.nsample, ...
            config.K, ...
            order, ...
            0, ...
            0, ...
            config.source.src_type, ...
            src_ang);
    t_smir_end = toc(t_smir_start);
    
    % timing
    results(order+1,2) = t_smir_end;

    h_rir = 4*pi*rir_generator(config.c, config.procFs, mic_pos, config.source.location, config.room.dimension, config.room.beta, config.nsample, 'omnidirectional', order, 3, [0 0], false);
    err = utils.rir_error(h_rir, h_smir);
    results(order+1,3) = err;
   
    %create plots and save them as pics into folder
    if (order == 1 || order == 6 || order == 10 || order == 20)
        H_rir = fft(h_rir, [], 2);
        plotcontainer.compare_rir(1, h_rir, h_smir, H_rir, H_smir, config.K, config.nsample, config.procFs)
        RIR_filename_path = fullfile(RIR_folder, strcat(filename, '_order_', string(order), '.png'));
        saveas(gcf,RIR_filename_path);
    end
end 

%% save csv file
res_table = array2table(results, "VariableNames",["Order","Time","Error"]);
full_file_path = fullfile(csv_folder, strcat('order_time_', room, '.csv'));
writetable(res_table,full_file_path);


%% plot
% order vs time plot
figure;
plot(res_table.("Order"), res_table.("Time"));
title("Order vs Time");
xlabel("Order")
ylabel("Time (s)")
set(gca,'xtick',0:config.room.max_order)
ylim([0 450])
filename_path = fullfile(plot_folder, strcat('order_vs_time_', room, '.png'));
saveas(gcf,filename_path)
%plotcontainer.save_plot(table_test, "Order", "Time", 1:config.room.max_order, [0 results(config.room.max_order, 2)], plot_folder)

% order vs error
figure;
plot(res_table.("Order"), res_table.("Error"));
title("Order vs Error");
xlabel("Order")
ylabel("Error SMIR / RIR (dB)")
set(gca,'xtick',1:config.room.max_order)
ylim([-40 -20])
filename_path = fullfile(plot_folder,strcat('order_vs_error_', room, '.png'));
saveas(gcf,filename_path)
%plotcontainer.save_plot(table_test, "Order", "Error", 1:config.room.max_order, [-40 -20], plot_folder)
