function  [legx, legy, legtrack, legtiming, legtime, legbrightness] = TrackLegs_01(p,v)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Identifies and tracks fly leg candidates
%
% INPUT:
% Leg
% v.legx
% v.legy
% v.legtrack
% v.legtiming
% p.radiusleg
% p.maxtimedifferenceleg
% p.mintimedifferenceleg
% v.time
% v.LegBrightness
% legtime
%
% OUTPUT:
% v.legx
% v.legy
% v.legtrack
% legtiming
% legtime
%
% (c) Imre Bartos, April 2009
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% number of total legs found [s(1)]
  s = size(v.Leg);
% number of mosquito tracks [s2(1)] and length of mosquito tracks [s2(2)]
  s2 = size(v.legx);
% number of tracks. This variable will be changed in this script as new
% tracks are added.
  Mnum = s2(1);
% we initially have zero added tracks 
  added(1:s(1)) = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Associate points with tracks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for j = 1:s2(1) % loop over mosquito tracks
  closest = p.radiusleg^2+1;
  found = 0;
  
  % continue with checking this track if the timing of this track is
  % within the limits
    if v.legtiming(j) <= p.maxtimedifferenceleg
      % if already tracked, calculate expected position and try to
      % track it from there
        if v.legtrack(j) > 1
          expectedlocationx =  v.legx(j,v.legtrack(j)) + v.legtiming(j) * (v.legx(j,v.legtrack(j)) - v.legx(j,v.legtrack(j)-1));
          expectedlocationy =  v.legy(j,v.legtrack(j)) + v.legtiming(j) * (v.legy(j,v.legtrack(j)) - v.legy(j,v.legtrack(j)-1));
        end
      % if not tracked yet, expected position = currrent position
        if v.legtrack(j) == 1
          expectedlocationx =  v.legx(j,v.legtrack(j));
          expectedlocationy =  v.legy(j,v.legtrack(j));
        end;      
      
      % Check if any of the new points is connected to this track (j)
        for i = 1:s(1) % loop over new points
          dist2 = (v.Leg(i,1)-expectedlocationx)^2 + (v.Leg(i,2)-expectedlocationy)^2;
          if  dist2 < min(p.radiusleg^2,closest) & added(i) == 0
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
        if v.legtiming(j) == 1      
          v.legtrack(j) = v.legtrack(j) + 1;
          v.legtiming(j) = 0;
          v.legx(j,v.legtrack(j)) = v.Leg(found,1);
          v.legy(j,v.legtrack(j)) = v.Leg(found,2);
          v.legbrightness(j,v.legtrack(j)) = v.LegBrightness(found);
          v.legtime(j,v.legtrack(j)) = v.time(v.FrameNumber);
        end;
        if v.legtiming(j) > 1      
          for k = 1:v.legtiming(j)
            v.legx(j,v.legtrack(j)+k) = v.legx(j,v.legtrack(j)) + k/v.legtiming(j) * (v.Leg(found,1) - v.legx(j,v.legtrack(j)));
            v.legy(j,v.legtrack(j)+k) = v.legy(j,v.legtrack(j)) + k/v.legtiming(j) * (v.Leg(found,2) - v.legy(j,v.legtrack(j)));
            v.legbrightness(j,v.legtrack(j)+k) =  v.legbrightness(j,v.legtrack(j));
            v.legtime(j,v.legtrack(j)+k) = v.time(v.FrameNumber);
          end;
          v.legtrack(j) = v.legtrack(j) + v.legtiming(j);
          v.legtiming(j) = 0;
        end;
    end
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if new point is not connected to any leg, make a new leg
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i = 1:s(1) % loop over new points
  if added(i) == 0
    Mnum = Mnum + 1;
    v.legtrack(Mnum) = 1;
    v.legtiming(Mnum) = 0;
    v.legx(Mnum,v.legtrack(Mnum)) = v.Leg(i,1);
    v.legy(Mnum,v.legtrack(Mnum)) = v.Leg(i,2);
    v.legbrightness(Mnum,v.legtrack(Mnum)) = v.LegBrightness(i);
    v.legtime(Mnum,v.legtrack(Mnum)) = v.time(v.FrameNumber);
  end
end


% add to mosquito timing
for j = 1:Mnum
    v.legtiming(j) = v.legtiming(j) + 1;
end;

% convert output
legx = v.legx;
legy = v.legy; 
legbrightness = v.legbrightness;
legtrack = v.legtrack; 
legtiming = v.legtiming; 
legtime = v.legtime;



return;