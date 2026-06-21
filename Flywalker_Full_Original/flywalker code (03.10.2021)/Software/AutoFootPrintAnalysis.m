function handles = AutoFootPrintAnalysis(handles,msg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function handles = AutoFootPrintAnalysis(handles)
% Tracks particles on a series of pictures. Calls ParticleFinder for every
% picture to find the particles on them, then uses this data to determine
% particle trajectories.
% see http://physics.georgetown.edu/matlab/tutorial.html for a tutorial on
% different matlab scripts below.
%
% Called from FootPrintAnalysis()
%
% (c) Imre Bartos, 2010.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

v = handles.v;
p = handles.p;
v.FrameNumber = handles.FrameNumber;
p.inputfilename = handles.inputfilename;
ButtonStatus = get(handles.auto_togglebutton,'Value');
framenum = v.FrameNumber
% if the analysis just starts, initialize
  if v.FrameNumber <= 1
    % initialize so the original track data from previous runs dont bother
    v = Initialize(v);
    % Initialize track data with data from track file
    v = InitializeTrackData(p,v);
  end;
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analyze frames starting with current frame as long as the Auto button is
% down.


   % REVERSE CHANGE:
    % check if dataset already contains deep learning estimatives
    dlPositionsFilename = [handles.p.outputfolder '/dl_positions.txt']; 
    if ~isfile(dlPositionsFilename)
         % File does not exist.
         % start deep learning estimations

        dlf = uifigure;
        dldialog = uiprogressdlg(dlf,'Title','Please wait...',...
            'Message','Estimating initial fly positions');

        if ~isfield(handles.p, 'DLInitAngle')
            handles.p.DLInitAngle = 0;
        end
        
         %handles.p.DLInitAngle = 0;
         load detector_13maimatlab.mat
         
        try
          canUseGPU = parallel.gpu.GPUDevice.isAvailable;
        catch ME
          canUseGPU = false;
        end
         
         if ~canUseGPU
            disp(["GPU not found/incompatible. Predicting on CPU."]);
            dl_positions = yoloFlyDetection(handles.p.foldername, detector_aux, true, 5, false, handles.p.DLInitAngle, dldialog);             
         else
             disp(["Predicting on GPU."]);
             dl_positions = yoloFlyDetectionGPU(handles.p.foldername, detector_aux, true, 5, false, handles.p.DLInitAngle, dldialog);
         end
         close(dldialog);
         close(dlf);
         
         dl_positions = double(dl_positions);

         save(dlPositionsFilename, 'dl_positions', '-ascii');
    else
         %file exists
         load(dlPositionsFilename);
    end
    handles.dlPositions = dl_positions;
tic

i = v.FrameNumber;

% Itres is a new list of frames size(Itres) == (w,h,total_frames)
Itres = [];
if p.UseBackgroundSubtraction
    removedBackgroundsFilename = [handles.p.outputfolder '/rmv_backgrounds.mat']; 
    if ~isfile(removedBackgroundsFilename)
        disp("Performing background subtraction...");
        Itres = computeNewBackground(v,p);
        save(removedBackgroundsFilename, 'Itres');
    else
        disp("Loading existing background subtraction data...");
        load(removedBackgroundsFilename, 'Itres');
    end
end
    
while i <= length(p.FileList) && ButtonStatus == 1

  % Change frame number in window
    set(handles.frame_edit,'String',num2str(i));
    drawnow;

    
  % display position in loop
    v.i = i;

  % read in next picture
    [v.pic, v.rawpic, v.nopic] = PictureReader_02(i, p);

  % filter image
    v.pic  = FilterImage(v,p);

  % identify fly legs and bodies
    [v.Leg, v.Body, v.Bodystd, v.BodySize, v.BodyBorder, v.BodyFit, v.LegBrightness] = FlyFinder_02(p,v);V=v.Leg;
  % track legs output: 
    [v.legx, v.legy, v.legtrack, v.legtiming, v.legtime, v.legbrightness] = TrackLegs_01(p,v);

  % track body output
    [v.bodyx, v.bodyy, v.bodytrack, v.bodytiming, v.BodyDirection1, v.BodyDirection2, v.BodyDirection3, v.Orientation, v.bodyborder, v.bodytime, v.bodystdPar, v.bodystdPerp] = TrackBody_01(p,v);

  % identify legs and associate them with bodies
    [v.Side, v.LegPosition] = IdentifyLegs_02(p,v);
       
    
  % save results
    v.index = v.index + 1;
    v = SavePicAuto_01(p,v);  

 %disp(['#' num2str(i) ' BD1:' num2str(v.CurrentBodyDirection1(i)) ' BD2:' num2str(v.CurrentBodyDirection2(i)) ' BD3:' num2str(v.CurrentBodyDirection3(i)) ' BO:' num2str(v.CurrentBodyOrientation(i)) ]);
    
 % REVERSE CHANGE
 % After the main algorithm, run Reverse's algorithm to detect center
 % point, and ellipse
    reversecontribution = 1;
    if reversecontribution
        positions = handles.dlPositions;
        [flyPoints, ellipseData, rad_extras] = reverseAnalysis_v2(v, p, positions, i, p.fixed_body_length_value, p.CenterFromFrontDist, Itres);

        % orientation angle    
        coefficients = polyfit([flyPoints(2), flyPoints(4)], [flyPoints(1), flyPoints(3)], 1);
        m = coefficients(1);
        b = coefficients(2);
        v.CurrentBodyDirection1(i) = m;
        v.CurrentBodyDirection2(i) = b;

        % true center (blue cross)
        v.TC_x(i) = flyPoints(6);
        v.TC_y(i) = flyPoints(5);

        % midpoint between front and back
        v.CurrentBodyX(i) = (flyPoints(4)+flyPoints(2))/2;
        v.CurrentBodyY(i) = (flyPoints(3)+flyPoints(1))/2;

        % small hack, that must be addresed in the future
        if(v.CurrentBodyDirection1(i) > -1 & v.CurrentBodyDirection1(i) < 1)
            v.CurrentBodyDirection3(i) = 1;       
        else 
            v.CurrentBodyDirection3(i) = 2;        
        end

        % distance from midpoint to front (and back)
        v.CurrentBodyStdY(i) = ellipseData.a;
        v.CurrentBodyStdX(i) = ellipseData.b;
        v.CurrentBodyOrientation(i) = 1;    
        disp(['[AUTO][' num2str(i) ' Ang:' num2str(atand(v.CurrentBodyDirection1(i))) ' BD1:' num2str(v.CurrentBodyDirection1(i)) ' BD2:' num2str(v.CurrentBodyDirection2(i)) ' BD3:' num2str(v.CurrentBodyDirection3(i)) ' BO:' num2str(v.CurrentBodyOrientation(i)) ]);
    end
    % END OF REVERSE's CONTRIBUTION
    
    % get button status to exit when necessary, but first flush event que
      drawnow;
      ButtonStatus = get(handles.auto_togglebutton,'Value');
      
    % draw current picture
      if p.drawwhileauto == 1
          handles.v = v;
          handles.p = p;
          handles = PlotforManual(handles);
      end;


    % step to next frame
      i = i + 1;
    
end;

%Plays a gong and shows a pop-up message when auto-tracking is done. (MARTA)
%load gong.mat;
%sound(y);

%%
%Ines commented following line
MSG=msg;
if MSG==0
    uiwait(msgbox('Auto-tracking DONE!',':)','modal'));
else
end

handles.v = v;
handles.p = p;



return;

% =========================================================================
% *************************************************************************
% =========================================================================

function [foldername, outputfolder, outputtablefilename] = OutputFiles(foldername)
% define output folder

  ind = find(foldername == '\');
  foldername(ind) = '/';
  if ind(end) ~= length(foldername);
      ind = [ind length(foldername)+1];
      foldername = [foldername '/'];
  end;
  outputfolder = ['./Video/Results-' foldername(ind(end-1)+1:ind(end)-1) '\']

  if exist(outputfolder) ~= 7
      mkdir(outputfolder);
      mkdir([outputfolder '/Data/']);
  end;
  outputtablefilename = [outputfolder 'Data/FlyTable.txt'];%sprintf('%sData\\FlyTable.txt', outputfolder);
  fid = fopen(outputtablefilename, 'w');
  
  fclose(fid);  
return;

% =========================================================================
function v = Initialize(v)
% Initialize variables. Variables are stored in structure 'v'.
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
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre
%   v.TCx = [];
%   v.TCy = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
  return;
  
% =========================================================================
  
  
% function pic = FilterImage(v)
% % filters image with masks defined in Masks(p)
% 
% % subtract masks
%   pic = v.pic - v.picAVG - 2*v.picSTD - v.DPM;
% 
% % put pic between constraints
%   pic = min(255,max(0,pic));
% 
% return;







