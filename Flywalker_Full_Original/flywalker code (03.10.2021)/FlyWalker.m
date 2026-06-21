function varargout = FlyWalker(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function varargout = FlyWalker(varargin)
%
% GUI for manually changing fly footprint reconstruction. The program also
% saves the changed data and frame images.
%
%
% (c) Imre Bartos, 2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath(['./Software/']);
% REVERSE CHANGE
%% 
% add new functions folder
addpath(['./Software/Reverse']);

% FLYWALKER M-file for FlyWalker.fig
%      FLYWALKER, by itself, creates a new FLYWALKER or raises the existing
%      singleton*.
%
%      H = FLYWALKER returns the handle to a new FLYWALKER or the handle to
%      the existing singleton*.
%
%      FLYWALKER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLYWALKER.M with the given input arguments.
%
%      FLYWALKER('Property','Value',...) creates a new FLYWALKER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FlyWalker_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FlyWalker_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FlyWalker

% Last Modified by GUIDE v2.5 30-Aug-2022 15:55:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FlyWalker_OpeningFcn, ...
                   'gui_OutputFcn',  @FlyWalker_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



% --- Executes just before FlyWalker is made visible.
function FlyWalker_OpeningFcn(hObject, eventdata, handles, varargin)

%whenever any key is pressed, myFunction is called
set(handles.figure1,                       'KeyPressFcn',@KeyPressFunction);
set(handles.picture_togglebutton,          'KeyPressFcn',@KeyPressFunction);
set(handles.evaluate_togglebutton,           'KeyPressFcn',@KeyPressFunction);
set(handles.front_pushbutton,              'KeyPressFcn',@KeyPressFunction);
set(handles.center_pushbutton,             'KeyPressFcn',@KeyPressFunction);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre
set(handles.TrueCenter,                    'KeyPressFcn',@KeyPressFunction);
set(handles.TrueFront,                    'KeyPressFcn',@KeyPressFunction);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
set(handles.save_pushbutton,               'KeyPressFcn',@KeyPressFunction);
set(handles.restore_pushbutton,            'KeyPressFcn',@KeyPressFunction);
set(handles.select_pushbutton,             'KeyPressFcn',@KeyPressFunction);
% set(handles.frame_edit,                  'KeyPressFcn',@KeyPressFunction)
set(handles.toend_pushbutton,              'KeyPressFcn',@KeyPressFunction);
set(handles.minus_pushbutton,              'KeyPressFcn',@KeyPressFunction);
set(handles.plus_pushbutton,               'KeyPressFcn',@KeyPressFunction);
set(handles.start_pushbutton,              'KeyPressFcn',@KeyPressFunction);
set(handles.RB_togglebutton,               'KeyPressFcn',@KeyPressFunction);
set(handles.LB_togglebutton,               'KeyPressFcn',@KeyPressFunction);
set(handles.RM_togglebutton,               'KeyPressFcn',@KeyPressFunction);
set(handles.LM_togglebutton,               'KeyPressFcn',@KeyPressFunction);
set(handles.RF_togglebutton,               'KeyPressFcn',@KeyPressFunction);
set(handles.load_pushbutton,               'KeyPressFcn',@KeyPressFunction);
% set(handles.load_edit,                   'KeyPressFcn',@KeyPressFunction)
set(handles.LF_togglebutton,               'KeyPressFcn',@KeyPressFunction);
set(handles.brightness_increase_pushbutton,'KeyPressFcn',@KeyPressFunction);
set(handles.brightness_decrease_pushbutton,'KeyPressFcn',@KeyPressFunction);
% set(handles.bodytrack_checkbox,            'KeyPressFcn',@KeyPressFunction)
% set(handles.ellipse_checkbox,              'KeyPressFcn',@KeyPressFunction)
set(handles.load_track_browse_pushbutton,  'KeyPressFcn',@KeyPressFunction);
set(handles.loadbrowse_pushbutton,         'KeyPressFcn',@KeyPressFunction);
% set(handles.load_track_edit,             'KeyPressFcn',@KeyPressFunction)
set(handles.auto_togglebutton,             'KeyPressFcn',@KeyPressFunction);
% set(handles.max_frame_text,                'KeyPressFcn',@KeyPressFunction)
set(handles.cut_out_pushbutton,            'KeyPressFcn',@KeyPressFunction);
set(handles.ruler_pushbutton,              'KeyPressFcn',@KeyPressFunction);
set(handles.body_off_pushbutton,           'KeyPressFcn',@KeyPressFunction);
set(handles.body_off_before_pushbutton,    'KeyPressFcn',@KeyPressFunction);
set(handles.body_off_after_pushbutton,     'KeyPressFcn',@KeyPressFunction);
set(handles.brightness_measure_pushbutton, 'KeyPressFcn',@KeyPressFunction);
set(handles.position_measure_pushbutton,   'KeyPressFcn',@KeyPressFunction);
set(handles.frame_slider,                  'KeyPressFcn',@KeyPressFunction);
% set(handles.settings_menu,                  'KeyPressFcn',@KeyPressFunction);


% Assign the GUI a name to appear in the window title.
  set(gcf,'Name','FlyWalker');

% Choose default command line output for FlyWalker
  handles.output = hObject;
  
% get original figure size
  handles.Figure_Size_Original = get(hObject,'Position');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define whatever value we want global here
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read in parameters file if it exists, otherwise use predefined
% parameters
  if exist('Parameters.mat')
    load('Parameters.mat');
    handles.p = p;
  else
    handles.p = Parameters();
  end;

% set starting settings to default
  set(handles.load_edit,         'String', handles.p.input_directory_path);
  set(handles.load_track_edit,   'String', handles.p.results_directory_path);
%   set(handles.ellipse_checkbox,  'Value',  handles.p.ellipse);
%   set(handles.bodytrack_checkbox,'Value',  handles.p.drawbodytrack);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre
set(handles.Hexa,'Checked','on');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Update handles structure
  guidata(hObject, handles);

% UIWAIT makes FlyWalker wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% store handle for FlyWalker in the root
  setappdata(0, 'hFootPrintAnalysis', gcf);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% KEY PRESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function KeyPressFunction(src,evnt)
% react to pressed keys

%this line brings the handles structures into the local workspace
%now we can use handles.cats in this subfunction!
handles = guidata(src);
eventdata = [];

% disp(int16(evnt.Character))
hObject = handles.output;
int16(evnt.Character); 
% evntmodifier = evnt.Modifier

% Settings menu
if evnt.Character == 'p'
    settings_menu_Callback(hObject, eventdata, handles);
end;

% toggle between different plot styles
if int16(evnt.Character) >= 49 & int16(evnt.Character) <= 57
  handles.p.WhatToPlot = int16(evnt.Character) - 48;
  handles = PlotforManual(handles);
  % Update handles structure
    guidata(hObject, handles);
end;
% decrease frame number
if int16(evnt.Character) == 28 | evnt.Character == 'z' % left arrow
    minus_pushbutton_Callback(hObject, eventdata, handles);
end;
% increase frame number
if int16(evnt.Character) == 29  | evnt.Character == 'c' % right arrow
    plus_pushbutton_Callback(hObject, eventdata, handles);
end;
% jump to the beginning (<<)
if evnt.Character == 'v' 
    start_pushbutton_Callback(hObject, eventdata, handles);
end;
% jump to the end (>>)
if evnt.Character == 'b' 
    toend_pushbutton_Callback(hObject, eventdata, handles);
end;
% Select
if int16(evnt.Character) == 31  | evnt.Character == 'x' % down arrow
    select_pushbutton_Callback(hObject, eventdata, handles);
end;
% RF
if evnt.Character == 'e'
    handles.RF_togglebuttonStatus = get(handles.RF_togglebutton,'Value');
    set(handles.RF_togglebutton,'Value',1-handles.RF_togglebuttonStatus);
    RF_togglebutton_Callback(hObject, eventdata, handles);
end;
% LF
if evnt.Character == 'd'
    handles.LF_togglebuttonStatus = get(handles.LF_togglebutton,'Value');
    set(handles.LF_togglebutton,'Value',1-handles.LF_togglebuttonStatus);
    LF_togglebutton_Callback(hObject, eventdata, handles);
end;
% RM
if evnt.Character == 'w'
    handles.RM_togglebuttonStatus = get(handles.RM_togglebutton,'Value');
    set(handles.RM_togglebutton,'Value',1-handles.RM_togglebuttonStatus);
    RM_togglebutton_Callback(hObject, eventdata, handles);
end;
% LM
if evnt.Character == 's'
    handles.LM_togglebuttonStatus = get(handles.LM_togglebutton,'Value');
    set(handles.LM_togglebutton,'Value',1-handles.LM_togglebuttonStatus);
    LM_togglebutton_Callback(hObject, eventdata, handles);
end;
% RB
if evnt.Character == 'q'
    handles.RB_togglebuttonStatus = get(handles.RB_togglebutton,'Value');
    set(handles.RB_togglebutton,'Value',1-handles.RB_togglebuttonStatus);
    RB_togglebutton_Callback(hObject, eventdata, handles);
end;
% LB
if evnt.Character == 'a'
    handles.LB_togglebuttonStatus = get(handles.LB_togglebutton,'Value');
    set(handles.LB_togglebutton,'Value',1-handles.LB_togglebuttonStatus);
    LB_togglebutton_Callback(hObject, eventdata, handles);
end;
% CENTER OF BODY
if evnt.Character == 'r'
    center_pushbutton_Callback(hObject, eventdata, handles);
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre

% TRUE CENTER OF BODY
if evnt.Character == 'o'
    TrueCenter_Callback(hObject, eventdata, handles);
end;

% TRUE FRONT OF BODY
if evnt.Character == 'l'
    TrueFront_Callback(hObject, eventdata, handles);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FRONT OF BODY
if evnt.Character == 'f'
    front_pushbutton_Callback(hObject, eventdata, handles);
end;
% CUT OUT
if evnt.Character == 't'
    cut_out_pushbutton_Callback(hObject, eventdata, handles);
end;
% RULER
if evnt.Character == 'g'
    ruler_pushbutton_Callback(hObject, eventdata, handles);
end;
% KEEP THE SAME %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % read FrameNumber
    FrameNumber  = str2num(get(handles.frame_edit,'String'));
  % execute only if FrameNumber > 1
    if FrameNumber > 1 & FrameNumber < length(handles.p.FileList)
        % determine which direction to take neighbor. If Control is
        % pressed, take it from next frame, otherwise previous frame
        Neighbor = -1; % previous frame
        for i = 1 : length(evnt.Modifier)
            if strcmp(evnt.Modifier(i),'alt')
                Neighbor = 1; % next frame
            end;
        end;
        % RF
        if evnt.Character == 'E'
            % make leg position equal to previous
            if handles.v.CurrentRightFrontLegX(FrameNumber+Neighbor) > 0
                handles.v.CurrentRightFrontLegX(FrameNumber) = handles.v.CurrentRightFrontLegX(FrameNumber+Neighbor);
                handles.v.CurrentRightFrontLegY(FrameNumber) = handles.v.CurrentRightFrontLegY(FrameNumber+Neighbor);
            end;
            % draw new direction
              handles = PlotforManual(handles);
            % Update handles structure
              guidata(hObject, handles);
        end;
        % LF
        if evnt.Character == 'D'
            % make leg position equal to previous
            if handles.v.CurrentLeftFrontLegX(FrameNumber+Neighbor) > 0
                handles.v.CurrentLeftFrontLegX(FrameNumber) = handles.v.CurrentLeftFrontLegX(FrameNumber+Neighbor);
                handles.v.CurrentLeftFrontLegY(FrameNumber) = handles.v.CurrentLeftFrontLegY(FrameNumber+Neighbor);
            end;
            % draw new direction
              handles = PlotforManual(handles);
            % Update handles structure
              guidata(hObject, handles);
        end;
        % RM
        if evnt.Character == 'W'
            % make leg position equal to previous
            if handles.v.CurrentRightMiddleLegX(FrameNumber+Neighbor) > 0
                handles.v.CurrentRightMiddleLegX(FrameNumber) = handles.v.CurrentRightMiddleLegX(FrameNumber+Neighbor);
                handles.v.CurrentRightMiddleLegY(FrameNumber) = handles.v.CurrentRightMiddleLegY(FrameNumber+Neighbor);
            end;
            % draw new direction
              handles = PlotforManual(handles);
            % Update handles structure
              guidata(hObject, handles);
        end;
        % LM
        if evnt.Character == 'S'
            % make leg position equal to previous
            if handles.v.CurrentLeftMiddleLegX(FrameNumber+Neighbor) > 0
                handles.v.CurrentLeftMiddleLegX(FrameNumber) = handles.v.CurrentLeftMiddleLegX(FrameNumber+Neighbor);
                handles.v.CurrentLeftMiddleLegY(FrameNumber) = handles.v.CurrentLeftMiddleLegY(FrameNumber+Neighbor);
            end
            % draw new direction
              handles = PlotforManual(handles);
            % Update handles structure
              guidata(hObject, handles);
        end;
        % RB
        if evnt.Character == 'Q'
            % make leg position equal to previous
            if handles.v.CurrentRightBackLegX(FrameNumber+Neighbor) > 0
                handles.v.CurrentRightBackLegX(FrameNumber) = handles.v.CurrentRightBackLegX(FrameNumber+Neighbor);
                handles.v.CurrentRightBackLegY(FrameNumber) = handles.v.CurrentRightBackLegY(FrameNumber+Neighbor);
            end
            % draw new direction
              handles = PlotforManual(handles);
            % Update handles structure
              guidata(hObject, handles);
        end;
        % LB
        if evnt.Character == 'A'
            % make leg position equal to previous
            if handles.v.CurrentLeftBackLegX(FrameNumber+Neighbor) > 0
                handles.v.CurrentLeftBackLegX(FrameNumber) = handles.v.CurrentLeftBackLegX(FrameNumber+Neighbor);
                handles.v.CurrentLeftBackLegY(FrameNumber) = handles.v.CurrentLeftBackLegY(FrameNumber+Neighbor);
            end
            % draw new direction
              handles = PlotforManual(handles);
            % Update handles structure
              guidata(hObject, handles);
        end;
        % CENTER OF BODY
        if evnt.Character == 'R'
            if handles.v.CurrentBodyX(FrameNumber+Neighbor) > 0
                handles.v.CurrentBodyX(FrameNumber) = handles.v.CurrentBodyX(FrameNumber+Neighbor);
                handles.v.CurrentBodyY(FrameNumber) = handles.v.CurrentBodyY(FrameNumber+Neighbor);
                    % after changing the center one has to recalibrate the
                    % direction too, so the direction is also changed to the
                    % previous one
                    handles.v.CurrentBodyOrientation(FrameNumber) = handles.v.CurrentBodyOrientation(FrameNumber+Neighbor);
                    handles.v.CurrentBodyDirection1(FrameNumber)  = handles.v.CurrentBodyDirection1(FrameNumber+Neighbor);
                    handles.v.CurrentBodyDirection3(FrameNumber)  = handles.v.CurrentBodyDirection3(FrameNumber+Neighbor);
                    if handles.v.CurrentBodyDirection3(FrameNumber) == 1
                        handles.v.CurrentBodyDirection2(FrameNumber) = handles.v.CurrentBodyY(FrameNumber) - handles.v.CurrentBodyDirection1(FrameNumber+Neighbor) * handles.v.CurrentBodyX(FrameNumber);
                    else
                        handles.v.CurrentBodyDirection2(FrameNumber) = handles.v.CurrentBodyX(FrameNumber) - handles.v.CurrentBodyDirection1(FrameNumber+Neighbor) * handles.v.CurrentBodyY(FrameNumber);
                    end;            
                    handles.v.CurrentBodyStdX(FrameNumber)        = handles.v.CurrentBodyStdX(FrameNumber+Neighbor);
                    handles.v.CurrentBodyStdY(FrameNumber)        = handles.v.CurrentBodyStdY(FrameNumber+Neighbor);
                % draw new direction
                  handles = PlotforManual(handles);
                % Update handles structure
                  guidata(hObject, handles);
            end;
        end;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Alexandre
        
        % TRUE CENTER OF BODY
        if evnt.Character == 'O'
            if handles.v.CurrentBodyX(FrameNumber+Neighbor) > 0
                handles.v.CurrentBodyX(FrameNumber) = handles.v.CurrentBodyX(FrameNumber+Neighbor);
                handles.v.CurrentBodyY(FrameNumber) = handles.v.CurrentBodyY(FrameNumber+Neighbor);
                    % after changing the center one has to recalibrate the
                    % direction too, so the direction is also changed to the
                    % previous one
%                     handles.v.CurrentBodyOrientation(FrameNumber) = handles.v.CurrentBodyOrientation(FrameNumber+Neighbor);
%                     handles.v.CurrentBodyDirection1(FrameNumber)  = handles.v.CurrentBodyDirection1(FrameNumber+Neighbor);
%                     handles.v.CurrentBodyDirection3(FrameNumber)  = handles.v.CurrentBodyDirection3(FrameNumber+Neighbor);
%                     if handles.v.CurrentBodyDirection3(FrameNumber) == 1
%                         handles.v.CurrentBodyDirection2(FrameNumber) = handles.v.CurrentBodyY(FrameNumber) - handles.v.CurrentBodyDirection1(FrameNumber+Neighbor) * handles.v.CurrentBodyX(FrameNumber);
%                     else
%                         handles.v.CurrentBodyDirection2(FrameNumber) = handles.v.CurrentBodyX(FrameNumber) - handles.v.CurrentBodyDirection1(FrameNumber+Neighbor) * handles.v.CurrentBodyY(FrameNumber);
%                     end;            
%                     handles.v.CurrentBodyStdX(FrameNumber)        = handles.v.CurrentBodyStdX(FrameNumber+Neighbor);
%                     handles.v.CurrentBodyStdY(FrameNumber)        = handles.v.CurrentBodyStdY(FrameNumber+Neighbor);
                % draw new direction
                handles = PlotforManual(handles);
                % Update handles structure
                guidata(hObject, handles);
            end;
        end;
        
        if evnt.Character == 'L'
            if handles.v.CurrentBodyOrientation(FrameNumber+Neighbor) > 0
                handles.v.CurrentBodyOrientation(FrameNumber) = handles.v.CurrentBodyOrientation(FrameNumber+Neighbor);
                handles.v.CurrentBodyDirection1(FrameNumber)  = handles.v.CurrentBodyDirection1(FrameNumber+Neighbor);
                handles.v.CurrentBodyDirection3(FrameNumber)  = handles.v.CurrentBodyDirection3(FrameNumber+Neighbor);
                if handles.v.CurrentBodyDirection3(FrameNumber) == 1
                    handles.v.CurrentBodyDirection2(FrameNumber) = handles.v.CurrentBodyY(FrameNumber) - handles.v.CurrentBodyDirection1(FrameNumber+Neighbor) * handles.v.CurrentBodyX(FrameNumber);
                else
                    handles.v.CurrentBodyDirection2(FrameNumber) = handles.v.CurrentBodyX(FrameNumber) - handles.v.CurrentBodyDirection1(FrameNumber+Neighbor) * handles.v.CurrentBodyY(FrameNumber);
                end;            
                handles.v.CurrentBodyStdX(FrameNumber)        = handles.v.CurrentBodyStdX(FrameNumber+Neighbor);
                handles.v.CurrentBodyStdY(FrameNumber)        = handles.v.CurrentBodyStdY(FrameNumber+Neighbor);

                % draw new direction
                  handles = PlotforManual(handles);
                % Update handles structure
                  guidata(hObject, handles);
            end;
        end;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % KEEP front of body and body size from previous
        if evnt.Character == 'F'
            if handles.v.CurrentBodyOrientation(FrameNumber+Neighbor) > 0
                handles.v.CurrentBodyOrientation(FrameNumber) = handles.v.CurrentBodyOrientation(FrameNumber+Neighbor);
                handles.v.CurrentBodyDirection1(FrameNumber)  = handles.v.CurrentBodyDirection1(FrameNumber+Neighbor);
                handles.v.CurrentBodyDirection3(FrameNumber)  = handles.v.CurrentBodyDirection3(FrameNumber+Neighbor);
                if handles.v.CurrentBodyDirection3(FrameNumber) == 1
                    handles.v.CurrentBodyDirection2(FrameNumber) = handles.v.CurrentBodyY(FrameNumber) - handles.v.CurrentBodyDirection1(FrameNumber+Neighbor) * handles.v.CurrentBodyX(FrameNumber);
                else
                    handles.v.CurrentBodyDirection2(FrameNumber) = handles.v.CurrentBodyX(FrameNumber) - handles.v.CurrentBodyDirection1(FrameNumber+Neighbor) * handles.v.CurrentBodyY(FrameNumber);
                end;            
                handles.v.CurrentBodyStdX(FrameNumber)        = handles.v.CurrentBodyStdX(FrameNumber+Neighbor);
                handles.v.CurrentBodyStdY(FrameNumber)        = handles.v.CurrentBodyStdY(FrameNumber+Neighbor);

                % draw new direction
                  handles = PlotforManual(handles);
                % Update handles structure
                  guidata(hObject, handles);
            end;
        end;
    end;



% --- Outputs from this function are returned to the command line.
function varargout = FlyWalker_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;



function load_edit_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'String') returns contents of load_edit as text
%        str2double(get(hObject,'String')) returns contents of load_edit as a double


