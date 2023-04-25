classdef utilsContainer
    methods
        function config = read_json(~, fname)
            fid = fopen(fname); 
            raw = fread(fid,inf); 
            str = char(raw'); 
            fclose(fid);
            config = jsondecode(str);
        end

        function [] = write_json(~, json_data, fname)
            if size(json_data.room.dimension, 1) == 1
                json_data.room.dimension = {json_data.room.dimension};
            end

            if size(json_data.source.position, 1) == 1
                json_data.source.position = {json_data.source.position};
            end

            if size(json_data.ULA.position, 1) == 1
                json_data.ULA.position = {json_data.ULA.position};
            end

            if size(json_data.SMA.position, 1) == 1
                json_data.ULA.position = {json_data.ULA.position};
            end

            json_data = jsonencode(json_data);
            fid = fopen(fname, 'w');
            fprintf(fid, '%s', json_data);
            fclose(fid);
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

        function [rot, stat] = rotate(~, ULA_pos, n_mic_ULA, mic, step)
            dim_pos = 1;
            dim_sta = 2;
            stat = ULA_pos(mic, dim_sta).* ones(1, n_mic_ULA);
            rot = ULA_pos(mic, dim_pos):step:(ULA_pos(mic, dim_pos)+(step*(n_mic_ULA-1)));
        end 

        function [Vr] = rotation(~, x, y, z, a, plot)
    
            %Vertices matrix
            V=[x(:) y(:) z(:)];
            
            V_centre=mean(V,1); %Centre, of line
            Vc=V-ones(size(V,1),1)*V_centre; %Centering coordinates
            a_rad=((a*pi)./180); %Angle in radians
            
            E=[0  0 a_rad]; %Euler angles for X,Y,Z-axis rotations
            
            %Direction Cosines (rotation matrix) construction
            Rx=[1        0        0;...
                0        cos(E(1))  -sin(E(1));...
                0        sin(E(1))  cos(E(1))]; %X-Axis rotation
            
            Ry=[cos(E(2))  0        sin(E(2));...
                0        1        0;...
                -sin(E(2)) 0        cos(E(2))]; %Y-axis rotation
            
            Rz=[cos(E(3))  -sin(E(3)) 0;...
                sin(E(3))  cos(E(3))  0;...
                0        0        1]; %Z-axis rotation
            
            R=Rx*Ry*Rz; %Rotation matrix
            Vrc=[R*Vc']'; %Rotating centred coordinates
            %Vruc=[R*V']'; %Rotating un-centred coordinates
            Vr=Vrc+ones(size(V,1),1)*V_centre; %Shifting back to original location
            
            %if plot == 1
            %    figure;
            %    plot3(V(:,1),V(:,2),V(:,3), 'g.-', MarkerSize=25);  
            %    hold on; %Original
            %    plot3(Vr(:,1),Vr(:,2),Vr(:,3),'r.-', MarkerSize=25); %Rotated around centre of line
            %    %scatter3(Vruc(:,1),Vruc(:,2),Vruc(:,3),'b'); %Rotated around origin
            %    grid on;
            %end
        end 

    end
end
