addpath('configurations');
addpath('src/lib');
addpath('src/SMIR-Generator/');
addpath('src/RIR-Generator/');

room = 'small';
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
disp(config)

%% generate rir with SMIR-Generator
[src_ang(1),src_ang(2)] = mycart2sph(config.sphere.location(1)-config.source.location(1),config.sphere.location(2)-config.source.location(2),config.sphere.location(3)-config.source.location(3)); % Towards the receiver
[mic_pos(:,1), mic_pos(:,2), mic_pos(:,3)] = mysph2cart(mic(:,1),mic(:,2),config.sphere.radius); % Microphone positions relative to centre of array ("sphLocation")
 mic_pos = mic_pos + repmat(config.sphere.location,size(mic,1),1);

for N_harm = 1:2
    
    disp(N_harm);
    disp(class(config.nsample))
    
    [h_smir, H_smir, beta_hat] = smir_generator(config.c, ...
            config.procFs, ...
            config.sphere.location, ...
            config.source.location, ... 
            config.room.dimension, ...
            config.room.beta, ...
            config.sphere.type, ...
            config.sphere.radius, ...
            mic, ...
            N_harm, ...
            config.nsample, ...
            config.K, ...
            config.room.max_order, ...
            0, ...
            0, ...
            config.source.src_type, ...
            src_ang);
    

    % rir generation
    h_rir = 4*pi*rir_generator(config.c, config.procFs, mic_pos, config.source.location, config.room.dimension, config.room.beta, config.nsample, 'omnidirectional', config.room.max_order, 3, [0 0], false);
  
    %create plots and save them as pics into folder
    if (config.room.max_order == 1 || config.room.max_order == 6 || config.room.max_order == 10 || config.room.max_order == 20 || config.room.max_order == 30)
        H_rir = fft(h_rir, [], 2);
        plotcontainer.compare_rir(1, h_rir, h_smir, H_rir, H_smir, config.K, config.nsample, config.procFs)
    end

end 


