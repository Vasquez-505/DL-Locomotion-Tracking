function handles = ChangeBodyCenter(handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles = ChangeBodyCenter(handles)
%
% Changes center of body to where the user clicks.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read FrameNumber
FrameNumber  = str2num(get(handles.frame_edit,'String'));

% let user place footprint manually
[x,y] = myginput(1,'Crosshair');

% Save footprint for the points after the placement which are
% before the next placement of the same footprint. Do this only if
% the placement is inside the image area, otherwise don't place.
if x <= 0 | x >= handles.v.picsize(2) | y <= 0 | y >= handles.v.picsize(1)
else
    % if there was already a body center, color it dark so we can see where
    % it was
    if handles.v.CurrentLeftFrontLegX(FrameNumber) > 0
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Alexandre  -> old one is commented
%         plot(handles.v.CurrentBodyX(FrameNumber)+handles.p.cut.left-1,handles.v.CurrentBodyY(FrameNumber)+handles.p.cut.up-1,'bo', 'MarkerSize', handles.p.circlesize);
        plot(handles.v.TC_x(FrameNumber)+handles.p.cut.left-1,handles.v.TC_y(FrameNumber)+handles.p.cut.up-1,'bo', 'MarkerSize', handles.p.circlesize);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
        % Make the original triangle blue
        % draw a little triangle to the end of the line in the
        % direction in which the fly is going
        if handles.v.CurrentBodyDirection3(FrameNumber) == 1
            if(handles.v.CurrentBodyOrientation(FrameNumber) == 1)
                X = [handles.v.CurrentBodyX(FrameNumber) + handles.v.CurrentBodyStdY(FrameNumber)];
            else
                X = [handles.v.CurrentBodyX(FrameNumber) - handles.v.CurrentBodyStdY(FrameNumber)];                    
            end;
            f = polyval([handles.v.CurrentBodyDirection1(FrameNumber) handles.v.CurrentBodyDirection2(FrameNumber)], X);
            plot(X+handles.p.cut.left-1,f+handles.p.cut.up-1,'bd','MarkerSize', 5, 'MarkerFaceColor','b');
        else
            if(handles.v.CurrentBodyOrientation(FrameNumber) == 1)
                Y = [handles.v.CurrentBodyY(FrameNumber) + handles.v.CurrentBodyStdX(FrameNumber)];
            else
                Y = [handles.v.CurrentBodyY(FrameNumber) - handles.v.CurrentBodyStdX(FrameNumber)];                    
            end;
            f = polyval([handles.v.CurrentBodyDirection1(FrameNumber) handles.v.CurrentBodyDirection2(FrameNumber)], Y);
            plot(f+handles.p.cut.left-1,Y+handles.p.cut.up-1,'b^','MarkerSize', 5, 'MarkerFaceColor','b');
        end;
        
    % make the original body line blue
        if handles.v.CurrentBodyDirection3(FrameNumber) == 1
            % draw original body line
            X = handles.v.CurrentBodyX(FrameNumber) + [-1 1 ]*handles.v.CurrentBodyStdY(FrameNumber);
            f = polyval([handles.v.CurrentBodyDirection1(FrameNumber) handles.v.CurrentBodyDirection2(FrameNumber)], X);
            plot(X+handles.p.cut.left-1,f+handles.p.cut.up-1,'b');
                
        else
            % draw original body line
            Y = handles.v.CurrentBodyY(FrameNumber) + [-1 1 ]*handles.v.CurrentBodyStdX(FrameNumber);
            f = polyval([handles.v.CurrentBodyDirection1(FrameNumber) handles.v.CurrentBodyDirection2(FrameNumber)], Y);
            plot(f+handles.p.cut.left-1,Y+handles.p.cut.up-1,'b');
        end;
    
   
    % Place footprint where the user placed it for all the frames
    % until 1 before the next placement of the same foot.
    i = FrameNumber;
    
    % Set data to specified
    handles.v.CurrentBodyX(FrameNumber) = x - handles.p.cut.left + 1;
    handles.v.CurrentBodyY(FrameNumber) = y - handles.p.cut.up   + 1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Alexandre
    handles.v.TC_x(FrameNumber) = x - handles.p.cut.left + 1;
    handles.v.TC_y(FrameNumber) = y - handles.p.cut.up   + 1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % plot center of body with new coordinates
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Alexandre -> old one is commented
%     plot(handles.v.CurrentBodyX(FrameNumber)+handles.p.cut.left-1,handles.v.CurrentBodyY(FrameNumber)+handles.p.cut.up-1,'co', 'MarkerSize', handles.p.circlesize);
      plot(handles.v.TC_x(FrameNumber)+handles.p.cut.left-1,handles.v.TC_y(FrameNumber)+handles.p.cut.up-1,'co', 'MarkerSize', handles.p.circlesize);

    % calculate new offset for new body line
        if handles.v.CurrentBodyDirection3(FrameNumber) == 1
            handles.v.CurrentBodyDirection2(FrameNumber) = handles.v.CurrentBodyY(FrameNumber) - handles.v.CurrentBodyDirection1(FrameNumber) * handles.v.CurrentBodyX(FrameNumber);
        else
            handles.v.CurrentBodyDirection2(FrameNumber) = handles.v.CurrentBodyX(FrameNumber) - handles.v.CurrentBodyDirection1(FrameNumber) * handles.v.CurrentBodyY(FrameNumber);
        end;
    
    % plot new body line
        if handles.v.CurrentBodyDirection3(FrameNumber) == 1
            % calculate body line
            X = handles.v.CurrentBodyX(FrameNumber) + [-1 1 ]*handles.v.CurrentBodyStdY(FrameNumber);
            f = polyval([handles.v.CurrentBodyDirection1(FrameNumber) handles.v.CurrentBodyDirection2(FrameNumber)], X);
            plot(X+handles.p.cut.left-1,f+handles.p.cut.up-1,'y');
        else
            % calculate body line
            Y = handles.v.CurrentBodyY(FrameNumber) + [-1 1 ]*handles.v.CurrentBodyStdX(FrameNumber);
            f = polyval([handles.v.CurrentBodyDirection1(FrameNumber) handles.v.CurrentBodyDirection2(FrameNumber)], Y);
            plot(f+handles.p.cut.left-1,Y+handles.p.cut.up-1,'y');
        end;
        % draw a little triangle to the end of the line in the
        % direction in which the fly is going
        if handles.v.CurrentBodyDirection3(FrameNumber) == 1
            if(handles.v.CurrentBodyOrientation(FrameNumber) == 1)
                X = [handles.v.CurrentBodyX(FrameNumber) + handles.v.CurrentBodyStdY(FrameNumber)];
            else
                X = [handles.v.CurrentBodyX(FrameNumber) - handles.v.CurrentBodyStdY(FrameNumber)];                    
            end;
            f = polyval([handles.v.CurrentBodyDirection1(FrameNumber) handles.v.CurrentBodyDirection2(FrameNumber)], X);
            plot(X+handles.p.cut.left-1,f+handles.p.cut.up-1,'yd','MarkerSize', 5, 'MarkerFaceColor','y');
        else
            if(handles.v.CurrentBodyOrientation(FrameNumber) == 1)
                Y = [handles.v.CurrentBodyY(FrameNumber) + handles.v.CurrentBodyStdX(FrameNumber)];
            else
                Y = [handles.v.CurrentBodyY(FrameNumber) - handles.v.CurrentBodyStdX(FrameNumber)];                    
            end;
            f = polyval([handles.v.CurrentBodyDirection1(FrameNumber) handles.v.CurrentBodyDirection2(FrameNumber)], Y);
            plot(f+handles.p.cut.left-1,Y+handles.p.cut.up-1,'y^','MarkerSize', 5, 'MarkerFaceColor','y');
        end;
    
end










return;