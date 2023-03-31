%% Get an empy conventions structure
function [] = saveRIR(h_rir)
    conventions='SingleRoomSRIR';
    disp(['Creating SOFA file with ' conventions 'conventions...']);
    Obj = SOFAgetConventions(conventions);
    
    %% Fill random data...
    Obj.Data.IR=rand;
    Obj.ListenerPosition=zeros(36000,3); Obj.ListenerPosition(:,1)=1;
    Obj.SourcePosition=zeros(36000,3); Obj.SourcePosition(:,2)=1;
    
    % Add ReceiverDescriptions as string array
    str={};
    for ii=1:Obj.API.R
      str{ii,1}=['String' num2str(round(rand(1,1)*10000))];
    end
    Obj = SOFAaddVariable(Obj,'ReceiverDescriptions','RS',str);
    
    
    %% Update dimensions
    Obj=SOFAupdateDimensions(Obj);
    
    %% Fill with attributes
    Obj.GLOBAL_ListenerShortName = 'dummy';
    Obj.GLOBAL_History = 'created with a demo script';
    Obj.GLOBAL_DatabaseName = 'none';
    Obj.GLOBAL_ApplicationName = 'Demo of the SOFA Toolbox';
    Obj.GLOBAL_ApplicationVersion = SOFAgetVersion('API');
    Obj.GLOBAL_Organization = 'Acoustics Research Institute';
    Obj.GLOBAL_AuthorContact = 'michael.mihocic@oeaw.ac.at';
    
    %% save the SOFA file
    SOFAfn=fullfile(SOFAdbPath,'sofatoolbox_test',[conventions '_' Obj.GLOBAL_SOFAConventionsVersion '.sofa']);
    disp(['Saving:  ' SOFAfn]);
    Obj=SOFAsave(SOFAfn, Obj);
end 
