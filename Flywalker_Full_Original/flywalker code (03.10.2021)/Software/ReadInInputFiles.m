function [FileList, VideoInput, VideoObject] = ReadInInputFiles(inputFolderName)

    % Obtain list of frame files OR video from input folder  
      FileList = [LS([inputFolderName '/*.jpg']); LS([inputFolderName '/*.png']); LS([inputFolderName '/*.bmp']); LS([inputFolderName '/*.tif']); LS([inputFolderName '/*.jpeg'])];
      % if there are no frame files then look for video --- see VideoReader command for supported formats
      % program assumes there will be only one video file --- make sure there is
    
      if isempty(FileList)
      
        VideoName = [LS([inputFolderName '/*.avi']);  LS([inputFolderName '/*.mj2']); ...
          LS([inputFolderName '/*.mpg']); LS([inputFolderName '/*.wmv']); LS([inputFolderName '/*.asf']); LS([inputFolderName '/*.asx']); ...
          LS([inputFolderName '/*.mp4']); LS([inputFolderName '/*.m4v']); ...
          LS([inputFolderName '/*.ogg']); LS([inputFolderName '/*.mov'])];
     
        % make sure there is only one video file that we read in
          VideoName = VideoName(1,:);
        % save parameter indicating that we are dealing with a video file
          VideoInput = 1;
        % load video object
          VideoObject = VideoReader([inputFolderName '/' VideoName]);
          
        % make FileList as long as number of frames in video
          % Get the number of frames.
            numFrames = get(VideoObject, 'NumberOfFrames');
          FileList = [1:numFrames]';
      else
        % save parameter indicating that we are NOT dealing with a video file
          VideoInput = 0;
          VideoObject = 0;
      end;
return;
