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

% Last Modified by GUIDE v2.5 07-Jun-2016 10:08:28

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

% TODO... this statement doesn't work. the problem lies with starting the
% sytem; we need the '/start' statement which doesn't work with this system
% call.
% system('python ../../../Documents/OpenBCI_Python-master/user.py -p=/dev/ttyUSB0 --add streamer_lsl /start');

% Choose default command line output for BCI_GUI
handles.output = hObject;

% destroy old GUI
close Begin_GUI

% maximize GUI
maxfig(gcf, 1);

% Get session and participant information
handles.session = varargin{1};
handles.userNum = varargin{2};

% load lab streaming layer library
lib = lsl_loadlib();

% create marker stream info (for ERP-based machine learning)
disp('Creating a new marker stream info...');
info = lsl_streaminfo(lib,'marker_stream','Markers',1,0,'cf_string','myuniquesourceid23443');

% open the marker stream outlet
disp('Opening an outlet...');
outlet = lsl_outlet(info);
handles.outlet = outlet;

% get EEG stream
inlet = getEEG();
handles.inlet = inlet;

% Update handles structure
guidata(hObject, handles);


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

handles.left_handles = imshow('left_hand_edges.jpg');


% --- Executes during object creation, after setting all properties.
function right_hand_CreateFcn(hObject, ~, handles)
% hObject    handle to right_hand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

imshow('right_hand_edges.jpg');


% --- Executes on button press in begin_button.
function begin_button_Callback(hObject, ~, handles)
% hObject    handle to begin_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set begin button to be invisible after user click
set(handles.begin_button, 'Visible', 'off');

% first things first, show the left / right hand edge images
axes(handles.left_hand);
imshow('left_hand_edges.jpg');
axes(handles.right_hand);
imshow('right_hand_edges.jpg');

% load the inlet / outlet from GUI startup
inlet = handles.inlet;
outlet = handles.outlet;

% compute norm, used for spectral analysis. depends on sampling frequency
% (250Hz), and a funny math trick we finagled (see 4th line)
ws = 2*pi/250;
wnorm = -pi:ws:pi;
wnorm = wnorm(1:250);
w = wnorm*250*.1604;

% randomly sample a starting time
rand = randsample(10:50, 1);

% initialize data array to be empty (will populate this we EEG data)
x = [];

% begin main loop. refresh FT plot every 0.1 seconds
for i = 1:3000
    [x, y] = getFFT(inlet, x);
    axes(handles.spectrogram);
    plot(w, abs(y*.001));
    set(gca, 'YScale','log', 'YTick', [0 1 10 100], 'YTickLabel', {0 1 10 100}, ...
        'YLim', [0.05 100], 'XLim', [0 60]);
    xlabel('Frequency (Hz)');
    ylabel('Amplitude (microvolts)');
    title('Frequency Content of Brain Waves');
    hold on;
    
    if i == rand
        % branch conditionally based on a random drawing from {1, 2}
        if randsample(2, 1) == 1 
            % left hand logic
            axes(handles.left_hand);
            imshow('left_hand.jpg');
            outlet.push_sample({'L'});   % note that the string is wrapped into a cell-array
        else
            axes(handles.right_hand);
            imshow('right_hand.jpg');
            outlet.push_sample({'R'});   % note that the string is wrapped into a cell-array
        end
    end
    if i == rand + 60
        axes(handles.left_hand);
        imshow('left_hand_edges.jpg');
        axes(handles.right_hand);
        imshow('right_hand_edges.jpg');
        rand = rand + 60 + randsample(10:50, 1);
    end
    
    pause(0.1);
    
    hold off;
end

% f = fopen(fullfile(filepath,[num2str(handles.userNum) '_' handles.session '.txt']), 'wt');
% 
% fprintf(f,'COL 1: MARKER\nCOL 2: TIME START\nCOL 3: TIME END'); 
% 
% fprintf(f,'\n\n');
% 
% for i = 1:30
%     fprintf(f,'%s\t%2.2f\t%2.2f\n', hand_arr(i, 1), hand_arr(i, 2), hand_arr(i, 3));
% end

% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function spectrogram_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spectrogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
