addpath('rir-simulations/configurations')
addpath('rir-simulations/src/lib')
addpath('rir-simulations/src/SMIR-Generator/')
addpath('rir-simulations/src/RIR-Generator/')

fname = 'order_vs_time.json';
file_path  = fullfile("configurations/",fname);

% TODO: Mic need to/4e added as angles to the JSON file
mic = [pi/4 pi/4];

% containers
utils = utilsContainer;
plotcontainer = plotfunctionsContainer;
RT60 = RT60functionsContainer;

%% read json file
config = utils.read_json(file_path);
display(config)

%% generate rir with SMIR-Generator
[src_ang(1),src_ang(2)] = mycart2sph(config.sphere.location(1)-config.source.location(1),config.sphere.location(2)-config.source.location(2),config.sphere.location(3)-config.source.location(3)); % Towards the receiver
[mic_pos(:,1), mic_pos(:,2), mic_pos(:,3)] = mysph2cart(mic(:,1),mic(:,2),config.sphere.radius); % Microphone positions relative to centre of array ("sphLocation")
 mic_pos = mic_pos + repmat(config.sphere.location,size(mic,1),1);

 % plot room 
plotcontainer.plot_room(mic_pos, config.sphere.location, config.source.location, config.room.dimension)
results = zeros(config.room.max_order,3);

for order = 1:config.room.max_order
    %adding order
    results(order,1) = order;
    
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
    results(order,2) = t_smir_end;

    h_rir = 4*pi*rir_generator(config.c, config.procFs, mic_pos, config.source.location, config.room.dimension, config.room.beta, config.nsample, 'omnidirectional', order, 3, [0 0], false);
    err = utils.rir_error(h_rir, h_smir);
    results(order,3) = err;
   
    %create plots and save them as pics into folder
    %H_rir = fft(h_rir, [], 2);
    %plotcontainer.compare_rir(1, h_rir, h_smir, H_rir, H_smir, config.K, config.nsample, config.procFs)
 
end 

%% plot
table_test = array2table(results, "VariableNames",["Order","Time","Error"]);
writetable(table_test,"test.csv");
M = readtable("test.csv");

figure;
plot(M.("Order"), M.("Error"));
saveas(gcf,'lineplot.png')









