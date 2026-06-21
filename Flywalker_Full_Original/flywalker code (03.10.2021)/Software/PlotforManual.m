function handles = PlotforManual(handles)


% Obtain FrameNumber and FileList
handles.p.foldername = get(handles.load_edit,'String');


% exit if nothing is loaded
if exist(handles.p.foldername) ~= 7
    return;
end;
try
    temp = handles.v.CurrentLeftFrontLegX;
catch ME
    return;
end


if handles.p.foldername(end) ~= '\' & handles.p.foldername(end) ~= '/' 
  handles.p.foldername = [handles.p.foldername '/'];
end;

FrameNumber  = max(1,str2num(get(handles.frame_edit,'String')));

% set up slider to the right scale   
  set(handles.frame_slider,'Value', FrameNumber);


% Get button and checkbox statuses
handles.LF_togglebuttonStatus = get(handles.LF_togglebutton,'Value');
handles.RF_togglebuttonStatus = get(handles.RF_togglebutton,'Value');
handles.LM_togglebuttonStatus = get(handles.LM_togglebutton,'Value');
handles.RM_togglebuttonStatus = get(handles.RM_togglebutton,'Value');
handles.LB_togglebuttonStatus = get(handles.LB_togglebutton,'Value');
handles.RB_togglebuttonStatus = get(handles.RB_togglebutton,'Value');


%% Set leg togglebuttons according to legs present

if length(handles.v.CurrentLeftFrontLegX) >= FrameNumber

    % LF
    if handles.v.CurrentLeftFrontLegX(FrameNumber) > 0
        set(handles.LF_togglebutton,'Value',1);
    elseif handles.LF_togglebuttonStatus == 1
        set(handles.LF_togglebutton,'Value',0);
    end;
    % RF
    if handles.v.CurrentRightFrontLegX(FrameNumber) > 0
        set(handles.RF_togglebutton,'Value',1);
    elseif handles.RF_togglebuttonStatus == 1
        set(handles.RF_togglebutton,'Value',0);
    end;
    % LM
    if handles.v.CurrentLeftMiddleLegX(FrameNumber) > 0
        set(handles.LM_togglebutton,'Value',1);
    elseif handles.LM_togglebuttonStatus == 1
        set(handles.LM_togglebutton,'Value',0);
    end;
    % RM
    if handles.v.CurrentRightMiddleLegX(FrameNumber) > 0
        set(handles.RM_togglebutton,'Value',1);
    elseif handles.RM_togglebuttonStatus == 1
        set(handles.RM_togglebutton,'Value',0);
    end;
    % LB
    if handles.v.CurrentLeftBackLegX(FrameNumber) > 0
        set(handles.LB_togglebutton,'Value',1);
    elseif handles.LB_togglebuttonStatus == 1
        set(handles.LB_togglebutton,'Value',0);
    end;
    % RB
    if handles.v.CurrentRightBackLegX(FrameNumber) > 0
        set(handles.RB_togglebutton,'Value',1);
    elseif handles.RB_togglebuttonStatus == 1
        set(handles.RB_togglebutton,'Value',0);
    end;

end;



%% read in image

p = handles.p;


% if FrameNumber greater than number of frames, decrease frame number, or
% if it is 0 increase it.
  S = size(p.FileList);
  if FrameNumber > S(1)
    FrameNumber = S(1);
    set(handles.frame_edit,'String',num2str(FrameNumber));
  end;
  if FrameNumber < 1
    FrameNumber = 1;
    set(handles.frame_edit,'String',num2str(FrameNumber));
  end;


[handles.v.pic, handles.v.rawpic, handles.v.nopic] = PictureReader_02(FrameNumber, p);

% Save picture size
handles.v.picsize = size(handles.v.rawpic);

v = handles.v;


% Filter Image
v.pic  = FilterImage(v,p);
% % modify rawpic's brightness in order not to change that part while
% % changing brightness below
% v.rawpic = v.rawpic ./ p.picbrightness;



