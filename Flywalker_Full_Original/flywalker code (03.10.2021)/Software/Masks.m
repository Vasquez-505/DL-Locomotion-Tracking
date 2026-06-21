function [DPM, picAVG, picSTD] = Masks(p)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [DPM, picAVG, picSTD] = Masks(p)
%
% Calculate Dead Pixel Mask (DPM), average picture brightness (picAVG) and 
% picture standard deviation (picSTD). DPM is 255 everywhere where the 
% background is too bright that it should be removed from the analysis, 
% and 0 everywhere else.
%
% (c) Imre Bartos, 2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% obtain frame file names
  Files = p.FileList;
  
  
% Load files in the comparison period at the end of the frame series and 
% obtain data from them.
  XR = 0.0;
  XR2 = 0.0;
  XG = 0.0;
  XG2 = 0.0;
  XB = 0.0;
  XB2 = 0.0;
  counter = 0;
  
  for i = length(Files) - p.BGlength - 1 : length(Files) % use this one if want to use last consecutive frames 
%   for i = 1 : round(length(Files)/p.BGlength) : length(Files) % use this one if want to evently distribute background frames 

%     % turn off smoothing for masking
%       temp = p.smoothing;
%       p.smoothing = 0;
    
    % read in next picture
      [pic, rawpic, nopic] = PictureReader_02(i, p);

    % if no picture found exit  
      if nopic == 1, break, end;

%     % resume smoothing
%       p.smoothing = temp;

      counter = counter + 1;
      XR = XR + pic.R;
      XR2 = XR2 + pic.R.^2;
      XG = XG + pic.G;
      XG2 = XG2 + pic.G.^2;
      XB = XB + pic.B;
      XB2 = XB2 + pic.B.^2;
  end;
  
  XR  = XR / counter;
  XR2 = XR2 / counter;
  XG  = XG / counter;
  XG2 = XG2 / counter;
  XB  = XB / counter;
  XB2 = XB2 / counter;
  
  picAVG.R = XR;
  picSTD.R = sqrt(XR2 - XR.^2);
  picAVG.G = XG;
  picSTD.G = sqrt(XG2 - XG.^2);
  picAVG.B = XB;
  picSTD.B = sqrt(XB2 - XB.^2);

  ind = find(XR > p.BGthreshold & XG > p.BGthreshold & XB > p.BGthreshold);
  DPM = XR;
  DPM(:) = 0;
  DPM(ind) = 255;
  
  
return;

% =========================================================================


