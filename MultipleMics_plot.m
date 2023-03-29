close all;
clc;
filenames = ["small", "medium1", "medium2", "big1", "big2"];
rooms_config = ["3*4*2 - 0.3", "5*4*2.5 - 0.5", "11*6*3 - 0.6", "7*20*4 - 1.3", "7*20*4 - 2.0"];
csv_folder = ('results_csv');
plot_folder = ('png/plots');

n_test = length(filenames);
tables = cell(n_test, 1);
tables_par = cell(n_test, 1);

for file_id = 1:n_test
    full_file_path = fullfile(csv_folder, strcat('multiple_mics_', filenames(file_id), '.csv'));
    tables{file_id} = table2cell(readtable(full_file_path));
    full_file_path_par = fullfile(csv_folder, strcat('multiple_mics_par_', filenames(file_id), '.csv'));
    tables_par{file_id} = table2cell(readtable(full_file_path_par));
end

%% plot
linewidth = 2;
rooms_config_2 = ["3*4*2 - 0.3 (for)", "3*4*2 - 0.3 (par)", "5*4*2.5 - 0.5 (for)", "5*4*2.5 - 0.5 (par)", "11*6*3 - 0.6 (for)", "11*6*3 - 0.6 (par)", "7*20*4 - 1.3 (for)", "7*20*4 - 1.3 (par)", "7*20*4 - 2.0 (for)", "7*20*4 - 2.0 (par)"];

% order vs T60 (smir)
figure;
for i = 1:n_test
    plot(cell2mat(tables{i}(:, 1)), (cell2mat(tables{i}(:, 2))*1/60), 'LineWidth', linewidth);
    hold on;
    plot(cell2mat(tables{i}(:, 1)), (cell2mat(tables_par{i}(:, 2))*1/60), '--', 'LineWidth', linewidth);
    hold on;
end  
grid on;
grid minor;
title("Mics - Time (m)");
xlabel("Mics")
ylabel("Time (m)")
set(gca,'xtick',1:30+1)
ylim([0 250])
filename_path = fullfile(plot_folder, 'mics_vs_time.png');
legend(rooms_config_2, 'Location', 'northwest')
saveas(gcf,filename_path)

% single plots
figure;
for i = 1:n_test
    plot(cell2mat(tables{i}(:, 1)), (cell2mat(tables{i}(:, 2))*1/60), 'LineWidth', linewidth);
    hold on;
end  
grid on;
grid minor;
title("Mics - Time (m) using for");
xlabel("Mics")
ylabel("Time (m)")
set(gca,'xtick',1:30+1)
ylim([0 250])
filename_path = fullfile(plot_folder, 'mics_vs_time_par.png');
legend(rooms_config, 'Location', 'northwest')
saveas(gcf,filename_path)

% single plots
figure;
for i = 1:n_test
    plot(cell2mat(tables{i}(:, 1)), (cell2mat(tables_par{i}(:, 2))*1/60), 'LineWidth', linewidth);
    hold on;
end  
grid on;
grid minor;
title("Mics - Time (m) using parfor");
xlabel("Mics")
ylabel("Time (m)")
set(gca,'xtick',1:30+1)
ylim([0 150])
filename_path = fullfile(plot_folder, 'mics_vs_time_par.png');
legend(rooms_config, 'Location', 'northwest')
saveas(gcf,filename_path)



