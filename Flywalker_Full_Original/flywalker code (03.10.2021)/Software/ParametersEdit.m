function varargout = ParametersEdit(varargin)
% PARAMETERSEDIT M-file for ParametersEdit.fig
%      PARAMETERSEDIT, by itself, creates a new PARAMETERSEDIT or raises the existing
%      singleton*.
%
%      H = PARAMETERSEDIT returns the handle to a new PARAMETERSEDIT or the handle to
%      the existing singleton*.
%
%      PARAMETERSEDIT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PARAMETERSEDIT.M with the given input arguments.
%
%      PARAMETERSEDIT('Property','Value',...) creates a new PARAMETERSEDIT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ParametersEdit_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ParametersEdit_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% (c) Imre Bartos, 2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ParametersEdit_OpeningFcn, ...
                   'gui_OutputFcn',  @ParametersEdit_OutputFcn, ...
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


% --- Executes just before ParametersEdit is made visible.
function ParametersEdit_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ParametersEdit (see VARARGIN)

% Choose default command line output for ParametersEdit
handles.output = hObject;

% update window title
set(gcf,'Name','FlyWalker - Parameter Setup');

% load handle for main GUI
handles.hFootPrintAnalysis = getappdata(0, 'hFootPrintAnalysis');
% load data from main gui
handles.p = getappdata(handles.hFootPrintAnalysis,'handlesp');

% set saveasdefault to 0, it will be set to 1 if user presses Save as
% Default button
handles.saveasdefault = 0;


% fill up setting boxes with parameters;
% Display Settings
set(handles.ellipse_checkbox,                 'Value',          handles.p.ellipse);
set(handles.body_track_checkbox,              'Value',          handles.p.drawbodytrack);
set(handles.colorbar_checkbox,                'Value',          handles.p.Colorbar);
set(handles.inverted_colors_checkbox,         'Value',          handles.p.invert);
set(handles.length_bar_checkbox,              'Value',          handles.p.lengthbar);
set(handles.draw_frames_in_auto_checkbox,     'Value',          handles.p.drawwhileauto);
set(handles.show_past_footprints_checkbox,    'Value',          0);
set(handles.show_past_footprints_lastframe_checkbox,    'Value',          0);
if handles.p.show_past_footprints == 1, set(handles.show_past_footprints_checkbox, 'Value', 1); end;
if handles.p.show_past_footprints == 2, set(handles.show_past_footprints_lastframe_checkbox, 'Value', 1); end;
set(handles.brightness_edit,                  'String', num2str(handles.p.picbrightness));
set(handles.colormap_edit,                    'String', num2str(handles.p.color));
set(handles.footprint_drawn_radius_edit,      'String', num2str(handles.p.circlesize));
set(handles.footprint_saved_radius_edit,      'String', num2str(handles.p.circlesize_saved));
% Frame settings
set(handles.fps_edit,                         'String', num2str(handles.p.fps));
set(handles.distance_calibration_edit,        'String', num2str(handles.p.distcal));
set(handles.picture_border_up_edit,           'String', num2str(handles.p.cut.up));
set(handles.picture_border_down_edit,         'String', num2str(handles.p.cut.down));
set(handles.picture_border_left_edit,         'String', num2str(handles.p.cut.left));
set(handles.picture_border_right_edit,        'String', num2str(handles.p.cut.right));
set(handles.background_length_edit,           'String', num2str(handles.p.BGlength));
set(handles.background_threshold_edit,        'String', num2str(handles.p.BGthreshold));
set(handles.smoothing_checkbox,               'Value',          handles.p.smoothing);
% Analysis parameters