%% Decide what to plot: original/body_only/foot_only based on p.WhatToPlot
% 1:'original', 2:'fixed scale', 3:'body + feet + tail', 4:'floating
% scale', 5:'body + tail', 6:'body only', 7:'feet only', 8:'tail only',
% 9:'all - no filter'
hold off;
 if p.WhatToPlot == 1
   % original
     PICR = v.rawpic(handles.p.cut.up:end-handles.p.cut.down,handles.p.cut.left:end-handles.p.cut.right,1);
     if length(size(v.rawpic)) == 3
       PICG = v.rawpic(handles.p.cut.up:end-handles.p.cut.down,handles.p.cut.left:end-handles.p.cut.right,2);
       PICB = v.rawpic(handles.p.cut.up:end-handles.p.cut.down,handles.p.cut.left:end-handles.p.cut.right,3);
     else
       PICG = PICR;
       PICB = PICR;
     end;
     PicRGB(:,:,1) = min(256,PICR.*p.picbrightness);
     PicRGB(:,:,2) = min(256,PICG.*p.picbrightness);
     PicRGB(:,:,3) = min(256,PICB.*p.picbrightness);
     % put v.pic onto v.rawpic to see the filtering on the output
       v.rawpic = v.rawpic ./ p.picbrightness;
       v.rawpic(handles.p.cut.up:end-handles.p.cut.down,handles.p.cut.left:end-handles.p.cut.right,1) = PicRGB(:,:,1);
       v.rawpic(handles.p.cut.up:end-handles.p.cut.down,handles.p.cut.left:end-handles.p.cut.right,2) = PicRGB(:,:,2);
       v.rawpic(handles.p.cut.up:end-handles.p.cut.down,handles.p.cut.left:end-handles.p.cut.right,3) = PicRGB(:,:,3);

     image(v.rawpic/256);
 elseif p.WhatToPlot == 2
   % background subtracted
     PIC = v.rawpic(:,:,1);
     PIC(handles.p.cut.up:end-handles.p.cut.down,handles.p.cut.left:end-handles.p.cut.right) = min(v.pic.R*p.picbrightness,255);     
     
      if p.UseBackgroundSubtraction
          %Itbc = Itres(:,:,FrameNumber) v.PIC;
          %mean(Itbc(:))
          %imagesc(min(Itbc*p.picbrightness,255));
          imagesc(PIC);
      else
          imagesc(PIC);
      end
     %imagesc(PIC);
     colormap(p.color);      
 elseif p.WhatToPlot == 3
   % body + feet + tail
     % clear pics of dirt
       v.picbody = v.pic.R;
       v.picbody(v.picbody < p.bodylowerthreshold | v.picbody > p.bodyupperthreshold) = 0;
       v.picfoot = v.pic.R;
       v.picfoot(v.picfoot < p.legthreshold) = 0;
       CleanBodyPIC = CleanPIC(v.picbody, p.MinBodySize);
       CleanFootPIC = v.picfoot;
     % combined pic - 0-125: body+tail; 126-255: feet
       v.pic.combined = min(125,CleanBodyPIC*p.picbrightness);
       % add feet when they are not zero
         ind = find(CleanFootPIC > 0);
         v.pic.combined(ind) = CleanFootPIC(ind)+127;
       % put v.pic onto v.rawpic to see the filtering on the output
         PIC = v.rawpic(:,:,1);
         PIC(handles.p.cut.up:end-handles.p.cut.down,handles.p.cut.left:end-handles.p.cut.right) = v.pic.combined;
      imagesc(PIC, [0 255]);
%      image(v.picfoot);
     colormap(p.color);      
 elseif p.WhatToPlot == 4
   % feet
     % clear pics of dirt
       v.picfoot = v.pic.R;
       v.picfoot(v.picfoot < p.legthreshold) = 0;
       CleanFootPIC = v.picfoot;
     imagesc(v.picfoot, [0 255]);
%      image(v.picfoot);
     colormap(p.color);      
 end;   
hold on;
axis off;

% %% Decide on image and colormap
%     hold off;
%     if p.color == 1
%         image(v.rawpic.*p.picbrightness);
%     else
%         colormap(p.color), image(v.rawpic.*p.picbrightness);
%     end;
%     if p.Colorbar == 1
%         colorbar;
%         set(gca, 'Units', 'normalized', 'Position', [0 0 0.9 1])
%     else
%         colorbar('off');
%         set(gca, 'Units', 'normalized', 'Position', [0 0 1 1])
%     end;
%     axis off;
%     hold on;

