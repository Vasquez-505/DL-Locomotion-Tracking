function handles = LoadData(handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function handles = LoadData(handles)
% load data for FootPrintAnalysis() given the directories of raw and
% processed data
%
% (c) Imre Bartos, 2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Load Image
% try
    % identify input frames folder name
      handles.p.foldername = get(handles.load_edit,'String');
      % make sure foldername ends with \
      if handles.p.foldername(end) ~= '/'
        handles.p.foldername = [handles.p.foldername '/'];
      end;
    % identify output data folder name
      handles.p.trackfoldername = get(handles.load_track_edit,'String');
      % Substitute default folder name if nothing's given
        if strcmp(handles.p.trackfoldername,'Default...') 
            handles.p.trackfoldername = [handles.p.foldername 'Results/'];
            %check if resultfolder exists
        end
        % make sure trackfoldername ends with \
        if handles.p.trackfoldername(end) ~= '/'
          handles.p.trackfoldername = [handles.p.trackfoldername '/'];
        end;
        % create results folder if it doesn't exist
        DoesFolderExist = exist(handles.p.trackfoldername);
        if DoesFolderExist ~= 7
            % run window that asks whether to create folder
            handlesptrackfoldername = handles.p.trackfoldername;
            % get gui handle
            hFootPrintAnalysis = getappdata(0,'hFootPrintAnalysis');
            % write data into gui handle that will be readable by the other
            % file
            setappdata(hFootPrintAnalysis,'handlesptrackfoldername',handlesptrackfoldername);

            CreateFolderQuestion();
            waitfor(CreateFolderQuestion);
            CreateNewProcessedFolder = getappdata(hFootPrintAnalysis,'CreateNewProcessedFolder');     
            if CreateNewProcessedFolder == 0
                return;
            end;
        end;
        
        
        % REVERSE CHANGE
        dlPositionsFilename = [handles.p.trackfoldername '/dl_positions.txt']; 
        if isfile(dlPositionsFilename)
             load(dlPositionsFilename);
             handles.dlPositions = dl_positions;
        end
        
        
%         % REVERSE CHANGE:
%         % check if dataset already contains deep learning estimatives
%         dlPositionsFilename = [handles.p.trackfoldername '/dl_positions.txt']; 
%         if ~isfile(dlPositionsFilename)
%              % File does not exist.
%              % start deep learning estimations
%              
%             dlf = uifigure;
%             dldialog = uiprogressdlg(dlf,'Title','Please wait...',...
%                 'Message','Estimating initial fly positions');
%    
%              
%              load detector_13maimatlab.mat
%              dl_positions = yoloFlyDetection(handles.p.foldername, detector_aux, true, 5, false, dldialog);             
%              close(dldialog);
%              close(dlf);
%              
%              save(dlPositionsFilename, 'dl_positions', '-ascii');
%         else
%              %file exists
%              load(dlPositionsFilename);
%         end
        
        %handles.dlPositions = dl_positions;
        
        
        % create Images folder if it doesn't exist
        handles.image_folder_name = [handles.p.trackfoldername 'Images' ];
        DoesFolderExist = exist(handles.image_folder_name);
        if DoesFolderExist ~= 7
            mkdir(handles.image_folder_name);
        end;

    % Obtain list of frame files OR video from input folder  
      [handles.p.FileList, handles.p.VideoInput, handles.p.VideoObject] = ReadInInputFiles(handles.p.foldername);
   
    % update window title so it now includes the name of the folder the data is in.
      WindowTitle = ['FootPrintAnalysis  -  ' handles.p.foldername '   -   ' num2str(length(handles.p.FileList)) ' frames'];
      set(gcf,'Name',WindowTitle);

    % write number of frames in window
      set(handles.uipanel4,'Title',['Select Frame   /   ' num2str(length(handles.p.FileList)) ' frames']);

    % set up slider to the right scale   
      set(handles.frame_slider,'Min', 1);
      set(handles.frame_slider,'Max', length(handles.p.FileList));

% catch ME
%     % if there is an error with the file names return;
%     return;
% end
% Load results from automatic analysis
  handles.inputfilename = sprintf('%sTRACKS.mat', handles.p.trackfoldername);  

  try
    % load data if there is saved data
      load(handles.inputfilename, 'p', 'v')
    
    % redefine sub-folder and file names. This is important if the whole
    % dataset is moved around
      p.outputfolder        = handles.p.trackfoldername;
      p.foldername          = handles.p.foldername;
      p.outputtablefilename = [p.outputfolder 'FlyTable.txt'];
      p.FileList            = [LS([p.foldername '*.jpg']); LS([p.foldername '*.png']); LS([p.foldername '*.bmp']); LS([p.foldername '*.tif']); LS([p.foldername '*.jpeg'])];
      [p.FileList, p.VideoInput, p.VideoObject] = ReadInInputFiles(p.foldername);
      

  catch ME
    % Load parameters and Initialize if there is no saved data
    % load in the parameters from Parameters.m
%     p = Parameters();
    % load in the parameters from Parameters.mat
      load('Parameters.mat');
      p.outputfolder        = handles.p.trackfoldername;
      p.foldername          = handles.p.foldername;
      p.outputtablefilename = [p.outputfolder 'FlyTable.txt'];

    % Obtain list of frame files from input folder  
      [p.FileList, p.VideoInput, p.VideoObject] = ReadInInputFiles(p.foldername);
    
    % Initialize Variables  
      v                     = Initialize(handles);

    % Calculate Dead Pixel Mask (DPM), average picture brightness (picAVG) and 
    % picture standard deviation (picSTD).
      [v.DPM, v.picAVG, v.picSTD] = Masks(p);
          
% Preload Images - proved to be not much faster
%     handles.v = v;
%     handles.p = p;
%     handles = PlotforManual(handles);
%     text(80,100,'Please wait while the program is loading the images...','BackgroundColor', [1 1 1],'FontSize',20)    
%     drawnow;
% tic
%     % Load and Save pictures after removing background --------------------
%     for i = 1:length(p.FileList)
%         % read in next picture
%         [v.pic, v.rawpic, v.nopic] = PictureReader_02(i, p);
%         % filter image
%         v.pic  = FilterImage(v);
%         % save loaded images
%         v.SavedPic(i,:,:) = v.pic;
%         v.SavedRawPic(i,:,:) = v.rawpic;
%     end;
% toc
    % save what we have so far
    save(handles.inputfilename, 'p', 'v');
  end

% add parameters that were not present in older versions
  if ~isfield(p,'BGoffset'),       p.BGoffset.R = 0; p.BGoffset.G = 0; p.BGoffset.B = 0;  p.BGoffset.sigma = 0; end;
  if ~isfield(p.BGoffset,'sigma'), p.BGoffset.sigma = 0; end;
  if ~isfield(p,'WhatToPlot'),     p.WhatToPlot = 3; end;
  if isfield(v,'pic') & ~isfield(v.pic,'R'),         [v.DPM, v.picAVG, v.picSTD] = Masks(p); end;
  if isfield(v,'picAVG') & ~isfield(v.picAVG,'R'),   [v.DPM, v.picAVG, v.picSTD] = Masks(p); end;
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre
 % if there's no info regarding TC in the saved data, use BodyX/Y as TC
  if ~isfield(v, 'TC_x') && ~isfield(v, 'TC_y')
      v.TC_x = v.CurrentBodyX;
      v.TC_y = v.CurrentBodyY;
  end
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
% save backup
handles.pbackup = p;
handles.vbackup = v;

 
handles.v = v;
handles.p = p;

% REVERSE - PERFORM BACKGROUND SUBTRACTION

% Itres is a new list of frames size(Itres) == (w,h,total_frames)
Itres = [];
if p.UseBackgroundSubtraction
    removedBackgroundsFilename = [handles.p.outputfolder '/rmv_backgrounds.mat']; 
    if ~isfile(removedBackgroundsFilename)
        disp("Performing background subtraction...");
        Itres = computeNewBackground(v,p);
        save(removedBackgroundsFilename, 'Itres');    
    end
end

handles = PlotforManual(handles);
% set(handles.ellipse_checkbox,'Value',handles.p.ellipse);
% set(handles.bodytrack_checkbox,'Value',handles.p.drawbodytrack);


return;

% =========================================================================
function v = Initialize(handles)
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
  v.legtime = [];
  v.Leg = [];

    % Initialize leg positions (make sure they are the right length)
    L = length(handles.p.FileList) + 1;

    v.CurrentBodyX(L)           = 0; 
    v.CurrentBodyY(L)           = 0; 
    v.CurrentBodyDirection1(L)  = 0; 
    v.CurrentBodyDirection2(L)  = 0;
    v.CurrentBodyDirection3(L)  = 0;
    v.CurrentBodyOrientation(L) = 0;
    v.CurrentBodyStdX(L)        = 0;
    v.CurrentBodyStdY(L)        = 0;
    v.CurrentLeftFrontLegX(L)   = 0;
    v.CurrentLeftFrontLegY(L)   = 0;
    v.CurrentRightFrontLegX(L)  = 0;
    v.CurrentRightFrontLegY(L)  = 0;
    v.CurrentLeftMiddleLegX(L)  = 0;
    v.CurrentLeftMiddleLegY(L)  = 0;
    v.CurrentRightMiddleLegX(L) = 0;
    v.CurrentRightMiddleLegY(L) = 0;
    v.CurrentLeftBackLegX(L)    = 0;
    v.CurrentLeftBackLegY(L)    = 0;
    v.CurrentRightBackLegX(L)   = 0;
    v.CurrentRightBackLegY(L)   = 0;
    % calculate time for the frame
    v.time(1:L) = [0:L-1]./handles.p.fps;  

  
  return;
  
% =========================================================================


