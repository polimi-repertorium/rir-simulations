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
    end
end