% --- Executes during object creation, after setting all properties.
function load_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LEG TOGGLEBUTTONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in LF_togglebutton.
function LF_togglebutton_Callback(hObject, eventdata, handles)
    % Change leg status according to button status
    handles = ChangeLegStatus(handles,'LF');
    % Update handles structure
    guidata(hObject, handles);
% --- Executes on button press in RF_togglebutton.
function RF_togglebutton_Callback(hObject, eventdata, handles)
    % Change leg status according to button status
    handles = ChangeLegStatus(handles,'RF');
    % Update handles structure
    guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of RF_togglebutton
% --- Executes on button press in LM_togglebutton.
function LM_togglebutton_Callback(hObject, eventdata, handles)
    % Change leg status according to button status
    handles = ChangeLegStatus(handles,'LM');
    % Update handles structure
    guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of LM_togglebutton
% --- Executes on button press in RM_togglebutton.
function RM_togglebutton_Callback(hObject, eventdata, handles)
    % Change leg status according to button status
    handles = ChangeLegStatus(handles,'RM');
    % Update handles structure
    guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of RM_togglebutton
% --- Executes on button press in LB_togglebutton.
function LB_togglebutton_Callback(hObject, eventdata, handles)
    % Change leg status according to button status
    handles = ChangeLegStatus(handles,'LB');
    % Update handles structure
    guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of LB_togglebutton
