function [ Leg, Body, Bodystd, BodySize, BodyBorder, BodyFit, LegBrightness] = FlyFinder_02(p,v)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [Leg, Body, Bodystd, BodySize, BodyBorder, BodyFit, LegBrightness] = FlyFinder_02(p,v)
%
% this program reads in a file and finds legs and bodies located on it. It
%
% (c) Imre Bartos, April 2009.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% spatial filter of the image
% choose loudest pixels and average them with surrounding pixels
  b = v.pic.R;

% highlight parts that are above a threshold
% assuming that the legs are brighter than the body, this is going to find
% the legs
  ind = find(b < p.legthreshold);
  b(ind) = 0;

% figure(2)
% image(v.pic);
% hold on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Identify LEGS and find their center
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % initialize
      LegX = [];
      Brightest = [];
    % find indices of legs
      [x,y] = find(b >= p.legthreshold);
    % loop over legs and find neighbors for them
      maxgap = p.maxgapleg; % max allowed gap between two pixels being parts of the same leg
      legnumber = 0; % leg number index
      LegIndex(1:length(x)) = 0;
      for i = 1:length(x) % loop over leg pixels
        % if leg not assigned yet, assign it
        if (LegIndex(i) == 0)
            legnumber = legnumber + 1;
            LegIndex(i) = legnumber;
        end;
        % find legs that are maximum 1+maxgap pixels away from pixel in
        % question
        for j = i+1:length(x) % loop over leg pixels
            if LegIndex(j) == 0 % only calculate the squares if the leg is not assigned yet
                if abs(x(i) - x(j)) < maxgap+1
                    if abs(y(i) - y(j)) < maxgap+1
                        if (x(i) - x(j))^2 + (y(i) - y(j))^2 + 0.01 <= 2*(1+maxgap)^2
                            % if a leg part is already associated with a different
                            % leg then merge the two legs
                            if LegIndex(j) ~= 0
                              Ind = find(LegIndex == LegIndex(j));
                              LegIndex(Ind) = LegIndex(i);
                            else
                              LegIndex(j) = LegIndex(i);
                            end;
                        end;
                    end;
                end;
            end;
        end;
      end;

    % Calculate center of mass for each leg
      for i = 1:legnumber
        % find pixels that are the part of leg i
        ind = find(LegIndex == i);
        % calculate their mean
        LegX(i) = mean(x(ind));
        LegY(i) = mean(y(ind));
        LegBrightness(i) = max(max(b(x(ind),y(ind))));
      end;

    % Convert leg means into the appropriate output format
      if length(LegX) > 2
        Leg(:,2) = LegX;
        Leg(:,1) = LegY;
      else
        Leg = [];
        LegBrightness = [];
      end;
    

%  hold off;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Identify BODY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % initialize
      BodyX = [];
      BodyY = [];
      Bodystd = [];
      BodyBorder = [];
      BodyFit = [];
      Body = [];
      BodySize = [];

    % delete everything thats not body
      b = v.pic.R;
      ind = find(b < p.bodylowerthreshold | b >= p.bodyupperthreshold);
      b(ind) = 0;

% figure(3)      
% bplot = b;    
% bplot(:,:) = 200;
% bplot(ind) = 0;
% image(bplot);
% hold on;
% use a similar algorithm for analyzing the body that we used to analyze the legs    
    % find indices of the body
      [x,y] = find(b >= p.bodylowerthreshold & b < p.bodyupperthreshold);
    % loop over legs and find neighbors for them
      maxgap = p.maxgapbody; % max allowed gap between two pixels being parts of the same leg
      bodynumber = 0; % leg number index
      BodyIndex(1:length(x)) = 0;
      for i = 1:length(x) % loop over body pixels
        % if leg not assigned yet, assign it
        if (BodyIndex(i) == 0)
            bodynumber = bodynumber + 1;
            BodyIndex(i) = bodynumber;
        end;

        % find bodies that are maximum 1+maxgap pixels away from pixel in
        % question
        for j = i+1:length(x) % loop over body pixels
          if abs(x(i) - x(j)) < maxgap+1
            if abs(y(i) - y(j)) < maxgap+1
              if (x(i) - x(j))^2 + (y(i) - y(j))^2 + 0.01 <= 2*(1+maxgap)^2
                % if a body part is already associated with a different
                % body part then merge the two bodies
                if BodyIndex(j) ~= 0
                  Ind = find(BodyIndex == BodyIndex(j));
                  BodyIndex(Ind) = BodyIndex(i);
                else
                  BodyIndex(j) = BodyIndex(i);
                end;
              end;
            end;
          end;
        end;
      end;

    % Calculate center of mass for each body
      for i = 1:bodynumber
        % find pixels that are the part of body i
        ind = find(BodyIndex == i);
        % calculate body size
        BodySize(i) = length(ind);
        % fit line to determine direction
        param = [0 0];

        if BodySize(i) >= p.MinBodySize
            % calculate their mean
            BodyX(i) = mean(x(ind));
            BodyY(i) = mean(y(ind));
            % calculate their std