set(handles.use_background_subtraction_checkbox,'Value', handles.p.UseBackgroundSubtraction);
set(handles.use_fit_ellipse_checkbox,'Value',          handles.p.UseFitEllipse);
set(handles.front_body_threshold,               'String', num2str(handles.p.FrontBodyThreshold)); % REVERSE ENG
set(handles.leg_threshold_edit,               'String', num2str(handles.p.legthreshold));
set(handles.leg_on_threshold_edit,            'String', num2str(handles.p.legonthreshold));
set(handles.body_lower_threshold_edit,        'String', num2str(handles.p.bodylowerthreshold));
set(handles.body_upper_threshold_edit,        'String', num2str(handles.p.bodyupperthreshold));
set(handles.min_body_size_edit,               'String', num2str(handles.p.MinBodySize));
set(handles.max_leg_move_edit,                'String', num2str(handles.p.radiusleg));
set(handles.max_body_move_edit,               'String', num2str(handles.p.radiusbody));
set(handles.max_leg_gap_edit,                 'String', num2str(handles.p.maxtimedifferenceleg));
set(handles.max_body_gap_edit,                'String', num2str(handles.p.maxtimedifferencebody));
set(handles.max_leg_pixel_separation_edit,    'String', num2str(handles.p.maxgapleg));
set(handles.max_body_pixel_sep_edit,          'String', num2str(handles.p.maxgapbody));
set(handles.max_leg_body_dist_edit,           'String', num2str(handles.p.maxDist));
set(handles.min_leg_body_dist_edit,           'String', num2str(handles.p.minDist));
set(handles.min_leg_swing_edit,               'String', num2str(handles.p.minlegswing));
set(handles.min_footprint_duration_edit,      'String', num2str(handles.p.minframe));
set(handles.define_center_from_front_checkbox,'Value',          handles.p.CenterFromFront);
set(handles.center_from_front_dist_edit,      'String', num2str(handles.p.CenterFromFrontDist));
set(handles.fixed_body_length_checkbox,       'Value',          handles.p.fixed_body_length);
set(handles.fixed_body_length_value_edit,     'String', num2str(handles.p.fixed_body_length_value));
set(handles.R_filter_edit,                    'String', num2str(handles.p.BGoffset.R));
set(handles.G_filter_edit,                    'String', num2str(handles.p.BGoffset.G));
set(handles.B_filter_edit,                    'String', num2str(handles.p.BGoffset.B));
set(handles.sigma_filter_edit,                'String', num2str(handles.p.BGoffset.sigma));

% Default directories
% if directories dont exist, make them default
if exist(handles.p.input_directory_path) ~= 7 handles.p.input_directory_path = ' '; end;
if exist(handles.p.results_directory_path) ~= 7 handles.p.results_directory_path = 'Default...'; end;
set(handles.input_directory_path_edit,        'String',         handles.p.input_directory_path);
set(handles.results_directory_path_edit,      'String',         handles.p.results_directory_path);

% set edit space gray if inactive
if handles.p.CenterFromFront == 0
    set(handles.center_from_front_dist_edit,      'BackgroundColor', [0.9 0.9 0.9]);
end

% set edit space gray if inactive
if handles.p.fixed_body_length == 0
    set(handles.fixed_body_length_value_edit,      'BackgroundColor', [0.9 0.9 0.9]);
end

% set up forced direction
if handles.p.force_direction == -1
    set(handles.left_radiobutton, 'Value', 1);
    set(handles.right_radiobutton, 'Value', 0);
elseif handles.p.force_direction == 1
    set(handles.left_radiobutton, 'Value', 0);
    set(handles.right_radiobutton, 'Value', 1);
else
    set(handles.left_radiobutton, 'Value', 0);
    set(handles.right_radiobutton, 'Value', 0);
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ParametersEdit wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ParametersEdit_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function OK_pushbutton_Callback(hObject, eventdata, handles)


% read in values
% Display Settings
handles.p.ellipse                   =         get(handles.ellipse_checkbox,                 'Value');
handles.p.drawbodytrack             =         get(handles.body_track_checkbox,              'Value');
handles.p.Colorbar                  =         get(handles.colorbar_checkbox,                'Value');
handles.p.invert                    =         get(handles.inverted_colors_checkbox,         'Value');
handles.p.lengthbar                 =         get(handles.length_bar_checkbox,              'Value');
handles.p.drawwhileauto             =         get(handles.draw_frames_in_auto_checkbox,     'Value');
handles.p.show_past_footprints      =         (get(handles.show_past_footprints_checkbox,    'Value') + ...
                                               2*get(handles.show_past_footprints_lastframe_checkbox,'Value'));