%% Draw length bar
if p.lengthbar == 1
    SizePic = size(v.rawpic);

    % Change the position of the distance bar
    X = 0; % CESAR: you only need to change THIS
    Y = 0;  % CESAR: and this too

    P1 = patch([1 1 -1 -1].*p.distcal*1000/2-119+SizePic(2)-1+X,[30 33 33 30]-Y,'w');
    % P2 = patch([0 0 -2 -2]+p.distcal/2-119+SizePic(2)-1,[28 35 35 28],'w');
    plot( [1 1].*p.distcal*1000/2-119+SizePic(2)-1+1+X,[28 35]-Y,'Color',[1 1 0.9], 'LineWidth', 2)
    plot(-[1 1].*p.distcal*1000/2-119+SizePic(2)-1+1+X,[28 35]-Y,'Color',[1 1 0.9], 'LineWidth', 2)
    % set(P1,'LineColor', 'w');
    % P = patch([1 1 -1 -1].*p.distcal/2-119+SizePic(2)-1,[30 33 33 30],'w');

    text(-109+SizePic(2)-1-27+X, 40-Y,'1 mm', 'Color',[0.8 0.8 0.8],'FontSize', 10);
        
end;

% RICARDO 
% COMMENTS
% positions = handles.dlPositions;
% cp = positions(FrameNumber,:);
% plot([cp(4) cp(6)], [cp(5) cp(7)],'y-','LineWidth',1.1);
% plot([cp(6) cp(8)], [cp(7) cp(9)],'y-','LineWidth',1.1);
% plot([cp(8) cp(10)], [cp(9) cp(11)],'y-','LineWidth',1.1);
% plot([cp(10) cp(4)], [cp(11) cp(5)],'y-','LineWidth',1.1);
% 

% dlPositionsFilenameNew = [handles.p.outputfolder '/dl_positions_new.txt']; 
% load(dlPositionsFilenameNew);
% cp = dl_positions_new(FrameNumber,:);
% plot([cp(4) cp(6)], [cp(5) cp(7)],'m-','LineWidth',1.1);
% plot([cp(6) cp(8)], [cp(7) cp(9)],'m-','LineWidth',1.1);
% plot([cp(8) cp(10)], [cp(9) cp(11)],'m-','LineWidth',1.1);
% plot([cp(10) cp(4)], [cp(11) cp(5)],'m-','LineWidth',1.1);


%% plot ellipse for body

if length(v.CurrentBodyStdX) >= FrameNumber
if handles.p.ellipse == 1
  picsize = size(v.pic);
        a = v.CurrentBodyStdY(FrameNumber);  % semimajor axis
        b = v.CurrentBodyStdX(FrameNumber); % semiminor axis
        ae = sqrt(a^2 - b^2);
        if v.CurrentBodyOrientation(FrameNumber) ~= 0
          % calculate ellipse
            % calculate angle of ellipse
             if(v.CurrentBodyDirection1(FrameNumber) > -1 & v.CurrentBodyDirection1(FrameNumber) < 1)
                angle = -atan(v.CurrentBodyDirection1(FrameNumber))*180/pi;
             else 
                 angle = -atan(v.CurrentBodyDirection1(FrameNumber))*180/pi;
             end
% RICARDO COMMENTED THIS            
%               if v.CurrentBodyDirection3(FrameNumber) == 1
%                   angle = -atan(v.CurrentBodyDirection1(FrameNumber))*180/pi;
%               else
%                   angle = atan(v.CurrentBodyDirection1(FrameNumber))*180/pi;
%               end;
              
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              % Alexandre -> if ~isfield(...)||sum(...)==0
%               if ~isfield(handles, 'TC') || sum(find(handles.TC.frame==FrameNumber))==0
              [X Y] = calculateEllipse(v.CurrentBodyX(FrameNumber), v.CurrentBodyY(FrameNumber), a, b, angle, 50);