% --- Executes on button press in RB_togglebutton.
function RB_togglebutton_Callback(hObject, eventdata, handles)
    % Change leg status according to button status
    handles = ChangeLegStatus(handles,'RB');
    % Update handles structure
    guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of RB_togglebutton
% --- Executes on button press in start_pushbutton.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BODY TOGGLEBUTTONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function center_pushbutton_Callback(hObject, eventdata, handles)
% place center of body.
    handles = ChangeBodyCenter(handles);
    % Update handles structure
    guidata(hObject, handles);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% Alexandre

% --- Executes on button press in TrueCenter.
function TrueCenter_Callback(hObject, eventdata, handles)
% place true center of body.
     handles = ChangeTrueCenter(handles);
     % Update handles structure
     guidata(hObject, handles);
     

% --- Executes on button press in TF.
function TrueFront_Callback(hObject, eventdata, handles)
% place true front of body.
    handles = ChangeTrueFront(handles);
    % Update handles structure
    guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function front_pushbutton_Callback(hObject, eventdata, handles)
% place front of body.
    handles = ChangeBodyFront(handles);
    % Update handles structure
    guidata(hObject, handles);

function body_off_pushbutton_Callback(hObject, eventdata, handles)
% turn body off at actual frame

    handles = BodyOff(handles, 'current');
    
    % Update handles structure
    guidata(hObject, handles);


