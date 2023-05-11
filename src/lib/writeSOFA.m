function [] = writeSOFA(rir, nsample, mic_pos, receiver_pos, full_path_filename)
    SOFAstart;
    
    %% Get an empy conventions structure
    conventions='SingleRoomSRIR';
    disp(['Creating SOFA file with ' conventions 'conventions...']);
    Obj = SOFAgetConventions(conventions);
    
    % Create the impulse response (we have them)
    N=int64(nsample);
    IR=rir;
    R=size(rir, 1); %(number of receiveres)

    % Fill data with data
    M=1; % only one measurement
    Obj.Data.IR = zeros(M,R,N); % data.IR must be [M R N]
    Obj.Data.Delay = zeros(1, R);
    Obj.ReceiverPosition_Type = 'cartesian';
    Obj.EmitterPosition_Type = 'cartesian';
    Obj.ReceiverPosition_Units = 'metre, metre, metre';
    Obj.EmitterPosition_Units = 'metre, metre, metre';
    
    Obj.Data.IR(1,:,:)=IR(:, :);
    Obj.ListenerPosition(:,:)=mic_pos(:, :);
    Obj.ReceiverPosition=receiver_pos(:, :);
   
    
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