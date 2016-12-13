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

%REQUIRES A RED,GREEN,BLUE OBJECTS FOR TRACKING
%import the java libraries for the robot function which allows us to
%implement virtual keyboard functions
import java.awt.*; 
import java.awt.Object.*;
import java.awt.event.*;
import java.awt.event.KeyEvent;
import java.awt.AWTException;
import java.awt.Robot;
robot = Robot; %set the the Robot function name

global obj;
obj = videoinput('macvideo');

set(obj,'framesperTrigger',10,'TriggerRepeat',Inf);
start(obj);

% video_in = videoinput('macvideo'); %get video input from camera
% preview(video_in); %preview the camera input
% set(video_in,'ReturnedColorSpace','rgb'); %store the video input in rgb format

%Now we will take snapshots of the video input and do frame differencing on
%to calculate changes in object positions. Since we want the code to run
%indefinately until we choose to exit we will use a while loop.

pause(2);
while 1;
    
    flushdata(obj);   
    frame_1 = getdata(obj,1);
    
    pause(.05);
    
    flushdata(obj);   
    frame_2 = getdata(obj,1);
    
    %Take a snapshot of the video and store
    %it as frame 1the frame is stored as a 3x3 array that contains the 
    %dimensions of the of image along along with the corresponding color
    %format so in our case X-by-Y-by-Red/Green/Blue
    
    %frame_1 = getsnapshot(video_in);    
    
    %frame_2 = getsnapshot(video_in); %take a snapshot of the video and store it as frame 2
    
    %We now want to seperate each matrix into a 1-by-3 matrix with just one
    %color being stored. To do this we can subtract the corresponding
    %colour matrix from greyscale version of the frame.
    frame_1_red = imsubtract(frame_1(:,:,1), rgb2gray(frame_1)); 
    %frame_1_green = imsubtract(frame_1(:,:,2), rgb2gray(frame_1)); 
    %frame_1_blue = imsubtract(frame_1(:,:,3), rgb2gray(frame_1));
    
    
    axes(handles.axes1);
    imshow(frame_1_red);
    
    frame_2_red = imsubtract(frame_2(:,:,1), rgb2gray(frame_2)); 
    %frame_2_green = imsubtract(frame_2(:,:,2), rgb2gray(frame_2)); 
    %frame_2_blue = imsubtract(frame_2(:,:,3), rgb2gray(frame_2));
    
    axes(handles.axes3);
    imshow(in3);
    pause(.05);
    
    %We now want to remove the noise from the grayscale images so that when
    %we convert it to a binary images we get a more accurate result
    frame_1_red = medfilt2(frame_1_red);
    %frame_1_green = medfilt2(frame_1_green);
    %frame_1_blue = medfilt2(frame_1_blue);
    
    frame_2_red = medfilt2(frame_2_red); 
    %frame_2_green = medfilt2(frame_2_green);
    %frame_2_blue = medfilt2(frame_2_blue);
    
    %We can now finally convert the frames into binary for easier frame
    %difference processing. Any pixels with values under the given
    %threshhold are replaced with 0. While those above the threshhold are
    %set to 1. 
    
    %We estimated the threshhold values of the three colors through trial
    %and error. Settling on or about; red = 0.20, green = 0.24, blue = 0.27
    
    frame_1_red = im2bw(frame_1_red,0.20);
    %frame_1_green = im2bw(frame_1_green,0.24);
    %frame_1_blue = im2bw(frame_1_blue,0.27);
    
    frame_2_red = im2bw(frame_2_red,0.20);
    %frame_2_green = im2bw(frame_2_green,0.24);
    %frame_2_blue = im2bw(frame_2_blue,0.27);
    
    %The final step before we can start subtracting objects in binary is to
    %first group neighbouring pixels to create objects with a given
    %coordinate defined by a centroid.
    
    %To do this in matlab we must detect and store any objects in a matrix
    
    %[B,L] = bwboundaries(...) returns the label matrix L as the second output 
    %argument. Objects and holes are labeled. L is a two-dimensional array of 
    %nonnegative integers that represent contiguous regions. The kth region includes 
    %all elements in L that have value k. The number of objects and holes represented 
    %by L is equal to max(L(:)). The zero-valued elements of L make up the background.
    %Also returns N, the number of objects found, the first N cells in B are object boundaries.
    
    [B_1r,L_1r,N_1r]= bwboundaries(frame_1_red,8,'noholes');
    %[B_1g,L_1g,N_1g]= bwboundaries(frame_1_green,8,'noholes');
    %[B_1b,L_1b,N_1b]= bwboundaries(frame_1_blue,8,'noholes');
    
    [B_2r,L_2r,N_2r]= bwboundaries(frame_2_red,8,'noholes');
    %[B_2g,L_2g,N_2g]= bwboundaries(frame_2_green,8,'noholes');
    %[B_2b,L_2b,N_2b]= bwboundaries(frame_2_blue,8,'noholes');
    
    f_1r=regionprops(L_1r,'centroid'); %red centroid locations in frame 1
    %f_1g=regionprops(L_1g,'centroid'); %green centroid locations in frame 1 
    %f_1b=regionprops(L_1b,'centroid'); %blue centroid locations in frame 1 
    
    f_2r=regionprops(L_2r,'centroid'); %red centroid locations in frame 2 
    %f_2g=regionprops(L_2g,'centroid'); %green centroid locations in frame 2 
    %f_2b=regionprops(L_2b,'centroid'); %blue centroid locations in frame 2 
   
    if N >= 1 && N_2 >= 1
        %fprintf('abc\n')
       if (f_1r(1).Centroid(1,1) - f_2r(1).Centroid(1,1) > 110)
           fprintf('RIGHT\n')
%            set(handles.righttxt, 'ForegroundColor',[0,1,0])
%            pause(0.3);
%            set(handles.righttxt, 'ForegroundColor',[0,0,0])
           
           if get(handles.checkbox1,'Value')==1
                robot.keyPress(java.awt.event.KeyEvent.VK_RIGHT); %press right arrow key VK_RIGHT
                robot.keyRelease(java.awt.event.KeyEvent.VK_RIGHT); %release right arrow key VK_RIGHT
           end
           
        elseif (f_1r(1).Centroid(1,1)-f_2r(1).Centroid(1,1) < -110)
            fprintf('LEFT\n')
%             set(handles.lefttxt, 'ForegroundColor',[0,1,0])
%             pause(0.3);
%             set(handles.lefttxt, 'ForegroundColor',[0,0,0])
            
            if get(handles.checkbox1,'Value')==1
                robot.keyPress(KeyEvent.VK_LEFT);
                robot.keyRelease(KeyEvent.VK_LEFT);  
            end
       end  
    end
end