function body_off_after_pushbutton_Callback(hObject, eventdata, handles)
% turn body off at frames at and after actual frame

    handles = BodyOff(handles, 'after');
    
    % Update handles structure
    guidata(hObject, handles);

function body_off_before_pushbutton_Callback(hObject, eventdata, handles)
% turn body off at frames at and before actual frame

    handles = BodyOff(handles, 'before');
    
    % Update handles structure
    guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% <<
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function start_pushbutton_Callback(hObject, eventdata, handles)

% Advance frame number with one
FrameNumber  = str2num(get(handles.frame_edit,'String'));
if FrameNumber ~= 1
    FrameNumber = 1;
    set(handles.frame_edit,'String',num2str(FrameNumber));
    guidata(hObject, handles);
    select_pushbutton_Callback(hObject, eventdata, handles);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% >
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in plus_pushbutton.
function plus_pushbutton_Callback(hObject, eventdata, handles)

% Advance frame number with one
handles.p.foldername = get(handles.load_edit,'String');
if handles.p.foldername(end) ~= '/'
    handles.p.foldername = [handles.p.foldername '/'];
end;
Length = length(handles.p.FileList);
FrameNumber  = str2num(get(handles.frame_edit,'String'));
FrameNumber = FrameNumber + 1;
if FrameNumber <= Length
    set(handles.frame_edit,'String',num2str(FrameNumber));
    guidata(hObject, handles);
    select_pushbutton_Callback(hObject, eventdata, handles);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% <
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in minus_pushbutton.
function minus_pushbutton_Callback(hObject, eventdata, handles)

% Decrease frame number with one
FrameNumber  = str2num(get(handles.frame_edit,'String'));
FrameNumber = FrameNumber - 1;
if FrameNumber >= 1
    set(handles.frame_edit,'String',num2str(FrameNumber));
    guidata(hObject, handles);
    select_pushbutton_Callback(hObject, eventdata, handles);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% >>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in toend_pushbutton.
function toend_pushbutton_Callback(hObject, eventdata, handles)

% go to the end of the frames
handles.p.foldername = get(handles.load_edit,'String');
if handles.p.foldername(end) ~= '/'
    handles.p.foldername = [handles.p.foldername '/'];
end;
Length = length(handles.p.FileList);
FrameNumber = Length;
set(handles.frame_edit,'String',num2str(FrameNumber));
guidata(hObject, handles);
select_pushbutton_Callback(hObject, eventdata, handles);

function frame_edit_Callback(hObject, eventdata, handles)

% Hints: get(hObject,'String') returns contents of frame_edit as text
%        str2double(get(hObject,'String')) returns contents of frame_edit as a double


% --- Executes during object creation, after setting all properties.
function frame_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in load_pushbutton.
function load_pushbutton_Callback(hObject, eventdata, handles)

handles = LoadData(handles);

figure1_ResizeFcn(hObject, eventdata, handles);

% Update handles structure
guidata(hObject, handles);







% Browse for input data folder
function loadbrowse_pushbutton_Callback(hObject, eventdata, handles)

old_folder_name = get(handles.load_edit,'String');
handles.p.start_path = old_folder_name;
% if start_path doesn't exist make it to the matlab directory
if exist(handles.p.start_path) ~= 7
    if exist(handles.p.input_directory_path) == 7
        handles.p.start_path = handles.p.input_directory_path;
    else
        handles.p.start_path = pwd;
    end
