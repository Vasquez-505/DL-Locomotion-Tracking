function Output = LS(Arg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function LS(Arg)
%
% LS to make sure that ls is compatible for PC and Mac (ls itself is not
% compatible).
%
% (c) Imre Bartos, 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in names with dir
  DIR = dir(Arg);
  
  Output = char([]);
  
% save to normal format
  for i = 1:length(DIR)
      Output(i,1:length(DIR(i).name)) = DIR(i).name;
  end;

return;