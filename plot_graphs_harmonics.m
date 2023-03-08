%% save csv file
filenames = ["small", "medium1", "medium2", "big1", "big2"];
csv_folder = ('rir-simulations/results_csv');
plot_folder = ('rir-simulations/png/plots');

n_test = length(filenames);

tables = cell(n_test, 1);

for file_id = 1:n_test
    full_file_path = fullfile(csv_folder, strcat('harmonics_', filenames(file_id), '.csv'));
    tables{file_id} = table2cell(readtable(full_file_path));
end

%% plot
linewidth = 2;

%% order vs time plot
figure;
for i = 1:n_test
    plot(cell2mat(tables{i}(:, 1)), cell2mat(tables{i}(:, 2)), 'LineWidth', linewidth);
    hold on;
end    
grid on;
grid minor;
title("Harmonics - Time");
xlabel("Order")
ylabel("Time (s)")
set(gca,'xtick',0:30+1)
ylim([0 800])
filename_path = fullfile(plot_folder, 'harmonics_vs_time_all.png');
legend(filenames)
saveas(gcf,filename_path)


%% order vs error plot
figure;
for i = 1:n_test
    plot(cell2mat(tables{i}(:, 1)), cell2mat(tables{i}(:, 3)), 'LineWidth', linewidth);
    hold on;
end  
grid on;
grid minor;
title("Harmonics - Error");
xlabel("Harmonics")
ylabel("Error SMIR / RIR (dB)")
set(gca,'xtick',1:30+1)
ylim([-35 -15])
filename_path = fullfile(plot_folder, 'harmonics_vs_error_all.png');
legend(filenames)
saveas(gcf,filename_path)


%% order vs T60 (smir)
figure;
for i = 1:n_test
    plot(cell2mat(tables{i}(:, 1)), cell2mat(tables{i}(:, 4)), 'LineWidth', linewidth);
    hold on;
end  
grid on;
grid minor;
title("Harmonics - T60 (SMIR)");
xlabel("Harmonics")
ylabel("T60 estimation SMIR (s)")
set(gca,'xtick',1:30+1)
ylim([0 7])
filename_path = fullfile(plot_folder, 'harmonics_vs_T60smir_all.png');
legend(filenames)
saveas(gcf,filename_path)

%% order vs T60 (rir)
figure;
for i = 1:n_test
    plot(cell2mat(tables{i}(:, 1)), cell2mat(tables{i}(:, 5)), 'LineWidth', linewidth);
    hold on;
end  
grid on;
grid minor;
title("Harmonics - T60 (RIR)");
xlabel("Harmonics")
ylabel("T60 estimation RIR (s)")
set(gca,'xtick',1:30+1)
ylim([0 2])
filename_path = fullfile(plot_folder, 'harmonics_vs_T60rir_all.png');
legend(filenames)
saveas(gcf,filename_path)