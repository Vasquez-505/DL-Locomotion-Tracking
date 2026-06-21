function FlyTracker_02(foldername, BEGIN)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function FlyTracker_02(foldername, BEGIN)
%
% Tracks particles on a series of pictures. Calls ParticleFinder for every
% picture to find the particles on them, then uses this data to determine
% particle trajectories.
% see http://physics.georgetown.edu/matlab/tutorial.html for a tutorial on
% different matlab scripts below.
%
%
% (c) Imre Bartos, April 2009.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load Parameters
  p = Parameters();
  p.foldername = foldername;
  p.BEGIN = BEGIN;

% Define Output Folder and output table file name
  [p.foldername, p.outputfolder, p.outputtablefilename] = OutputFiles(foldername);
  
% Obtain list of frame files from input folder  
  p.FileList = LS([p.foldername '*.png']);
  
% Initialize Variables  
  v = Initialize();

% Calculate Dead Pixel Mask (DPM), average picture brightness (picAVG) and 
% picture standard deviation (picSTD).
  [v.DPM, v.picAVG, v.picSTD] = Masks(p);


% % Calibrate brightness thresholds using user-defined frame  
%   p = CalibrateBrightnessThresholds_01(p,v);
%   
%   return;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop over frames  
for i = BEGIN:length(p.FileList(:,1))
  
  % display position in loop
    disp([i i-BEGIN+1])
    v.i = i;
  
  % calculate time for the frame
    v.time = v.time + 1/p.fps;
    
  % read in next picture
    [v.pic, v.rawpic, v.nopic] = PictureReader_02(i, p);

  % exit loop if there are no more pictures
    if v.nopic == 1, break, end;
    
  % filter image
    v.pic  = FilterImage(v);

  % identify fly legs and bodies
    [v.Leg, v.Body, v.Bodystd, v.BodySize, v.BodyBorder, v.BodyFit, v.LegBrightness] = FlyFinder_02(p,v);

  % track legs output: 
    [v.legx, v.legy, v.legtrack, v.legtiming, v.legtime, v.legbrightness] = TrackLegs_01(p,v);
  
  % track body output
    [v.bodyx, v.bodyy, v.bodytrack, v.bodytiming, v.BodyDirection1, v.BodyDirection2, v.BodyDirection3, v.Orientation, v.bodyborder, v.bodytime, v.bodystdPar, v.bodystdPerp] = TrackBody_01(p,v);
  
  % identify legs and associate them with bodies
    [v.Side, v.LegPosition] = IdentifyLegs_02(p,v);

  % save results
  v.index = v.index + 1;
  v = SavePic_01(p,v);  


end;


return;

% =========================================================================
% *************************************************************************
% =========================================================================

function [foldername, outputfolder, outputtablefilename] = OutputFiles(foldername)
% define output folder

  ind = find(foldername == '\');
  if ind(end) ~= length(foldername);
      ind = [ind length(foldername)+1];
      foldername = [foldername '\'];
  end;
  outputfolder = ['.\Video\Results-' foldername(ind(end-1)+1:ind(end)-1) '\']

  if exist(outputfolder) ~= 7
      mkdir(outputfolder);
      mkdir([outputfolder '\Data\']);
  end;
  outputtablefilename = [outputfolder 'Data\FlyTable.txt'];%sprintf('%sData\\FlyTable.txt', outputfolder);
  fid = fopen(outputtablefilename, 'w');
  
  fclose(fid);  
return;

% =========================================================================
function v = Initialize()
% Initialize variables. Variables are stored in structure 'v'.
  v.time = 0;
  v.index = 0;
  v.legx = [];
  v.legy = [];
  v.legtrack = [];
  v.legtiming = [];
  v.bodyx = [];
  v.bodyy = [];
  v.bodytrack = [];
  v.bodytiming = [];
  v.BodyDirection1 = [];
  v.BodyDirection2 = [];
  v.BodyDirection3 = [];
  v.bodystdPar = [];
  v.bodystdPerp = [];
  v.Orientation = [];
  v.Side = 0;
  v.bodyborder = [];
  v.LegPosition = [];
  v.legtime = [];
  v.bodytime = [];
  v.legbrightness = [];
  v.legtimes(1:6) = 1000;
  
  return;
  
% =========================================================================
  
  
function pic = FilterImage(v)
% filters image with masks defined in Masks(p)

% subtract masks
  pic = v.pic - v.picAVG - 2*v.picSTD - v.DPM;

% put pic between constraints
  pic = min(255,max(0,pic));

return;







