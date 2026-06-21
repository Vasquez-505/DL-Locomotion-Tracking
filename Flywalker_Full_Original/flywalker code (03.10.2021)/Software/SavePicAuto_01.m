function v = SavePicAuto_01(p,v)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SAVE ONLY DATA NO PICTURE
%
% saves a picture into a file called v.index in the folder foldername. It
% saves the picture after plotting identified particles' locations on it.
%
% 02/01/10 - stretch figure such that it looks like original
%
% (c) Imre Bartos 2009
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% initialize
CurrentBodyX           = -1;
CurrentBodyY           = -1;
CurrentBodyDirection1  = -1;
CurrentBodyDirection2  = -1;
CurrentBodyDirection3  = -1;
CurrentBodyOrientation = -1;
CurrentBodySize        = -1;
CurrentBodyStdX        = -1;
CurrentBodyStdY        = -1;
CurrentLeftFrontLegX   = -1;
CurrentLeftFrontLegY   = -1; 
CurrentRightFrontLegX  = -1;
CurrentRightFrontLegY  = -1;
CurrentLeftMiddleLegX  = -1;
CurrentLeftMiddleLegY  = -1;
CurrentRightMiddleLegX = -1;
CurrentRightMiddleLegY = -1;
CurrentLeftBackLegX    = -1;
CurrentLeftBackLegY    = -1;  
CurrentRightBackLegX   = -1; 
CurrentRightBackLegY   = -1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre
TC_x                   = -1;
TC_y                   = -1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% save picture only if there were detected moving particles
temp = size(v.Leg);
Detected = temp(1);

% put v.pic onto v.rawpic to see the filtering on the output
% v.rawpic(p.cut.up:end-p.cut.down,p.cut.left:end-p.cut.right) = v.pic;

%% save picture
if 1%Detected > 0
%     W = length(v.rawpic(:,1,1));
%     H = length(v.rawpic(1,:,1));
%     h = figure('visible','off','PaperPositionMode', 'manual', 'PaperUnits', 'points', 'PaperPosition', [0 0 H W]);
    % Draw picture itself
%     image(v.rawpic*5);
    % Draw inverted picture
