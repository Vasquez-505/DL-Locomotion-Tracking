function MultiEvaluate(filename, outputfilename, type)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function MultiEvaluate(filename, outputfilename)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evaluates multiple files with EvaluateFlyTable_02().
% Alexandre -> now uses activex!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INPUT:
%    filename - file containing folder names in each row. Each folder
%    contains the analyzed data. Analyzed data should be within the folder
%    in <foldername>/Results/TRACKS.mat
%
% (c) Imre Bartos, 2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% default outpufilename
  if nargin < 2
      outputfilename = 'ResultSummary.xlsx';
  else
      if length(outputfilename > 4) & ~strcmp(outputfilename(end-3:end),'.xlsx')
        outputfilename = [outputfilename '.xlsx'];
      end;
  end;

% load file name list from filename
  fid = fopen(filename, 'r');
  
% read in files one by one  
  counter = 0;
  while 1
      line = fgetl(fid); % read in line
      % exit if there are no more lines
        if ~ischar(line),   break,   end; 
        
      % evaluate data in file name defined by line
        try
          disp(['Evaluating data in ' line]);
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          % Alexandre -> commented the conversion
          % convert folder format to compatible one
%             line(line == '\') = '/';
%             if line(end) ~= '/'
%                 line = [line '/'];
%             end;
%             disp([line 'Results/TRACKS.mat'])
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          % evaluate file
          
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          % Alexandre -> old code is commented; replaced '/' with '\' and
          % added '\' before 'Results\(...)'
            if type == 'h'
                EvaluateFlyTable_activex_hexa([line '\Results\TRACKS.mat'], -1);
            elseif type == 'q'
                EvaluateFlyTable_activex_quad([line '\Results\TRACKS.mat'], -1);
            else
                disp('You know nothing, Alexandre. (MultiEvaluate.m)')
            end
                
%             EvaluateFlyTable_02([line 'Results/TRACKS.mat'], -1);
            
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
          % write summary of results to excel file
            % determine excel file name
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Alexandre -> applied same fixes as previsously in path name
              FILEname = [line '\Results\TRACKS.mat'];
              ind = find(FILEname == '/' | FILEname == '\');
              foldername = FILEname(1:ind(end))   ;         
              ind = find(foldername == '/' | foldername == '\' | foldername == ' ' | foldername == '.' | foldername == ':');
              ExcelFileName = foldername;
              ExcelFileName(ind) = '_';
              ExcelFileName = ExcelFileName(max(1,end-30):end);
            % read data
              [num,txt,raw] = xlsread([foldername ExcelFileName '.xlsx'],'1.Info_Sheet', 'A40:DQ41');
            % save data in matrix
              counter = counter + 1;
              % save header
                if counter == 1
                    Data(1,:) = raw(1,:);
                    counter = counter + 1;
                end;
              Data(counter,:) = raw(2,:);
          
        catch ME
          disp('Something went wrong with this file. Skipping...');
        end;
  end;

  % save data in new excel file
    xlswrite(outputfilename, Data,'1');
  
  
    disp('Multi evaluation finished.')
    uiwait(msgbox('Multi evaluation finished.', 'Finished'));

return;