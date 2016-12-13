%REQUIRES A RED OBJECT FOR TRACKING
clear;
clc;

import java.awt.*;
import java.awt.Object.*;
import java.awt.event.*;
import java.awt.AWTException;
import java.awt.Robot;
import java.awt.event.KeyEvent;
robot = Robot;

vid=videoinput('macvideo',1); %get video feed
set(vid,'ReturnedColorSpace','rgb'); %return colour space
preview(vid);
pause(2);

while 1
    im1=getsnapshot(vid);
    % Now to track red objects in real time
    % we have to subtract the red component
    % from the grayscale image to extract the red components in the image.
   
    %extract red component  
    im2= imsubtract(im1(:,:,1), rgb2gray(im1));
    im2_b= imsubtract(im1(:,:,3), rgb2gray(im1));
    
    %Use a median filter to filter out noise
    im3 = medfilt2(im2, [3 3]);
    im3_b = medfilt2(im2_b, [3 3]);
    
    % Convert the resultisng grayscale image into a binary image.
    im3 = im2bw(im3,0.20);%
    im3_b = im2bw(im3_b,0.23);%
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
    [B_b,L_b,N_b]= bwboundaries(im3_b,8,'noholes');
        
    %get the coordinates of each object in the binary file
    a_r = regionprops(L,'centroid'); %red centroid locations in 1st frame 
    a_b = regionprops(L_b,'centroid'); %blue centroid locations in 1st frame 
   
    %---------------------- do the same for the second frame --------------------------------    
    in1=getsnapshot(vid); % not sure if we need another snapshot command
    
    %extract red component  
    in2= imsubtract(in1(:,:,1), rgb2gray(in1));
    in2_b= imsubtract(in1(:,:,3), rgb2gray(in1));
    %Use a median filter to filter out noise
    in3 = medfilt2(in2, [3 3]);
    in3_b = medfilt2(in2_b, [3 3]);
    
    % Convert the resultisng grayscale image into a binary image.
    in3 = im2bw(in3,0.20);
    in3_b = im2bw(in3_b,0.23);
    [B_2,L_2,N_2]=bwboundaries(in3,8,'noholes');
    [B_2_b,L_2_b,N_2_b]=bwboundaries(in3,8,'noholes');
    
    %get the coordinates of each object in the binary file
    b_r=regionprops(L_2,'centroid'); %red centroid locations in 2nd frame 
    b_b=regionprops(L_2_b,'centroid'); %blue centroid locations in 2nd frame 
%     s = regionprops(bwlabel(bw2(:,:,1)), 'centroid');
%     c = [s.Centroid]
    
    %frame differencing below -----
    %a(1).Centroid(1,1)
    %b(1).Centroid(1,1)
    
    if N >= 1 && N_2 >= 1 && N_b == 0 && N_2_b == 0 %left and right page turn loop
        %fprintf('abc\n')
       if (a_r(1).Centroid(1,1) - b_r(1).Centroid(1,1) > 70)
           fprintf('RIGHT\n')
           robot.keyPress(java.awt.event.KeyEvent.VK_RIGHT); %press right arrow key VK_RIGHT
           robot.keyRelease(java.awt.event.KeyEvent.VK_RIGHT); %release right arrow key VK_RIGHT
           %public void setAutoDelay(1000);       
           
        elseif (a_r(1).Centroid(1,1)- b_r(1).Centroid(1,1) < -70)
            fprintf('LEFT\n')
             robot.keyPress(java.awt.event.KeyEvent.VK_LEFT);
             robot.keyPress(java.awt.event.KeyEvent.VK_LEFT);
             %public void setAutoDelay(1000);    
       end  
    end
    
    if N >= 1 && N_2 >= 1 && N_b >= 1 && N_2_b >= 1 %zoom in and out loop
        %fprintf('abc\n')
       if (a_r(1).Centroid(1,1) - b_r(1).Centroid(1,1) > 70) && (a_b(1).Centroid(1,1) - b_b(1).Centroid(1,1) < -70)
           fprintf('RIGHT\n')
           robot.keyPress(java.awt.event.KeyEvent.VK_META); %meta = command key on mac
           robot.keyPress(java.awt.event.KeyEvent.VK_PLUS);
           robot.keyRelease(java.awt.event.KeyEvent.VK_META); 
           robot.keyRelease(java.awt.event.KeyEvent.VK_PLUS);
           
       elseif (a_r(1).Centroid(1,1) - b_r(1).Centroid(1,1) < -70) && (a_b(1).Centroid(1,1) - b_b(1).Centroid(1,1) > 70)
            fprintf('LEFT\n')
             robot.keyPress(java.awt.event.KeyEvent.VK_META); %meta = command key on mac
             robot.keyPress(java.awt.event.KeyEvent.VK_MINUS);
             robot.keyRelease(java.awt.event.KeyEvent.VK_META); 
             robot.keyRelease(java.awt.event.KeyEvent.VK_MINUS);
       end  
    end
end
    
 