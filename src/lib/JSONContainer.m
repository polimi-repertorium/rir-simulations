classdef JSONContainer
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
    end
end
