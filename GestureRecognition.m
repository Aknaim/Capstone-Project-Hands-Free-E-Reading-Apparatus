clc;
clear;

import java.awt.*;
import java.awt.Object.*;
import java.awt.event.*;
import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.KeyEvent;
robot = Robot;

vid=videoinput('macvideo',1); %get video feed
set(vid,'ReturnedColorSpace','rgb'); %return colour space
%preview(vid);
pause(2);

while 1
    im1=getsnapshot(vid);
    % Now to track red objects in real time
    % we have to subtract the red component
    % from the grayscale image to extract the red components in the image.
   
    %extract red component  
    im2= imsubtract(im1(:,:,1), rgb2gray(im1));
    
    %Use a median filter to filter out noise
    im3 = medfilt2(im2, [3 3]);
    
    % Convert the resultisng grayscale image into a binary image.
    im3 = im2bw(im3,0.23);%

    %preview the binary image
    imshow(im3);
    
    pause(0.05);
    %[B,L] = bwboundaries(...) returns the label matrix L as the second output 
    %argument. Objects and holes are labeled. L is a two-dimensional array of 
    %nonnegative integers that represent contiguous regions. The kth region includes 
    %all elements in L that have value k. The number of objects and holes represented 
    %by L is equal to max(L(:)). The zero-valued elements of L make up the background.
    %Also returns N, the number of objects found, the first N cells in B are object boundaries.
    [B,L,N]= bwboundaries(im3,8,'noholes');
    
        
    %get the coordinates of each object in the binary file
    a = regionprops(L,'centroid');
   
    %---------------------- do the same for the second frame --------------------------------    
    %in1=getsnapshot(vid); --- not sure if we need another snapshot command
    
    %extract red component  
    in2= imsubtract(im1(:,:,1), rgb2gray(im1));
    
    %Use a median filter to filter out noise
    in3 = medfilt2(in2, [3 3]);
    
    % Convert the resultisng grayscale image into a binary image.
    in3 = im2bw(in3,0.23);
    [B_2,L_2,N_2]=bwboundaries(in3,8,'noholes');
    
    %get the coordinates of each object in the binary file
    b=regionprops(L_2,'centroid');
    s = regionprops(bwlabel(bw2(:,:,1)), 'centroid');
    c = [s.Centroid]
    
    %frame differencing below -----
    
    if N == 0 && N_2 >= 1
       if (a(1).Centroid(1,1) - b(1).Centroid(1,1) > 70)
           robot.keyPress(java.awt.event.KeyEvent.VK_RIGHT); %press right arrow key VK_RIGHT
           robot.keyRelease(java.awt.event.KeyEvent.VK_RIGHT); %release right arrow key VK_RIGHT
       end
           
%        else if(a(1).Centroid(1,1)-b(1).Centroid(1,1) < -70)
%              robot.keyPress(KeyEvent.VK_LEFT);
%              robot.keyRelease(KeyEvent.VK_LEFT);  
%        end  
    end
end
    
 