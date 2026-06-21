function varargout = CreateFolderQuestion(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function varargout = CreateFolderQuestion(varargin)
%
%
% (c) Imre Bartos, 2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Edit the above text to modify the response to help CreateFolderQuestion

% Last Modified by GUIDE v2.5 30-Jul-2010 15:18:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CreateFolderQuestion_OpeningFcn, ...
                   'gui_OutputFcn',  @CreateFolderQuestion_OutputFcn, ...
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


% --- Executes just before CreateFolderQuestion is made visible.
function CreateFolderQuestion_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CreateFolderQuestion (see VARARGIN)

% Choose default command line output for CreateFolderQuestion
handles.output = hObject;


% load handle for main GUI
handles.hFootPrintAnalysis = getappdata(0, 'hFootPrintAnalysis');
% load data from main gui
folder_name = getappdata(handles.hFootPrintAnalysis,'handlesptrackfoldername');
handles.folder_name = folder_name;
% write folder name in text box
set(handles.folder_name_edit,'String',handles.folder_name);

% update window title
set(gcf,'Name','FootPrintAnalysis: Create New Output Folder');


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CreateFolderQuestion wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CreateFolderQuestion_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function folder_name_edit_Callback(hObject, eventdata, handles)


function folder_name_edit_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function yes_pushbutton_Callback(hObject, eventdata, handles)
% if yes we should create directory
mkdir(handles.folder_name);
mkdir([handles.folder_name 'Images' ]);
% load handle for main GUI
% hFootPrintAnalysis = getappdata(0, 'hFootPrintAnalysis');
setappdata(handles.hFootPrintAnalysis,'CreateNewProcessedFolder',1);
delete(gcf)

function no_pushbutton_Callback(hObject, eventdata, handles)
% if no we shouldn't create directory
% load handle for main GUI
% hFootPrintAnalysis = getappdata(0, 'hFootPrintAnalysis');
setappdata(handles.hFootPrintAnalysis,'CreateNewProcessedFolder',0);
delete(gcf)


