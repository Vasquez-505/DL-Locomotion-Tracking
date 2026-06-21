function [Side, LegPosition] = IdentifyLegs_02(p,v);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% identify legs and associate them with bodies
%
% INPUT:
% v.bodytiming
% v.Orientation
% v.bodytrack
% v.bodyx
% v.bodyy
% v.BodyDirection1
% v.BodyDirection2
% v.BodyDirection3
% v.legtiming
% v.legtrack
% v.legx
% v.legy
% v.Side
% v.bodyborder
% v.LegPosition
% v.legbrightness
% p.mindist
% 
% OUTPUT:
% v.Side
% v.LegPosition
%
% (c) Imre Bartos, April 2009
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% identify where bodies are
    % orientation of these: 
    %   v.Orientation(indBodies, v.bodytrack(intBodies))
    % center of these: 
    %    v.bodyx(indBodies, v.bodytrack(intBodies))
    %    v.bodyy(indBodies, v.bodytrack(intBodies))
    % body direction two components y = (1)x + (2)
    %    v.BodyDirection1(indBodies,v.bodytrack(indBodies))
    %    v.BodyDirection2(indBodies,v.bodytrack(indBodies))  
  indBodies = find(v.bodytiming == 1); % Bodies at the moment are those for which v.bodytiming == 0

        
% identify where legs are
% consider legs that are present, present for at least two frames but not
% present for longer than 4 frames
    % time of legs being tracked: 
    %    v.legtrack(indLegs)
    % position of these legs 
    %    v.legx(indLegs, v.legtrack(intLegs))
    %    v.legy(indLegs, v.legtrack(intLegs))
  indLegs = find(v.legtiming == 1 & v.legtrack >= 0 & v.legtrack < 5);

    
% legs that are active. These are not necessarily new legs, they are
% used to check what is present and what is not.
  indactiveLegs = find(v.legtiming == 1 & v.legtrack > 1);
    
  
% Increment leg times - add one to all leg times to track how long legs
% have been absent
  v.legtimes(1:6) = v.legtimes(1:6) + 1;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate leg distances
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    LegDistancePar = [];
    LegDistancePerp = [];
    for i = indBodies
        for j = indLegs
          if v.Orientation(i,v.bodytrack(i)) ~= 0
            % calculate perpenicular and parallel distances from
            % center. Parallel refers to the orientation of the fly
            if v.BodyDirection3(i,v.bodytrack(i)) == 1
                [d, x0, y0]  = point_to_line(v.legx(j,v.legtrack(j)),v.legy(j,v.legtrack(j)),v.BodyDirection1(i,v.bodytrack(i)),v.BodyDirection2(i,v.bodytrack(i)));
            else
                [d, y0, x0]  = point_to_line(v.legy(j,v.legtrack(j)),v.legx(j,v.legtrack(j)),v.BodyDirection1(i,v.bodytrack(i)),v.BodyDirection2(i,v.bodytrack(i)));
            end;
            LegDistancePerp(i,j) = d;
            LegDistancePar(i,j) = sqrt((y0 - v.bodyy(i,v.bodytrack(i)))^2 + (x0 - v.bodyx(i,v.bodytrack(i)))^2);
            % determine sine of parallel distance
            if v.BodyDirection3(i,v.bodytrack(i)) == 1
                LegDistancePar(i,j) = LegDistancePar(i,j) * v.Orientation(i,v.bodytrack(i)) * sign(x0 - v.bodyx(i,v.bodytrack(i)));
            else
                LegDistancePar(i,j) = LegDistancePar(i,j) * v.Orientation(i,v.bodytrack(i)) * sign(y0 - v.bodyy(i,v.bodytrack(i)));
            end;
          else
              LegDistancePar(i,j) = 9999;
              LegDistancePerp(i,j) = 9999;
          end;
        end;
    end;  
    
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% determine whether LEGS are LEFT or RIGHT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % is leg above or below the direction line?
    if length(indBodies) > 0
        for j = indLegs
            % determine which body the leg is the closest to