%     picavg = median(median(v.rawpic(:,:,1)));
%     ind  = find(v.rawpic >  p.legthreshold + picavg);
%     ind2 = find(v.rawpic > p.bodylowerthreshold + picavg);
%     v.rawpic(:) = 0;
%     v.rawpic(ind2) = 15;
%     v.rawpic(ind) = 255;
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
% if p.lengthbar == 1
%     SizePic = size(v.rawpic);
% 
%     % Change the position of the distance bar
%     X = 0; % CESAR: you only need to change THIS
%     Y = 0;  % CESAR: and this too
% 
%     P1 = patch([1 1 -1 -1]./p.distcal/2-119+SizePic(2)-1+X,[30 33 33 30]-Y,'w');
%     % P2 = patch([0 0 -2 -2]+p.distcal/2-119+SizePic(2)-1,[28 35 35 28],'w');
%     plot( [1 1]./p.distcal/2-119+SizePic(2)-1+1+X,[28 35]-Y,'Color',[1 1 0.9], 'LineWidth', 2)
%     plot(-[1 1]./p.distcal/2-119+SizePic(2)-1+1+X,[28 35]-Y,'Color',[1 1 0.9], 'LineWidth', 2)
%     % set(P1,'LineColor', 'w');
%     % P = patch([1 1 -1 -1].*p.distcal/2-119+SizePic(2)-1,[30 33 33 30],'w');
% 
%     text(-119+SizePic(2)-1-27+X, 42-Y,'1000 \mum', 'Color',[0.8 0.8 0.8],'FontSize', 10);
% end;
%% plot ellipse for body
% if p.ellipse == 1
%   s = size(v.bodyx);
%   picsize = size(v.pic);
%   % plot tracks only that are nonzero long.
%   for i = 1:s(1)
%       if v.bodytrack(i) >= 1
%         CurrentBodyX = v.bodyx(i,v.bodytrack(i));
%         CurrentBodyY = v.bodyy(i,v.bodytrack(i));
% 
%         a = v.bodystdPar(i,v.bodytrack(i));  % semimajor axis
%         b = v.bodystdPerp(i,v.bodytrack(i)); % semiminor axis
%         ae = sqrt(a^2 - b^2);
%        
%         if v.Orientation(i,v.bodytrack(i)) ~= 0
%             for j = max(1,- round(a)+CurrentBodyX):min(round(a)+CurrentBodyX,picsize(2))
%                 for k = max(1,- round(a)+CurrentBodyY):min(round(a)+CurrentBodyY,picsize(1))
%                     % calculate perp and par distances from center
%                     % calculate perpenicular and parallel distances from
%                     % center. Parallel refers to the orientation of the fly
%                     if v.BodyDirection3(i,v.bodytrack(i)) == 1
%                         [d, x0, y0]  = point_to_line(j,k,v.BodyDirection1(i,v.bodytrack(i)),v.BodyDirection2(i,v.bodytrack(i)));
%                     else
%                         [d, y0, x0]  = point_to_line(k,j,v.BodyDirection1(i,v.bodytrack(i)),v.BodyDirection2(i,v.bodytrack(i)));
%                     end;
%                     PerpDist = d;
%                     ParDist = sqrt((y0 - v.bodyy(i,v.bodytrack(i)))^2 + (x0 - v.bodyx(i,v.bodytrack(i)))^2);
%                     % added distances from the two focus points
%                     D1 = sqrt((ParDist - ae)^2 + PerpDist^2);
%                     D2 = sqrt((ParDist + ae)^2 + PerpDist^2);
%                     D = D1 + D2;
%                     if abs(D - 2*a) < 0.5
%                         plot(j+p.cut.left-1,k+p.cut.up-1,'y');
%                     end;
%                 end;
%             end;
%         end;
%       end;
%   end;
% end;
  %% plot leg tracks
    s = size(v.legx);
    % plot tracks only that are longer than two. Plot active tracks with
    % different colors

    for i = 1:s(1)
        if v.legtrack(i) > 0
          if v.legtiming(i) > 1
              if v.legtiming(i) < 200000
%                 plot(v.legx(i,1:v.legtrack(i))+p.cut.left,v.legy(i,1:v.legtrack(i))+p.cut.up,'g');
%                 plot(v.legx(i,1:v.legtrack(i))+p.cut.left,v.legy(i,1:v.legtrack(i))+p.cut.up,'go');
                % plot side and position
                if length(v.Side(1,:)) >= i
                    ind = find(v.Side(:,i) ~= 0);
                    if ~isempty(ind)
                        ind = ind(1);
                        % side
                        if v.Side(ind,i) == 1
                            Text = 'L';
                        elseif  v.Side(ind,i) == -1 
                            Text = 'R';
                        else
                            Text = '';
                        end;
                        % position
                        temp = size(v.LegPosition);
                        if temp(1)*temp(2) >= ind*i
                            if v.LegPosition(ind,i) == 1
                                Text = [Text, 'F'];
                            elseif v.LegPosition(ind,i) == 2
                                Text = [Text, 'M'];                        
                            elseif v.LegPosition(ind,i) == 3
                                Text = [Text, 'B'];                        
                            else
                                Text = [Text];        
                            end
                        else
                            disp('legposition not defined')
                        end
%                         text(v.legx(i,v.legtrack(i))+p.cut.left + 5, v.legy(i,v.legtrack(i))+p.cut.up - 5,Text,'Interpreter','none', 'Color','g','FontSize', 8);
                    end;                  
                end;
              end;
          else
