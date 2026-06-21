function varargout = Shortcuts(varargin)
% SHORTCUTS M-file for Shortcuts.fig
%      SHORTCUTS, by itself, creates a new SHORTCUTS or raises the existing
%      singleton*.
%
%      H = SHORTCUTS returns the handle to a new SHORTCUTS or the handle to
%      the existing singleton*.
%
%      SHORTCUTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SHORTCUTS.M with the given input arguments.
%
%      SHORTCUTS('Property','Value',...) creates a new SHORTCUTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Shortcuts_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Shortcuts_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% (c) Imre Bartos, 2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Edit the above text to modify the response to help Shortcuts

% Last Modified by GUIDE v2.5 27-Jul-2010 19:57:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Shortcuts_OpeningFcn, ...
                   'gui_OutputFcn',  @Shortcuts_OutputFcn, ...
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


% --- Executes just before Shortcuts is made visible.
function Shortcuts_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Shortcuts (see VARARGIN)

% Choose default command line output for Shortcuts
handles.output = hObject;


% update window title
set(gcf,'Name','FootPrintAnalysis: Keyboard Shortcuts');


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Shortcuts wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Shortcuts_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
