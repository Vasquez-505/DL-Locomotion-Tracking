function [Mr,ang, left, right, cc, MOSCA_BW] = my_radon(I,theta, close_thr, open_thr, bl, cl, debug);

I = filter2(ones(7,7), I)/49;
  
  totsu = otsuthresh(imhist(I/255))*255;
  M = I > totsu;%tgr;%totsu;

  preBW=imopen(M,ones(4));
  BWc = imclose(preBW, ones(close_thr));
  BW=imopen(BWc,ones(open_thr));
  
  label = bwlabel(BW);
  blobs = regionprops(label,'Orientation','Centroid','Area');
  aux=0; ind=1;
  for i=1:length(blobs),
    if aux < blobs(i).Area,
      aux = blobs(i).Area;
      ind = i;
    end
  end
  MOSCA_BW = label==ind;
    
  if(length(blobs) < 1)
      Mr = ones(1,1); ang = -1; left = [-1 -1];
      right = [-1 -1]; cc = [-1 -1]; BW = ones(1,1);
      return 
      
  end
  
  ang2 = -blobs(ind).Orientation;
  
  cc = blobs(ind).Centroid;
  
  R = radon(double(I.*imdilate(MOSCA_BW, ones(8))),theta);
  v = [];
  for i=1:size(R,2),
      v = [v; max(conv(R(:,i),R(:,i)))];
  end;
  [Mr,ind]=max(v);
  ang = 90-theta(ind);
  
  % Deteta extremos
  [y,x]=find(MOSCA_BW); x = x-cc(1); y = y-cc(2);
  
  r = (x*cos(ang*pi/180)+y*sin(ang*pi/180));
  t = abs(y*cos(ang*pi/180)-x*sin(ang*pi/180));
  [m,ind_max] = max(r.*(t<1));
  [mm,ind_min] = min(r.*(t<1));
  
  ang = ang+90;
  
  % old, based on blob indexing
  %left = [x(ind_max) + cc(1), y(ind_max) + cc(2)];
  %right = [x(ind_min) + cc(1), y(ind_min) + cc(2)];
  
  % new, based on centroid assumption
  left = (cc + cl*[cosd(ang-90) sind(ang-90)]);
  right = (cc - (bl-cl)*[cosd(ang-90) sind(ang-90)]);
  
  
  if debug
      % useful to insert breakpoint here
      disp('');
  end
  