%             plot(v.legx(i,1:v.legtrack(i))+p.cut.left,v.legy(i,1:v.legtrack(i))+p.cut.up,'r');
%             plot(v.legx(i,v.legtrack(i))+p.cut.left,v.legy(i,v.legtrack(i))+p.cut.up,'ro');
            % plot left or right and fly number
            if length(v.Side(1,:)) >= i
                ind = find(v.Side(:,i) ~= 0);
                if ~isempty(ind)
                    ind = ind(1);
                    % side
                    if v.Side(ind,i) == 1
                         Text = 'L';
                    elseif  v.Side(ind,i) == -1 
                        Text = 'R';
                    else
                        Text = '';
                    end;
                    % position
                    temp = size(v.LegPosition);
                    if temp(1)*temp(2) >= ind*i
                        if v.LegPosition(ind,i) == 1
                            Text = [Text, 'F'];
                            % save current leg position in separate variable
                            if v.Side(ind,i) == 1
                                CurrentLeftFrontLegX = v.legx(i,v.legtrack(i));
                                CurrentLeftFrontLegY = v.legy(i,v.legtrack(i));
                            end;
                            if v.Side(ind,i) == -1
                                CurrentRightFrontLegX = v.legx(i,v.legtrack(i));
                                CurrentRightFrontLegY = v.legy(i,v.legtrack(i));
                            end;
                        elseif v.LegPosition(ind,i) == 2
                            Text = [Text, 'M'];                        
                            % save current leg position in separate variable
                            if v.Side(ind,i) == 1
                                CurrentLeftMiddleLegX = v.legx(i,v.legtrack(i));
                                CurrentLeftMiddleLegY = v.legy(i,v.legtrack(i));
                            end;
                            if v.Side(ind,i) == -1
                                CurrentRightMiddleLegX = v.legx(i,v.legtrack(i));
                                CurrentRightMiddleLegY = v.legy(i,v.legtrack(i));
                            end;
                        elseif v.LegPosition(ind,i) == 3
                            Text = [Text, 'B'];
                            % save current leg position in separate variable
                            if v.Side(ind,i) == 1
                                CurrentLeftBackLegX = v.legx(i,v.legtrack(i));
                                CurrentLeftBackLegY = v.legy(i,v.legtrack(i));
                            end;
                            if v.Side(ind,i) == -1
                                CurrentRightBackLegX = v.legx(i,v.legtrack(i));
                                CurrentRightBackLegY = v.legy(i,v.legtrack(i));
                            end;
                        else
                            Text = [Text];        
                        end
                    end
                    % plot legs only if they are complete - all information
                    % is found for them
%                     if v.LegPosition(ind,i) == 1 | v.LegPosition(ind,i) == 2 | v.LegPosition(ind,i) == 3
%                         plot(v.legx(i,v.legtrack(i))+p.cut.left-1,v.legy(i,v.legtrack(i))+p.cut.up-1,'go');
%                         text(v.legx(i,v.legtrack(i))+p.cut.left + 5, v.legy(i,v.legtrack(i))+p.cut.up - 5,Text,'Interpreter','none', 'Color','g','FontSize', 8);
%                     end;
                end;                  
            end;
          end;     
        end
    end;
    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot Body tracks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    s = size(v.bodyx);
    % plot tracks only that are nonzero. Plot active tracks with
    % different colors
    for i = 1:s(1)
        if v.bodytrack(i) >= 1
          if v.bodytiming(i) < p.maxtimedifferencebody
            % save body position and direction
            CurrentBodyX           = v.bodyx(i,v.bodytrack(i));
            CurrentBodyY           = v.bodyy(i,v.bodytrack(i));
            CurrentBodyDirection1  = v.BodyDirection1(i,v.bodytrack(i));
            CurrentBodyDirection2  = v.BodyDirection2(i,v.bodytrack(i));
            CurrentBodyDirection3  = v.BodyDirection3(i,v.bodytrack(i));
            CurrentBodyOrientation = v.Orientation(i,v.bodytrack(i));
            CurrentBodyStdX        = v.bodystdPerp(i,v.bodytrack(i));
            CurrentBodyStdY        = v.bodystdPar(i,v.bodytrack(i));
            
%             if v.bodytiming(i) > 1
%                 if v.bodytiming(i) < 200000
% %                     plot(v.bodyx(i,1:v.bodytrack(i))+p.cut.left,v.bodyy(i,1:v.bodytrack(i))+p.cut.up,'c');
%                 end;
%             else
%             plot(v.bodyx(i,1:v.bodytrack(i))+p.cut.left,v.bodyy(i,1:v.bodytrack(i))+p.cut.up,'c');
%             plot(v.bodyx(i,v.bodytrack(i))+p.cut.left,v.bodyy(i,v.bodytrack(i))+p.cut.up,'co');
            % plot line representing the direction of the fly in the middle
            % of the fly
            if v.BodyDirection3(i,v.bodytrack(i)) == 1
                X = v.bodyx(i,v.bodytrack(i)) + [-1 1 ]*v.bodystdPar(i,v.bodytrack(i));
                f = polyval([v.BodyDirection1(i,v.bodytrack(i)) v.BodyDirection2(i,v.bodytrack(i))], X);
