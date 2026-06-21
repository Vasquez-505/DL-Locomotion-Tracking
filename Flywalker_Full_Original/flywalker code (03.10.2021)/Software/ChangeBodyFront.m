function handles = ChangeBodyFront(handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% handles = ChangeBodyFront(handles)
%
% Changes front of body to where the user clicks.
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
    % if there was already a body front, color it dark so we can see where
    % it was
    if handles.v.CurrentBodyX(FrameNumber) > 0
        plot(handles.v.CurrentBodyX(FrameNumber)+handles.p.cut.left-1,handles.v.CurrentBodyY(FrameNumber)+handles.p.cut.up-1,'bo', 'MarkerSize', handles.p.circlesize);
    end
   
    % Place footprint where the user placed it for all the frames
    % until 1 before the next placement of the same foot.
    i = FrameNumber;
    
    % Set data to specified
    handles.v.CurrentFrontX(FrameNumber) = x - handles.p.cut.left + 1;
    handles.v.CurrentFrontY(FrameNumber) = y - handles.p.cut.up   + 1;
    
    % decide which direction the body is at
      % save old direction for erasing previous mark
        oldCurrentBodyDirection3 = handles.v.CurrentBodyDirection3(FrameNumber);
      if abs(handles.v.CurrentFrontX(FrameNumber) - handles.v.CurrentBodyX(FrameNumber)) > abs(handles.v.CurrentFrontY(FrameNumber) - handles.v.CurrentBodyY(FrameNumber))
        handles.v.CurrentBodyDirection3(FrameNumber) = 1;
      else
        handles.v.CurrentBodyDirection3(FrameNumber) = 2;
      end;
    
    
if length(handles.v.CurrentBodyX) >= FrameNumber
    if handles.v.CurrentBodyX(FrameNumber) > 0
    
        % Make the original triangle blue
        % draw a little triangle to the end of the line in the
        % direction in which the fly is going
        if oldCurrentBodyDirection3 == 1
            if(handles.v.CurrentBodyOrientation(FrameNumber) == 1)
                X = [handles.v.CurrentBodyX(FrameNumber) + handles.v.CurrentBodyStdY(FrameNumber)];
            else
                X = [handles.v.CurrentBodyX(FrameNumber) - handles.v.CurrentBodyStdY(FrameNumber)];                    
            end;
            f = polyval([handles.v.CurrentBodyDirection1(FrameNumber) handles.v.CurrentBodyDirection2(FrameNumber)], X);
            plot(X+handles.p.cut.left-1,f+handles.p.cut.up-1,'bd','MarkerSize', 5, 'MarkerFaceColor','b');
            
            % draw original body line
            X = handles.v.CurrentBodyX(FrameNumber) + [-1 1 ]*handles.v.CurrentBodyStdY(FrameNumber);
            f = polyval([handles.v.CurrentBodyDirection1(FrameNumber) handles.v.CurrentBodyDirection2(FrameNumber)], X);
            plot(X+handles.p.cut.left-1,f+handles.p.cut.up-1,'b');
            
        else
            if(handles.v.CurrentBodyOrientation(FrameNumber) == 1)
                Y = [handles.v.CurrentBodyY(FrameNumber) + handles.v.CurrentBodyStdX(FrameNumber)];
            else
                Y = [handles.v.CurrentBodyY(FrameNumber) - handles.v.CurrentBodyStdX(FrameNumber)];                    
            end;
            f = polyval([handles.v.CurrentBodyDirection1(FrameNumber) handles.v.CurrentBodyDirection2(FrameNumber)], Y);
            plot(f+handles.p.cut.left-1,Y+handles.p.cut.up-1,'bd','MarkerSize', 5, 'MarkerFaceColor','b');
            
            % draw original body line
            Y = handles.v.CurrentBodyY(FrameNumber) + [-1 1 ]*handles.v.CurrentBodyStdX(FrameNumber);
            f = polyval([handles.v.CurrentBodyDirection1(FrameNumber) handles.v.CurrentBodyDirection2(FrameNumber)], Y);
            plot(f+handles.p.cut.left-1,Y+handles.p.cut.up-1,'b');            
        end;
        
        if handles.v.CurrentBodyDirection3(FrameNumber) == 1
            % calculate new direction
            handles.v.CurrentBodyDirection1(FrameNumber) = (handles.v.CurrentBodyY(FrameNumber) - handles.v.CurrentFrontY(FrameNumber))/(handles.v.CurrentBodyX(FrameNumber) - handles.v.CurrentFrontX(FrameNumber));
            handles.v.CurrentBodyDirection2(FrameNumber) = handles.v.CurrentBodyY(FrameNumber) - handles.v.CurrentBodyDirection1(FrameNumber) * handles.v.CurrentBodyX(FrameNumber);
            % calculate new length
%             handles.v.CurrentBodyStdY(FrameNumber) = abs(handles.v.CurrentBodyX(FrameNumber) - handles.v.CurrentFrontX(FrameNumber));
%             handles.v.CurrentBodyStdX(FrameNumber) = handles.v.CurrentBodyStdY(FrameNumber)/3;
            handles.v.CurrentBodyStdY(FrameNumber) = sqrt((handles.v.CurrentBodyX(FrameNumber) - handles.v.CurrentFrontX(FrameNumber))^2 + (handles.v.CurrentBodyY(FrameNumber) - handles.v.CurrentFrontY(FrameNumber))^2);
            handles.v.CurrentBodyStdX(FrameNumber) = handles.v.CurrentBodyStdY(FrameNumber)/3;
            % calculate body line
%             X = handles.v.CurrentBodyX(FrameNumber) + [-1 1 ]*handles.v.CurrentBodyStdY(FrameNumber);
%             f = polyval([handles.v.CurrentBodyDirection1(FrameNumber) handles.v.CurrentBodyDirection2(FrameNumber)], X);
            X = [handles.v.CurrentFrontX(FrameNumber) 2*handles.v.CurrentBodyX(FrameNumber) - handles.v.CurrentFrontX(FrameNumber)];
            Y = [handles.v.CurrentFrontY(FrameNumber) 2*handles.v.CurrentBodyY(FrameNumber) - handles.v.CurrentFrontY(FrameNumber)];
            plot(X+handles.p.cut.left-1,Y+handles.p.cut.up-1,'y');
            plot(X(1)+handles.p.cut.left-1,Y(1)+handles.p.cut.up-1,'yd','MarkerSize', 5, 'MarkerFaceColor','y');
            
            % figure out which way the fly is moving
            if handles.v.CurrentBodyX(FrameNumber) >= handles.v.CurrentFrontX(FrameNumber)
                handles.v.CurrentBodyOrientation(FrameNumber) = -1;
            else
                handles.v.CurrentBodyOrientation(FrameNumber) = 1;
            end;
                
        else
            % calculate new direction
            handles.v.CurrentBodyDirection1(FrameNumber) = (handles.v.CurrentBodyX(FrameNumber) - handles.v.CurrentFrontX(FrameNumber))/(handles.v.CurrentBodyY(FrameNumber) - handles.v.CurrentFrontY(FrameNumber));
            handles.v.CurrentBodyDirection2(FrameNumber) = handles.v.CurrentBodyX(FrameNumber) - handles.v.CurrentBodyDirection1(FrameNumber) * handles.v.CurrentBodyY(FrameNumber);
            % calculate new length
%             handles.v.CurrentBodyStdX(FrameNumber) = ...
%                 abs(handles.v.CurrentBodyY(FrameNumber) - handles.v.CurrentFrontY(FrameNumber));
            handles.v.CurrentBodyStdX(FrameNumber) = sqrt((handles.v.CurrentBodyX(FrameNumber) - handles.v.CurrentFrontX(FrameNumber))^2 + (handles.v.CurrentBodyY(FrameNumber) - handles.v.CurrentFrontY(FrameNumber))^2);
            handles.v.CurrentBodyStdY(FrameNumber) = handles.v.CurrentBodyStdX(FrameNumber)/3;

            % calculate body line
            X = [handles.v.CurrentFrontX(FrameNumber) 2*handles.v.CurrentBodyX(FrameNumber) - handles.v.CurrentFrontX(FrameNumber)];
            Y = [handles.v.CurrentFrontY(FrameNumber) 2*handles.v.CurrentBodyY(FrameNumber) - handles.v.CurrentFrontY(FrameNumber)];
            plot(X+handles.p.cut.left-1,Y+handles.p.cut.up-1,'y');
            plot(X(1)+handles.p.cut.left-1,Y(1)+handles.p.cut.up-1,'yd','MarkerSize', 5, 'MarkerFaceColor','y');

            % figure out which way the fly is moving
            if handles.v.CurrentBodyY(FrameNumber) >= handles.v.CurrentFrontY(FrameNumber)
                handles.v.CurrentBodyOrientation(FrameNumber) = -1;
            else
                handles.v.CurrentBodyOrientation(FrameNumber) = 1;
            end;
        end
    end
end
    
    
    
    
    
    % plot center of body with new coordinates
    plot(handles.v.CurrentBodyX(FrameNumber)+handles.p.cut.left-1,handles.v.CurrentBodyY(FrameNumber)+handles.p.cut.up-1,'co', 'MarkerSize', handles.p.circlesize);
end


handlescirclesize = handles.p.circlesize







return;