end;
folder_name = uigetdir(handles.p.start_path,'Select input directory path');
if folder_name == 0
    folder_name = old_folder_name;
end
set(handles.load_edit,'String',folder_name);
% set start_path to loaded directory
handles.p.start_path = folder_name;
% Update handles structure
guidata(hObject, handles);

% browse for processed data folder
function load_track_browse_pushbutton_Callback(hObject, eventdata, handles)

old_track_folder_name = get(handles.load_track_edit,'String');
handles.p.start_path_results = old_track_folder_name;
% if start_path doesn't exist make it to the matlab directory
if exist(handles.p.start_path_results) ~= 7
    if exist(handles.p.results_directory_path) == 7
        handles.p.start_path_results = handles.p.results_directory_path;
    else
        handles.p.start_path_results = 'Default...';
    end;
end;
track_folder_name = uigetdir(handles.p.start_path_results,'Select output directory path');
if track_folder_name == 0
    track_folder_name = old_track_folder_name;
end
set(handles.load_track_edit,'String',track_folder_name);
% set start_path to loaded directory
handles.p.start_path_results = track_folder_name;
% Update handles structure
guidata(hObject, handles);



function load_track_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function load_track_edit_Callback(hObject, eventdata, handles)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SELECT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in select_pushbutton.
function select_pushbutton_Callback(hObject, eventdata, handles)

handles = PlotforManual(handles);

% Update handles structure
guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECKBOXES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function ellipse_checkbox_Callback(hObject, eventdata, handles)
% % checks whether there should or should not be an ellipse drawn around the
% % fly.
% handles.p.ellipse = get(handles.ellipse_checkbox,'Value');
% handles = PlotforManual(handles);
% 
% % Update handles structure
% guidata(hObject, handles);
% 
% function bodytrack_checkbox_Callback(hObject, eventdata, handles)
% % turns body track on/off
% handles.p.drawbodytrack = get(handles.bodytrack_checkbox,'Value');
% handles = PlotforManual(handles);
% 
% % Update handles structure
% guidata(hObject, handles);
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESTORE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function restore_pushbutton_Callback(hObject, eventdata, handles)
handles.p = handles.pbackup;
handles.v = handles.vbackup;

handles = PlotforManual(handles);

% Update handles structure
guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SAVE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function save_pushbutton_Callback(hObject, eventdata, handles)
% save the changed information 
p = handles.p;
v = handles.v;
save(handles.inputfilename, 'p', 'v');
% write output file that evaluateflytable is going to use
fid = fopen(handles.p.outputtablefilename, 'wt');
v.time = 0;
for i = 1:length(handles.v.CurrentBodyX)
    if handles.v.CurrentBodyX(i) > 0
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Alexandre -> extra two %f and TC_x and TC_y at the end
        fprintf(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f\n', ...
            v.time,                handles.v.CurrentBodyX(i),          handles.v.CurrentBodyY(i),           handles.v.CurrentBodyDirection1(i), ...
            handles.v.CurrentBodyDirection2(i), handles.v.CurrentBodyDirection3(i), handles.v.CurrentBodyOrientation(i), handles.v.CurrentBodyStdX(i), ...
            handles.v.CurrentBodyStdY(i), ... 
            handles.v.CurrentLeftFrontLegX(i),  handles.v.CurrentLeftFrontLegY(i),  handles.v.CurrentRightFrontLegX(i),  handles.v.CurrentRightFrontLegY(i), ...
            handles.v.CurrentLeftMiddleLegX(i), handles.v.CurrentLeftMiddleLegY(i), handles.v.CurrentRightMiddleLegX(i), handles.v.CurrentRightMiddleLegY(i), ...
            handles.v.CurrentLeftBackLegX(i),   handles.v.CurrentLeftBackLegY(i),   handles.v.CurrentRightBackLegX(i),   handles.v.CurrentRightBackLegY(i), handles.v.TC_x(i), handles.v.TC_y(i));
    end;
    v.time = v.time + 1/handles.p.fps;
end;
fclose(fid);
text(220,100,'Data saved...','BackgroundColor', [1 1 1],'FontSize',22)

% Make sure that restore will restore the saved version
handles.pbackup = handles.p;
handles.vbackup = handles.v;

guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HELP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function help_menu_Callback(hObject, eventdata, handles)

function about_help_menu_Callback(hObject, eventdata, handles)
% Show about help menu option
About();

function howto_help_menu_Callback(hObject, eventdata, handles)
% Show help
Help();

function shortcuts_Callback(hObject, eventdata, handles)
% show list of shortcuts
Shortcuts();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BRIGHTNESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function brightness_decrease_pushbutton_Callback(hObject, eventdata, handles)
% decrease brightness
handles.p.picbrightness = handles.p.picbrightness / 1.2;
handles = PlotforManual(handles);
% Update handles structure
guidata(hObject, handles);


function brightness_increase_pushbutton_Callback(hObject, eventdata, handles)
% increase brightness
handles.p.picbrightness = handles.p.picbrightness * 1.2;
handles = PlotforManual(handles);
% Update handles structure
guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EVALUATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run EvaluateFlyTable
function evaluate_togglebutton_Callback(hObject, eventdata, handles)
  ind = find(handles.p.foldername == '/');
  folderout = handles.p.outputtablefilename;
  
  % run only if button is not pushed already 
    if get(handles.evaluate_togglebutton,'Value') == 1
        % draw message to let user know that the program is evaluating
          text(120,100,'Evaluating...','BackgroundColor', [1 1 1],'FontSize',13)
        % cange button name to indicate that function is running
          set(handles.evaluate_togglebutton,'string','cancel','BackgroundColor',[240 200 200]/255);
          
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          % Alexandre -> old code is commented
          
%         EvaluateFlyTable_02(handles.inputfilename, handles);

          if isequal(get(handles.Hexa,'Checked'),'on')
              EvaluateFlyTable_activex_hexa(handles.inputfilename, handles);
          elseif isequal(get(handles.Quad,'Checked'),'on')
              EvaluateFlyTable_activex_quad(handles.inputfilename, handles);
          else
              uiwait(msgbox('Please select either Hexa or Quad under the File menu.', 'Error'));
          end
          
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % change button name to indicate that function is running
          set(handles.evaluate_togglebutton,'string','evaluate','BackgroundColor', [240 240 240]/255);
        % put button back to normal
          set(handles.evaluate_togglebutton,'Value', 0);


        % get rid of mesage
        handles = PlotforManual(handles);
        drawnow;
        disp('Evaluation finished.')
        %load train.mat;
        %sound(y);
        uiwait(msgbox('Evaluation DONE!',':)','modal'))

        % Update handles structure
        guidata(hObject, handles);
    end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SAVE PICTURES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function picture_togglebutton_Callback(hObject, eventdata, handles)
