function handles = BodyOff(handles, Where)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function handles = BodyOff(handles, Where)
%
% (c) Imre Bartos, 2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% turn off body and legs at specified frames

    FrameNumber  = str2num(get(handles.frame_edit,'String'));

    MaxFrame = length(handles.p.FileList);
    
    % select which indices to cut
    if strcmp(Where,'current')
        Indices = FrameNumber;
    end;
    if strcmp(Where,'after')
        Indices = FrameNumber:MaxFrame;
    end;
    if strcmp(Where,'before')
        Indices = 1:FrameNumber;
    end;
    

% cut body and legs at Indices
for i = Indices
    handles.v.CurrentBodyX(i)           = 0; 
    handles.v.CurrentBodyY(i)           = 0; 
    handles.v.CurrentBodyDirection1(i)  = 0; 
    handles.v.CurrentBodyDirection2(i)  = 0;
    handles.v.CurrentBodyDirection3(i)  = 0;
    handles.v.CurrentBodyOrientation(i) = 0;
    handles.v.CurrentBodyStdX(i)        = 0;
    handles.v.CurrentBodyStdY(i)        = 0;
    handles.v.CurrentLeftFrontLegX(i)   = 0;
    handles.v.CurrentLeftFrontLegY(i)   = 0;
    handles.v.CurrentRightFrontLegX(i)  = 0;
    handles.v.CurrentRightFrontLegY(i)  = 0;
    handles.v.CurrentLeftMiddleLegX(i)  = 0;
    handles.v.CurrentLeftMiddleLegY(i)  = 0;
    handles.v.CurrentRightMiddleLegX(i) = 0;
    handles.v.CurrentRightMiddleLegY(i) = 0;
    handles.v.CurrentLeftBackLegX(i)    = 0;
    handles.v.CurrentLeftBackLegY(i)    = 0;
    handles.v.CurrentRightBackLegX(i)   = 0;
    handles.v.CurrentRightBackLegY(i)   = 0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Alexandre
    handles.v.TC_x(i)                   = 0;
    handles.v.TC_y(i)                   = 0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end;
    
% draw new direction
  handles = PlotforManual(handles);
    
return;