%               BodyXstd(i) = mean(abs(x(ind) - BodyX(i)));
%               BodyYstd(i) = mean(abs(y(ind) - BodyY(i)));
  
            % save borders
            BodyBorder(i,1) = min(x(ind));
            BodyBorder(i,2) = max(x(ind));
            BodyBorder(i,3) = min(y(ind));
            BodyBorder(i,4) = max(y(ind));

            % fit line, also deciding whether a vertical fit is better or a
            % horizontal fit
            [phorizontal,Shorizontal] = polyfit(y(ind),x(ind),1);
            [pvertical,Svertical] = polyfit(x(ind),y(ind),1);
            if Shorizontal.normr < Svertical.normr
                param = phorizontal;
                fitdirection = 1;
            else 
                param = pvertical;
                fitdirection = 2;
            end;
            
            
            % Calculate STD in the direction of the body and perpendicular to it
              Par = [];
              Perp = [];
              for j = 1:length(ind)
                if fitdirection == 1
                    [d, y0, x0]  = point_to_line(y(ind(j)),x(ind(j)),param(1),param(2));
                    Par(j) = sqrt((x0 - BodyX(i))^2 + (y0 - BodyY(i))^2) * sign(y0 - BodyY(i));
                else
                    [d, x0, y0]  = point_to_line(x(ind(j)),y(ind(j)),param(1),param(2));
                    Par(j) = sqrt((x0 - BodyX(i))^2 + (y0 - BodyY(i))^2) * sign(x0 - BodyX(i));
                end;
                Perp(j) = d;
              end;

              if fitdirection == 1
                BodyXstd(i) = 2*mean(abs(Perp));
                BodyYstd(i) = 2*mean(abs(Par));
              else
                BodyXstd(i) = 2*mean(abs(Par));
                BodyYstd(i) = 2*mean(abs(Perp));
              end;
              
              
              % Determine the location of the front point of the fly ------
              maxind = find(Par == max(Par));
              minind = find(Par == min(Par));
              
              BodyBorder(i,5) = x(ind(maxind));
              BodyBorder(i,6) = y(ind(maxind));
              BodyBorder(i,7) = x(ind(minind));
              BodyBorder(i,8) = y(ind(minind));
              
              
%               plot([BodyY(i) - BodyYstd(i) BodyY(i) + BodyYstd(i)],[BodyX(i) - BodyXstd(i) BodyX(i) + BodyXstd(i)],'g');
%               f = polyval(param,[BodyY(i) - BodyYstd(i) BodyY(i) + BodyYstd(i)]);
% %             plot(y(ind), x(ind), 'gx');
%             plot([BodyY(i) - BodyYstd(i) BodyY(i) + BodyYstd(i)],f,'g');
%             hold off

%% Identify legs ----------------------------------------------
            for j = 1:legnumber
                % calculate perpenicular and parallel distances from
                % center. Parallel refers to the orientation of the fly
                if fitdirection == 1
                    [d, y0, x0]  = point_to_line(LegY(j),LegX(j),param(1),param(2));
                else
                    [d, x0, y0]  = point_to_line(LegX(j),LegY(j),param(1),param(2));
                end;
                LegDistancePerp(i,j) = d;
                LegDistancePar(i,j) = sqrt((x0 - BodyX(i))^2 + (y0 - BodyY(i))^2);
                
            end;
            BodyFit(i,1:2) = param;
            BodyFit(i,3) = fitdirection;
        end;
      end;
    % Convert body means into the appropriate output format
      if bodynumber > 0
        ind = find(BodySize >= p.MinBodySize);
        if length(ind) > 0
            Body(:,2) = BodyX(ind);
            Body(:,1) = BodyY(ind);
            Bodystd(:,2) = BodyXstd(ind);
            Bodystd(:,1) = BodyYstd(ind);
            temp = BodyFit;
            BodyFit = [];
            BodyFit(:,1) = temp(ind,1);
            BodyFit(:,2) = temp(ind,2);
            BodyFit(:,3) = temp(ind,3);
            temp = BodyBorder;
            BodyBorder = [];
            BodyBorder(:,1) = temp(ind,1);
            BodyBorder(:,2) = temp(ind,2);
            BodyBorder(:,3) = temp(ind,3);
            BodyBorder(:,4) = temp(ind,4);
            BodyBorder(:,5) = temp(ind,5);
            BodyBorder(:,6) = temp(ind,6);
            BodyBorder(:,7) = temp(ind,7);
            BodyBorder(:,8) = temp(ind,8);
        else
            Body = [];
            Bodystd = [];
            BodyFit = [];
            BodyBorder = [];
        end;
      end;
%     plot(BodyY,BodyX,'go')
%     hold off;

    
    

clear a b 'pkfnd.m' 'bpass.m' referencepic;
fclose('all');
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