%             Dist2 = LegDistancePerp(indBodies,j).^2 + LegDistancePar(indBodies,j).^2;
            Dist2 = LegDistancePerp(indBodies,j).^2 + LegDistancePar(indBodies,j).^2;
            
            i = find(Dist2 == min(Dist2));
            i = indBodies(i(1));

            Dist2 = [];
            Dist2(indBodies) = LegDistancePerp(indBodies,j).^2 + LegDistancePar(indBodies,j).^2;
            % Define length of body as twice the bodystd
            BodyLength = 2*v.bodystdPar(i,v.bodytrack(i));

            % there is only point defining sides if there is a direction
            if v.Orientation(i,v.bodytrack(i)) ~= 0
                % require that leg is closer to body than body length * p.minDist
                % bodylength at given time
                if Dist2(i) < BodyLength^2 * p.maxDist^2
                    % Require that legs shouldn't start off under the body,
                    % where the body is approximated with an ellipse of
                    % semimajor and semiminor axes a and b, respectively,
                    % and eccentricity e
                      a = v.bodystdPar(i,v.bodytrack(i));  % semimajor axis
                      b = v.bodystdPerp(i,v.bodytrack(i)); % semiminor axis
                      ae = sqrt(a^2 - b^2);
                      % added distances from the two focus points
                        D1 = sqrt((LegDistancePar(i,j) - ae)^2 + LegDistancePerp(i,j)^2);
                        D2 = sqrt((LegDistancePar(i,j) + ae)^2 + LegDistancePerp(i,j)^2);
                        D = D1 + D2;
                    if D > 2*a*p.minDist % if leg is outside of the ellipse
                        % only assign this for legs which are not assigned already
                        if length(v.Side) < i*j
                            v.Side(i,j) = 0;
                        end
                        % only consider a leg if its size is not determined yet
                        if v.Side(i,j) == 0
                            % define side base on the initial appearance of the leg as it
                            % can move later on but that doesn't count
                            if v.BodyDirection3(i,v.bodytrack(i)) == 1
                                f = polyval([v.BodyDirection1(i,v.bodytrack(i)) v.BodyDirection2(i,v.bodytrack(i))],v.legx(j,v.legtrack(j)));
                                if v.legy(j,v.legtrack(j)) >= f
                                    v.Side(i,j) = 1; % above
                                else
                                    v.Side(i,j) = -1; % below
                                end;
                            else
                                f = polyval([v.BodyDirection1(i,v.bodytrack(i)) v.BodyDirection2(i,v.bodytrack(i))],v.legy(j,v.legtrack(j)));
                                if v.legx(j,v.legtrack(j)) <= f
                                    v.Side(i,j) = 1; % above
                                else
                                    v.Side(i,j) = -1; % below
                                end;
                            end;

                            % decide whether up or down is left or right
                            v.Side(i,j) = v.Side(i,j) * v.Orientation(i,v.bodytrack(i));
                        end
                    end
                end;
            end;
        end;
    end;        

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% determine if (new) leg is FRONT, MIDDLE or BACK leg
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if length(indBodies) > 0
        for j = indLegs
            % calculate for the body for which it is the closest
            Dist2 = LegDistancePerp(indBodies,j).^2 + LegDistancePar(indBodies,j).^2;
        
            i = find(Dist2 == min(Dist2));
            i = indBodies(i(1));
            Dist2 = [];
            Dist2(indBodies) = LegDistancePerp(indBodies,j).^2 + LegDistancePar(indBodies,j).^2;

            % if v.Side was determined
            if length(v.Side) < i*max(j,max(indLegs))
               v.Side(i,max(j,max(indLegs))) = 0;
            end
            if length(v.Side) < i*max(indactiveLegs)
               v.Side(i,max(j,max(indactiveLegs))) = 0;
            end
            if v.Side(i,j) ~= 0
                % Define length of body as twice the bodystd
                BodyLength = 2*v.bodystdPar(i,v.bodytrack(i));
                
