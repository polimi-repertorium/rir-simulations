classdef plotfunctionsContainer
    methods
        function [] = plot_rir(~, mic_to_plot, h, nsample, procFs, RIR_plot_path)
            figure;
            plot([0:nsample-1]/procFs, h(mic_to_plot,1:nsample), 'r')
            xlim([0 (nsample-1)/procFs]);
            title(['Room impulse response at microphone ', num2str(mic_to_plot)]);
            xlabel('Time (s)');
            ylabel('Amplitude'); 
            if exist('RIR_plot_path', 'var')
                saveas(gcf, RIR_plot_path)
            end
        end 


        function [] = compare_rir(~, mic_to_plot, h_rir, h_smir, H_rir, H_smir, K, nsample, procFs)

            figure;
            subplot(211);
            plot([0:nsample-1]/procFs, h_rir(mic_to_plot,1:nsample), 'g')
            hold all;
            plot([0:nsample-1]/procFs,h_smir(mic_to_plot,1:nsample), 'r')
            xlim([0 (nsample-1)/procFs]);
            title(['Room impulse response at microphone ', num2str(mic_to_plot)]);
            xlabel('Time (s)');
            ylabel('Amplitude');
            legend('RIR generator', 'SMIR generator');
            
            subplot(212);
            plot((0:1/nsample:1/2)*procFs,mag2db(abs(H_rir(mic_to_plot,1:nsample/2+1))), 'g');
            hold all;
            plot((0:1/(K*nsample):1/2)*procFs,mag2db(abs(H_smir(mic_to_plot,1:K*nsample/2+1))), 'r');
            title(['Room transfer function magnitude at microphone ', num2str(mic_to_plot)]);
            xlabel('Frequency (Hz)');
            ylabel('Amplitude (dB)');
            legend('RIR generator', 'SMIR generator');
        end 

        function [] = plot_rir_smir(~, mic_to_plot, h1, h2, nsample, procFs)
            figure;
            subplot(211);
            plot([0:nsample-1]/procFs, h1(mic_to_plot,1:nsample), 'r');
            hold all;
            plot([0:nsample-1]/procFs, h2(mic_to_plot,1:nsample), 'b');
            xlim([0 (nsample-1)/procFs]);
            title(['Room impulse response at microphone ', num2str(mic_to_plot)]);
            xlabel('Time (s)');
            ylabel('Amplitude');
            legend('RIR generator', 'SMIR generator');
        end 

        function [] = plot_configuration(~, mic_to_plot, h1, h2, nsample, procFs)
            figure;
            subplot(211);
            plot([0:nsample-1]/procFs, h1(mic_to_plot,1:nsample), 'r');
            hold all;
            plot([0:nsample-1]/procFs, h2(mic_to_plot,1:nsample), 'b');
            xlim([0 (nsample-1)/procFs]);
            title(['Room impulse response at microphone ', num2str(mic_to_plot)]);
            xlabel('Time (s)');
            ylabel('Amplitude');
            legend('RIR generator', 'SMIR generator');
        end 

        function [] = plot_room(~, mic_array, SMA_pos, src_pos, room_dim, save_plot_path)
            % the room configuration will be plotted (make function)
            figure;
            scatter3(mic_array(:,1), mic_array(:,2), mic_array(:,3), 'filled');
            hold on;
            xlim([0, room_dim(1)])
            ylim([0, room_dim(2)])
            zlim([0, room_dim(3)])
            scatter3(src_pos(:, 1), src_pos(:, 2), src_pos(:, 3), 'filled');
            hold all;
            scatter3(SMA_pos(:, 1), SMA_pos(:, 2), SMA_pos(:, 3), 'filled');
            legend('Microphone arrays positions', 'Source position', 'Spherical microphone arrays position', 'Location', 'best');
            if exist('save_plot_path', 'var')
                saveas(gcf, save_plot_path)
            end
        end

        function [] = plot_frequency_RIR(~, H, procFs, nsample)
            figure;
            plot((0:1/nsample:1/2)*procFs,mag2db(abs(H(1,1:nsample/2+1))), 'g');
            title('Room transfer function magnitude at microphone');
            xlim([0 nsample])
            xlabel('Frequency (Hz)');
            ylabel('Amplitude (dB)');
            legend('RIR generator');
        end


        function [] = save_plot(~, table, x, y, x_range, y_range, dir)
            figure;
            plot(table.(x), table.(y));
            title(strcat(x, ' vs ', y));
            xlabel(x)
            ylabel(y)
            set(gca,'xtick',x_range)
            ylim(y_range)
            filename_path = fullfile(dir,x+'_vs_'+y+'.png');
            saveas(gcf,filename_path)
        end
    end
end
