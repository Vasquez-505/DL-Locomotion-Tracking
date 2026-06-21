function v = InitializeTrackData(p,v)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% v = InitializeTrackData(p,v)
%
% Use tracked values to reconstruct what saved data should look like if all
% data was generated with the automatic tracking function
% AutoFootPrintAnalysis.
%
%
% (c) Imre Bartos, 2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

v.bodytrack(1) = 1;


% save body position and direction
v.bodyx(1,v.bodytrack(1))          = v.CurrentBodyX(v.FrameNumber);
v.bodyy(1,v.bodytrack(1))          = v.CurrentBodyY(v.FrameNumber);
v.BodyDirection1(1,v.bodytrack(1)) = v.CurrentBodyDirection1(v.FrameNumber);
v.BodyDirection2(1,v.bodytrack(1)) = v.CurrentBodyDirection2(v.FrameNumber);
v.BodyDirection3(1,v.bodytrack(1)) = v.CurrentBodyDirection3(v.FrameNumber);
v.Orientation(1,v.bodytrack(1))    = v.CurrentBodyOrientation(v.FrameNumber);
v.Bodystd(1,2) = v.CurrentBodyStdX(v.FrameNumber);
v.Bodystd(1,1) = v.CurrentBodyStdY(v.FrameNumber);
v.bodystdPar(1,v.bodytrack(1)) = v.Bodystd(1,2);
v.bodystdPerp(1,v.bodytrack(1)) = v.Bodystd(1,1);
v.bodytiming(1) = -1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre
% v.TCx(1,v.bodytrack(1))            = v.TC_x(v.FrameNumber);
% v.TCy(1,v.bodytrack(1))            = v.TC_y(v.FrameNumber);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

counter = 0;

if v.CurrentLeftFrontLegX(v.FrameNumber) > 0
    counter = counter + 1;
    v.legtrack(counter) = 1;
    v.legx(counter,v.legtrack(counter)) = v.CurrentLeftFrontLegX(v.FrameNumber);
    v.legy(counter,v.legtrack(counter)) = v.CurrentLeftFrontLegY(v.FrameNumber);
    v.Side(1,counter) = 1;
    v.legtiming(counter) = 1;
end

if v.CurrentRightFrontLegX(v.FrameNumber) > 0
    counter = counter + 1;
    v.legtrack(counter) = 1;
    v.legx(counter,v.legtrack(counter)) = v.CurrentRightFrontLegX(v.FrameNumber);
    v.legy(counter,v.legtrack(counter)) = v.CurrentRightFrontLegY(v.FrameNumber);
    v.Side(1,counter) = -1;
    v.legtiming(counter) = 1;
end

if v.CurrentLeftMiddleLegX(v.FrameNumber) > 0
    counter = counter + 1;
    v.legtrack(counter) = 1;
    v.legx(counter,v.legtrack(counter)) = v.CurrentLeftMiddleLegX(v.FrameNumber);
    v.legy(counter,v.legtrack(counter)) = v.CurrentLeftMiddleLegY(v.FrameNumber);
    v.Side(1,counter) = 1;
    v.legtiming(counter) = 1;
end

if v.CurrentRightMiddleLegX(v.FrameNumber) > 0
    counter = counter + 1;
    v.legtrack(counter) = 1;
    v.legx(counter,v.legtrack(counter)) = v.CurrentRightMiddleLegX(v.FrameNumber);
    v.legy(counter,v.legtrack(counter)) = v.CurrentRightMiddleLegY(v.FrameNumber);
    v.Side(1,counter) = -1;
    v.legtiming(counter) = 1;
end

if v.CurrentLeftBackLegX(v.FrameNumber) > 0
    counter = counter + 1;
    v.legtrack(counter) = 1;
    v.legx(counter,v.legtrack(counter)) = v.CurrentLeftBackLegX(v.FrameNumber);
    v.legy(counter,v.legtrack(counter)) = v.CurrentLeftBackLegY(v.FrameNumber);
    v.Side(1,counter) = 1;
    v.legtiming(counter) = 1;
end

if v.CurrentRightBackLegX(v.FrameNumber) > 0
    counter = counter + 1;
    v.legtrack(counter) = 1;
    v.legx(counter,v.legtrack(counter)) = v.CurrentRightBackLegX(v.FrameNumber);
    v.legy(counter,v.legtrack(counter)) = v.CurrentRightBackLegY(v.FrameNumber);
    v.Side(1,counter) = -1;
    v.legtiming(counter) = 1;
end



return;