function handles = ChangeLegStatus(handles,Leg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function handles = ChangeLegStatus(handles,Leg)
%
% Change leg status following Footprint Status toggle button actions by the
% user
%
% (c) Imre Bartos, 2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read FrameNumber
FrameNumber  = str2num(get(handles.frame_edit,'String'));

% LF ----------------------------------------------------------------------
if strcmp(Leg,'LF')
    % retrieve new button position after toggle
    handles.LF_togglebuttonStatus = get(handles.LF_togglebutton,'Value');
    if handles.LF_togglebuttonStatus == 1
        % let user place footprint manually
        [x,y] = myginput(1,'crosshair');
        % Save footprint for the points after the placement which are
        % before the next placement of the same footprint. Do this only if
        % the placement is inside the image area, otherwise don't place.
        if x <= 0 | x >= handles.v.picsize(2) | y <= 0 | y >= handles.v.picsize(1)
            set(handles.LF_togglebutton,'Value',0);
        else
            % Place footprint where the user placed it for all the frames
            % until 1 before the next placement of the same foot.
            i = FrameNumber;
            % Set data to specified
            handles.v.CurrentLeftFrontLegX(FrameNumber) = x - handles.p.cut.left + 1;
            handles.v.CurrentLeftFrontLegY(FrameNumber) = y - handles.p.cut.up   + 1;
            plot(handles.v.CurrentLeftFrontLegX(FrameNumber)+handles.p.cut.left-1,handles.v.CurrentLeftFrontLegY(FrameNumber)+handles.p.cut.up-1,'go', 'MarkerSize', handles.p.circlesize);
            text(handles.v.CurrentLeftFrontLegX(FrameNumber)+handles.p.cut.left + 5, handles.v.CurrentLeftFrontLegY(FrameNumber)+handles.p.cut.up - 5,'LF','Interpreter','none', 'Color','g','FontSize', 8);
            
            while i ~= -1
                % exit if next footprint is already on otherwise go till
                % the end of the set of frames
                if length(handles.p.FileList) > i
                    if length(handles.v.CurrentLeftFrontLegX) > i
                        if handles.v.CurrentLeftFrontLegX(i+1) > 0
                            i = -1;
                        else
                            % Set data to specified
                            handles.v.CurrentLeftFrontLegX(i) = x - handles.p.cut.left + 1;
                            handles.v.CurrentLeftFrontLegY(i) = y - handles.p.cut.up   + 1;
                            i = i + 1;
                        end;
                    else
                        % Set data to specified
                        handles.v.CurrentLeftFrontLegX(i) = x - handles.p.cut.left + 1;
                        handles.v.CurrentLeftFrontLegY(i) = y - handles.p.cut.up   + 1;
                        i = -1;
                    end;
                else
                    % Set data to specified
                    handles.v.CurrentLeftFrontLegX(i) = x - handles.p.cut.left + 1;
                    handles.v.CurrentLeftFrontLegY(i) = y - handles.p.cut.up   + 1;
                    i = -1;
                end
            end;
        end
            
        
    else
        % overplot existing leg
        if length(handles.v.CurrentLeftFrontLegX) >= FrameNumber       
            if handles.v.CurrentLeftFrontLegX(FrameNumber) > 0
               plot(handles.v.CurrentLeftFrontLegX(FrameNumber)+handles.p.cut.left-1,handles.v.CurrentLeftFrontLegY(FrameNumber)+handles.p.cut.up-1,'ro', 'MarkerSize', handles.p.circlesize);
               text(handles.v.CurrentLeftFrontLegX(FrameNumber)+handles.p.cut.left + 5, handles.v.CurrentLeftFrontLegY(FrameNumber)+handles.p.cut.up - 5,'LF','Interpreter','none', 'Color','r','FontSize', 8);
            end
        end
        % Turn footprint off till as long as the current footprint is
        % placed.
        i = FrameNumber;
        while i ~= -1
            if length(handles.v.CurrentLeftFrontLegX) >= i
                % exit if current footprint is off
                if handles.v.CurrentLeftFrontLegX(i) == -1
                    i = -1;
                else
                    % Erase data
                    handles.v.CurrentLeftFrontLegX(i) = -1;
                    handles.v.CurrentLeftFrontLegY(i) = -1;
                    i = i + 1;
                end;
            else
                i = -1;                
            end;
        end;
    end;
end

% RF ----------------------------------------------------------------------
if strcmp(Leg,'RF')
    % retrieve new button position after toggle
    handles.RF_togglebuttonStatus = get(handles.RF_togglebutton,'Value');
    if handles.RF_togglebuttonStatus == 1
        % let user place footprint manually
        [x,y] = myginput(1,'crosshair');
        % Save footprint for the points after the placement which are
        % before the next placement of the same footprint. Do this only if
        % the placement is inside the image area, otherwise don't place.
        if x <= 0 | x >= handles.v.picsize(2) | y <= 0 | y >= handles.v.picsize(1)
            set(handles.RF_togglebutton,'Value',0);
        else
            % Place footprint where the user placed it for all the frames
            % until 1 before the next placement of the same foot.
            i = FrameNumber;
            % Set data to specified
            handles.v.CurrentRightFrontLegX(FrameNumber) = x - handles.p.cut.left + 1;
            handles.v.CurrentRightFrontLegY(FrameNumber) = y - handles.p.cut.up   + 1;
            plot(handles.v.CurrentRightFrontLegX(FrameNumber)+handles.p.cut.left-1,handles.v.CurrentRightFrontLegY(FrameNumber)+handles.p.cut.up-1,'go', 'MarkerSize', handles.p.circlesize);
            text(handles.v.CurrentRightFrontLegX(FrameNumber)+handles.p.cut.left + 5, handles.v.CurrentRightFrontLegY(FrameNumber)+handles.p.cut.up - 5,'RF','Interpreter','none', 'Color','g','FontSize', 8);
            
            while i ~= -1
                % exit if next footprint is already on otherwise go till
                % the end of the set of frames
                if length(handles.p.FileList) > i
                    if length(handles.v.CurrentRightFrontLegX) > i
                        if handles.v.CurrentRightFrontLegX(i+1) > 0
                            i = -1;
                        else
                            % Set data to specified
                            handles.v.CurrentRightFrontLegX(i) = x - handles.p.cut.left + 1;
                            handles.v.CurrentRightFrontLegY(i) = y - handles.p.cut.up   + 1;
                            i = i + 1;
                        end;
                    else
                        % Set data to specified
                        handles.v.CurrentRightFrontLegX(i) = x - handles.p.cut.left + 1;
                        handles.v.CurrentRightFrontLegY(i) = y - handles.p.cut.up   + 1;
                        i = -1;
                    end;
                else
                    % Set data to specified
                    handles.v.CurrentRightFrontLegX(i) = x - handles.p.cut.left + 1;
                    handles.v.CurrentRightFrontLegY(i) = y - handles.p.cut.up   + 1;
                    i = -1;
                end
            end;
        end
            
        
    else
        % overplot existing leg
        if length(handles.v.CurrentRightFrontLegX) >= FrameNumber       
            if handles.v.CurrentRightFrontLegX(FrameNumber) > 0
               plot(handles.v.CurrentRightFrontLegX(FrameNumber)+handles.p.cut.left-1,handles.v.CurrentRightFrontLegY(FrameNumber)+handles.p.cut.up-1,'ro', 'MarkerSize', handles.p.circlesize);
               text(handles.v.CurrentRightFrontLegX(FrameNumber)+handles.p.cut.left + 5, handles.v.CurrentRightFrontLegY(FrameNumber)+handles.p.cut.up - 5,'RF','Interpreter','none', 'Color','r','FontSize', 8);
            end
        end
        % Turn footprint off till as long as the current footprint is
        % placed.
        i = FrameNumber;
        while i ~= -1
            if length(handles.v.CurrentRightFrontLegX) >= i
                % exit if current footprint is off
                if handles.v.CurrentRightFrontLegX(i) == -1
                    i = -1;
                else
                    % Erase data
                    handles.v.CurrentRightFrontLegX(i) = -1;
                    handles.v.CurrentRightFrontLegY(i) = -1;
                    i = i + 1;
                end;
            else
                i = -1;                
            end;
        end;
    end;
end

% LM ----------------------------------------------------------------------
if strcmp(Leg,'LM')
    % retrieve new button position after toggle
    handles.LM_togglebuttonStatus = get(handles.LM_togglebutton,'Value');
    if handles.LM_togglebuttonStatus == 1
        % let user place footprint manually
        [x,y] = myginput(1,'crosshair');
        % Save footprint for the points after the placement which are
        % before the next placement of the same footprint. Do this only if
        % the placement is inside the image area, otherwise don't place.
        if x <= 0 | x >= handles.v.picsize(2) | y <= 0 | y >= handles.v.picsize(1)
            set(handles.LM_togglebutton,'Value',0);
        else
            % Place footprint where the user placed it for all the frames
            % until 1 before the next placement of the same foot.
            i = FrameNumber;
            % Set data to specified
            handles.v.CurrentLeftMiddleLegX(FrameNumber) = x - handles.p.cut.left + 1;
            handles.v.CurrentLeftMiddleLegY(FrameNumber) = y - handles.p.cut.up   + 1;
            plot(handles.v.CurrentLeftMiddleLegX(FrameNumber)+handles.p.cut.left-1,handles.v.CurrentLeftMiddleLegY(FrameNumber)+handles.p.cut.up-1,'go', 'MarkerSize', handles.p.circlesize);
            text(handles.v.CurrentLeftMiddleLegX(FrameNumber)+handles.p.cut.left + 5, handles.v.CurrentLeftMiddleLegY(FrameNumber)+handles.p.cut.up - 5,'LM','Interpreter','none', 'Color','g','FontSize', 8);
            
            while i ~= -1
                % exit if next footprint is already on otherwise go till
                % the end of the set of frames
                if length(handles.p.FileList) > i
                    if length(handles.v.CurrentLeftMiddleLegX) > i
                        if handles.v.CurrentLeftMiddleLegX(i+1) > 0
                            i = -1;
                        else
                            % Set data to specified
                            handles.v.CurrentLeftMiddleLegX(i) = x - handles.p.cut.left + 1;
                            handles.v.CurrentLeftMiddleLegY(i) = y - handles.p.cut.up   + 1;
                            i = i + 1;
                        end;
                    else
                        % Set data to specified
                        handles.v.CurrentLeftMiddleLegX(i) = x - handles.p.cut.left + 1;
                        handles.v.CurrentLeftMiddleLegY(i) = y - handles.p.cut.up   + 1;
                        i = -1;
                    end;
                else
                    % Set data to specified
                    handles.v.CurrentLeftMiddleLegX(i) = x - handles.p.cut.left + 1;
                    handles.v.CurrentLeftMiddleLegY(i) = y - handles.p.cut.up   + 1;
                    i = -1;
                end
            end;
        end
            
        
    else
        % overplot existing leg
        if length(handles.v.CurrentLeftMiddleLegX) >= FrameNumber       
            if handles.v.CurrentLeftMiddleLegX(FrameNumber) > 0
               plot(handles.v.CurrentLeftMiddleLegX(FrameNumber)+handles.p.cut.left-1,handles.v.CurrentLeftMiddleLegY(FrameNumber)+handles.p.cut.up-1,'ro', 'MarkerSize', handles.p.circlesize);
               text(handles.v.CurrentLeftMiddleLegX(FrameNumber)+handles.p.cut.left + 5, handles.v.CurrentLeftMiddleLegY(FrameNumber)+handles.p.cut.up - 5,'LM','Interpreter','none', 'Color','r','FontSize', 8);
            end
        end
        % Turn footprint off till as long as the current footprint is
        % placed.
        i = FrameNumber;
        while i ~= -1
            if length(handles.v.CurrentLeftMiddleLegX) >= i
                % exit if current footprint is off
                if handles.v.CurrentLeftMiddleLegX(i) == -1
                    i = -1;
                else
                    % Erase data
                    handles.v.CurrentLeftMiddleLegX(i) = -1;
                    handles.v.CurrentLeftMiddleLegY(i) = -1;
                    i = i + 1;
                end;
            else
                i = -1;                
            end;
        end;
    end;
end

% RM ----------------------------------------------------------------------
if strcmp(Leg,'RM')
    % retrieve new button position after toggle
    handles.RM_togglebuttonStatus = get(handles.RM_togglebutton,'Value');
    if handles.RM_togglebuttonStatus == 1
        % let user place footprint manually
        [x,y] = myginput(1,'crosshair');
        % Save footprint for the points after the placement which are
        % before the next placement of the same footprint. Do this only if
        % the placement is inside the image area, otherwise don't place.
        if x <= 0 | x >= handles.v.picsize(2) | y <= 0 | y >= handles.v.picsize(1)
            set(handles.RM_togglebutton,'Value',0);
        else
            % Place footprint where the user placed it for all the frames
            % until 1 before the next placement of the same foot.
            i = FrameNumber;
            % Set data to specified
            handles.v.CurrentRightMiddleLegX(FrameNumber) = x - handles.p.cut.left + 1;
            handles.v.CurrentRightMiddleLegY(FrameNumber) = y - handles.p.cut.up   + 1;
            plot(handles.v.CurrentRightMiddleLegX(FrameNumber)+handles.p.cut.left-1,handles.v.CurrentRightMiddleLegY(FrameNumber)+handles.p.cut.up-1,'go', 'MarkerSize', handles.p.circlesize);
            text(handles.v.CurrentRightMiddleLegX(FrameNumber)+handles.p.cut.left + 5, handles.v.CurrentRightMiddleLegY(FrameNumber)+handles.p.cut.up - 5,'RM','Interpreter','none', 'Color','g','FontSize', 8);
            
            while i ~= -1
                % exit if next footprint is already on otherwise go till
                % the end of the set of frames
                if length(handles.p.FileList) > i
                    if length(handles.v.CurrentRightMiddleLegX) > i
                        if handles.v.CurrentRightMiddleLegX(i+1) > 0
                            i = -1;
                        else
                            % Set data to specified
                            handles.v.CurrentRightMiddleLegX(i) = x - handles.p.cut.left + 1;
                            handles.v.CurrentRightMiddleLegY(i) = y - handles.p.cut.up   + 1;
                            i = i + 1;
                        end;
                    else
                        % Set data to specified
                        handles.v.CurrentRightMiddleLegX(i) = x - handles.p.cut.left + 1;
                        handles.v.CurrentRightMiddleLegY(i) = y - handles.p.cut.up   + 1;
                        i = -1;
                    end;
                else
                    % Set data to specified
                    handles.v.CurrentRightMiddleLegX(i) = x - handles.p.cut.left + 1;
                    handles.v.CurrentRightMiddleLegY(i) = y - handles.p.cut.up   + 1;
                    i = -1;
                end
            end;
        end
            
        
    else
        % overplot existing leg
        if length(handles.v.CurrentRightMiddleLegX) >= FrameNumber       
            if handles.v.CurrentRightMiddleLegX(FrameNumber) > 0
               plot(handles.v.CurrentRightMiddleLegX(FrameNumber)+handles.p.cut.left-1,handles.v.CurrentRightMiddleLegY(FrameNumber)+handles.p.cut.up-1,'ro', 'MarkerSize', handles.p.circlesize);
               text(handles.v.CurrentRightMiddleLegX(FrameNumber)+handles.p.cut.left + 5, handles.v.CurrentRightMiddleLegY(FrameNumber)+handles.p.cut.up - 5,'RM','Interpreter','none', 'Color','r','FontSize', 8);
            end
        end
        % Turn footprint off till as long as the current footprint is
        % placed.
        i = FrameNumber;
        while i ~= -1
            if length(handles.v.CurrentRightMiddleLegX) >= i
                % exit if current footprint is off
                if handles.v.CurrentRightMiddleLegX(i) == -1
                    i = -1;
                else
                    % Erase data
                    handles.v.CurrentRightMiddleLegX(i) = -1;
                    handles.v.CurrentRightMiddleLegY(i) = -1;
                    i = i + 1;
                end;
            else
                i = -1;                
            end;
        end;
    end;
end

% LB ----------------------------------------------------------------------
if strcmp(Leg,'LB')
    % retrieve new button position after toggle
    handles.LB_togglebuttonStatus = get(handles.LB_togglebutton,'Value');
    if handles.LB_togglebuttonStatus == 1
        % let user place footprint manually
        [x,y] = myginput(1,'crosshair');
        % Save footprint for the points after the placement which are
        % before the next placement of the same footprint. Do this only if
        % the placement is inside the image area, otherwise don't place.
        if x <= 0 | x >= handles.v.picsize(2) | y <= 0 | y >= handles.v.picsize(1)
            set(handles.LB_togglebutton,'Value',0);
        else
            % Place footprint where the user placed it for all the frames
            % until 1 before the next placement of the same foot.
            i = FrameNumber;
            % Set data to specified
            handles.v.CurrentLeftBackLegX(FrameNumber) = x - handles.p.cut.left + 1;
            handles.v.CurrentLeftBackLegY(FrameNumber) = y - handles.p.cut.up   + 1;
            plot(handles.v.CurrentLeftBackLegX(FrameNumber)+handles.p.cut.left-1,handles.v.CurrentLeftBackLegY(FrameNumber)+handles.p.cut.up-1,'go', 'MarkerSize', handles.p.circlesize);
            text(handles.v.CurrentLeftBackLegX(FrameNumber)+handles.p.cut.left + 5, handles.v.CurrentLeftBackLegY(FrameNumber)+handles.p.cut.up - 5,'LH','Interpreter','none', 'Color','g','FontSize', 8);
            
            while i ~= -1
                % exit if next footprint is already on otherwise go till
                % the end of the set of frames
                if length(handles.p.FileList) > i
                    if length(handles.v.CurrentLeftBackLegX) > i
                        if handles.v.CurrentLeftBackLegX(i+1) > 0
                            i = -1;
                        else
                            % Set data to specified
                            handles.v.CurrentLeftBackLegX(i) = x - handles.p.cut.left + 1;
                            handles.v.CurrentLeftBackLegY(i) = y - handles.p.cut.up   + 1;
                            i = i + 1;
                        end;
                    else
                        % Set data to specified
                        handles.v.CurrentLeftBackLegX(i) = x - handles.p.cut.left + 1;
                        handles.v.CurrentLeftBackLegY(i) = y - handles.p.cut.up   + 1;
                        i = -1;
                    end;
                else
                    % Set data to specified
                    handles.v.CurrentLeftBackLegX(i) = x - handles.p.cut.left + 1;
                    handles.v.CurrentLeftBackLegY(i) = y - handles.p.cut.up   + 1;
                    i = -1;
                end
            end;
        end
            
        
    else
        % overplot existing leg
        if length(handles.v.CurrentLeftBackLegX) >= FrameNumber       
            if handles.v.CurrentLeftBackLegX(FrameNumber) > 0
               plot(handles.v.CurrentLeftBackLegX(FrameNumber)+handles.p.cut.left-1,handles.v.CurrentLeftBackLegY(FrameNumber)+handles.p.cut.up-1,'ro', 'MarkerSize', handles.p.circlesize);
               text(handles.v.CurrentLeftBackLegX(FrameNumber)+handles.p.cut.left + 5, handles.v.CurrentLeftBackLegY(FrameNumber)+handles.p.cut.up - 5,'LH','Interpreter','none', 'Color','r','FontSize', 8);
            end
        end
        % Turn footprint off till as long as the current footprint is
        % placed.
        i = FrameNumber;
        while i ~= -1
            if length(handles.v.CurrentLeftBackLegX) >= i
                % exit if current footprint is off
                if handles.v.CurrentLeftBackLegX(i) == -1
                    i = -1;
                else
                    % Erase data
                    handles.v.CurrentLeftBackLegX(i) = -1;
                    handles.v.CurrentLeftBackLegY(i) = -1;
                    i = i + 1;
                end;
            else
                i = -1;                
            end;
        end;
    end;
end

% RB ----------------------------------------------------------------------
if strcmp(Leg,'RB')
    % retrieve new button position after toggle
    handles.RB_togglebuttonStatus = get(handles.RB_togglebutton,'Value');
    if handles.RB_togglebuttonStatus == 1
        % let user place footprint manually
        [x,y] = myginput(1,'crosshair');
        % Save footprint for the points after the placement which are
        % before the next placement of the same footprint. Do this only if
        % the placement is inside the image area, otherwise don't place.
        if x <= 0 | x >= handles.v.picsize(2) | y <= 0 | y >= handles.v.picsize(1)
            set(handles.RB_togglebutton,'Value',0);
        else
            % Place footprint where the user placed it for all the frames
            % until 1 before the next placement of the same foot.
            i = FrameNumber;
            % Set data to specified
            handles.v.CurrentRightBackLegX(FrameNumber) = x - handles.p.cut.left + 1;
            handles.v.CurrentRightBackLegY(FrameNumber) = y - handles.p.cut.up   + 1;
            plot(handles.v.CurrentRightBackLegX(FrameNumber)+handles.p.cut.left-1,handles.v.CurrentRightBackLegY(FrameNumber)+handles.p.cut.up-1,'go', 'MarkerSize', handles.p.circlesize);
            text(handles.v.CurrentRightBackLegX(FrameNumber)+handles.p.cut.left + 5, handles.v.CurrentRightBackLegY(FrameNumber)+handles.p.cut.up - 5,'RH','Interpreter','none', 'Color','g','FontSize', 8);
            
            while i ~= -1
                % exit if next footprint is already on otherwise go till
                % the end of the set of frames
                if length(handles.p.FileList) > i
                    if length(handles.v.CurrentRightBackLegX) > i
                        if handles.v.CurrentRightBackLegX(i+1) > 0
                            i = -1;
                        else
                            % Set data to specified
                            handles.v.CurrentRightBackLegX(i) = x - handles.p.cut.left + 1;
                            handles.v.CurrentRightBackLegY(i) = y - handles.p.cut.up   + 1;
                            i = i + 1;
                        end;
                    else
                        % Set data to specified
                        handles.v.CurrentRightBackLegX(i) = x - handles.p.cut.left + 1;
                        handles.v.CurrentRightBackLegY(i) = y - handles.p.cut.up   + 1;
                        i = -1;
                    end;
                else
                    % Set data to specified
                    handles.v.CurrentRightBackLegX(i) = x - handles.p.cut.left + 1;
                    handles.v.CurrentRightBackLegY(i) = y - handles.p.cut.up   + 1;
                    i = -1;
                end
            end;
        end
            
        
    else
        % overplot existing leg
        if length(handles.v.CurrentRightBackLegX) >= FrameNumber       
            if handles.v.CurrentRightBackLegX(FrameNumber) > 0
               plot(handles.v.CurrentRightBackLegX(FrameNumber)+handles.p.cut.left-1,handles.v.CurrentRightBackLegY(FrameNumber)+handles.p.cut.up-1,'ro', 'MarkerSize', handles.p.circlesize);
               text(handles.v.CurrentRightBackLegX(FrameNumber)+handles.p.cut.left + 5, handles.v.CurrentRightBackLegY(FrameNumber)+handles.p.cut.up - 5,'RH','Interpreter','none', 'Color','r','FontSize', 8);
            end
        end
        % Turn footprint off till as long as the current footprint is
        % placed.
        i = FrameNumber;
        while i ~= -1
            if length(handles.v.CurrentRightBackLegX) >= i
                % exit if current footprint is off
                if handles.v.CurrentRightBackLegX(i) == -1
                    i = -1;
                else
                    % Erase data
                    handles.v.CurrentRightBackLegX(i) = -1;
                    handles.v.CurrentRightBackLegY(i) = -1;
                    i = i + 1;
                end;
            else
                i = -1;                
            end;
        end;
    end;
end














return;