%               else
%                 % use old center to plot ellipse if there's already a TC 
%                 index = find(handles.TC.frame==FrameNumber,1,'first'); 
%                 [X Y] = calculateEllipse(handles.TC.old(index,1), handles.TC.coord(index,2), a, b, angle, 50);
%               end
              plot(X+p.cut.left-1,Y+p.cut.up-1,'c--', 'LineWidth', 1);
        end;
end;
end;


% image(v.rawpic);
axis off;
box on;



%% plot leg tracks
if length(v.CurrentLeftFrontLegX) >= FrameNumber
    % plot previous legs if set
    if p.show_past_footprints == 1 | (p.show_past_footprints == 2 & FrameNumber == length(handles.p.FileList))
        PASTCOLOR = [159;182;205]/255;
        % LF
        ind = find(v.CurrentLeftFrontLegX(1:FrameNumber-1) > 0);
        plot(v.CurrentLeftFrontLegX(ind)+p.cut.left-1,v.CurrentLeftFrontLegY(ind)+p.cut.up-1,'o', 'Color', PASTCOLOR, 'MarkerSize', handles.p.circlesize);
        plot(v.CurrentLeftFrontLegX(ind)+p.cut.left-1,v.CurrentLeftFrontLegY(ind)+p.cut.up-1,'.', 'Color', PASTCOLOR, 'MarkerSize', 1);
        text(v.CurrentLeftFrontLegX(ind)+p.cut.left + 5, v.CurrentLeftFrontLegY(ind)+p.cut.up - 5,'LF','Interpreter','none', 'Color',PASTCOLOR,'FontSize', 8);
        % RF
        ind = find(v.CurrentRightFrontLegX(1:FrameNumber-1) > 0);
        plot(v.CurrentRightFrontLegX(ind)+p.cut.left-1,v.CurrentRightFrontLegY(ind)+p.cut.up-1,'o', 'Color', PASTCOLOR, 'MarkerSize', handles.p.circlesize);
        plot(v.CurrentRightFrontLegX(ind)+p.cut.left-1,v.CurrentRightFrontLegY(ind)+p.cut.up-1,'.', 'Color', PASTCOLOR, 'MarkerSize', 1);
        text(v.CurrentRightFrontLegX(ind)+p.cut.left + 5, v.CurrentRightFrontLegY(ind)+p.cut.up - 5,'RF','Interpreter','none', 'Color',PASTCOLOR,'FontSize', 8);
        % LM
        ind = find(v.CurrentLeftMiddleLegX(1:FrameNumber-1) > 0);
        plot(v.CurrentLeftMiddleLegX(ind)+p.cut.left-1,v.CurrentLeftMiddleLegY(ind)+p.cut.up-1,'o', 'Color', PASTCOLOR, 'MarkerSize', handles.p.circlesize);
        plot(v.CurrentLeftMiddleLegX(ind)+p.cut.left-1,v.CurrentLeftMiddleLegY(ind)+p.cut.up-1,'.', 'Color', PASTCOLOR, 'MarkerSize', 1);
        text(v.CurrentLeftMiddleLegX(ind)+p.cut.left + 5, v.CurrentLeftMiddleLegY(ind)+p.cut.up - 5,'LM','Interpreter','none', 'Color',PASTCOLOR,'FontSize', 8);
        % RM
        ind = find(v.CurrentRightMiddleLegX(1:FrameNumber-1) > 0);
        plot(v.CurrentRightMiddleLegX(ind)+p.cut.left-1,v.CurrentRightMiddleLegY(ind)+p.cut.up-1,'o', 'Color', PASTCOLOR, 'MarkerSize', handles.p.circlesize);
        plot(v.CurrentRightMiddleLegX(ind)+p.cut.left-1,v.CurrentRightMiddleLegY(ind)+p.cut.up-1,'.', 'Color', PASTCOLOR, 'MarkerSize', 1);
        text(v.CurrentRightMiddleLegX(ind)+p.cut.left + 5, v.CurrentRightMiddleLegY(ind)+p.cut.up - 5,'RM','Interpreter','none', 'Color',PASTCOLOR,'FontSize', 8);
        % LB
        ind = find(v.CurrentLeftBackLegX(1:FrameNumber-1) > 0);
        plot(v.CurrentLeftBackLegX(ind)+p.cut.left-1,v.CurrentLeftBackLegY(ind)+p.cut.up-1,'o', 'Color', PASTCOLOR, 'MarkerSize', handles.p.circlesize);
        plot(v.CurrentLeftBackLegX(ind)+p.cut.left-1,v.CurrentLeftBackLegY(ind)+p.cut.up-1,'.', 'Color', PASTCOLOR, 'MarkerSize', 1);
        text(v.CurrentLeftBackLegX(ind)+p.cut.left + 5, v.CurrentLeftBackLegY(ind)+p.cut.up - 5,'LH','Interpreter','none', 'Color',PASTCOLOR,'FontSize', 8);
        % RB
        ind = find(v.CurrentRightBackLegX(1:FrameNumber-1) > 0);
        plot(v.CurrentRightBackLegX(ind)+p.cut.left-1,v.CurrentRightBackLegY(ind)+p.cut.up-1,'o', 'Color', PASTCOLOR, 'MarkerSize', handles.p.circlesize);
        plot(v.CurrentRightBackLegX(ind)+p.cut.left-1,v.CurrentRightBackLegY(ind)+p.cut.up-1,'.', 'Color', PASTCOLOR, 'MarkerSize', 1);
        text(v.CurrentRightBackLegX(ind)+p.cut.left + 5, v.CurrentRightBackLegY(ind)+p.cut.up - 5,'RH','Interpreter','none', 'Color',PASTCOLOR,'FontSize', 8);
    end;
    % plot current legs
    CURRENTCOLORFront  = [255;255;0]/255;
    CURRENTCOLORMiddle = [3;180;200]/255;
    CURRENTCOLORBack   = [9;249;17]/255;
    % LF
    if v.CurrentLeftFrontLegX(FrameNumber) > 0
        plot(v.CurrentLeftFrontLegX(FrameNumber)+p.cut.left-1,v.CurrentLeftFrontLegY(FrameNumber)+p.cut.up-1,'o', 'Color', CURRENTCOLORFront, 'MarkerSize', handles.p.circlesize);
        text(v.CurrentLeftFrontLegX(FrameNumber)+p.cut.left + 5, v.CurrentLeftFrontLegY(FrameNumber)+p.cut.up - 5,'LF','Interpreter','none', 'Color', CURRENTCOLORFront,'FontSize', 8);
    end
    % RF
    if v.CurrentRightFrontLegX(FrameNumber) > 0
        plot(v.CurrentRightFrontLegX(FrameNumber)+p.cut.left-1,v.CurrentRightFrontLegY(FrameNumber)+p.cut.up-1,'o', 'Color', CURRENTCOLORFront, 'MarkerSize', handles.p.circlesize);
        text(v.CurrentRightFrontLegX(FrameNumber)+p.cut.left + 5, v.CurrentRightFrontLegY(FrameNumber)+p.cut.up - 5,'RF','Interpreter','none', 'Color', CURRENTCOLORFront,'FontSize', 8);
    end
    % LM
    if v.CurrentLeftMiddleLegX(FrameNumber) > 0
        plot(v.CurrentLeftMiddleLegX(FrameNumber)+p.cut.left-1,v.CurrentLeftMiddleLegY(FrameNumber)+p.cut.up-1,'o', 'Color', CURRENTCOLORMiddle, 'MarkerSize', handles.p.circlesize);
        text(v.CurrentLeftMiddleLegX(FrameNumber)+p.cut.left + 5, v.CurrentLeftMiddleLegY(FrameNumber)+p.cut.up - 5,'LM','Interpreter','none', 'Color', CURRENTCOLORMiddle,'FontSize', 8);
    end
    % RM
    if v.CurrentRightMiddleLegX(FrameNumber) > 0
        plot(v.CurrentRightMiddleLegX(FrameNumber)+p.cut.left-1,v.CurrentRightMiddleLegY(FrameNumber)+p.cut.up-1,'o', 'Color', CURRENTCOLORMiddle, 'MarkerSize', handles.p.circlesize);
        text(v.CurrentRightMiddleLegX(FrameNumber)+p.cut.left + 5, v.CurrentRightMiddleLegY(FrameNumber)+p.cut.up - 5,'RM','Interpreter','none', 'Color', CURRENTCOLORMiddle,'FontSize', 8);
    end
    % LB
    if v.CurrentLeftBackLegX(FrameNumber) > 0
        plot(v.CurrentLeftBackLegX(FrameNumber)+p.cut.left-1,v.CurrentLeftBackLegY(FrameNumber)+p.cut.up-1,'o', 'Color', CURRENTCOLORBack, 'MarkerSize', handles.p.circlesize);
        text(v.CurrentLeftBackLegX(FrameNumber)+p.cut.left + 5, v.CurrentLeftBackLegY(FrameNumber)+p.cut.up - 5,'LH','Interpreter','none', 'Color', CURRENTCOLORBack,'FontSize', 8);
    end
    % RB
    if v.CurrentRightBackLegX(FrameNumber) > 0
        plot(v.CurrentRightBackLegX(FrameNumber)+p.cut.left-1,v.CurrentRightBackLegY(FrameNumber)+p.cut.up-1,'o', 'Color', CURRENTCOLORBack, 'MarkerSize', handles.p.circlesize);
        text(v.CurrentRightBackLegX(FrameNumber)+p.cut.left + 5, v.CurrentRightBackLegY(FrameNumber)+p.cut.up - 5,'RH','Interpreter','none', 'Color', CURRENTCOLORBack,'FontSize', 8);
    end
