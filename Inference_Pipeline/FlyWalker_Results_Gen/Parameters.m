function p = Parameters()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function p = Parameters()
%
% Parameter file for FlyTracker. All used parameters are given here.
% Parameters are stored in structure 'p'.
%
% (c) Imre Bartos, 2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% frame per second
  p.fps = 250;

% Define part of the images that is used for the analysis. Each part
% defines the number of pixels ommited. E.g. cut.up = 50 means that the top
% 50 rows of the picture is omitted.
  p.cut.up = 50;
  p.cut.down = 1;
  p.cut.right = 1;
  p.cut.left = 1;


% Threshold brightness for the footprints and for the body. A footprint is identified initially as a footprint if it is 
% brighter than legonthreshold. After initial identification, the footprint has to stay above legthrehold to be identified as a footprint.
% Pixels are considered the parts of a body if they are greater than bodythreshold but smaller than legthreshold.
  p.legthreshold = 7; % leg_threshold
  p.legonthreshold = 10; % leg_on_threshold
  p.bodylowerthreshold = 0.5; % body_lower_threshold
  p.bodyupperthreshold = 50; % body_upper_threshold
  
  
% Define the minimum size of coherent pixels that are identified as parts
% of a body. 
  p.MinBodySize = 800; % min_body_size

  
% radiusleg and radiusbody define the maximum distance that a footprint
% or the body can move. If the they move more than this, or there is a new
% footprint or body appearing further than this on the next frame, they
% will be identified as separate footprints or bodies.
  p.radiusleg = 3; % max_leg_move
  p.radiusbody = 100; % max_body_move

  
% If a footprint (body) appears in a given frame, it will be considered the
% continuation of a previous footprint if the previous one was not missing
% for more than p.maxtimedifferenceleg (p.maxtimedifferencebody)
  p.maxtimedifferenceleg = 2; % max leg gap
  
  p.maxtimedifferencebody = 15; % max body gap

% BGlength is the number of frames at the end of the series of frames in
% the frame folder that will be used for calculating the background masks.
  p.BGlength = 10; % Background length [frames]

  
% Defines level of smoothing of the frame pictures.
% 0 if there should be no smoothing. 
% 'n' if there should be smoothing over a distance of n from a given pixel. 
% E.g. if smoothing is 2 then the pixels value will be the average of the 
% pixels over a 2*n+1 rectangle centered around the pixel.
  p.smoothing = 0; % Smoothin
  
% brightness threshold. The picture will be cut out for pixels which exceed 
% this threshold, on average, in the reference pictures.
  p.BGthreshold = 50; % Background threshold [0-255]
  
% max allowed empty space (gap) between two pixels that are the parts of
% the same leg. If there are two bright pixels and they are less than
% maxgapleg apart, they will be considered to be the parts of the same
% footrpint
  p.maxgapleg = 1; % Max leg pixel separation [pixel]
  
% max allowed empty space (gap) between two pixels being parts of the same
% body. Similar to maxgapleg (see comment there).
  p.maxgapbody = 1; % Max body pixel sep. [pixel]
  
% max distance of legs in units of body length. The leg has to be closer 
% than BodyLength*p.maxDist to the center of the body to be considered a 
% leg
  p.maxDist = 1; % Max leg-body dist. [body size]

% min distance of legs in units of ellipse 'radius'. The closest the leg 
% can be to the body center is the distance of the edge ellipse fit to the 
% body times p.minDist
  p.minDist = 1.1;% Min leg-body dist. [ellipse size]
  
% amplifies the pictures brightness with p.picbirghtness so it will appear
% brighter on the output. 
  p.picbrightness = 2.5; % Birhtness
  
% defines the colormap of the picture
% Options: 'Jet', 'HSV', 'Hot', 'Cool', 'Spring', 'Summer', 'Autumn',
% 'Winter', 'Gray', 'Bone', 'Copper', 'Pink', 'Lines'
  p.color = 'hot'; % Colormap
  

% defines whether an ellipse should be drawn around the fly
% 1 -    ellipse
% 0 - no ellipse
  p.ellipse = 1; % Ellipse
  
% defines whether the colorbar should be drawn
% 1 -    colorbar
% 0 - no colorbar
  p.Colorbar = 0; % Colorbar
  
% Invert brightness
% 1 - invert
% 0 - no change
  p.invert = 0; % Inverted colors
  
% Minimum Leg Swing duration: a given leg has to be swinging for at least p.minlegswing. 
% This means that a footprint will not be identified as a given leg if the
% given leg was down in less than p.minlegwing frames ago.
  p.minlegswing = 2; % Min leg swing [frames]
  
% Distance calibration - conversion between pixels and cm.
% distcal = pixel/um
  p.distcal = 2.125/100; % Distance calibration [pixel/um]
  
% Minimum number of frames for which a footprint is considered a footprint.
% if the number of frames for which the footprint is continuously present
% is shorter than p.minframe, the frame is cut out OF THE ANALYSIS (it will
% still appear in the video)
  p.minframe = 2; % Min footprint duration [frames]
  
% Define center of body from front
% if p.CenterFromFront == 1 then center is defined as being
% p.CenterFromFrontDist far (in pixels) from the front of the body along the body line,
% otherwise (if p.CenterFromFront ~= 1) center of body is defined as center
% of mass of fly
  p.CenterFromFront = 0; % Define center from front
  p.CenterFromFrontDist = 30; % Center from front dist. [pixel]
  
% Turn on/off length bar on the pictures.
% p.lengthbar == 1 - length bar is drawn
% p.lengthbar ~= 1 - length bar is NOT drawn
  p.lengthbar = 0; % Length bar
  
% Draws progress in auto mode during auto tracking if p.drawwhileauto == 1
  p.drawwhileauto = 0; % Draw frames in Auto
  
% Define size of the circles around legs and body center
  p.circlesize = 15; % Footprint drawn radius [pixel]
  p.circlesize_saved = 7; % Footprint saved radius [pixel]
  
% Define start path for loading and saving data separately. If start_path does not exist the 
% program will resume to the Matlab directory. After using the program, it
% will always start with the directory that was last specified.
  p.input_directory_path = '<SPECIFY INPUT DIRECTORY>'; % Input directory path
  p.results_directory_path = 'Default...'; % Results directory path
  
% show past footprints?
  p.show_past_footprints = 0;
  
% draw body track
  p.drawbodytrack = 1;
  
% force direction for the entire track
%  1: right all the time
% -1: left all the time
%  0: no fordec direction
  p.force_direction = 0;
  
  
  % choose between using automatic length detection, or define fixed
  % distance
  % p.fixed_body_length = 1: set bodylength to fixed_body_length_value
  % p.fixed_body_length = 0: let AutoFinder determine length
    p.fixed_body_length = 0;
    p.fixed_body_length_value = 80; % fixed_body_length_value
    
% background - max brightness offset (above BG STD) that is considered background compared to BG average 
  p.BGoffset.R     = 5;
  p.BGoffset.G     = 5;
  p.BGoffset.B     = 5;  
  p.BGoffset.sigma = 1;  
   
% Decide what to PLOT (1 - original)
% this basically decides whether to use any filter to select body or foot before plotting
  p.WhatToPlot = 3;

  
% REVERSE CHANGE:
% Initial angle for deep learning estimates
p.DLInitAngle = 0;

% Front body threhsold
% if the front point is too much outside the fly -> increase
% if it is inside the fly's body - > decreatse
p.FrontBodyThreshold = 12;

% Use fii_ellipse/ use_radon
p.UseFitEllipse = 1;

% Use proposed background subtraction algorithm
p.UseBackgroundSubtraction = 1;

return;

