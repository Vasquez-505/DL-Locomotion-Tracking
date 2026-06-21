function  [bodyx, bodyy, bodytrack, bodytiming, BodyDirection1, BodyDirection2, BodyDirection3, Orientation, bodyborder, bodytime, bodystdPar, bodystdPerp] = TrackBody_01(p,v)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Identifies and tracks fly body candidates
%
% INPUT:
% v.Body
% v.bodyx
% v.bodyy
% v.bodytrack
% v.bodytiming
% p.radiusbody
% p.maxtimedifferencebody
% p.mintimedifferencebody
% v.BodyFit
% v.BodyDirection1
% v.BodyDirection2
% v.BodyDirection3
% v.Orientation
% v.bodyborder
% v.BodyBorder
% v.time
% v.bodytime
%
% OUTPUT:
% v.bodyx
% v.bodyy
% v.bodytrack
% v.bodytiming
% v.BodyDirection1
% v.BodyDirection2
% v.BodyDirection3
% v.Orientation
% v.bodyborder
% v.bodytime
% bodystdPar
% bodystdPerp
%
% takes new positions and keeps track of bodies
% 
% (c) Imre Bartos, April 2009
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


s = size(v.Body);
s2 = size(v.bodyx);
% [temp S2] = sort(v.bodytrack);
Mnum = s2(1);
added(1:s(1)) = 0;