end;


%% plot body tracks
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre 
 
% change body coordinates if there's a TC for the current frame. "Old"
% center coordinates are stored in handles.TC.old
% if isfield(handles, 'TC') && sum(find(handles.TC.frame==FrameNumber))>0
%     index = find(handles.TC.frame==FrameNumber,1,'last');
%     handles.v.CurrentBodyX(FrameNumber) = handles.TC.coord(index,1);
%     handles.v.CurrentBodyY(FrameNumber) = handles.TC.coord(index,2);
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if length(v.CurrentBodyX) >= FrameNumber
    if v.CurrentBodyX(FrameNumber) > 0

        % plot center of body and body track
        if handles.p.drawbodytrack == 1
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Alexandre
                %  && isfield(handles.v, 'TC_x') && isfield(handles.v, 'TC_y')
                if p.CenterFromFront == 1
                    plot(v.TC_x(v.TC_x(1:FrameNumber) > 0)+p.cut.left,v.TC_y(v.TC_x(1:FrameNumber) > 0)+p.cut.up,'c');
                else
            plot(v.CurrentBodyX(v.CurrentBodyX(1:FrameNumber) > 0)+p.cut.left,v.CurrentBodyY(v.CurrentBodyX(1:FrameNumber) > 0)+p.cut.up,'c');           
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 elseif sum(find(handles.TC.frame==FrameNumber))==0 && sum(ismember(1:FrameNumber,handles.TC.frame))==0
%                     disp('elseif')
%                     handles.TC.vector=[handles.TC.vector;(v.CurrentBodyX(v.CurrentBodyX(1:FrameNumber) > 0)+p.cut.left)',(v.CurrentBodyY(v.CurrentBodyX(1:FrameNumber) > 0)+p.cut.up)'];
%                     plot(v.CurrentBodyX(v.CurrentBodyX(1:FrameNumber) > 0)+p.cut.left,v.CurrentBodyY(v.CurrentBodyX(1:FrameNumber) > 0)+p.cut.up,'c');           
%                 elseif sum(find(handles.TC.frame==FrameNumber))==1
%                     disp('elseif_2')
%                     index = find(handles.TC.frame==FrameNumber,1,'last');
%                     handles.TC.vector=[handles.TC.vector;handles.TC.coord(index,1),handles.TC.coord(index,2)];
% %                     plot([v.CurrentBodyX(v.CurrentBodyX(1:FrameNumber-1) > 0),handles.TC.coord(index,1)]+p.cut.left,[v.CurrentBodyY(v.CurrentBodyX(1:FrameNumber-1) > 0),handles.TC.coord(index,2)]+p.cut.up,'c');           
%                     disp(handles.TC.vector)
%                     plot(handles.TC.vector(:,1)+p.cut.left,handles.TC.vector(:,2)+p.cut.up,'c'); 
%                 else
%                     if sum(ismember(1:FrameNumber,handles.TC.frame))>0
%                     disp('elseif')
%                     disp(handles.TC.vector)
%                     plot(handles.TC.vector(:,1),handles.TC.vector(:,2))
%                     plot(handles.TC.vector(handles.TC.vector(1:FrameNumber-1,1)>0),handles.TC.vector(handles.TC.vector(1:FrameNumber-1,2)>0))
%                 end
        end;
        plot(v.CurrentBodyX(FrameNumber)+p.cut.left-1,v.CurrentBodyY(FrameNumber)+p.cut.up-1,'c');
        disp('')
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Alexandre -> old_cross = plot(...)
        old_cross = plot(v.CurrentBodyX(FrameNumber)+p.cut.left-1,v.CurrentBodyY(FrameNumber)+p.cut.up-1,'cx', 'MarkerSize', handles.p.circlesize, 'LineWidth', 2);
        % plot line representing the direction of the fly in the middle
        % of the fly
              if v.CurrentBodyDirection3(FrameNumber) == 1
                  angle = -atan(v.CurrentBodyDirection1(FrameNumber))*180/pi;
              else
                  % Ricardo commented
                  % angle = atan(v.CurrentBodyDirection1(FrameNumber))*180/pi;
                  angle = -atan(v.CurrentBodyDirection1(FrameNumber))*180/pi;
              end;
              if handles.p.ellipse == 1
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % Alexandre 
                % plot ellipse using old center if there's already a TC
