%% read csv file
filenames = ["small", "medium1", "medium2", "big1", "big2"];
rooms_config = ["3*4*2 - 0.3", "5*4*2.5 - 0.5", "11*6*3 - 0.6", "7*20*4 - 1.3", "7*20*4 - 2.0"];
csv_folder = ('results_csv/filter');
plot_folder = ('png/plots/filter');

n_test = length(filenames);
tables = cell(n_test, 1);

for file_id = 1:n_test
    full_file_path = fullfile(csv_folder, strcat('order_time_', filenames(file_id), '__filter.csv'));
    tables{file_id} = table2cell(readtable(full_file_path));
end

%% plot
linewidth = 2;
rooms_config_2 = ["3*4*2 - 0.3 (smir)", "3*4*2 - 0.3 (rir)", "5*4*2.5 - 0.5 (smir)", "5*4*2.5 - 0.5 (rir)", "11*6*3 - 0.6 (smir)", "11*6*3 - 0.6 (rir)", "7*20*4 - 1.3 (smir)", "7*20*4 - 1.3 (rir)", "7*20*4 - 2.0 (smir)", "7*20*4 - 2.0 (rir)"];

% order vs T60 (smir)
figure;
for i = 1:n_test
    plot(cell2mat(tables{i}(:, 1)), cell2mat(tables{i}(:, 4)), 'LineWidth', linewidth);
    hold on;
    plot(cell2mat(tables{i}(:, 1)), cell2mat(tables{i}(:, 5)), '--','LineWidth', linewidth);
    hold on;
end  
grid on;
grid minor;
title("Order - T60 (SMIR)");
xlabel("Order")
ylabel("T60 estimation SMIR (s)")
set(gca,'xtick',1:30+1)
ylim([0 2.5])
filename_path = fullfile(plot_folder, 'order_vs_T60_all_filter.png');
legend(rooms_config_2, 'Location', 'northwest')
saveas(gcf,filename_path)

% single plots
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
ylim([0 2.5])
filename_path = fullfile(plot_folder, 'order_vs_T60smir_filter.png');
legend(rooms_config)
saveas(gcf,filename_path)

% order vs T60 (rir)
figure;
for i = 1:n_test
    plot(cell2mat(tables{i}(:, 1)), cell2mat(tables{i}(:, 5)),'LineWidth', linewidth);
    hold on;
end  
grid on;
grid minor;
title("Order - T60 (RIR)");
xlabel("Order")
ylabel("T60 estimation RIR (s)")
set(gca,'xtick',1:30+1)
ylim([0 2.5])
filename_path = fullfile(plot_folder, 'order_vs_T60rir_filter.png');
legend(rooms_config)
saveas(gcf,filename_path)