ButtonStatus = get(handles.picture_togglebutton,'Value');
if ButtonStatus == 1
    
    % change drawn circle size so it shows ok on the saved pics; also save
    % original value;
    handles.p.circlesize_temp = handles.p.circlesize;
    handles.p.circlesize = handles.p.circlesize_saved;
    
    W = handles.v.picsize(1);
    H = handles.v.picsize(2);
    text(120,100,'Saving pictures. Press ''Pictures!'' to stop...','BackgroundColor', [1 1 1],'FontSize',13)
    FrameNumber  = str2num(get(handles.frame_edit,'String'));
    i = FrameNumber;
    while i <= length(handles.p.FileList) && ButtonStatus == 1
        h = figure('visible','off','PaperPositionMode', 'manual', 'PaperUnits', 'points', 'PaperPosition', [0 0 H W]*0.7);
        axes('position', [0 0 1 1]);                
        set(handles.frame_edit,'String',num2str(i));
        handles = PlotforManual(handles);
        % FrameNumber  = str2num(get(handles.frame_edit,'String'));
        outputfilename = [handles.p.outputfolder 'Images/' num2str(i) '.png'];
        saveas(h,outputfilename,'png');
        close(h);
        i = i + 1;
        ButtonStatus = get(handles.picture_togglebutton,'Value');
    end;

    % change back circle size
    handles.p.circlesize = handles.p.circlesize_temp;

end;


handles = PlotforManual(handles);
% Update handles structure
guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESIZE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% defines resize properties - default is proportional
function figure1_ResizeFcn(hObject, eventdata, handles)

%Figure Units are fixed as 'pixels';
if isfield(handles, 'Figure_Size_Original')
    originalsize = handles.Figure_Size_Original;
end
Figure_Size = get(handles.figure1,'Position');

% set size of imagebox_uipanel such that it is always proportional to
% picture size
if isfield(handles,'v')
    if isfield(handles.v,'rawpic')
        % get picture size
        PicSize = size(handles.v.rawpic)
        Pic_x = PicSize(2);
        Pic_y = PicSize(1);
        
        % get window coordinates in points
        set(handles.figure1,'Units','Pixels');              % Was normalized
        window_size = get(handles.figure1,'Position');      % Now in points
        window_width = window_size(3);
        window_height = window_size(4);
        set(handles.figure1,'Units','normalized');          % Now normalized again
        
        % get coordinates in points
        set(handles.imagebox_uipanel,'Units','Pixels');    
        imagebox_uipanel_position = get(handles.imagebox_uipanel,'Position');
        imagebox_x      = imagebox_uipanel_position(1);
        imagebox_y      = imagebox_uipanel_position(2);
        imagebox_width  = imagebox_uipanel_position(3);
        imagebox_height = imagebox_uipanel_position(4);

        % resize the size that is the smaller one compared to what it is
        % supposed to be
        imagebox_height = window_height   * 0.8;
        imagebox_width  = imagebox_height * Pic_x / Pic_y;
        if imagebox_width > window_width - 2 * imagebox_x
            imagebox_width  = window_width - 2 * imagebox_x;
            imagebox_height = imagebox_width * Pic_y / Pic_x;
        end;
        % shift bottom of imagebox such that it touches the buttons
        imagebox_y = window_height*0.8 - imagebox_height;

        % update sizes
        set(handles.imagebox_uipanel,'Position',[imagebox_x imagebox_y imagebox_width imagebox_height]);

        % switch back to normalized more
        set(handles.imagebox_uipanel,'Units','Normalized');    
        
    end;
end;
Figure_Size = get(handles.figure1,'Position');
imagebox_uipanel_position = get(handles.image_axes,'Position');
image_axes_position = get(handles.imagebox_uipanel,'Position');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUTO ANALYSIS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function auto_togglebutton_Callback(hObject, eventdata, handles)
% runs AutoFootprintAnalysis

ButtonStatus = get(handles.auto_togglebutton,'Value');

% run only if button is pressed down
if ButtonStatus == 1    
    % output info text
    text(120,100,'Auto Analyzing data. Press ''Auto'' to stop...','BackgroundColor', [1 1 1],'FontSize',13);
    % determine frame number
    handles.FrameNumber  = str2num(get(handles.frame_edit,'String'));
    % run fly tracking
    handles = AutoFootPrintAnalysis(handles,0);
    % plot results
    handles = PlotforManual(handles);
end;

% make sure that after the analysis the toggle button is up
set(handles.auto_togglebutton,'Value',0);

% Update handles structure
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EDIT SETTINGS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Settings menu
function settings_menu_Callback(hObject, eventdata, handles)

% write current parameters to the desktop
  % get gui handle
    hFootPrintAnalysis = getappdata(0,'hFootPrintAnalysis');

  % write data into gui handle that will be readable by the other file
    setappdata(hFootPrintAnalysis,'handlesp',handles.p);

  % save old border parameters before the change so the mask can be updated
    oldcut = handles.p.cut;
    
  % run parameter edit script
    ParametersEdit();
    waitfor(ParametersEdit);

    
  % retrieve data  
    handles.p = getappdata(hFootPrintAnalysis,'handlesp');  
  
    
  % If picture border changed reinitialize mask  
    if oldcut.up ~= handles.p.cut.up | oldcut.down ~= handles.p.cut.down | oldcut.left ~= handles.p.cut.left | oldcut.right ~= handles.p.cut.right
      % Calculate Dead Pixel Mask (DPM), average picture brightness (picAVG) and 
      % picture standard deviation (picSTD).
        [handles.v.DPM, handles.v.picAVG, handles.v.picSTD] = Masks(handles.p);
    end
    
  % redraw plot and buttons to refresh
    handles = PlotforManual(handles);
%     set(handles.ellipse_checkbox,  'Value',  handles.p.ellipse);
%     set(handles.bodytrack_checkbox,'Value',  handles.p.drawbodytrack);
    
% Update handles structure
guidata(hObject, handles);  



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MULTI-TRACK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function file_menu_Callback(hObject, eventdata, handles)