%                 if ~isfield(handles, 'TC') || sum(find(handles.TC.frame==FrameNumber))==0
                [X Y] = calculateEllipse(v.CurrentBodyX(FrameNumber), v.CurrentBodyY(FrameNumber), a, b, angle, 50);
%                 else
%                     index = find(handles.TC.frame==FrameNumber,1,'first'); 
%                     [X Y] = calculateEllipse(handles.TC.old(index,1), handles.TC.coord(index,2), a, b, angle, 50);
%                 end
                   % RICARDO COMMENTED THIS LINE
                   %plot(X+p.cut.left-1,Y+p.cut.up-1,'y--', 'LineWidth', 1);        
              end;
        if v.CurrentBodyDirection3(FrameNumber) == 1
            angle = atan(v.CurrentBodyDirection1(FrameNumber));
            FrontX = handles.v.CurrentBodyX(FrameNumber) + v.CurrentBodyStdY(FrameNumber)*cos(angle);
            FrontY = handles.v.CurrentBodyY(FrameNumber) + v.CurrentBodyStdY(FrameNumber)*sin(angle);
            X = [FrontX 2*handles.v.CurrentBodyX(FrameNumber) - FrontX];
            Y = [FrontY 2*handles.v.CurrentBodyY(FrameNumber) - FrontY];
            plot(X+p.cut.left-1,Y+p.cut.up-1,'y', 'LineWidth', 1.5);
            if v.CurrentBodyOrientation(FrameNumber) == 1
              plot(X(1)+p.cut.left-1,Y(1)+p.cut.up-1,'yd','MarkerSize', 5, 'MarkerFaceColor','y');
            elseif v.CurrentBodyOrientation(FrameNumber) == -1 
                % Ricardo commented
                plot(X(2)+p.cut.left-1,Y(2)+p.cut.up-1,'yd','MarkerSize', 5, 'MarkerFaceColor','y');
            end;
        else
            angle = atan(v.CurrentBodyDirection1(FrameNumber));
            % RICARDO COMMENTED THIS
            %FrontX = handles.v.CurrentBodyX(FrameNumber) + v.CurrentBodyStdX(FrameNumber)*sin(angle);
            %FrontY = handles.v.CurrentBodyY(FrameNumber) + v.CurrentBodyStdX(FrameNumber)*cos(angle);
            FrontX = handles.v.CurrentBodyX(FrameNumber) + v.CurrentBodyStdY(FrameNumber)*cos(angle);
            FrontY = handles.v.CurrentBodyY(FrameNumber) + v.CurrentBodyStdY(FrameNumber)*sin(angle);
            X = [FrontX 2*handles.v.CurrentBodyX(FrameNumber) - FrontX];
            Y = [FrontY 2*handles.v.CurrentBodyY(FrameNumber) - FrontY];
            plot(X+p.cut.left-1,Y+p.cut.up-1,'y');
            if v.CurrentBodyOrientation(FrameNumber) == 1
              plot(X(1)+p.cut.left-1,Y(1)+p.cut.up-1,'yd','MarkerSize', 5, 'MarkerFaceColor','y');
            elseif v.CurrentBodyOrientation(FrameNumber) == -1            
              plot(X(2)+p.cut.left-1,Y(2)+p.cut.up-1,'yd','MarkerSize', 5, 'MarkerFaceColor','y');
            end;
        end;
    end
