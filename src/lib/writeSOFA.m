function [] = writeSOFA(h_rir, nsample, mic_pos, full_path_filename)
    SOFAstart;
    
    %% Get an empy conventions structure
    conventions='GeneralFIR';
    disp(['Creating SOFA file with ' conventions 'conventions...']);
    Obj = SOFAgetConventions(conventions);
    
    % Create the impulse response (we have them)
    N=nsample;
    IR=h_rir;
    R=size(h_rir, 2); %(number of receiveres)
    
    % Fill data with data
    M=1; % only one measurement
    Obj.Data.IR = NaN(M,R,N); % data.IR must be [M R N]
    %Obj.Data.Delay=[0 0];

    for mic = 1:R
        Obj.Data.IR(M,mic,:)=IR(:, mic);
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