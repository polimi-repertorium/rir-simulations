classdef utilsContainer
    methods
        function config = read_json(~, fname)
            fid = fopen(fname); 
            raw = fread(fid,inf); 
            str = char(raw'); 
            fclose(fid);
            config = jsondecode(str);
        end

        function freq = room_mode(~, c, room_dim, Nx, Ny, Nz)
            freq = c/2 * sqrt(((Nx/room_dim(1))^2) + ((Ny/room_dim(2))^2) + ((Nz/room_dim(3))^2));
            display(freq)
            
        end

        function err = rir_error(~, h_smir, h_rir)
            err = 10*log10(sqrt(mean((h_smir-h_rir).^2)));
        end

        % change function name
        function [] = save_file(~, gcf, dir, filename)
            mkdir(dir)
            filename_path = fullfile(dir,filename);
            saveas(gcf,filename_path)
        end

    end
end