%                 plot(X+p.cut.left,f+p.cut.up,'y');
            else
                Y = v.bodyy(i,v.bodytrack(i)) + [-1 1 ]*v.bodystdPar(i,v.bodytrack(i));
                f = polyval([v.BodyDirection1(i,v.bodytrack(i)) v.BodyDirection2(i,v.bodytrack(i))], Y);
%                 plot(f+p.cut.left,Y+p.cut.up,'y');
            end;
%% draw a little triangle to the end of the line in the direction in which 
% the fly is going
            if v.BodyDirection3(i,v.bodytrack(i)) == 1
                if(v.Orientation(i,v.bodytrack(i)) == 1)
                    X = [v.bodyx(i,v.bodytrack(i)) + v.bodystdPar(i,v.bodytrack(i))];
                else
                    X = [v.bodyx(i,v.bodytrack(i)) - v.bodystdPar(i,v.bodytrack(i))];                    
                end;
                f = polyval([v.BodyDirection1(i,v.bodytrack(i)) v.BodyDirection2(i,v.bodytrack(i))], X);
%                 plot(X+p.cut.left,f+p.cut.up,'yd','MarkerSize', 5, 'MarkerFaceColor','y');
            else
                if(v.Orientation(i,v.bodytrack(i)) == 1)
                    Y = [v.bodyy(i,v.bodytrack(i)) + v.bodystdPar(i,v.bodytrack(i))];
                else
                    Y = [v.bodyy(i,v.bodytrack(i)) - v.bodystdPar(i,v.bodytrack(i))];                    
                end;
                f = polyval([v.BodyDirection1(i,v.bodytrack(i)) v.BodyDirection2(i,v.bodytrack(i))], Y);
%                 plot(f+p.cut.left,Y+p.cut.up,'y^','MarkerSize', 5, 'MarkerFaceColor','y');
            end;
            % calculate center position if body determination is front
            % based
            if p.CenterFromFront == 1
                if v.BodyDirection3(i,v.bodytrack(i)) == 1
                    if(v.Orientation(i,v.bodytrack(i)) == 1)
                        X = [v.bodyx(i,v.bodytrack(i)) + v.bodystdPar(i,v.bodytrack(i)) - p.CenterFromFrontDist/sqrt(1+v.BodyDirection1(i,v.bodytrack(i))^2)];
                    else
                        X = [v.bodyx(i,v.bodytrack(i)) - v.bodystdPar(i,v.bodytrack(i)) + p.CenterFromFrontDist/sqrt(1+v.BodyDirection1(i,v.bodytrack(i))^2)];                    
                    end;
                    f = polyval([v.BodyDirection1(i,v.bodytrack(i)) v.BodyDirection2(i,v.bodytrack(i))], X);
                    % define new center position
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Alexandre -> old code is commented
                    TC_x = X;
                    TC_y = f;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       CurrentBodyX           = X;
%                       CurrentBodyY           = f;
%     %                   CurrentBodyStdX        = p.CenterFromFrontDist/sqrt(1+v.BodyDirection1(i,v.bodytrack(i))^2);
%                       CurrentBodyStdY        = p.CenterFromFrontDist/sqrt(1+v.BodyDirection1(i,v.bodytrack(i))^2);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                else
                    if(v.Orientation(i,v.bodytrack(i)) == 1)
                        Y = [v.bodyy(i,v.bodytrack(i)) + v.bodystdPar(i,v.bodytrack(i)) - p.CenterFromFrontDist/sqrt(1+v.BodyDirection1(i,v.bodytrack(i))^2)];
                    else
                        Y = [v.bodyy(i,v.bodytrack(i)) - v.bodystdPar(i,v.bodytrack(i)) + p.CenterFromFrontDist/sqrt(1+v.BodyDirection1(i,v.bodytrack(i))^2)];                    
                    end;
                    f = polyval([v.BodyDirection1(i,v.bodytrack(i)) v.BodyDirection2(i,v.bodytrack(i))], Y);
                    % define new center position
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Alexandre
                    TC_x = f;
                    TC_y = Y;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       CurrentBodyX           = f;
