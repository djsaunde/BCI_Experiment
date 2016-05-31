function varargout = BCI_GUI(varargin)
% BCI_GUI MATLAB code for BCI_GUI.fig
%      BCI_GUI, by itself, creates a new BCI_GUI or raises the existing
%      singleton*.
%
%      H = BCI_GUI returns the handle to a new BCI_GUI or the handle to
%      the existing singleton*.
%
%      BCI_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BCI_GUI.M with the given input arguments.
%
%      BCI_GUI('Property','Value',...) creates a new BCI_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BCI_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BCI_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BCI_GUI

% Last Modified by GUIDE v2.5 28-May-2016 17:08:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BCI_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @BCI_GUI_OutputFcn, ...
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


% --- Executes just before BCI_GUI is made visible.
function BCI_GUI_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BCI_GUI (see VARARGIN)

% TODO...
% system('python ../../../Documents/OpenBCI_Python-master/user.py -p=/dev/ttyUSB0 --add streamer_lsl /start');

% Choose default command line output for BCI_GUI
handles.output = hObject;

% destroy old GUI
close Begin_GUI

% maximize GUI
maxfig(gcf, 1);

% get EEG stream
inlet = getEEG();

% set up initial EEG window (zeros to start) and FFT window (empty to
% start)
x = zeros(250, 8);
y = [];

% set timer object to execute the calculation of the FFT every 1/250
% seconds (250Hz)
t = timer('TimerFcn', {@getFFT, inlet, x}, 'Period', 1/250, 'UserData', y, 'Name', 'fft_timer', 'ExecutionMode', 'fixedRate');

% start FFT stream
disp('Computing FFT at 250Hz...')
start(t);

% Get session and participant information
handles.session = varargin{1};
handles.userNum = varargin{2};

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BCI_GUI wait for user response (see UIRESUME)
% uiwait(handles.Figure);


% --- Outputs from this function are returned to the command line.
function varargout = BCI_GUI_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

maxfig(gcf, 1);

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function left_hand_CreateFcn(hObject, ~, handles)
% hObject    handle to left_hand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

axes(hObject);
handles.left_handles = imshow('left_hand_edges.jpg');
guidata(hObject, handles)


% --- Executes during object creation, after setting all properties.
function right_hand_CreateFcn(hObject, ~, handles)
% hObject    handle to right_hand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

axes(hObject);
handles.right_handle = imshow('right_hand_edges.jpg');
guidata(hObject, handles);


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, ~, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.begin_button = hObject;
guidata(hObject, handles);

set(handles.begin_button, 'Visible', 'off');

axes(handles.left_hand);
imshow('left_hand_edges.jpg');
axes(handles.right_hand);
imshow('right_hand_edges.jpg');

lib = lsl_loadlib();

disp('Creating a new marker stream info...');
info = lsl_streaminfo(lib,'marker_stream','Markers',1,0,'cf_string','myuniquesourceid23443');

disp('Opening an outlet...');
outlet = lsl_outlet(info);

for i = 1:30
    pause(randsample(5, 1))
    if randsample(2, 1) == 1
        axes(handles.left_hand);
        imshow('left_hand.jpg');
        mrk = 'L';
        disp(['now sending ' mrk]);
        outlet.push_sample({mrk});   % note that the string is wrapped into a cell-array
        pause(6);
        imshow('left_hand_edges.jpg');
    else
        axes(handles.right_hand);
        imshow('right_hand.jpg');
        mrk = 'L';
        disp(['now sending ' mrk]);
        outlet.push_sample({mrk});   % note that the string is wrapped into a cell-array
        pause(6);
        imshow('right_hand_edges.jpg');
    end
end

f = fopen(fullfile(filepath,[num2str(handles.userNum) '_' handles.session '.txt']), 'wt');

fprintf(f,'COL 1: MARKER\nCOL 2: TIME START\nCOL 3: TIME END'); 

fprintf(f,'\n\n');

for i = 1:30
    fprintf(f,'%s\t%2.2f\t%2.2f\n', hand_arr(i, 1), hand_arr(i, 2), hand_arr(i, 3));
end

% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