handles.p.picbrightness             = str2num(get(handles.brightness_edit,                  'String'));
handles.p.color                     =         get(handles.colormap_edit,                    'String');
handles.p.circlesize                = str2num(get(handles.footprint_drawn_radius_edit,      'String'));
handles.p.circlesize_saved          = str2num(get(handles.footprint_saved_radius_edit,      'String'));
% Frame settings
handles.p.fps                       = str2num(get(handles.fps_edit,                         'String'));
handles.p.distcal                   = str2num(get(handles.distance_calibration_edit,        'String'));
handles.p.cut.up                    = str2num(get(handles.picture_border_up_edit,           'String'));
handles.p.cut.down                  = str2num(get(handles.picture_border_down_edit,         'String'));
handles.p.cut.left                  = str2num(get(handles.picture_border_left_edit,         'String'));
handles.p.cut.right                 = str2num(get(handles.picture_border_right_edit,        'String'));
handles.p.BGlength                  = str2num(get(handles.background_length_edit,           'String'));
handles.p.BGthreshold               = str2num(get(handles.background_threshold_edit,        'String'));
handles.p.smoothing                 =         get(handles.smoothing_checkbox,               'Value');
% Analysis parameters
handles.p.UseBackgroundSubtraction  = get(handles.use_background_subtraction_checkbox,'Value');
handles.p.UseFitEllipse             = get(handles.use_fit_ellipse_checkbox,'Value');
handles.p.FrontBodyThreshold        = str2num(get(handles.front_body_threshold,         'String'));
handles.p.legthreshold              = str2num(get(handles.leg_threshold_edit,               'String'));
handles.p.legonthreshold            = str2num(get(handles.leg_on_threshold_edit,            'String'));
handles.p.bodylowerthreshold        = str2num(get(handles.body_lower_threshold_edit,        'String'));
handles.p.bodyupperthreshold        = str2num(get(handles.body_upper_threshold_edit,        'String'));
handles.p.MinBodySize               = str2num(get(handles.min_body_size_edit,               'String'));
handles.p.radiusleg                 = str2num(get(handles.max_leg_move_edit,                'String'));
handles.p.radiusbody                = str2num(get(handles.max_body_move_edit,               'String'));
handles.p.maxtimedifferenceleg      = str2num(get(handles.max_leg_gap_edit,                 'String'));
handles.p.maxtimedifferencebody     = str2num(get(handles.max_body_gap_edit,                'String'));
handles.p.maxgapleg                 = str2num(get(handles.max_leg_pixel_separation_edit,    'String'));
handles.p.maxgapbody                = str2num(get(handles.max_body_pixel_sep_edit,          'String'));
handles.p.maxDist                   = str2num(get(handles.max_leg_body_dist_edit,           'String'));
handles.p.minDist                   = str2num(get(handles.min_leg_body_dist_edit,           'String'));
handles.p.minlegswing               = str2num(get(handles.min_leg_swing_edit,               'String'));
handles.p.minframe                  = str2num(get(handles.min_footprint_duration_edit,      'String'));
handles.p.CenterFromFront           =         get(handles.define_center_from_front_checkbox,'Value');
handles.p.CenterFromFrontDist       = str2num(get(handles.center_from_front_dist_edit,      'String'));
left                                =         get(handles.left_radiobutton,                 'Value');
right                               =         get(handles.right_radiobutton,                'Value');
handles.p.force_direction           = right - left;
handles.p.fixed_body_length         =         get(handles.fixed_body_length_checkbox,       'Value');
handles.p.fixed_body_length_value   = str2num(get(handles.fixed_body_length_value_edit,     'String'));
% Default directories
handles.p.input_directory_path      =         get(handles.input_directory_path_edit,        'String');
handles.p.results_directory_path    =         get(handles.results_directory_path_edit,      'String');
handles.p.BGoffset.R                = str2num(get(handles.R_filter_edit,                    'String'));
handles.p.BGoffset.G                = str2num(get(handles.G_filter_edit,                    'String'));
handles.p.BGoffset.B                = str2num(get(handles.B_filter_edit,                    'String'));
handles.p.BGoffset.sigma            = str2num(get(handles.sigma_filter_edit,                    'String'));




% save parameters to default parameter file Parameters.mat
  if handles.saveasdefault == 1
      p = handles.p;
%       save('./Software/Parameters.mat','p');
      save('Parameters.mat','p');
      disp(' ')
      disp('Parameter values saved as default to ''Parameters.mat''')
      disp(' ')
  end;

% save values to desktop
setappdata(handles.hFootPrintAnalysis,'handlesp',handles.p);