function multitrack_menu_Callback(hObject, eventdata, handles)
% load txt file that has list of folder names that one would like to multi auto
% track. The user needs to fil  l a file with the folder names of the videos
% they want to analyze. The results folder should be default. Each line
% should be a separate folder name.
  % let user browse for file with list
    startdirectory = pwd;
    [FileName,PathName,FilterIndex] = uigetfile({'*.*'},'Select file for muti-track');
    multitrack_file_name = [PathName '/' FileName];
  % load lines from file
    fid = fopen(multitrack_file_name);
    tline = fgetl(fid);
    num=0;
    while ischar(tline)
      disp(tline)
      num = num + 1;
      handles.multitrackfoldername(num) = {tline};
      tline = fgetl(fid);
    end
    fclose(fid);
  % go through files
    for i = 1:num
          % only do this if path exists
            if exist(char(handles.multitrackfoldername(i)))
              save_handles = handles;
              try 
                % set load path
                  set(handles.load_edit,'String',char(handles.multitrackfoldername(i)));
                % results will be default
                  handles.p.start_path_results = 'Default...';
                  set(handles.load_track_edit,'String',handles.p.start_path_results);
                % load video
                  handles = LoadData(handles);
                  figure1_ResizeFcn(hObject, eventdata, handles);
                % auto analysis
                  % output info text
                    text(120,100,'Auto Analyzing data. Press ''Auto'' to stop...','BackgroundColor', [1 1 1],'FontSize',13);
                  % set frame number to 1
      %               set(handles.frame_edit,'String',1);
                    handles.FrameNumber  = 1;%str2num(get(handles.frame_edit,'String'));
                  % set auto button to 1 for running
                    set(handles.auto_togglebutton,'Value',1);
                  % run fly tracking
                    handles = AutoFootPrintAnalysis(handles,1);
                  % set auto button back to 0
                    set(handles.auto_togglebutton,'Value',0);
                  % plot results
                    handles = PlotforManual(handles);
              catch
                handles = save_handles;
              end;
            end;
    end;
    %Ines added following line
    uiwait(msgbox('Auto-tracking DONE!',':)','modal')); 
  % auto track
    auto_togglebutton_Callback(hObject, eventdata, handles);
  % start
  % Update handles structure
  guidata(hObject, handles);

  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MULTI EVALUATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function multievaluate_menu_Callback(hObject, eventdata, handles)
% % load txt file that has list of folder names that one would like to multi auto
% % evaluate. The user needs to fill a file with the folder names of the
% % videos they want to evaluate. The results folder should be default. Each line
%   % let user browse for file with list
%     startdirectory = pwd;
%     [FileName,PathName,FilterIndex] = uigetfile({'*.*'},'Select file for muti-evaluate');
%     multievaluate_file_name = [PathName '/' FileName];
%   % load lines from file
%     fid = fopen(multievaluate_file_name);
%     tline = fgetl(fid);
%     num=0;
%     while ischar(tline)
%       disp(tline)
%       num = num + 1;
%       handles.multievaluatefoldername(num) = {tline};
%       tline = fgetl(fid);
%     end
%     fclose(fid);
%   % go through files
%     for i = 1:num
%           % only do this if path exists
%             if exist(char(handles.multievaluatefoldername(i)))
%               % set load path
%                 set(handles.load_edit,'String',char(handles.multievaluatefoldername(i)));
%               % results will be default
%                 handles.p.start_path_results = 'Default...';
%                 set(handles.load_track_edit,'String',handles.p.start_path_results);
%               % load video
%                 handles = LoadData(handles);
%                 figure1_ResizeFcn(hObject, eventdata, handles);
%               % auto analysis
%                 % output info text
%                   text(120,100,'Auto Evaluating data. Press ''Auto'' to stop...','BackgroundColor', [1 1 1],'FontSize',13);
%                 % set frame number to 1
%     %               set(handles.frame_edit,'String',1);
%                   handles.FrameNumber  = 1;%str2num(get(handles.frame_edit,'String'));
%                 % set auto button to 1 for running
%                   set(handles.evaluate_togglebutton,'Value',1);
%                 % run evaluation
%                 
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 
%                 % Alexandre -> old code is commented
%                 
%               	if isequal(get(handles.Hexa,'Checked'),'on')
%                     EvaluateFlyTable_activex_hexa(handles.inputfilename, handles);
%                 elseif isequal(get(handles.Quad,'Checked'),'on')
%                     EvaluateFlyTable_activex_quad(handles.inputfilename, handles);
%                 else
%                     disp('You know nothing, Alexandre. (FlyWalker.m, line 1195)')
%                 end
% %                   EvaluateFlyTable_02(handles.inputfilename, handles);
% 
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 
%                 % set auto button back to 0
%                   set(handles.evaluate_togglebutton,'Value',0);
%                 % plot results
%                   handles = PlotforManual(handles);
%             end;
%     end;
% 
%   % auto track
%     auto_togglebutton_Callback(hObject, eventdata, handles);
%   % start
%   % Update handles structure
%   guidata(hObject, handles);
%   disp('Multi evaluation finished.')
%   uiwait(msgbox('Multi evaluation finished.', 'Finished'));
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Alexandre -> Commented old code above
  
  % Select input file
  [filename,pathname,~] = uigetfile('*.txt;','Select paths file.');
  
  % Check hexa or quad
  
  if isequal(get(handles.Hexa,'Checked'),'on')
      type = 'h';
  elseif isequal(get(handles.Quad,'Checked'),'on')
      type = 'q';
  else
      uiwait(msgbox('Please select either Hexa or Quad under the File menu.', 'Error'));
  end
  
  % Run the script
  MultiEvaluate(fullfile(pathname,filename),strcat(pathname,'Summary'),type);
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MULTI DEEP LEARNING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ricardo Aires Reverse 2020
%
function multidl_menu_Callback(hObject, eventdata, handles)
    disp("Select all the video folders to perform deep learning predictions...");
    all_videos_dir = uigetdir(pwd, "Select directory containing all the videos.")
    MultiDeeepLearning(all_videos_dir);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXIT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
function exit_menu_Callback(hObject, eventdata, handles)
% exit
  disp('Bye...')
  close(gcf)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CUT OUT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cut_out_pushbutton_Callback(hObject, eventdata, handles)
% let the user define a rectangle by pointing at its two corners. Cut the
% rectangle out such that it wont be analyzed any longer.

% let user place the first corner manually
  [x,y] = myginput(1, 'crosshair');
% continue only if the placement is within the frame
  if x > 0 & x < handles.v.picsize(2) & y > 0 & y < handles.v.picsize(1)
      % mark the first corner
      plot(x,y,'bo')
      % let user place the second corner manually
        [x2,y2] = myginput(1, 'crosshair');
      % continue only if the placement is within the frame
        if x2 > 0 & x2 < handles.v.picsize(2) & y2 > 0 & y2 < handles.v.picsize(1)
            % round values and choose which corner is smaller and which is
            % bigger
              DPMsize = size(handles.v.DPM);
              minx = max(1,round(min(x,x2)) + 1) - handles.p.cut.left + 1;
              maxx = min(DPMsize(2),round(max(x,x2)) + 1) - handles.p.cut.left + 1;
              miny = max(1, round(min(y,y2)) + 1) - handles.p.cut.up   + 1;
              maxy = min(DPMsize(1), round(max(y,y2)) + 1) - handles.p.cut.up   + 1;
            % cut out rectangle from frames by making mask include
            % rectangle
           
              handles.v.DPM(miny:maxy,minx:maxx) = 255;
            % replot screen
              handles = PlotforManual(handles);    
            % mark the four corners
              plot([minx minx maxx maxx minx]-1+handles.p.cut.left-1,[miny maxy maxy miny miny]-1+handles.p.cut.up-1,'b:', 'MarkerFaceColor',[0 0 1]);