end

%%  Alexandre - plot true center

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre

% Check if TC exists (button has already been pressed) and if there's
% information regarding the current frame

% && sum(find(handles.TC.frame==FrameNumber))>0
% if isfield(handles, 'TC') && sum(find(handles.TC.frame==FrameNumber))>0
%     % the largest index corresponds to the most recent information
%     index = find(handles.TC.frame==FrameNumber,1,'last');
%     new_cross = plot(handles.TC.coord(index,1)+handles.p.cut.left-1,handles.TC.coord(index,2)+handles.p.cut.up-1,'cx', 'MarkerSize', handles.p.circlesize,'LineWidth', 2);
%     set(old_cross,'Visible','off')
% 
% end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre

% isfield(handles.v, 'TC_x')
% isfield(handles.v, 'TC_y')

if isfield(handles.v, 'TC_x') && isfield(handles.v, 'TC_y') && p.CenterFromFront == 1
    other_cross = plot(handles.v.TC_x(FrameNumber)+handles.p.cut.left-1,handles.v.TC_y(FrameNumber)+handles.p.cut.up-1,'cx', 'MarkerSize', handles.p.circlesize,'LineWidth', 2);
    if exist('old_cross','var')
        set(old_cross,'Visible','off')
    end
    if exist('new_cross','var')
        set(other_cross,'Visible','off')
    end