% exit
delete(gcf)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SAVE AS DEFAULT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function save_as_default_pushbutton_Callback(hObject, eventdata, handles)

% set default save to 1
  handles.saveasdefault = 1;
% run OK_Callback
  OK_pushbutton_Callback(hObject, eventdata, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CANCEL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cancel_pushbutton_Callback(hObject, eventdata, handles)

% exit
delete(gcf)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BROWSE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% browse for input directory
function input_directory_path_browser_pushbutton_Callback(hObject, eventdata, handles)

old_folder_name = get(handles.input_directory_path_edit, 'String');
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
set(handles.input_directory_path_edit,'String',folder_name);
% set start_path to loaded directory
handles.p.input_directory_path = folder_name;
% Update handles structure
guidata(hObject, handles);

% browse for output directory
function results_directory_path_browser_pushbutton_Callback(hObject, eventdata, handles)

old_folder_name = get(handles.results_directory_path_edit, 'String');
handles.p.start_path = old_folder_name;
% if start_path doesn't exist make it to the matlab directory
if exist(handles.p.start_path) ~= 7
    if exist(handles.p.results_directory_path) == 7
        handles.p.start_path = handles.p.results_directory_path;
    else
        handles.p.start_path = 'Default...';
    end
end;
folder_name = uigetdir(handles.p.start_path,'Select output directory path');
if folder_name == 0
    folder_name = old_folder_name;
end
set(handles.results_directory_path_edit,'String',folder_name);
% set start_path to loaded directory
handles.p.results_directory_path = folder_name;
% Update handles structure
guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DIRECTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function right_radiobutton_Callback(hObject, eventdata, handles)
if get(handles.right_radiobutton, 'Value')
    set(handles.left_radiobutton, 'Value',0)
end

function left_radiobutton_Callback(hObject, eventdata, handles)
if get(handles.left_radiobutton, 'Value')
    set(handles.right_radiobutton, 'Value',0)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RECOLOR INACTIVE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function define_center_from_front_checkbox_Callback(hObject, eventdata, handles)
% set edit space gray if inactive
CenterFromFront           =         get(handles.define_center_from_front_checkbox,'Value');
if CenterFromFront == 0
    set(handles.center_from_front_dist_edit,      'BackgroundColor', [0.9 0.9 0.9]);
else
    set(handles.center_from_front_dist_edit,      'BackgroundColor', [1 1 1]);
end

function fixed_body_length_checkbox_Callback(hObject, eventdata, handles)
% set edit space gray if inactive
FixedBodyLength           =         get(handles.fixed_body_length_checkbox,'Value');
if FixedBodyLength == 0
    set(handles.fixed_body_length_value_edit,      'BackgroundColor', [0.9 0.9 0.9]);
else
    set(handles.fixed_body_length_value_edit,      'BackgroundColor', [1 1 1]);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PAST FOOTPRINT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% select whether past footprints should be shown on all or just the very
% last frame.

function show_past_footprints_lastframe_checkbox_Callback(hObject, eventdata, handles)
if get(handles.show_past_footprints_lastframe_checkbox, 'Value')
    set(handles.show_past_footprints_checkbox, 'Value',0)
end

function show_past_footprints_checkbox_Callback(hObject, eventdata, handles)
if get(handles.show_past_footprints_checkbox, 'Value')
    set(handles.show_past_footprints_lastframe_checkbox, 'Value',0)
end



%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------


function fps_edit_Callback(hObject, eventdata, handles)


function fps_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function picture_border_up_edit_Callback(hObject, eventdata, handles)


function picture_border_up_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit4_Callback(hObject, eventdata, handles)

function edit4_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit5_Callback(hObject, eventdata, handles)


function edit5_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit14_Callback(hObject, eventdata, handles)


function edit14_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit15_Callback(hObject, eventdata, handles)


function edit15_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit16_Callback(hObject, eventdata, handles)


function edit16_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit17_Callback(hObject, eventdata, handles)


function edit17_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function picture_border_down_edit_Callback(hObject, eventdata, handles)


function picture_border_down_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function picture_border_left_edit_Callback(hObject, eventdata, handles)


function picture_border_left_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function picture_border_right_edit_Callback(hObject, eventdata, handles)


function picture_border_right_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function leg_threshold_edit_Callback(hObject, eventdata, handles)


function leg_threshold_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function leg_on_threshold_edit_Callback(hObject, eventdata, handles)


function leg_on_threshold_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function body_lower_threshold_edit_Callback(hObject, eventdata, handles)


function body_lower_threshold_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function body_upper_threshold_edit_Callback(hObject, eventdata, handles)


function body_upper_threshold_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function min_body_size_edit_Callback(hObject, eventdata, handles)


function min_body_size_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function max_leg_move_edit_Callback(hObject, eventdata, handles)


function max_leg_move_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function max_body_move_edit_Callback(hObject, eventdata, handles)


function max_body_move_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function max_leg_gap_edit_Callback(hObject, eventdata, handles)


function max_leg_gap_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function max_body_gap_edit_Callback(hObject, eventdata, handles)


function max_body_gap_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function background_length_edit_Callback(hObject, eventdata, handles)


function background_length_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function smoothing_checkbox_Callback(hObject, eventdata, handles)


function background_threshold_edit_Callback(hObject, eventdata, handles)


function background_threshold_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function max_leg_pixel_separation_edit_Callback(hObject, eventdata, handles)


function max_leg_pixel_separation_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function max_body_pixel_sep_edit_Callback(hObject, eventdata, handles)


function max_body_pixel_sep_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function max_leg_body_dist_edit_Callback(hObject, eventdata, handles)


function max_leg_body_dist_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function min_leg_body_dist_edit_Callback(hObject, eventdata, handles)


function min_leg_body_dist_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function brightness_edit_Callback(hObject, eventdata, handles)


function brightness_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function colormap_edit_Callback(hObject, eventdata, handles)


function colormap_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ellipse_checkbox_Callback(hObject, eventdata, handles)


function colorbar_checkbox_Callback(hObject, eventdata, handles)


function inverted_colors_checkbox_Callback(hObject, eventdata, handles)


function min_leg_swing_edit_Callback(hObject, eventdata, handles)


function min_leg_swing_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function distance_calibration_edit_Callback(hObject, eventdata, handles)


function distance_calibration_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function min_footprint_duration_edit_Callback(hObject, eventdata, handles)


function min_footprint_duration_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function center_from_front_dist_edit_Callback(hObject, eventdata, handles)


function center_from_front_dist_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function length_bar_checkbox_Callback(hObject, eventdata, handles)


function draw_frames_in_auto_checkbox_Callback(hObject, eventdata, handles)


function footprint_drawn_radius_edit_Callback(hObject, eventdata, handles)


function footprint_drawn_radius_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function footprint_saved_radius_edit_Callback(hObject, eventdata, handles)


function footprint_saved_radius_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function input_directory_path_edit_Callback(hObject, eventdata, handles)


function input_directory_path_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function results_directory_path_edit_Callback(hObject, eventdata, handles)


function results_directory_path_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function figure1_ResizeFcn(hObject, eventdata, handles)

function body_track_checkbox_Callback(hObject, eventdata, handles)

function edit48_Callback(hObject, eventdata, handles)

function edit48_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function fixed_body_length_value_edit_Callback(hObject, eventdata, handles)

function fixed_body_length_value_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function R_filter_edit_Callback(hObject, eventdata, handles)

function R_filter_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function G_filter_edit_Callback(hObject, eventdata, handles)

function G_filter_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function B_filter_edit_Callback(hObject, eventdata, handles)

function B_filter_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sigma_filter_edit_Callback(hObject, eventdata, handles)

function sigma_filter_edit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function front_body_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to front_body_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of front_body_threshold as text
%        str2double(get(hObject,'String')) returns contents of front_body_threshold as a double


% --- Executes during object creation, after setting all properties.
function front_body_threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to front_body_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in use_fit_ellipse_checkbox.
function use_fit_ellipse_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to use_fit_ellipse_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of use_fit_ellipse_checkbox


% --- Executes during object creation, after setting all properties.
function use_fit_ellipse_checkbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to use_fit_ellipse_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in use_background_subtraction_checkbox.
function use_background_subtraction_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to use_background_subtraction_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of use_background_subtraction_checkbox


% --- Executes during object creation, after setting all properties.
function use_background_subtraction_checkbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to use_background_subtraction_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
