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

room = 'big2';
filename = strcat('harmonics_time_', room);
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

% initialization of results arrays
results = zeros(config.N_harm_max,5);

nsample = sprintf("%d", (config.room.beta * 1.5 * config.procFs));
nsample = double(nsample);
fprintf("Nsample: %d", nsample)

for harmonics = 1:config.N_harm_max
    %adding harmonics
    results(harmonics,1) = harmonics;
    
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
            harmonics, ...
            nsample, ...
            config.K, ...
            config.room.order, ...
            0, ...
            0, ...
            config.source.src_type, ...
            src_ang);
    t_smir_end = toc(t_smir_start);
    
    % timing
    results(harmonics,2) = t_smir_end;

    % rir generation
    h_rir = 4*pi*rir_generator(config.c, config.procFs, mic_pos, config.source.location, config.room.dimension, config.room.beta, nsample, 'omnidirectional', config.room.order, 3, [0 0], false);
    err = utils.rir_error(h_rir, h_smir);
    results(harmonics,3) = err;

    %create plots and save them as pics into folder
    if (harmonics == 1 || harmonics == 6 || harmonics == 10 || harmonics == 20 || harmonics == 30)
        H_rir = fft(h_rir, [], 2);
        plotcontainer.compare_rir(1, h_rir, h_smir, H_rir, H_smir, config.K, nsample, config.procFs)
        RIR_filename_path = fullfile(RIR_folder, strcat(filename, '_harmonics_', string(harmonics), '.png'));
        saveas(gcf,RIR_filename_path);
    end

    % T60 SMIR estimation 
    if (harmonics == 1 || harmonics == 6 || harmonics == 10 || harmonics == 20 || harmonics == 30)
        plot_ok=1;
        T60_smir = Estimate_T60(h_smir, config.procFs, plot_ok);
        T60_plot_path = fullfile(T60_folder, strcat(filename, '_smir_harmonics_', string(harmonics), '.png'));
        saveas(gcf,T60_plot_path);
    else
        plot_ok=0;
        T60_smir = Estimate_T60(h_smir, config.procFs, plot_ok);
    end
    results(harmonics,4) = T60_smir;

    % T60 RIR estimation 
    if (harmonics == 1 || harmonics == 6 || harmonics == 10 || harmonics == 20 || harmonics == 30)
        plot_ok=1;
        T60_rir = Estimate_T60(h_rir, config.procFs, plot_ok);
        T60_plot_path = fullfile(T60_folder, strcat(filename, '_rir_harmonics_', string(harmonics), '.png'));
        saveas(gcf,T60_plot_path);
    else
        plot_ok=0;
        T60_rir = Estimate_T60(h_rir, config.procFs, plot_ok);
    end
    results(harmonics,5) = T60_rir;

    results(harmonics,6) = utils.rir_error(T60_smir, T60_rir);
end 

%% save csv file
res_table = array2table(results, "VariableNames",["Harmonics","Time","Error","T60_smir","T60_rir","T60_err"]);
full_file_path = fullfile(csv_folder, strcat('harmonics_', room, '.csv'));
writetable(res_table,full_file_path);


%% plot
% harmonics vs time plot
figure;
plot(res_table.("Harmonics"), res_table.("Time"));
title("Harmonics vs Time");
xlabel("Harmonics")
ylabel("Time (s)")
set(gca,'xtick',0:config.N_harm_max)
ylim([0 900])
filename_path = fullfile(plot_folder, strcat('harmonics_vs_time_', room, '.png'));
saveas(gcf,filename_path)


% harmonics vs error
figure;
plot(res_table.("Harmonics"), res_table.("Error"));
title("Harmonics vs Error");
xlabel("Harmonics")
ylabel("Error SMIR / RIR (dB)")
set(gca,'xtick',1:config.N_harm_max)
ylim([-40 -20])
filename_path = fullfile(plot_folder,strcat('harmonics_vs_error_', room, '.png'));
saveas(gcf,filename_path)

