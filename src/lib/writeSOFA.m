function [] = writeSOFA(rir, nsample, mic_pos, full_path_filename)
    SOFAstart;
    
    %% Get an empy conventions structure
    conventions='GeneralFIR';
    disp(['Creating SOFA file with ' conventions 'conventions...']);
    Obj = SOFAgetConventions(conventions);
    
    % Create the impulse response (we have them)
    N=nsample;
    IR=rir;
    R=size(rir, 2); %(number of receiveres)
    disp(R)
    
    % Fill data with data
    M=1; % only one measurement
    Obj.Data.IR = NaN(R,M,N); % data.IR must be [M R N]
    

    for mic = 1:R
        Obj.Data.IR(mic,1,:)=IR(:, mic);
        Obj.SourcePosition(mic,:)=mic_pos(mic, :);
    end
    
    %% Update dimensions
    Obj=SOFAupdateDimensions(Obj);
    
    %% Fill with attributes
    Obj.GLOBAL_ListenerShortName = 'ULA';
    Obj.GLOBAL_History = 'pipeline test';
    Obj.GLOBAL_DatabaseName = 'none';
    Obj.GLOBAL_ApplicationName = 'REPERTORIUM porject';
    Obj.GLOBAL_ApplicationVersion = SOFAgetVersion('API');
    Obj.GLOBAL_Organization = 'Politecnico di Milano';
    Obj.GLOBAL_AuthorContact = 'francesca.ronchini@polimi.it';
    Obj.GLOBAL_Comment = 'Contains simple pulses for mic array containing 4 receivers';
    
    %% save the SOFA file
    SOFAfn=fullfile(full_path_filename,[conventions 'test.sofa']);
    disp(['Saving:  ' SOFAfn]);
    Obj=SOFAsave(SOFAfn, Obj);
end