%               P = patch([minx minx maxx maxx]+handles.p.cut.left-1, [miny maxy maxy miny]+handles.p.cut.up-1,'k');

            % Update handles structure
              guidata(hObject, handles);  
        end;
  end;
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RULER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Measures the distance between two points the user defines
function ruler_pushbutton_Callback(hObject, eventdata, handles)
% let user place the first point manually
  [x,y] = myginput(1, 'crosshair');
% continue only if the placement is within the frame
  if x > 0 & x < handles.v.picsize(2) & y > 0 & y < handles.v.picsize(1)
      % mark the first point
      plot(x,y,'bo')
      % let user place the second point manually
        [x2,y2] = myginput(1, 'crosshair');
      % continue only if the placement is within the frame
        if x2 > 0 & x2 < handles.v.picsize(2) & y2 > 0 & y2 < handles.v.picsize(1)

              % measure distance between points
              DIST_in_pixel = sqrt((x - x2)^2 + (y - y2)^2)
              DIST_in_us = DIST_in_pixel / handles.p.distcal
              ANGLEP = atan2d(y2-y, x2-x);
              % replot screen
              handles = PlotforManual(handles);    
            % mark the distance between the two ends
              plot([x x2],[y y2],'b', 'MarkerFaceColor',[0 0 1], 'LineWidth',2);
              plot([x x2],[y y2],'bx', 'MarkerFaceColor',[0 0 1], 'LineWidth',2);
            
            % write distance on screen
            TEXT = [num2str(round(DIST_in_pixel)) ' pixels'];
            text(5,handles.p.cut.up + 15,TEXT,'Color','y','FontSize',18)
            TEXT = [num2str(round(DIST_in_us)) ' um'];
            text(5,handles.p.cut.up + 30,TEXT,'Color','y','FontSize',18)
            TEXT = [num2str(round(ANGLEP)) ' deg'];
            text(5,handles.p.cut.up + 45,TEXT,'Color','y','FontSize',18)
           
            handles.p.DLInitAngle = ANGLEP;

            
            % Update handles structure
              guidata(hObject, handles);  
        end;
  end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function brightness_measure_pushbutton_Callback(hObject, eventdata, handles)
  % let user choose a point on figure, measure its brightness and output it to screen
  % determine picture size
    if isfield(handles,'v')
      if isfield(handles.v, 'pic')
        picsize = handles.v.picsize;
      else, return; end;
    else return; end;
  % let user place the first point manually
    [x,y] = myginput(1, 'crosshair');
    x = round(x)-handles.p.cut.left;
    y = round(y)-handles.p.cut.up;
  % continue only if the placement is within the frame
    if x > 0 & x < picsize(2) & y > 0 & y < picsize(1)
      % replot screen
        handles = PlotforManual(handles);
      % write distance on screen
        TEXT = ['[' num2str(handles.v.pic.R(y,x)), ',' num2str(handles.v.pic.G(y,x)) ',' num2str(handles.v.pic.B(y,x)) ']'];
        text(picsize(1)/20+5,picsize(2)/20+10,TEXT,'Color','b','FontSize',20)
      % Update handles structure
        guidata(hObject, handles);  
    end;  

function position_measure_pushbutton_Callback(hObject, eventdata, handles)
  % let user choose a point on figure, measure its position and output it to screen
  % determine picture size
    if isfield(handles,'v')
      if isfield(handles.v, 'pic')
        picsize = handles.v.picsize;
      else, return; end;
    else return; end;
  % let user place the first point manually
    [x,y] = myginput(1, 'crosshair');
    x = round(x);
    y = round(y);
  % continue only if the placement is within the frame
    if x > 0 & x < picsize(2) & y > 0 & y < picsize(1)
      % replot screen
        handles = PlotforManual(handles);
      % write distance on screen
        TEXT = ['(' num2str(round(x)) ', ' num2str(round(y)) ')'];
        text(picsize(1)/20+5,picsize(2)/20+10,TEXT,'Color','b','FontSize',20)
      % Update handles structure
        guidata(hObject, handles);  
    end;  
%==========================================================================  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FRAME SLIDER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on slider movement.
function frame_slider_Callback(hObject, eventdata, handles)

  % determine which frame to plot with slider
    FrameNumber = round(get(handles.frame_slider,'Value'))
    set(handles.frame_edit,'String',num2str(FrameNumber));
  % plot 
    select_pushbutton_Callback(hObject, eventdata, handles);

function frame_slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%==========================================================================


% --------------------------------------------------------------------
function Changelog_v2_Callback(hObject, eventdata, handles)
% show Changelog
open('Changelog.pdf');

% --------------------------------------------------------------------
function Hexa_Callback(hObject, eventdata, handles)
if isequal(get(handles.Quad,'Checked'),'on')
    set(handles.Quad,'Checked','off');
    set(hObject,'Checked','on');
else
    set(hObject,'Checked','on');
end

% --------------------------------------------------------------------
function Quad_Callback(hObject, eventdata, handles)
if isequal(get(handles.Hexa,'Checked'),'on')
    set(handles.Hexa,'Checked','off');
    set(hObject,'Checked','on');
else
    set(hObject,'Checked','on');
end


% --------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre
function Filename_compiler_Callback(hObject, eventdata, handles)
% run filename_compiler_v2.m

out_dir = uigetdir('','Choose directory to list.');

filename_compiler_v2(out_dir);

disp(' ')
disp('File saved to specified directory. <a href="matlab: open(''file.txt'')">Click to view</a>.');


% --------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre
function Result_compiler_Callback(hObject, eventdata, handles)

[filename,pathname,~] = uigetfile('*.txt;','Select paths file.');

disp('Creating summary file...')
disp(' ')

fid = fopen(fullfile(pathname,filename), 'r');

% read in files one by one
counter = 0;
while 1
    line = fgetl(fid); % read in line
    % exit if there are no more lines
    if ~ischar(line),   break,   end;
    
    % evaluate data in file name defined by line
    try
        FILEname = [line '\Results\TRACKS.mat'];
        ind = find(FILEname == '/' | FILEname == '\');
        foldername = FILEname(1:ind(end))   ;
        ind = find(foldername == '/' | foldername == '\' | foldername == ' ' | foldername == '.' | foldername == ':');
        ExcelFileName = foldername;
        ExcelFileName(ind) = '_';
        ExcelFileName = ExcelFileName(max(1,end-30):end);
        % read data
        [num,txt,raw] = xlsread([foldername ExcelFileName '.xlsx'],'1.Info_Sheet', 'A40:EB41');%Modified by Inês
        % save data in matrix
        counter = counter + 1;
        % save header
        if counter == 1
            Data(1,:) = raw(1,:);
            counter = counter + 1;
        end;
        Data(counter,:) = raw(2,:);
        
    catch ME
%         disp('Something went wrong with this file. Skipping...');
    end;
end;

% save data in new excel file
outputfilename = strcat(pathname,'Result_compiler.xlsx');
xlswrite(outputfilename, Data,'1');
disp('Done.')


% --- Executes on button press in pushbutton41.
function pushbutton41_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton41 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