for j = 1:s2(1) % loop over body tracks
  closest = p.radiusbody^2+1;
  found = 0;
  if v.bodytiming(j) <= p.maxtimedifferencebody
      % if already tracked, calculate expected position and try to
      % track it from there
      if v.bodytrack(j) > 1
          expectedlocationx =  v.bodyx(j,v.bodytrack(j)) + v.bodytiming(j) * (v.bodyx(j,v.bodytrack(j)) - v.bodyx(j,v.bodytrack(j)-1));
          expectedlocationy =  v.bodyy(j,v.bodytrack(j)) + v.bodytiming(j) * (v.bodyy(j,v.bodytrack(j)) - v.bodyy(j,v.bodytrack(j)-1));
      end
      % if not tracked yet, expected position = currrent position
      if v.bodytrack(j) == 1
          expectedlocationx =  v.bodyx(j,v.bodytrack(j));
          expectedlocationy =  v.bodyy(j,v.bodytrack(j));
      end;      
      for i = 1:s(1) % loop over new points
          dist2 = (v.Body(i,1)-expectedlocationx)^2 + (v.Body(i,2)-expectedlocationy)^2;
          if  dist2 < min(p.radiusbody^2,closest) & added(i) == 0
            found = i;
            closest = dist2;
          end;
      end
  end
  % if found as the continuation of a track, add to the closest track
  if found ~= 0
      added(found) = 1;
      % if lost track for a few time steps, put in several points into the
      % track
      if v.bodytiming(j) == 1      
        v.bodytrack(j) = v.bodytrack(j) + 1;
        v.bodytiming(j) = 0;
        v.bodyx(j,v.bodytrack(j))           = v.Body(found,1);
        v.bodyy(j,v.bodytrack(j))           = v.Body(found,2);
        v.BodyDirection1(j,v.bodytrack(j))  = v.BodyFit(found,1);
        v.BodyDirection2(j,v.bodytrack(j))  = v.BodyFit(found,2);
        v.BodyDirection3(j,v.bodytrack(j))  = v.BodyFit(found,3);
        v.bodyborder(j,v.bodytrack(j), 1)   = v.BodyBorder(found,1);
        v.bodyborder(j,v.bodytrack(j), 2)   = v.BodyBorder(found,2);
        v.bodyborder(j,v.bodytrack(j), 3)   = v.BodyBorder(found,3);
        v.bodyborder(j,v.bodytrack(j), 4)   = v.BodyBorder(found,4);
        v.bodyborder(j,v.bodytrack(j), 5)   = v.BodyBorder(found,5);
        v.bodyborder(j,v.bodytrack(j), 6)   = v.BodyBorder(found,6);
        v.bodyborder(j,v.bodytrack(j), 7)   = v.BodyBorder(found,7);
        v.bodyborder(j,v.bodytrack(j), 8)   = v.BodyBorder(found,8);
        v.bodystdPar(j,v.bodytrack(j))      = v.Bodystd(found,1);
        v.bodystdPerp(j,v.bodytrack(j))     = v.Bodystd(found,2);
        v.bodytime(j,v.bodytrack(j))        = v.time(v.FrameNumber);
      end;
      if v.bodytiming(j) > 1      
          for k = 1:v.bodytiming(j)
            v.bodyx(j,v.bodytrack(j)+k)          = v.bodyx(j,v.bodytrack(j)) + k/v.bodytiming(j) * (v.Body(found,1) - v.bodyx(j,v.bodytrack(j)));
            v.bodyy(j,v.bodytrack(j)+k)          = v.bodyy(j,v.bodytrack(j)) + k/v.bodytiming(j) * (v.Body(found,2) - v.bodyy(j,v.bodytrack(j)));
            % for the directions one cannot use the usual method because
            % the animal might change direction in which case the direction
            % parameters are not compatible
            v.BodyDirection1(j,v.bodytrack(j)+k) = v.BodyFit(found,1);%v.BodyDirection1(j,v.bodytrack(j)) + k/v.bodytiming(j) * (v.BodyFit(found,1) - v.BodyDirection1(j,v.bodytrack(j)));
            v.BodyDirection2(j,v.bodytrack(j)+k) = v.BodyFit(found,2);%v.BodyDirection2(j,v.bodytrack(j)) + k/v.bodytiming(j) * (v.BodyFit(found,2) - v.BodyDirection2(j,v.bodytrack(j)));
            v.BodyDirection3(j,v.bodytrack(j)+k) = v.BodyFit(found,3);%v.BodyDirection3(j,v.bodytrack(j));
            v.bodyborder(j,v.bodytrack(j)+k, 1)  = v.bodyborder(j,v.bodytrack(j), 1) + k/v.bodytiming(j) * (v.Body(found,2) - v.bodyborder(j,v.bodytrack(j), 1));
            v.bodyborder(j,v.bodytrack(j)+k, 2)  = v.bodyborder(j,v.bodytrack(j), 2) + k/v.bodytiming(j) * (v.Body(found,2) - v.bodyborder(j,v.bodytrack(j), 2));
            v.bodyborder(j,v.bodytrack(j)+k, 3)  = v.bodyborder(j,v.bodytrack(j), 3) + k/v.bodytiming(j) * (v.Body(found,2) - v.bodyborder(j,v.bodytrack(j), 3));
            v.bodyborder(j,v.bodytrack(j)+k, 4)  = v.bodyborder(j,v.bodytrack(j), 4) + k/v.bodytiming(j) * (v.Body(found,2) - v.bodyborder(j,v.bodytrack(j), 4));
            v.bodyborder(j,v.bodytrack(j)+k, 5)  = v.bodyborder(j,v.bodytrack(j), 5) + k/v.bodytiming(j) * (v.Body(found,2) - v.bodyborder(j,v.bodytrack(j), 5));
            v.bodyborder(j,v.bodytrack(j)+k, 6)  = v.bodyborder(j,v.bodytrack(j), 6) + k/v.bodytiming(j) * (v.Body(found,2) - v.bodyborder(j,v.bodytrack(j), 6));
            v.bodyborder(j,v.bodytrack(j)+k, 7)  = v.bodyborder(j,v.bodytrack(j), 7) + k/v.bodytiming(j) * (v.Body(found,2) - v.bodyborder(j,v.bodytrack(j), 7));
            v.bodyborder(j,v.bodytrack(j)+k, 8)  = v.bodyborder(j,v.bodytrack(j), 8) + k/v.bodytiming(j) * (v.Body(found,2) - v.bodyborder(j,v.bodytrack(j), 8));
            v.bodystdPar(j,v.bodytrack(j)+k)     = v.bodystdPar(j,v.bodytrack(j));
            v.bodystdPerp(j,v.bodytrack(j)+k)    = v.bodystdPerp(j,v.bodytrack(j));
            v.bodytime(j,v.bodytrack(j)+k)       = v.time(v.FrameNumber);
          end;
          v.bodytrack(j) = v.bodytrack(j) + v.bodytiming(j);
          v.bodytiming(j) = 0;
      end;
      % identify directton of motion and therefore fly orientation
      v.Orientation(j,v.bodytrack(j)) = 0;
      if v.bodytrack(j) > 1
          if v.BodyDirection3(j,v.bodytrack(j)) == 1
              if v.bodyx(j,v.bodytrack(j)) > v.bodyx(j,v.bodytrack(j)-min(v.bodytrack(j)-1,4))
                  v.Orientation(j,v.bodytrack(j)) = 1;
              else
                  v.Orientation(j,v.bodytrack(j)) = -1;
              end;
          else
              if v.bodyy(j,v.bodytrack(j)) > v.bodyy(j,v.bodytrack(j)-min(v.bodytrack(j)-1,4))
                  v.Orientation(j,v.bodytrack(j)) = 1;
              else
                  v.Orientation(j,v.bodytrack(j)) = -1;
              end;
          end;
      end;
      if v.bodytrack(j) >= 1
        % set up forced direction
          if p.force_direction ~= 0
              v.Orientation(j,v.bodytrack(j)) = p.force_direction; 
          end;
      end      
  end