%                       CurrentBodyY           = Y; % was X before
%     %                   CurrentBodyStdX        = p.CenterFromFrontDist/sqrt(1+v.BodyDirection1(i,v.bodytrack(i))^2);
%                       CurrentBodyStdY        = p.CenterFromFrontDist/sqrt(1+v.BodyDirection1(i,v.bodytrack(i))^2);
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end;
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           % Alexandre -> if body determination is not front based, match TC with the
           % center of the ellipse
            else
                TC_x = CurrentBodyX;
                TC_y = CurrentBodyY;
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end;
        end;
    end
end;
%% Make Body length fixed if it is set
if p.fixed_body_length == 1
                if v.BodyDirection3(i,v.bodytrack(i)) == 1
                    CurrentBodyStdY = p.fixed_body_length_value/2;%p.CenterFromFrontDist/sqrt(1+v.BodyDirection1(i,v.bodytrack(i))^2);
                else
                    CurrentBodyStdY = p.fixed_body_length_value/2;%p.CenterFromFrontDist/sqrt(1+v.BodyDirection1(i,v.bodytrack(i))^2);
                end;
end;

  %% plot borders
%     S = size(v.rawpic);

%   plot([p.cut.left S(2)-p.cut.right S(2)-p.cut.right p.cut.left p.cut.left], [p.cut.up p.cut.up S(1)-p.cut.down S(1)-p.cut.down p.cut.up], 'b:');
%     hold off;
%     outputfilename = sprintf('%s%d.png', p.outputfolder, v.index);
    
  end; % end creating the picture if detected
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% save current variables in pixel units
v.CurrentBodyX(v.i)           = CurrentBodyX; 
v.CurrentBodyY(v.i)           = CurrentBodyY; 
v.CurrentBodyDirection1(v.i)  = CurrentBodyDirection1; 
v.CurrentBodyDirection2(v.i)  = CurrentBodyDirection2; 
v.CurrentBodyDirection3(v.i)  = CurrentBodyDirection3; 
v.CurrentBodyOrientation(v.i) = CurrentBodyOrientation;
v.CurrentBodyStdX(v.i)        = CurrentBodyStdX; 
v.CurrentBodyStdY(v.i)        = CurrentBodyStdY; 
v.CurrentLeftFrontLegX(v.i)   = CurrentLeftFrontLegX;  
v.CurrentLeftFrontLegY(v.i)   = CurrentLeftFrontLegY; 
v.CurrentRightFrontLegX(v.i)  = CurrentRightFrontLegX; 
v.CurrentRightFrontLegY(v.i)  = CurrentRightFrontLegY; 
v.CurrentLeftMiddleLegX(v.i)  = CurrentLeftMiddleLegX; 
v.CurrentLeftMiddleLegY(v.i)  = CurrentLeftMiddleLegY; 
v.CurrentRightMiddleLegX(v.i) = CurrentRightMiddleLegX; 
v.CurrentRightMiddleLegY(v.i) = CurrentRightMiddleLegY; 
v.CurrentLeftBackLegX(v.i)    = CurrentLeftBackLegX;
v.CurrentLeftBackLegY(v.i)    = CurrentLeftBackLegY;
v.CurrentRightBackLegX(v.i)   = CurrentRightBackLegX;
v.CurrentRightBackLegY(v.i)   = CurrentRightBackLegY;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre
v.TC_x(v.i)                    = TC_x;
v.TC_y(v.i)                    = TC_y;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% change units to um
if CurrentBodyX ~= -1,           CurrentBodyX           = CurrentBodyX / p.distcal; end;
if CurrentBodyY ~= -1,           CurrentBodyY           = CurrentBodyY / p.distcal; end;
if CurrentBodyDirection1 ~= -1,  CurrentBodyDirection1  = CurrentBodyDirection1; end;
if CurrentBodyDirection2 ~= -1,  CurrentBodyDirection2  = CurrentBodyDirection2 / p.distcal; end;
if CurrentBodyDirection3 ~= -1,  CurrentBodyDirection3  = CurrentBodyDirection3; end;
if CurrentBodyOrientation ~= -1, CurrentBodyOrientation = CurrentBodyOrientation; end;
if CurrentBodyStdX ~= -1,        CurrentBodyStdX        = CurrentBodyStdX / p.distcal; end;
if CurrentBodyStdY ~= -1,        CurrentBodyStdY        = CurrentBodyStdY / p.distcal; end;
if CurrentLeftFrontLegX ~= -1,   CurrentLeftFrontLegX   = CurrentLeftFrontLegX / p.distcal; end;
if CurrentLeftFrontLegY ~= -1,   CurrentLeftFrontLegY   = CurrentLeftFrontLegY / p.distcal; end;
if CurrentRightFrontLegX ~= -1,  CurrentRightFrontLegX  = CurrentRightFrontLegX / p.distcal; end;
if CurrentRightFrontLegY ~= -1,  CurrentRightFrontLegY  = CurrentRightFrontLegY / p.distcal; end;
if CurrentLeftMiddleLegX ~= -1,  CurrentLeftMiddleLegX  = CurrentLeftMiddleLegX / p.distcal; end;
if CurrentLeftMiddleLegY ~= -1,  CurrentLeftMiddleLegY  = CurrentLeftMiddleLegY / p.distcal; end;
if CurrentRightMiddleLegX ~= -1, CurrentRightMiddleLegX = CurrentRightMiddleLegX / p.distcal; end;
if CurrentRightMiddleLegY ~= -1, CurrentRightMiddleLegY = CurrentRightMiddleLegY / p.distcal; end;
if CurrentLeftBackLegX ~= -1,    CurrentLeftBackLegX    = CurrentLeftBackLegX / p.distcal; end;
if CurrentLeftBackLegY ~= -1,    CurrentLeftBackLegY    = CurrentLeftBackLegY / p.distcal; end;
if CurrentRightBackLegX ~= -1,   CurrentRightBackLegX   = CurrentRightBackLegX / p.distcal; end;
if CurrentRightBackLegY ~= -1,   CurrentRightBackLegY   = CurrentRightBackLegY / p.distcal; end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre
if TC_x ~= -1,                   TC_x                   = TC_x / p.distcal; end;
if TC_y ~= -1,                   TC_y                   = TC_y / p.distcal; end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%   outputfilename = sprintf('%sData\\%d.mat', p.foldername, v.index);
outputfilename = p.inputfilename;
save(outputfilename, 'p', 'v');


  
% SAVE TABLE
outputtablefilename = p.outputtablefilename;
fid = fopen(outputtablefilename, 'at');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> extra two %f and TC_x and TC_y at the end
fprintf(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f\n', ...
        v.time,                CurrentBodyX,          CurrentBodyY,           CurrentBodyDirection1, ...
        CurrentBodyDirection2, CurrentBodyDirection3, CurrentBodyOrientation, CurrentBodyStdX, ...
        CurrentBodyStdY, ... 
        CurrentLeftFrontLegX,  CurrentLeftFrontLegY,  CurrentRightFrontLegX,  CurrentRightFrontLegY, ...
        CurrentLeftMiddleLegX, CurrentLeftMiddleLegY, CurrentRightMiddleLegX, CurrentRightMiddleLegY, ...
        CurrentLeftBackLegX,   CurrentLeftBackLegY,   CurrentRightBackLegX,   CurrentRightBackLegY, ...
        TC_x, TC_y);

  

  
fclose(fid);



return;
%%
function [d, x0, y0]  = point_to_line(x1,y1,m,b)
% calculate distance between line y=mx+b and point (x1,y1).
% d        - distance
% (x0,y0)  - coordinates of the closest point on the line to the point

    x0 = (m*y1 + x1 - m*b)   / (m^2 + 1);
    y0 = (m^2*y1 + m*x1 + b) / (m^2 + 1);
    d = abs(y1 - m*x1 - b)   / sqrt(m^2+1);

return;