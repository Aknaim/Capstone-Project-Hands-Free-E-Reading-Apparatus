function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 10-Jan-2016 14:44:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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



% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in buttonstart.
function buttonstart_Callback(hObject, eventdata, handles)
% hObject    handle to buttonstart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
import java.awt.*;
import java.awt.Object.*;
import java.awt.event.*;
import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.KeyEvent;
robot = Robot;

global obj;
obj = videoinput('macvideo',1,'ARGB32_1920x1080');

set(obj,'framesperTrigger',10,'TriggerRepeat',Inf);
start(obj);

%vid=videoinput('macvideo',2); %get video feed
%set(vid,'ReturnedColorSpace','rgb'); %return colour space
%set(vid, 'FramesPerTrigger', 60)
%preview(obj);
pause(2);

while 1
    %im1=getsnapshot(vid);
    % subtract the red component
    % from the grayscale image
    flushdata(obj);
    
    
    im1 = getdata(obj,1);
    %preview(vid)

  

    %[f, t] = getdata(vid);
    %numframes = size(f, 4);

    %im1=imresize(f(:,:,:,5),.5);
    %in1=imresize(f(:,:,:,55),.5);
    %extract red component  
    im2= imsubtract(im1(:,:,1), rgb2gray(im1));
    axes(handles.axes1);
    imshow(im2);
    %filter out noise
    im3 = medfilt2(im2, [3 3]);
    
    % grayscale image into a binary image.
    im3 = im2bw(im3,0.28);%
 
    %preview the binary image
    %subplot(1,2,1)
    
    pause(.05);
    %[B,L] = bwboundaries(...) returns the label matrix L as the second output 
    %argument. Objects and holes are labeled. L is a two-dimensional array of 
    %nonnegative integers that represent contiguous regions. The kth region includes 
    %all elements in L that have value k. The number of objects and holes represented 
    %by L is equal to max(L(:)). The zero-valued elements of L make up the background.
    %Also returns N, the number of objects found, the first N cells in B are object boundaries.
    [B,L,N]= bwboundaries(im3,8,'noholes');
    %pause(.05);
        
    %get the coordinates of each object in the binary file
    a = regionprops(L,'centroid');
   %pause(.05);
    %---------------------- do the same for the second frame --------------------------------    
   % in1=getsnapshot(vid); % not sure if we need another snapshot command
   % pause(.05);
    %extract red component  
    
    flushdata(obj);
    
    
    in1 = getdata(obj,1);
    
    in2= imsubtract(in1(:,:,1), rgb2gray(in1));
   % pause(.05);
    %Use a median filter to filter out noise
    in3 = medfilt2(in2, [3 3]);
   % pause(.05);
    % Convert the resultisng grayscale image into a binary image.
    in3 = im2bw(in3,0.28);
    %subplot(1,2,2)
    
    axes(handles.axes3);
    imshow(in3);
    pause(.05);
    
    [B_2,L_2,N_2]=bwboundaries(in3,8,'noholes');
   % pause(.05);
    %get the coordinates of each object in the binary file
    b=regionprops(L_2,'centroid');
%     s = regionprops(bwlabel(bw2(:,:,1)), 'centroid');
%     c = [s.Centroid]
   % pause(.05);
    %frame differencing below -----
    %a(1).Centroid(1,1)
    %b(1).Centroid(1,1)
    
    if N >= 1 && N_2 >= 1
        %fprintf('abc\n')
       if (a(1).Centroid(1,1) - b(1).Centroid(1,1) > 110)
           fprintf('RIGHT\n')
           set(handles.righttxt, 'ForegroundColor',[0,1,0])
           pause(0.3);
           set(handles.righttxt, 'ForegroundColor',[0,0,0])
           
           if get(handles.checkbox1,'Value')==1
                robot.keyPress(java.awt.event.KeyEvent.VK_RIGHT); %press right arrow key VK_RIGHT
                robot.keyRelease(java.awt.event.KeyEvent.VK_RIGHT); %release right arrow key VK_RIGHT
           end
           
        elseif (a(1).Centroid(1,1)-b(1).Centroid(1,1) < -110)
            fprintf('LEFT\n')
            set(handles.lefttxt, 'ForegroundColor',[0,1,0])
            pause(0.3);
            set(handles.lefttxt, 'ForegroundColor',[0,0,0])
            
            if get(handles.checkbox1,'Value')==1
                robot.keyPress(KeyEvent.VK_LEFT);
                robot.keyRelease(KeyEvent.VK_LEFT);  
            end
       end  
    end
  
    
end

% --- Executes on button press in buttonstop.
function buttonstop_Callback(hObject, eventdata, handles)
% hObject    handle to buttonstop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global obj;
stop(obj);


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
