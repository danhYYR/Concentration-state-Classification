%% Load event data .cdt based on loadcurry function
% This is the subfunction from loadcurry function
% The requirement input is path of .cdt data
% Output is the matrix with field
    % numsamples
    % numchannel;
    % numTrials;
    % samplingFreq;
    % offsetUsec;
    % isASCII;
    % multiplex;
    % sampleTime

function [event]=  Loadeventdata(path)
    [folder,file,ext] = fileparts(path);
    
    switch ext
        case ".cdt"
            parameterFile = [path,'.dpa'];
            parameterFile2 = [path,'.dpo'];
            eventFile = [path,'.cef'];
            eventFile2 = [path,'.ceo'];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % open parameter file
            fid = fopen(parameterFile,'rt');
            % open alternative parameter file
            if fid < 0
            fid = fopen(parameterFile2,'rt');
            end
            cell = textscan(fid,'%s','whitespace','','endofline','§');
            fclose(fid);
            cont = cell2mat(cell{1});
            % read parameters from parameter file
            % tokens (second line is for Curry 6 notation)
            tok = { 'NumSamples'; 'NumChannels'; 'NumTrials'; 'SampleFreqHz';  'TriggerOffsetUsec';  'DataFormat'; 'DataSampOrder';   'SampleTimeUsec';
            'NUM_SAMPLES';'NUM_CHANNELS';'NUM_TRIALS';'SAMPLE_FREQ_HZ';'TRIGGER_OFFSET_USEC';'DATA_FORMAT';'DATA_SAMP_ORDER'; 'SAMPLE_TIME_USEC'};

            % scan in cell 1 for keywords - all keywords must exist!
            nt = size(tok,1);
            a = zeros(nt,1);
            for i = 1:nt
                ctok = tok{i,1};
                ix = strfind(cont,ctok);
                if ~isempty ( ix )
                 text = sscanf(cont(ix+numel(ctok):end),' = %s');     % skip =
                 if strcmp ( text,'ASCII' ) || strcmp ( text,'CHAN' ) % test for alphanumeric values
                     a(i) = 1;
                 else 
                     c = sscanf(text,'%f');         % try to read a number
                     if ~isempty ( c )
                         a(i) = c;                  % assign if it was a number
                     end
                 end
                end 
            end
            % derived variables. numbers (1) (2) etc are the token numbers
            numsamples    = a(1)+a(1+nt/2);
            numchannel   = a(2)+a(2+nt/2);
            numTrials     = a(3)+a(3+nt/2);
            samplingFreq  = a(4)+a(4+nt/2);
            offsetUsec    = a(5)+a(5+nt/2);
            isASCII       = a(6)+a(6+nt/2);
            multiplex     = a(7)+a(7+nt/2);
            sampleTime    = a(8)+a(8+nt/2);
            fid = fopen(eventFile,'rt');
    %% Get Event data per channel
    n_e = 0;                             % number of events
    event_tmp = zeros(4,0);
    % find appropriate file
    fid = fopen(eventFile,'rt');

    if fid < 0
        fid = fopen(eventFile2,'rt');
    end
     if fid >= 0
        cell = textscan(fid,'%s','whitespace','','endofline','§');
        fclose(fid);
        cont = cell2mat(cell{1});

        % scan in cell 1 for NUMBER_LIST (occurs five times)
        ix = strfind(cont,'NUMBER_LIST');

        newLines = ix(4) - 1 + strfind(cont(ix(4):ix(5)),char(10));     % newline
        last = size(newLines,2)-1;
        for j = 1:last                                                  % loop over labels
            text = cont(newLines(j)+1:newLines(j+1)-1);
            tcell = textscan(text,'%d');                           
            sample = tcell{1}(1);                                       % access more content using different columns
            type = tcell{1}(3);
            startSample = tcell{1}(5);
            endSample = tcell{1}(6);
            n_e = n_e + 1;
            event_tmp = cat ( 2, event_tmp, [ sample; type; startSample; endSample ] );
        end

        % scan in cell 1 for REMARK_LIST (occurs five times)
        ix = strfind(cont,'REMARK_LIST');
        na = 0;

        newLines = ix(4) - 1 + strfind(cont(ix(4):ix(5)),char(10));     % newline
        last = size(newLines,2)-1;
        for j = 1:last                                                  % loop over labels
            text = cont(newLines(j)+1:newLines(j+1)-1);
            na = na + 1;
            annotations(na) = cellstr(text);
        end    
     end
            event_tmp(3:4,:)=[];
            event{1}=[numsamples;numchannel;numTrials;samplingFreq;offsetUsec;isASCII;multiplex;sampleTime];
            event{2}=event_tmp;
        case ".edf"
        otherwise
    end
end