end
% 
% disp('início')
% xis = handles.v.TC_x(FrameNumber)
% xis_antigo = handles.v.CurrentBodyX(FrameNumber)
% upsilon = handles.v.TC_y(FrameNumber)
% upsilon_antigo = handles.v.CurrentBodyY(FrameNumber)
% 
% handles.v.CurrentBodyX(FrameNumber)
% handles.v.CurrentBodyY(FrameNumber)
% disp('fim')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

return;
 

%% ========================================================================

function [d, x0, y0]  = point_to_line(x1,y1,m,b)
% calculate distance between line y=mx+b and point (x1,y1).
% d        - distance
% (x0,y0)  - coordinates of the closest point on the line to the point

    x0 = (m*y1 + x1 - m*b)   / (m^2 + 1);
    y0 = (m^2*y1 + m*x1 + b) / (m^2 + 1);
    d = abs(y1 - m*x1 - b)   / sqrt(m^2+1);

return;

function [X Y] = calculateEllipse(x, y, a, b, angle, steps)
% from http://stackoverflow.com/questions/2153768/draw-ellipse-and-ellipsoid-in-matlab  
    %# This functions returns points to draw an ellipse
    %#
    %#  @param x     X coordinate
    %#  @param y     Y coordinate
    %#  @param a     Semimajor axis
    %#  @param b     Semiminor axis
    %#  @param angle Angle of the ellipse (in degrees)
    %#

    error(nargchk(5, 6, nargin));
    if nargin<6, steps = 36; end

    beta = -angle * (pi / 180);
    sinbeta = sin(beta);
    cosbeta = cos(beta);

    alpha = linspace(0, 360, steps)' .* (pi / 180);
    sinalpha = sin(alpha);
    cosalpha = cos(alpha);

    X = x + (a * cosalpha * cosbeta - b * sinalpha * sinbeta);
    Y = y + (a * cosalpha * sinbeta + b * sinalpha * cosbeta);

    if nargout==1, X = [X Y]; end
return;