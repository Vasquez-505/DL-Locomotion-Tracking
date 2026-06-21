function [pic, rawpic, nopic] = PictureReader_02(index, p)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read in a picture with the given index and folder name
%
% INPUTS:
% index          - the # in the file name.
% p.smoothing    - 0 if there should be no smoothing. 'n' if there should 
%                  be smoothing over a distance of n from a given pixel. 
%                  E.g. if smoothing is 2 then the pixels value will be the 
%                  average of the pixels over a 2*n+1 rectangle centered 
%                  around the pixel.
% p.foldername   - folder name where the frame files are.
%
% OUTPUT:
% rawpic         - picture from the frame file
% pic            - picture after applied smoothing and side cuts, contains pic.R, pic.G, pic.G 
% nopic          - 1 if the program had trouble reading in the image
%
% (c) Imre Bartos 2009
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Determine what operating system I'm using, and use slashes accordingly
if ispc, Slash = '\'; else, Slash = '/'; end;


% determine picture name
%   zeros = [];
%   if index <10000  zeros ='00'; end;
%   if index <1000 zeros = '000'; end;
%   if index <100 zeros = '0000'; end;
%   if index <10 zeros = '00000'; end;
% %   picturename = sprintf('images%s%d.png',zeros,index);
%   picturename = sprintf('wt_1%s%d.png',zeros,index);
%   fullpicturename = sprintf('%s\\%s', p.foldername, picturename);

% determine file name of actual frame, but only if we are working with frames
  if p.VideoInput == 0
    fullpicturename = sprintf('%s%c%s', p.foldername, Slash, p.FileList(index,:));
  end;

  try
    % load frame
      if p.VideoInput == 0
        rawpic = (imread(fullpicturename));
      else
        rawpic = read(p.VideoObject,index);
        
      end;

    if p.invert == 1
        rawpic = 255 - rawpic;
    end;
    nopic = 0;
  catch ME1
    nopic = 1;
    pic = [];
    rawpic = [];
  end;

  % Convert picture to double from uint8
    rawpic = double(rawpic) + 1;

  % cut out unnecessary parts from the side
      pic.R = rawpic(p.cut.up:end-p.cut.down,p.cut.left:end-p.cut.right,1);
    if length(size(rawpic)) == 3
      pic.G = rawpic(p.cut.up:end-p.cut.down,p.cut.left:end-p.cut.right,2);
      pic.B = rawpic(p.cut.up:end-p.cut.down,p.cut.left:end-p.cut.right,3);
    else
      pic.G = pic.R;
      pic.B = pic.R;
    end;

  
% smooth picture
  if p.smoothing ~= 0
      AddR = pic.R;
      AddG = pic.G;
      AddB = pic.B;
      Add(:,:) = 0;
      n = 1;
      for i = -n:n
          for j = -n:n
              AddR(n+2:end-n-2,n+2:end-n-2) = AddB(n+2:end-n-2,n+2:end-n-2) + pic.R(n+2+i:end-n-2+i,n+2+j:end-n-2+j);
              AddG(n+2:end-n-2,n+2:end-n-2) = AddG(n+2:end-n-2,n+2:end-n-2) + pic.G(n+2+i:end-n-2+i,n+2+j:end-n-2+j);
              AddB(n+2:end-n-2,n+2:end-n-2) = AddR(n+2:end-n-2,n+2:end-n-2) + pic.B(n+2+i:end-n-2+i,n+2+j:end-n-2+j);
          end;
      end;
      pic.R = Add ./ (2*n+1)^2;
      pic.F = Add ./ (2*n+1)^2;
      pic.B = Add ./ (2*n+1)^2;
%       rawpic(p.cut.up:end-p.cut.down,p.cut.left:end-p.cut.right) = rawpic2;
  end;
  
  

   
  fclose 'all';
  clear zeros index picturename fullpicturename;
 return;