end;

% if new point is not connected to any mosquito, make a new mosquito
for i = 1:s(1) % loop over new points
  if added(i) == 0
    Mnum = Mnum + 1;
    v.bodytrack(Mnum) = 1;
    v.bodytiming(Mnum) = 0;
    v.bodyx(Mnum,v.bodytrack(Mnum)) = v.Body(i,1);
    v.bodyy(Mnum,v.bodytrack(Mnum)) = v.Body(i,2);        
    v.BodyDirection1(Mnum,v.bodytrack(Mnum)) = v.BodyFit(i,1);
    v.BodyDirection2(Mnum,v.bodytrack(Mnum)) = v.BodyFit(i,2);  
    v.BodyDirection3(Mnum,v.bodytrack(Mnum)) = v.BodyFit(i,3);  
    v.Orientation(Mnum,v.bodytrack(Mnum)) = 0;
    v.bodyborder(Mnum,v.bodytrack(Mnum), 1) = v.BodyBorder(i,1);
    v.bodyborder(Mnum,v.bodytrack(Mnum), 2) = v.BodyBorder(i,2);
    v.bodyborder(Mnum,v.bodytrack(Mnum), 3) = v.BodyBorder(i,3);
    v.bodyborder(Mnum,v.bodytrack(Mnum), 4) = v.BodyBorder(i,4);
    v.bodyborder(Mnum,v.bodytrack(Mnum), 5) = v.BodyBorder(i,5);
    v.bodyborder(Mnum,v.bodytrack(Mnum), 6) = v.BodyBorder(i,6);
    v.bodyborder(Mnum,v.bodytrack(Mnum), 7) = v.BodyBorder(i,7);
    v.bodyborder(Mnum,v.bodytrack(Mnum), 8) = v.BodyBorder(i,8);
    v.bodystdPar(Mnum,v.bodytrack(Mnum))    = v.Bodystd(i,1);
    v.bodystdPerp(Mnum,v.bodytrack(Mnum))   = v.Bodystd(i,2);
    
    v.bodytime(Mnum,v.bodytrack(Mnum)) = v.time(v.FrameNumber);
  end
end


% add to mosquito timing
for j = 1:Mnum
    v.bodytiming(j) = v.bodytiming(j) + 1;
end;


% convert output variables to right format
bodyx = v.bodyx;
bodyy = v.bodyy;
bodytrack = v.bodytrack;
bodytiming = v.bodytiming;
BodyDirection1 = v.BodyDirection1;
BodyDirection2 = v.BodyDirection2;
BodyDirection3 = v.BodyDirection3;
Orientation = v.Orientation;
bodyborder = v.bodyborder;
bodytime = v.bodytime;
bodystdPar = v.bodystdPar;
bodystdPerp = v.bodystdPerp;
return;