%% save csv file
filenames = ["small", "medium1", "medium2", "big1", "big2"];
csv_folder = ('rir-simulations/results_csv');
plot_folder = ('rir-simulations/png/plots');

n_test = length(filenames);

tables = cell(n_test, 1);

for file_id = 1:n_test
    full_file_path = fullfile(csv_folder, strcat('order_time_', filenames(file_id), '.csv'));
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
title("Order - Time");
xlabel("Order")
ylabel("Time (s)")
set(gca,'xtick',0:30+1)
ylim([0 1400])
filename_path = fullfile(plot_folder, 'order_vs_time_all.png');
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
title("Order - Error");
xlabel("Order")
ylabel("Error SMIR / RIR (dB)")
set(gca,'xtick',1:30+1)
ylim([-45 -20])
filename_path = fullfile(plot_folder, 'order_vs_error_all.png');
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
title("Order - T60 (SMIR)");
xlabel("Order")
ylabel("T60 estimation SMIR (s)")
set(gca,'xtick',1:30+1)
ylim([0 7])
filename_path = fullfile(plot_folder, 'order_vs_T60smir_all.png');
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
title("Order - T60 (RIR)");
xlabel("Order")
ylabel("T60 estimation RIR (s)")
set(gca,'xtick',1:30+1)
ylim([0 2.5])
filename_path = fullfile(plot_folder, 'order_vs_T60rir_all.png');
legend(filenames)
saveas(gcf,filename_path)