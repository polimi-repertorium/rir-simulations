%% save csv file
filenames = ["small", "medium1"];
rooms_config = ["3*4*2 - 0.3", "5*4*2.5 - 0.5"];
csv_folder = ('rir-simulations/results_csv');
plot_folder = ('rir-simulations/png/plots');

n_test = length(filenames);

tables = cell(n_test, 1);

for file_id = 1:n_test
    full_file_path = fullfile(csv_folder, strcat('multiple_mics_', filenames(file_id), '.csv'));
    tables{file_id} = table2cell(readtable(full_file_path));
end

%% plot
linewidth = 2;

%% order vs time plot
figure;
for i = 1:n_test
    plot(cell2mat(tables{i}(:, 1)), (cell2mat(tables{i}(:, 2))*1/60), 'LineWidth', linewidth);
    hold on;
end    
grid on;
grid minor;
title("Sphere Mics - Time");
xlabel("Spherical Mics")
ylabel("Time (m)")
set(gca,'xtick',0:30+1)
ylim([0 120])
filename_path = fullfile(plot_folder, 'spheremics_vs_time_all.png');
legend(rooms_config)
saveas(gcf,filename_path)