%                 Dist2(indBodies) = LegDistancePerp(indBodies,j).^2 + LegDistancePar(indBodies,j).^2;
%                 IND = find(Dist2 == min(Dist2(indBodies)));
%                 IND = IND(1);
                % do the whole calculation only if the leg is not already
                % assigned a position
                if length(v.LegPosition) < i*max(j,max(indLegs))
                    v.LegPosition(i,max(j,max(indLegs))) = 0;
                end

                % proceed only if legbrightness is above threshold
                if v.legbrightness(j,v.legtrack(j)) > p.legonthreshold
                    if v.LegPosition(i,j) == 0
                        % require that leg is closer to body than body length * p.minDist bodylength at given time
                        if Dist2(i) < BodyLength^2 * p.minDist^2
                            % Determine which active legs are on the same side as the current leg
                            temp = v.Side(i,:);
                            temp(:) = -9999;
                            temp(indactiveLegs) = v.Side(i,indactiveLegs);
                            indSide = find(temp == v.Side(i,j));
                            % Determine whether there is already a front leg but first make sure the dimensions match
                            if length(v.LegPosition(i,:)) < length(v.Side(i,:))
                                v.LegPosition(i,length(v.Side(i,:))) = 0;
                            end;
        %% FRONT
                            temp = [];
                            temp = v.LegPosition(i,indSide);
                            indFront = find(temp == 1);
                            % proceed if there is no front leg so far
                            if isempty(indFront)
                              % proceed only if the leg has not been present for too short
                              if (v.Side(i,j) == -1 & v.legtimes(1) > p.minlegswing) | (v.Side(i,j) == 1 & v.legtimes(4) > p.minlegswing)
                                    % identify leg as FRONT leg if it is ahead of the fly
                                    if LegDistancePar(i,j) >= BodyLength/2 - BodyLength/8
                                        v.LegPosition(i,j) = 1;
                                        indactiveLegs = [indactiveLegs j];
                                        % save that the leg has just been present - restart the timing
                                        if v.Side(i,j) == -1
                                            v.legtimes(1) = 0;
                                        elseif v.Side(i,j) == 1
                                            v.legtimes(4) = 0;
                                        else
                                            disp('something is wrong!!!')
                                        end;
                                    end
                              end;
                            end;
        %% MIDDLE
                            temp = [];
                            temp = v.LegPosition(i,indSide);
                            indMiddle = find(temp == 2);
                            % proceed if there is no front leg so far
                            if isempty(indMiddle) & v.LegPosition(i,j) == 0
                                % proceed if this is the foremost leg out
                                % of those which are not assigned
        %                         temp = v.LegPosition(i,indSide);
        %                         indNotAssigned = find(temp == 0);
        %                         LegDistanceParij = LegDistancePar(i,j);
        %                         LegDistancePar(i,indSide(indNotAssigned));
        %                         LegDistancePariindNotAssigned = max(LegDistancePar(i,indSide(indNotAssigned)));
        %                         if LegDistanceParij >= max(LegDistancePar(i,indSide(indNotAssigned)))
        %                             LegDistanceParij = LegDistancePar(i,j);
                                % proceed only if the leg has not been present for too short
                                if (v.Side(i,j) == -1 & v.legtimes(2) > p.minlegswing) | (v.Side(i,j) == 1 & v.legtimes(5) > p.minlegswing)
                                   % identify middle leg if it is at the first half of the fly
                                   if LegDistancePar(i,j) > 0 & LegDistancePar(i,j) < BodyLength/2 & LegDistancePerp(i,j) < LegDistancePerp(i,j)*1.2
                                        v.LegPosition(i,j) = 2;
                                        indactiveLegs = [indactiveLegs j];
                                        % save that the leg has just been present - restart the timing
                                        if v.Side(i,j) == -1
                                            v.legtimes(2) = 0;
                                        elseif v.Side(i,j) == 1
                                            v.legtimes(5) = 0;
                                        else
                                            disp('something is wrong!!!')
                                        end;

                                   end                                    
                              end;
                            end;

        %% BACK
                            temp = [];
                            temp = v.LegPosition(i,indSide);
                            indBack = find(temp == 3);
                            % proceed if there is no front leg so far
                            if isempty(indBack) & v.LegPosition(i,j) == 0
                                % proceed if this is the foremost leg out
                                % of those which are not assigned
        %                         temp = v.LegPosition(i,indSide);
        %                         indNotAssigned = find(temp == 0);
        %                         LegDistanceParij = LegDistancePar(i,j);
        %                         LegDistancePar(i,indSide(indNotAssigned));
        %                         LegDistancePariindNotAssigned = max(LegDistancePar(i,indSide(indNotAssigned)));
        %                         if LegDistanceParij >= max(LegDistancePar(i,indSide(indNotAssigned)))

                                % proceed only if the leg has not been present for too short
                                if (v.Side(i,j) == -1 & v.legtimes(3) > p.minlegswing) | (v.Side(i,j) == 1 & v.legtimes(6) > p.minlegswing)
                                  % identify back if it is behind the middle of the fly
                                    if LegDistancePar(i,j) < 0
                                        v.LegPosition(i,j) = 3;
                                        indactiveLegs = [indactiveLegs j];
                                        % save that the leg has just been present - restart the timing
                                        if v.Side(i,j) == -1
                                            v.legtimes(3) = 0;
                                        elseif v.Side(i,j) == 1
                                            v.legtimes(6) = 0;
                                        else
                                            disp('something is wrong!!!')
                                        end;

                                    end                                    
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;

% convert output variables to right format
    Side = v.Side;
    LegPosition = v.LegPosition;

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