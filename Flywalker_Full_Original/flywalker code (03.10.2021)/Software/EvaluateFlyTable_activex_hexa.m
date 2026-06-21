function FinishState = EvaluateFlyTable_activex_hexa(filename, handles)
tic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Evaluate data from FlyTable
%
% FinishState - determines whether there was any error.
%
% (c) Imre Bartos, 2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% version: 04_03_14

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HARDCODED PARAMETERS

% turn plotting on and off (1-plot everything; 0-no plot)
  PLOT = 1;

  
% 4 feet version if you are interested in step patterns with only fore and
% hind feet (1- four feet analysis; 0-regular 6 feet analysis)
  FourFeetOn = 0;
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if something goes wrong this number will be set to -1
  FinishState = 1;  
  
%try % this will avoid error messages stopping the script



% turn off warning message
warning off;


disp('---------------------------------')
disp('---------------------------------')
disp(' ')
disp('Loading data...')


% Load data
load(filename);

%   p = Parameters();

% detemine foldername so the output can go here  
ind = find(filename == '/' | filename == '\');
foldername = filename(1:ind(end));

% % Read data from Table
% fid = fopen(filename, 'r');
% FlyTable = fscanf(fid, '%f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f', [21 inf]);


% organize data in table
FlyTable(1,:)  = v.time;
FlyTable(2,:)  = v.CurrentBodyX;
FlyTable(3,:)  = v.CurrentBodyY;
FlyTable(4,:)  = v.CurrentBodyDirection1; 
FlyTable(5,:)  = v.CurrentBodyDirection2; 
FlyTable(6,:)  = v.CurrentBodyDirection3;
FlyTable(7,:)  = v.CurrentBodyOrientation;
FlyTable(8,:)  = v.CurrentBodyStdY;
FlyTable(9,:)  = v.CurrentBodyStdX;
FlyTable(10,:) = v.CurrentLeftFrontLegX;  
FlyTable(11,:) = v.CurrentLeftFrontLegY;  
FlyTable(12,:) = v.CurrentRightFrontLegX;  
FlyTable(13,:) = v.CurrentRightFrontLegY;
FlyTable(14,:) = v.CurrentLeftMiddleLegX; 
FlyTable(15,:) = v.CurrentLeftMiddleLegY; 
FlyTable(16,:) = v.CurrentRightMiddleLegX; 
FlyTable(17,:) = v.CurrentRightMiddleLegY;
FlyTable(18,:) = v.CurrentLeftBackLegX;   
FlyTable(19,:) = v.CurrentLeftBackLegY;   
FlyTable(20,:) = v.CurrentRightBackLegX;   
FlyTable(21,:) = v.CurrentRightBackLegY;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre
 % if there's no info regarding TC in the saved data, use BodyX/Y as TC
  if ~isfield(v, 'TC_x') && ~isfield(v, 'TC_y')
      v.TC_x = v.CurrentBodyX;
      v.TC_y = v.CurrentBodyY;
  end

% make sure the dimensions match
if size(v.TC_x,2)~=size(v.CurrentBodyX,2)
    v.TC_x(end+1:size(v.CurrentBodyX,2)) = 0;
    v.TC_y(end+1:size(v.CurrentBodyX,2)) = 0;
end

FlyTable(22,:) = v.TC_x;
FlyTable(23,:) = v.TC_y;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% conversion from pixels to um - it should be done in the main file, just
% in case we want to change it here...
ind = find(FlyTable == -1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> added 2 rows
FlyTable([2:3 5 8:23],:) = FlyTable([2:3 5 8:23],:) / p.distcal;
FlyTable(ind) = -1;

% cut out where body is not present
ind = find(FlyTable(2,:) == 0);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> added 2 rows
FlyTable([2:3 5 8:23],ind) = -1;


time            = FlyTable(1,:);
BodyX           = FlyTable(2,:);
BodyY           = FlyTable(3,:); 
BodyDirection1  = FlyTable(4,:); 
BodyDirection2  = FlyTable(5,:); 
BodyDirection3  = FlyTable(6,:);
Orientation     = FlyTable(7,:);
BodyStdY        = FlyTable(8,:);
BodyStdX        = FlyTable(9,:);
LeftFrontLegX   = FlyTable(10,:);  
LeftFrontLegY   = FlyTable(11,:);  
RightFrontLegX  = FlyTable(12,:);  
RightFrontLegY  = FlyTable(13,:);
LeftMiddleLegX  = FlyTable(14,:); 
LeftMiddleLegY  = FlyTable(15,:); 
RightMiddleLegX = FlyTable(16,:); 
RightMiddleLegY = FlyTable(17,:);
LeftBackLegX    = FlyTable(18,:);   
LeftBackLegY    = FlyTable(19,:);   
RightBackLegX   = FlyTable(20,:);   
RightBackLegY   = FlyTable(21,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre
TCx             = FlyTable(22,:);
TCy             = FlyTable(23,:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Cut out those footprints that are only present for less than p.minframe frame!
for i = 2:length(time)-p.minframe-1
    if LeftFrontLegX(i-1) == -1 & LeftFrontLegX(i+p.minframe-1) == -1
        LeftFrontLegX(i) = -1;
        LeftFrontLegY(i) = -1;
    end;
    if RightFrontLegX(i-1) == -1 & RightFrontLegX(i+p.minframe-1) == -1
        RightFrontLegX(i) = -1;
        RightFrontLegY(i) = -1;
    end;
    if LeftMiddleLegX(i-1) == -1 & LeftMiddleLegX(i+p.minframe-1) == -1
        LeftMiddleLegX(i) = -1;
        LeftMiddleLegY(i) = -1;
    end;
    if RightMiddleLegX(i-1) == -1 & RightMiddleLegX(i+p.minframe-1) == -1
        RightMiddleLegX(i) = -1;
        RightMiddleLegY(i) = -1;
    end;
    if LeftBackLegX(i-1) == -1 & LeftBackLegX(i+p.minframe-1) == -1
        LeftBackLegX(i) = -1;
        LeftBackLegY(i) = -1;
    end;
    if RightBackLegX(i-1) == -1 & RightBackLegX(i+p.minframe-1) == -1
        RightBackLegX(i) = -1;
        RightBackLegY(i) = -1;
    end;
end;

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;
  
% Derive other values that are used in the analysis
for i = 1:length(time)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Alexandre -> old code is commmented
%     [Distance(1,i), PerpDist(1,i), ParaDist(1,i), Angle(1,i)] = LegDistance(BodyX(i), BodyY(i), LeftFrontLegX(i),   LeftFrontLegY(i),   BodyDirection1(i), BodyDirection2(i), BodyDirection3(i), Orientation(i));
%     [Distance(2,i), PerpDist(2,i), ParaDist(2,i), Angle(2,i)] = LegDistance(BodyX(i), BodyY(i), LeftMiddleLegX(i),  LeftMiddleLegY(i),  BodyDirection1(i), BodyDirection2(i), BodyDirection3(i), Orientation(i));
%     [Distance(3,i), PerpDist(3,i), ParaDist(3,i), Angle(3,i)] = LegDistance(BodyX(i), BodyY(i), LeftBackLegX(i),    LeftBackLegY(i),    BodyDirection1(i), BodyDirection2(i), BodyDirection3(i), Orientation(i));
%     [Distance(4,i), PerpDist(4,i), ParaDist(4,i), Angle(4,i)] = LegDistance(BodyX(i), BodyY(i), RightFrontLegX(i),  RightFrontLegY(i),  BodyDirection1(i), BodyDirection2(i), BodyDirection3(i), Orientation(i));
%     [Distance(5,i), PerpDist(5,i), ParaDist(5,i), Angle(5,i)] = LegDistance(BodyX(i), BodyY(i), RightMiddleLegX(i), RightMiddleLegY(i), BodyDirection1(i), BodyDirection2(i), BodyDirection3(i), Orientation(i));
%     [Distance(6,i), PerpDist(6,i), ParaDist(6,i), Angle(6,i)] = LegDistance(BodyX(i), BodyY(i), RightBackLegX(i),   RightBackLegY(i),   BodyDirection1(i), BodyDirection2(i), BodyDirection3(i), Orientation(i));
    [Distance(1,i), PerpDist(1,i), ParaDist(1,i), Angle(1,i)] = LegDistance(TCx(i), TCy(i), LeftFrontLegX(i),   LeftFrontLegY(i),   BodyDirection1(i), BodyDirection2(i), BodyDirection3(i), Orientation(i));
    [Distance(2,i), PerpDist(2,i), ParaDist(2,i), Angle(2,i)] = LegDistance(TCx(i), TCy(i), LeftMiddleLegX(i),  LeftMiddleLegY(i),  BodyDirection1(i), BodyDirection2(i), BodyDirection3(i), Orientation(i));
    [Distance(3,i), PerpDist(3,i), ParaDist(3,i), Angle(3,i)] = LegDistance(TCx(i), TCy(i), LeftBackLegX(i),    LeftBackLegY(i),    BodyDirection1(i), BodyDirection2(i), BodyDirection3(i), Orientation(i));
    [Distance(4,i), PerpDist(4,i), ParaDist(4,i), Angle(4,i)] = LegDistance(TCx(i), TCy(i), RightFrontLegX(i),  RightFrontLegY(i),  BodyDirection1(i), BodyDirection2(i), BodyDirection3(i), Orientation(i));
    [Distance(5,i), PerpDist(5,i), ParaDist(5,i), Angle(5,i)] = LegDistance(TCx(i), TCy(i), RightMiddleLegX(i), RightMiddleLegY(i), BodyDirection1(i), BodyDirection2(i), BodyDirection3(i), Orientation(i));
    [Distance(6,i), PerpDist(6,i), ParaDist(6,i), Angle(6,i)] = LegDistance(TCx(i), TCy(i), RightBackLegX(i),   RightBackLegY(i),   BodyDirection1(i), BodyDirection2(i), BodyDirection3(i), Orientation(i));
end

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALCULATE STEP DISTANCES, TIMES AND VELOCITY FOR EACH LEG & BODY VELOCITY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    disp(' ')
    disp('Calculating step distances...')
    disp(' ')

    FrameRate = p.fps;
    TEXT = ['LF'; 'LM'; 'LH'; 'RF'; 'RM'; 'RH'; 'LF'; 'LM'; 'LH'; 'RF'; 'RM'; 'RH'];
    AllLegsX = [LeftFrontLegX; LeftMiddleLegX; LeftBackLegX; RightFrontLegX; RightMiddleLegX; RightBackLegX; LeftFrontLegX; LeftMiddleLegX; LeftBackLegX; RightFrontLegX; RightMiddleLegX; RightBackLegX];
    AllLegsY = [LeftFrontLegY; LeftMiddleLegY; LeftBackLegY; RightFrontLegY; RightMiddleLegY; RightBackLegY; LeftFrontLegY; LeftMiddleLegY; LeftBackLegY; RightFrontLegY; RightMiddleLegY; RightBackLegY];
   
    counter(1:6) = 0; % counter for how many steps were made
    

    % find first and last frames with the body on. Lets which are present 
    % on this frame will not be used for the analysis as they might be 
    % showing middles of steps
      temp = find(LeftFrontLegX > 0 | LeftMiddleLegX > 0 | LeftBackLegX > 0 | RightFrontLegX > 0 | RightMiddleLegX > 0 | RightBackLegX > 0 );
      FirstTimeIndex = temp(1);
      LastTimeIndex = temp(end);
        
%       disp('FirstTimeIndex')
%       disp(FirstTimeIndex)
      
    % calculate total number of frames in which the body is on
      BodyOnNumber = length(find(BodyStdX > 0));
    
    % make t=0 at the first appearance of the body
      time = time - time(FirstTimeIndex);
    
    % calculate step positions and times
    for i = 1:6 % loop over legs
        starttime = 0;
        stoptime = -1;
        for j = 1:length(time) % loop over time
            if AllLegsX(i,j) ~= -1
                if starttime == 0
                    starttime = j;
                end;
                stoptime = j;
            else
              if starttime ~= 0 & stoptime ~= -1;
                % save step only if this is not a step starting on the very
                % first frame or very last frame
                if starttime > FirstTimeIndex & stoptime < LastTimeIndex
                    % save step
                    counter(i) = counter(i) + 1;
                    StartStep(i,counter(i)) = starttime;
                    StopStep(i,counter(i)) = stoptime;
                    LegXatStart(i,counter(i)) = AllLegsX(i,starttime);
                    LegYatStart(i,counter(i)) = AllLegsY(i,starttime);
                    LegXatStop(i,counter(i)) = AllLegsX(i,stoptime);
                    LegYatStop(i,counter(i)) = AllLegsY(i,stoptime);
                end;
              end;
              starttime = 0;
            end;
        end;
    end;

    % calculate body velocity
    for j = 1:length(time)-1 % loop over time
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Alexandre -> old code is commmented
        if TCx(j) > 0 & TCx(j+1) > 0
%         if BodyX(j) > 0 & BodyX(j+1) > 0 
%             BodyVelocity(j) = sqrt((BodyX(j+1) - BodyX(j))^2 + (BodyY(j+1) - BodyY(j))^2)*FrameRate;
            BodyVelocity(j) = sqrt((TCx(j+1) - TCx(j))^2 + (TCy(j+1) - TCy(j))^2)*FrameRate;
        else
            BodyVelocity(j) = 0;
        end;
    end;

    % calculate step sizes and times
    for i = 1:6 % loop over legs
        for j = 1:counter(i)-1 % loop over steps
            % Step - basically means swing. From lifting the leg to placing it again
            StepLength(i,j)     = sqrt((LegXatStart(i,j+1) - LegXatStop(i,j))^2 + (LegYatStart(i,j+1) - LegYatStop(i,j))^2);
            StepCycle(i,j)       = time(StartStep(i,j+1)) - time(StopStep(i,j));
            % Stance - from placing the leg to lifting it again
            StanceTime(i,j)     = time(StopStep(i,j)) - time(StartStep(i,j));
            % Total step - stance and swing together
            TotalStepCycle(i,j) = time(StopStep(i,j+1)) - time(StopStep(i,j));
            % calculate how much the body moved during the swing
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Alexandre -> old code is commmented
            BodyStepLength(i,j)     = sqrt((TCx(StopStep(i,j)) - TCx(StartStep(i,j)))^2 + (TCy(StopStep(i,j)) - TCy(StartStep(i,j)))^2);
%             BodyStepLength(i,j)     = sqrt((BodyX(StopStep(i,j)) - BodyX(StartStep(i,j)))^2 + (BodyY(StopStep(i,j)) - BodyY(StartStep(i,j)))^2);
            StepVelocity(i,j)   = (StepLength(i,j) / StepCycle(i,j) - BodyStepLength(i,j)/StanceTime(i,j))/1000;
        end;
    end;
    
    
% save counter for later use
StepCounter = counter;
% plot step lengths as function of time
    RGB = [1   0   0; ...
           1   0.5 0; ...
           0   1   0; ...
           0.5 1   1; ...
           0   0   1; ...
           0   0   0];
    h = figure('visible', 'off'); % create plot for this
    hold off;
    LegendNames = {'Left Fore', 'Left Middle', 'Left Hind', 'Right Fore', 'Right Middle', 'Right Hind'};
    for i = 1:6
        if counter(i) > 0
          plot(time(StopStep(i,1:counter(i)-1)), StepLength(i,1:counter(i)-1),'color', RGB(i,:), 'LineWidth', 2, 'DisplayName', char(LegendNames(i)));

          hold on;
        end;
    end;
    L = legend('Location', 'NW');
    for i = 1:6
        auxh = plot(time(StopStep(i,1:counter(i)-1)), StepLength(i,1:counter(i)-1), 'o','color', RGB(i,:), 'MarkerSize', 5, 'MarkerFaceColor',RGB(i,:));
        set(get(get(auxh,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

    end;
    set(L,'Interpreter','none', 'FontSize', 8, 'Location', 'EastOutside');
    title('Step Size');
    xlabel('time (lift of leg before step) [sec]');
    ylabel('step size [\mum]')
    grid on;
    box on;
    hold off;
    ind = find(filename == '\' | filename == '/');
    outputfilename = sprintf('%sStepSize_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
    saveas(h,outputfilename,'png');
    close(h);

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;
    

% plot step velocity    
    h = figure('visible', 'off'); % create plot for this
    hold off;
    LegendNames = {'Left Fore', 'Left Middle', 'Left Hind', 'Right Fore', 'Right Middle', 'Right Hind','Body'};
    for i = 1:6
        if counter(i) > 0
          plot(time(StopStep(i,1:counter(i)-1)), StepVelocity(i,1:counter(i)-1)/1000,'color', RGB(i,:), 'LineWidth', 2, 'DisplayName', char(LegendNames(i)));
          hold on;
        end;
    end;
    % place body velocity with running average
    auxh = plot(time((BodyVelocity > 0)), smooth(BodyVelocity(BodyVelocity > 0)/1000,round(FrameRate/20)),'--','color', [0 0 0], 'LineWidth', 2);
    set(get(get(auxh,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

    L = legend('Location', 'NW');

    % plot body velocity without smoothing too
    auxh = plot(time((BodyVelocity > 0)), smooth(BodyVelocity(BodyVelocity > 0)/1000,round(FrameRate/40)),'--','color', [0.3 0.3 0.3], 'LineWidth', 0.5);
    set(get(get(auxh,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

    for i = 1:6
        if counter(i) > 0
          auxh = plot(time(StopStep(i,1:counter(i)-1)), StepVelocity(i,1:counter(i)-1)/1000, 'o','color', RGB(i,:), 'MarkerSize', 5, 'MarkerFaceColor',RGB(i,:));
          set(get(get(auxh,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

        end;
    end;
    
    % REVRSE's RICARDO CHANGE
    %set(L,'Interpreter','none', 'FontSize', 8, 'Location', 'NorthWest');
    
    set(gcf, 'unit', 'inches');
    figure_size =  get(gcf, 'position');
       
    set(L,'Interpreter','none', 'FontSize', 8, 'Location', 'EastOutside');
    set(L, 'unit', 'inches');
    legend_size = get(L, 'position');
    figure_size(3) = figure_size(3) + legend_size(3);
    set(gcf, 'position', figure_size);
    
    
    
    title('Step Velocity');
%     xlim([time(1) time(end)]);
    xlabel('time (lift of leg before step) [sec]');
    ylabel('step velocity [mm/s]')
    grid on;
    box on;
    hold off;
    ind = find(filename == '\' | filename == '/');
    outputfilename = sprintf('%sStepVelocity_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
    saveas(h,outputfilename,'png');
    close(h);    

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALCULATE DIFFERENCE BETWEEN PARALLEL PLACEMENT OF CONSECUTIVE F-M-H LEGS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% loop over Left Foreleg starting points
for i = 1:counter(1)
    % find middle d back leg that will considered the parts of the same 
    % set attempted to be put at the same position. We choose the ones that
    % are closest.
      % order of legs: LF LM LH RF RM RH
      % foreleg parallel position: ParaDist(1,StartStep(1,i))
      % time when this happened:   time(StartStep(1,i))
      indLF = StartStep(1,i);
      if indLF > 0 & counter(2) > 0 & counter(3) > 0
          timeLF = time(indLF);
          ParaDistLF = ParaDist(1,indLF);

          % find Middle and Hind legs that are closest, also requiring that
          % they have to be placed after the first leg
          indLMtemp = find((LeftMiddleLegX(StartStep(2,1:counter(2))) - LeftFrontLegX(indLF)).^2 + (LeftMiddleLegY(StartStep(2,1:counter(2))) - LeftFrontLegY(indLF)).^2 == min((LeftMiddleLegX(StartStep(2,1:counter(2))) - LeftFrontLegX(indLF)).^2 + (LeftMiddleLegY(StartStep(2,1:counter(2))) - LeftFrontLegY(indLF)).^2));
          indLM = StartStep(2,indLMtemp(1));
          indLHtemp = find((LeftBackLegX(StartStep(3,1:counter(3))) - LeftFrontLegX(indLF)).^2 + (LeftBackLegY(StartStep(3,1:counter(3))) - LeftFrontLegY(indLF)).^2 == min((LeftBackLegX(StartStep(3,1:counter(3))) - LeftFrontLegX(indLF)).^2 + (LeftBackLegY(StartStep(3,1:counter(3))) - LeftFrontLegY(indLF)).^2));
          indLH = StartStep(3,indLHtemp(1));
          % Calculate ParaDist for Middle and Hind legs given the body's
          % position and direction at the time the first leg was placed
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          % Alexandre -> old code is commmented
          [LMDistance, LMPerpDist, LMParaDist, LMAngle] = LegDistance(TCx(indLF), TCy(indLF), LeftMiddleLegX(indLM),   LeftMiddleLegY(indLM),   BodyDirection1(indLF), BodyDirection2(indLF), BodyDirection3(indLF), Orientation(indLF));      
%           [LMDistance, LMPerpDist, LMParaDist, LMAngle] = LegDistance(BodyX(indLF), BodyY(indLF), LeftMiddleLegX(indLM),   LeftMiddleLegY(indLM),   BodyDirection1(indLF), BodyDirection2(indLF), BodyDirection3(indLF), Orientation(indLF));  
          [LHDistance, LHPerpDist, LHParaDist, LHAngle] = LegDistance(TCx(indLF), TCy(indLF), LeftBackLegX(indLH),     LeftBackLegY(indLH),     BodyDirection1(indLF), BodyDirection2(indLF), BodyDirection3(indLF), Orientation(indLF));      
%           [LHDistance, LHPerpDist, LHParaDist, LHAngle] = LegDistance(BodyX(indLF), BodyY(indLF), LeftBackLegX(indLH),     LeftBackLegY(indLH),     BodyDirection1(indLF), BodyDirection2(indLF), BodyDirection3(indLF), Orientation(indLF));      

          % Calculate standard deviation of ParaDist from the average of the
          % three legs
          Average = (ParaDist(1,indLF) + LMParaDist + LHParaDist)/3;
          LeftLegSTD(i) = std([ParaDist(1,indLF) LMParaDist LHParaDist]);
          LFLMParaDist(i) = ParaDist(1,indLF) - LMParaDist;
          LFLHParaDist(i) = ParaDist(1,indLF) - LHParaDist;          

          % if the closest leg combination has the middle or hind legs placed
          % after the front leg, make it -1
          if indLF > indLM | indLF > indLH
              LeftLegSTD(i) = -1;
              LFLMParaDist(i) = -1;
              LFLHParaDist(i) = -1;
              
          end;
      else
              LeftLegSTD(i) = -1;
              LFLMParaDist(i) = -1;
              LFLHParaDist(i) = -1;
              
      end;

      % SAME WITH THE RIGHT SIDE
      indRF = StartStep(4,i);
      if indRF > 0 & counter(5) > 0 & counter(6) > 0
          timeRF = time(indRF);
          ParaDistRF = ParaDist(4,indRF);

          % find Middle and Hind legs that are closest, also requiring that
          % they have to be placed after the first leg
          indRMtemp = find((RightMiddleLegX(StartStep(5,1:counter(5))) - RightFrontLegX(indRF)).^2 + (RightMiddleLegY(StartStep(5,1:counter(5))) - RightFrontLegY(indRF)).^2 == min((RightMiddleLegX(StartStep(5,1:counter(5))) - RightFrontLegX(indRF)).^2 + (RightMiddleLegY(StartStep(5,1:counter(5))) - RightFrontLegY(indRF)).^2));
          indRM = StartStep(5,indRMtemp(1));
          indRHtemp = find((RightBackLegX(StartStep(6,1:counter(6))) - RightFrontLegX(indRF)).^2 + (RightBackLegY(StartStep(6,1:counter(6))) - RightFrontLegY(indRF)).^2 == min((RightBackLegX(StartStep(6,1:counter(6))) - RightFrontLegX(indRF)).^2 + (RightBackLegY(StartStep(6,1:counter(6))) - RightFrontLegY(indRF)).^2));
          indRH = StartStep(6,indRHtemp(1));
          % Calculate ParaDist for Middle and Hind legs given the body's
          % position and direction at the time the first leg was placed
          %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          % Alexandre -> old code is commmented
          [RMDistance, RMPerpDist, RMParaDist, RMAngle] = LegDistance(TCx(indRF), TCy(indRF), RightMiddleLegX(indRM),   RightMiddleLegY(indRM),   BodyDirection1(indRF), BodyDirection2(indRF), BodyDirection3(indRF), Orientation(indRF));      
%           [RMDistance, RMPerpDist, RMParaDist, RMAngle] = LegDistance(BodyX(indRF), BodyY(indRF), RightMiddleLegX(indRM),   RightMiddleLegY(indRM),   BodyDirection1(indRF), BodyDirection2(indRF), BodyDirection3(indRF), Orientation(indRF));      
          [RHDistance, RHPerpDist, RHParaDist, RHAngle] = LegDistance(TCx(indRF), TCy(indRF), RightBackLegX(indRH),     RightBackLegY(indRH),     BodyDirection1(indRF), BodyDirection2(indRF), BodyDirection3(indRF), Orientation(indRF));      
%           [RHDistance, RHPerpDist, RHParaDist, RHAngle] = LegDistance(BodyX(indRF), BodyY(indRF), RightBackLegX(indRH),     RightBackLegY(indRH),     BodyDirection1(indRF), BodyDirection2(indRF), BodyDirection3(indRF), Orientation(indRF));      


          % Calculate standard deviation of ParaDist from the average of the
          % three legs
          Average = (ParaDist(4,indRF) + RMParaDist + RHParaDist)/3;
          RightLegSTD(i) = std([ParaDist(4,indRF) RMParaDist RHParaDist]);
          RFRMParaDist(i) = ParaDist(4,indRF) - RMParaDist;
          RFRHParaDist(i) = ParaDist(4,indRF) - RHParaDist;

          % if the closest leg combination has the middle or hind legs placed
          % after the front leg, make it -1
          if indRF > indRM | indRF > indRH
              RightLegSTD(i) = -1;
              RFRMParaDist(i) = -1;
              RFRHParaDist(i) = -1;
          end;
      else
              RightLegSTD(i) = -1;
              RFRMParaDist(i) = -1;
              RFRHParaDist(i) = -1;
      end;
end;


% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT STEP POSITIONS COMPARED TO BODY CENTER AND DIRECTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    RGBbright = [1      0.75  0.75; ...
                 1      0.85  0.75; ...
                 0.75   1     0.75; ...
                 0.85   1     1; ...
                 0.75   0.75  1; ...
                 0.75   0.75  0.75];
               
    % calculate body size and direction for start legs
    if BodyDirection3(StartStep(1,1)) == 1
        BodyLength =  2 * median(BodyStdY(BodyStdY > 0));
        if length(BodyStdX(BodyStdX > 0)) > 0
            BodyWidth =  2 * median(BodyStdX(BodyStdX > 0));
        else
            BodyWidth =  0;
        end;
    else
%         BodyLength =  median(BodyStdX(BodyStdY > 0));
%         if length(BodyStdY(BodyStdY > 0)) > 0
%             BodyWidth =  2 * median(BodyStdY(BodyStdY > 0));
%         else
%             BodyWidth =  0;
%         end;
        BodyLength = 2* median(BodyStdY(BodyStdY > 0));
        if length(BodyStdX(BodyStdX > 0)) > 0
            BodyWidth =  median(BodyStdX(BodyStdX > 0));
        else
            BodyWidth =  0;
        end;
    end;

    
% STARTING POSITIONS    
    % plot leg positions
    h = figure('visible', 'off'); % create plot for this
    hold off;
    % plot starting points
    for j = 1:6 % loop over legs
        Sign = 1;
        if j > 3, Sign = -1; end; 
        plot(Sign*PerpDist(j,StartStep(j,1:counter(j))) / BodyLength, ParaDist(j,StartStep(j,1:counter(j))) / BodyLength, 'o','color', RGB(j,:), 'MarkerSize', 6, 'MarkerFaceColor',RGB(j,:));
        hold on;
    end;
    L = legend('Left Fore', 'Left Middle', 'Left Hind', 'Right Fore', 'Right Middle', 'Right Hind');

    % load fruitfly image
%     fruitflypic = imread('drosophila.png');
%     image([-1.29 1.49],[1.1 -1.55],fruitflypic);
%     image([-1.29 1.49]/4,[1.1 -1.55]/4,fruitflypic);

    % plot leg tracks with brighter colors
    for i = 1:6
        if counter(i) > 0
          ind = find(PerpDist(i,:) ~= -1);
          ind = ind(ind >= StartStep(i,1) & ind <= StopStep(i,counter(i))); % this makes sure that only those parts are taken into account that are not part of the steps that are present at the very first or last frames with the body on        
          for j = 1:length(ind)-1
              if ind(j+1) - ind(j) == 1
                  I = [ind(j) ind(j+1)];
                  Sign = 1;
                  if i > 3, Sign = -1; end; 
                  auxh = plot(Sign*PerpDist(i,I) / BodyLength, ParaDist(i,I) / BodyLength,'color', RGB(i,:), 'LineWidth', 2);%Line thickness
                  set(get(get(auxh,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

              end
          end
        end;
    end;
    % plot starting points again for the sake of the legend
    for j = 1:6 % loop over legs
        Sign = 1;
        StartPositionXAvg(j) = mean(PerpDist(j,StartStep(j,1:counter(j))) / BodyLength);
        StartPositionYAvg(j) = mean(ParaDist(j,StartStep(j,1:counter(j))) / BodyLength);
        StopPositionXAvg(j)  = mean(PerpDist(j, StopStep(j,1:counter(j))) / BodyLength);
        StopPositionYAvg(j)  = mean(ParaDist(j, StopStep(j,1:counter(j))) / BodyLength);
        StartPositionXSTD(j) =  std(PerpDist(j,StartStep(j,1:counter(j))) / BodyLength);
        StartPositionYSTD(j) =  std(ParaDist(j,StartStep(j,1:counter(j))) / BodyLength);
        StopPositionXSTD(j)  =  std(PerpDist(j, StopStep(j,1:counter(j))) / BodyLength);
        StopPositionYSTD(j)  =  std(ParaDist(j, StopStep(j,1:counter(j))) / BodyLength);
        if j > 3, Sign = -1; end; 
        auxh = plot(Sign*PerpDist(j,StartStep(j,1:counter(j))) / BodyLength, ParaDist(j,StartStep(j,1:counter(j))) / BodyLength, 'o','color', RGB(j,:), 'MarkerSize', 7, 'MarkerFaceColor',RGB(j,:));
        set(get(get(auxh,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        hold on;
    end;

% Calculate the distance difference between the AEP and PEP of left-right leg pairs
  AEPFrontDiff  = sqrt((StartPositionXAvg(1) - StartPositionXAvg(4))^2 + (StartPositionYAvg(1) - StartPositionYAvg(4))^2);
  PEPFrontDiff  = sqrt(( StopPositionXAvg(1) -  StopPositionXAvg(4))^2 + ( StopPositionYAvg(1) -  StopPositionYAvg(4))^2);
  AEPMiddleDiff = sqrt((StartPositionXAvg(2) - StartPositionXAvg(5))^2 + (StartPositionYAvg(2) - StartPositionYAvg(5))^2);
  PEPMiddleDiff = sqrt(( StopPositionXAvg(2) -  StopPositionXAvg(5))^2 + ( StopPositionYAvg(2) -  StopPositionYAvg(5))^2);
  AEPHindDiff   = sqrt((StartPositionXAvg(3) - StartPositionXAvg(6))^2 + (StartPositionYAvg(3) - StartPositionYAvg(6))^2);
  PEPHindDiff   = sqrt(( StopPositionXAvg(3) -  StopPositionXAvg(6))^2 + ( StopPositionYAvg(3) -  StopPositionYAvg(6))^2);
    
    % plot ellipse
    t = 0:0.001:2*pi;
    auxh1 = plot(BodyWidth/BodyLength*cos(t)/2,sin(t)/2,'color',[0.5,0.5,0.5],'LineWidth',2);
%     plot(cos(t),sin(t),'color',[0.5,0.5,0.5],'LineWidth',2)
    % plot little arrow
    auxh2 = plot([0 0],    [-0.15 0.15],'color',[0.5,0.5,0.5],'LineWidth',2);
    auxh3 = plot([0  0.01],[0.15 0.01] ,'color',[0.5,0.5,0.5],'LineWidth',1);
    auxh4 = plot([0 -0.01],[0.15 0.01] ,'color',[0.5,0.5,0.5],'LineWidth',1);
    set(get(get(auxh1,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    set(get(get(auxh2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    set(get(get(auxh3,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    set(get(get(auxh4,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

    set(L,'Interpreter','none', 'FontSize', 8, 'Location', 'NorthWest');

    % set picture limits (CESAR)
      XLIMIT = [-1 +1];
      YLIMIT = [-1.2 1.2];
    
      xlim(XLIMIT);
      ylim(YLIMIT);
      
    % set picture size to have correct ratio
    H = xlim;
    W = ylim;
    set(h,'PaperPosition', [0 0 H(2)-H(1)+0.85 W(2)-W(1)]*5);
    set(gca,'Layer','Top'); % put grid on top
    title('Step AEPs');
    xlabel('perpendicular distance from body center [normalized to body length]');
    ylabel('parallel distance from body center [normalized to body length]')
    grid on;
    set(gca, 'FontSize', 12)
    box on;
    hold off;
    ind = find(filename == '\' | filename == '/');
    
    
    set(h, 'unit', 'inches');
    figure_size = get(h, 'position');
    set(L,'Interpreter','none', 'FontSize', 7, 'Location', 'EastOutside');
    set(L, 'unit', 'inches');
    legend_size = get(L, 'position');
    figure_size(3) = figure_size(3) + legend_size(3);
    set(h, 'position', figure_size);
    
     
    
    outputfilename = sprintf('%sStepStartRelativePosition_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
    saveas(h,outputfilename,'png');
    close(h);
    
%%
%Added by Ines
%Just AEP & PEP position

% STARTING POSITIONS    
    % plot leg positions
    hh = figure('visible', 'off'); % create plot for this
    hold off;
    % plot starting points (AEP), the size of dot is here ('MarkerSize', xxx,)
    for j = 1:6 % loop over legs
        Sign = 1;
        if j > 3, Sign = -1; end; 
        plot(Sign*PerpDist(j,StartStep(j,1:counter(j))) / BodyLength, ParaDist(j,StartStep(j,1:counter(j))) / BodyLength, 'o','color', RGB(j,:), 'MarkerSize', 4, 'MarkerFaceColor',RGB(j,:));
        hold on;
    end;
    
    %plot final points (PEP), the size of dot is here ('MarkerSize', xxx,)
    for j = 1:6 % loop over legs
        Sign = 1;
        if j > 3, Sign = -1; end; 
        plot(Sign*PerpDist(j,StopStep(j,1:counter(j))) / BodyLength, ParaDist(j,StopStep(j,1:counter(j))) / BodyLength, 'o','color', RGB(j,:), 'MarkerSize', 4, 'MarkerFaceColor',RGB(j,:));
      
        hold on;
    end;
    L = legend('Left Fore', 'Left Middle', 'Left Hind', 'Right Fore', 'Right Middle', 'Right Hind');

    % load fruitfly image
%     fruitflypic = imread('drosophila.png');
%     image([-1.29 1.49],[1.1 -1.55],fruitflypic);
%     image([-1.29 1.49]/4,[1.1 -1.55]/4,fruitflypic);

  
    % plot starting points again for the sake of the legend
    for j = 1:6 % loop over legs
        Sign = 1;
        StartPositionXAvg(j) = mean(PerpDist(j,StartStep(j,1:counter(j))) / BodyLength);
        StartPositionYAvg(j) = mean(ParaDist(j,StartStep(j,1:counter(j))) / BodyLength);
        StopPositionXAvg(j)  = mean(PerpDist(j, StopStep(j,1:counter(j))) / BodyLength);
        StopPositionYAvg(j)  = mean(ParaDist(j, StopStep(j,1:counter(j))) / BodyLength);
        StartPositionXSTD(j) =  std(PerpDist(j,StartStep(j,1:counter(j))) / BodyLength);
        StartPositionYSTD(j) =  std(ParaDist(j,StartStep(j,1:counter(j))) / BodyLength);
        StopPositionXSTD(j)  =  std(PerpDist(j, StopStep(j,1:counter(j))) / BodyLength);
        StopPositionYSTD(j)  =  std(ParaDist(j, StopStep(j,1:counter(j))) / BodyLength);
        if j > 3, Sign = -1; end; 
        auxh = plot(Sign*PerpDist(j,StartStep(j,1:counter(j))) / BodyLength, ParaDist(j,StartStep(j,1:counter(j))) / BodyLength, 'o','color', RGB(j,:), 'MarkerSize', 2, 'MarkerFaceColor',RGB(j,:));
        set(get(get(auxh,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        hold on;
    end;
    
    % plot stoping points again for the sake of the legend
    for j = 1:6 % loop over legs
      if counter(i) > 0
        Sign = 1;
        if j > 3, Sign = -1; end; 
        auxh = plot(Sign*PerpDist(j,StopStep(j,1:counter(j))) / BodyLength, ParaDist(j,StopStep(j,1:counter(j))) / BodyLength, 'o','color', RGB(j,:), 'MarkerSize', 2, 'MarkerFaceColor',RGB(j,:));
        set(get(get(auxh,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

        
        hold on;
      end;
    end;

% Calculate the distance difference between the AEP and PEP of left-right leg pairs
  AEPFrontDiff  = sqrt((StartPositionXAvg(1) - StartPositionXAvg(4))^2 + (StartPositionYAvg(1) - StartPositionYAvg(4))^2);
  PEPFrontDiff  = sqrt(( StopPositionXAvg(1) -  StopPositionXAvg(4))^2 + ( StopPositionYAvg(1) -  StopPositionYAvg(4))^2);
  AEPMiddleDiff = sqrt((StartPositionXAvg(2) - StartPositionXAvg(5))^2 + (StartPositionYAvg(2) - StartPositionYAvg(5))^2);
  PEPMiddleDiff = sqrt(( StopPositionXAvg(2) -  StopPositionXAvg(5))^2 + ( StopPositionYAvg(2) -  StopPositionYAvg(5))^2);
  AEPHindDiff   = sqrt((StartPositionXAvg(3) - StartPositionXAvg(6))^2 + (StartPositionYAvg(3) - StartPositionYAvg(6))^2);
  PEPHindDiff   = sqrt(( StopPositionXAvg(3) -  StopPositionXAvg(6))^2 + ( StopPositionYAvg(3) -  StopPositionYAvg(6))^2);
    
    % plot ellipse
    t = 0:0.001:2*pi;
    auxh1 = plot(BodyWidth/BodyLength*cos(t)/2,sin(t)/2,'color',[0.5,0.5,0.5],'LineWidth',2);
%     plot(cos(t),sin(t),'color',[0.5,0.5,0.5],'LineWidth',2)
    % plot little arrow
    auxh2 = plot([0 0],    [-0.15 0.15],'color',[0.5,0.5,0.5],'LineWidth',2);
    auxh3 = plot([0  0.01],[0.15 0.01] ,'color',[0.5,0.5,0.5],'LineWidth',1);
    auxh4 = plot([0 -0.01],[0.15 0.01] ,'color',[0.5,0.5,0.5],'LineWidth',1);
    set(get(get(auxh1,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    set(get(get(auxh2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    set(get(get(auxh3,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    set(get(get(auxh4,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

    set(L,'Interpreter','none', 'FontSize', 8, 'Location', 'NorthWest');

    % set picture limits (CESAR)
      XLIMIT = [-1 +1];
      YLIMIT = [-1.2 1.2];
    
      xlim(XLIMIT);
      ylim(YLIMIT);
      
    % set picture size to have correct ratio
    H = xlim;
    W = ylim;
    set(hh,'PaperPosition', [0 0 H(2)-H(1)+0.85 W(2)-W(1)]*5);
    set(gca,'Layer','Top'); % put grid on top
    title('Step AEPs & PEPs');
    xlabel('perpendicular distance from body center [normalized to body length]');
    ylabel('parallel distance from body center [normalized to body length]')
    grid on;
    set(gca, 'FontSize', 12)
    box on;
    hold off;
    ind = find(filename == '\' | filename == '/');
    
    
    set(hh, 'unit', 'inches');
    figure_size = get(hh, 'position');
    set(L,'Interpreter','none', 'FontSize', 7, 'Location', 'EastOutside');
    set(L, 'unit', 'inches');
    legend_size = get(L, 'position');
    figure_size(3) = figure_size(3) + legend_size(3);
    set(hh, 'position', figure_size);
    
     
    
    outputfilename = sprintf('%sAEP_&_PEP_Positions_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
    saveas(hh,outputfilename,'png');
    close(hh);
%%
    
% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;
    
% PEPS    
    % plot leg positions
    h = figure('visible', 'off'); % create plot for this
    hold off;
    % plot starting points
    for j = 1:6 % loop over legs
        Sign = 1;
        if j > 3, Sign = -1; end; 
        plot(Sign*PerpDist(j,StopStep(j,1:counter(j))) / BodyLength, ParaDist(j,StopStep(j,1:counter(j))) / BodyLength, 'o','color', RGB(j,:), 'MarkerSize', 5, 'MarkerFaceColor',RGB(j,:));
      
        hold on;
    end;
    
    % RICARDO CHANGE -> goes downstrea,
    L = legend('Left Fore', 'Left Middle', 'Left Hind', 'Right Fore', 'Right Middle', 'Right Hind');
    
    % ###################################
    % ###################################
    
    % It's cell with n rows and m column, with n=number of legs
    % and m= number of steps, each element contains a matrix of the 
    % following format:
    %       [Start_X, Start_Y, End_X, End_Y] 
    leg_steps_raw = {};
    
    % plot leg tracks with brighter colors
    for i = 1:6
      
      % %%% Added by Inês, 07/06/2021
      points = [];
      points_counter = 0;
      % %%%
      
      if counter(i) > 0
        ind = find(PerpDist(i,:) ~= -1);
        ind = ind(ind >= StartStep(i,1) & ind <= StopStep(i,counter(i))); % this makes sure that only those parts are taken into account that are not part of the steps that are present at the very first or last frames with the body on
        for j = 1:length(ind)-1
            if ind(j+1) - ind(j) == 1
                I = [ind(j) ind(j+1)];
                Sign = 1;
                if i > 3, Sign = -1; end;                 
                
                % Get the points where the lines should be drawn
                X = Sign*PerpDist(i,I) / BodyLength;
                Y = ParaDist(i,I) / BodyLength;
                
                % Plot the Points into the graph
                auxh = plot(X, Y,'color', RGB(i,:), 'LineWidth', 2); %Line thickness
                set(get(get(auxh,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
                
                % %%% Added by Inês, 07/06/2021
                % Convert the points to the format [Start_X, Start_Y,
                % End_X, End_Y] and append to the list
                start_point = [X(:, 1) Y(:, 1)];
                end_point = [X(:, 2) Y(:, 2)];
                points = [points ; start_point end_point];
            else
                % If we reach the end of the the current step, we must save
                % it and reset for the next step
                leg_steps_raw{i, points_counter + 1} = points;
                % save(['trace_par_i' num2str(i) '_' num2str(points_counter)],'points')
                points_counter = points_counter + 1;
                points = [];
                % %%%
            end
        end
      end;
      
      % %%% Added by Inês, 07/06/2021
      % If we reach the end of the step, we must save the data
      if isempty(points) == 0
      	leg_steps_raw{i, points_counter + 1} = points;
        %save(['trace_par_i' num2str(i) '_' num2str(points_counter)],'points')
      end
      % %%% 
    end;
    
    MAXIMUM_ALLOWED_LEGS = 6;
    % Create a Cell containing each leg as a row and each step as a column
    stc_traces_cluster = nan(MAXIMUM_ALLOWED_LEGS, 1);
    for leg = (1:MAXIMUM_ALLOWED_LEGS)
        
        steps = {};
        % The number of steps for the current leg
        number_of_steps = size(leg_steps_raw(leg, :), 2);
        
        for step = 1:number_of_steps
            
            points = leg_steps_raw{leg, step};
            
            if ~isempty(points)
                % Extract the X and Y to be stored
                x = [real(points(:, 1)); real(points(end,3))];
                y = [real(points(:, 2)); real(points(end,4))];

                % Store the X and Y in the Cell
                steps{step} = [x y];
            end
        end
        
        if ~isempty(steps)
            stc_traces_cluster(leg) = calculate_stc_trc_cluster(steps);
        end
    end
    
    % Calculate average front leg
    stc_trace_cluster_mean_front= (stc_traces_cluster(1)+stc_traces_cluster(4))/2;
    
    % Calculate average hind leg
    stc_trace_cluster_mean_hind= (stc_traces_cluster(3)+stc_traces_cluster(6))/2;
    
    % Calculate average all legs
    stc_trace_cluster_mean_all= (stc_traces_cluster(1)+ stc_traces_cluster(2)+stc_traces_cluster(3)+stc_traces_cluster(4)+ stc_traces_cluster(5)+stc_traces_cluster(6))/6;

    % ###################################
    % ###################################
    
    % plot starting points again for the sake of the legend
    for j = 1:6 % loop over legs
      if counter(i) > 0
        Sign = 1;
        if j > 3, Sign = -1; end; 
        auxh = plot(Sign*PerpDist(j,StopStep(j,1:counter(j))) / BodyLength, ParaDist(j,StopStep(j,1:counter(j))) / BodyLength, 'o','color', RGB(j,:), 'MarkerSize', 7, 'MarkerFaceColor',RGB(j,:));
        set(get(get(auxh,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

        
        hold on;
      end;
    end;

    % plot ellipse
    t = 0:0.001:2*pi;
    auxhe1 = plot(BodyWidth/BodyLength*cos(t)/2,sin(t)/2,'color',[0.5,0.5,0.5],'LineWidth',2);
    %plot(cos(t),sin(t),'color',[0.5,0.5,0.5],'LineWidth',2)
    % plot little arrow
    auxhe2 = plot([0 0],[-0.15 0.15],'color',[0.5,0.5,0.5],'LineWidth',2);
    auxhe3 = plot([0  0.01],[0.15 0.01],'color',[0.5,0.5,0.5],'LineWidth',1);
    auxhe4 = plot([0 -0.01],[0.15 0.01],'color',[0.5,0.5,0.5],'LineWidth',1);

   
    set(get(get(auxhe1,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    set(get(get(auxhe2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    set(get(get(auxhe3,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    set(get(get(auxhe4,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

           
    xlim(XLIMIT);
    ylim(YLIMIT);

    % set picture size to have correct ratio
    H = xlim;
    W = ylim;
    
    % RICARDO ADDED SPACE FOR THE LEGEND
    %set(h,'PaperPosition', [0 0 H(2)-H(1) W(2)-W(1)]*5);
    set(h,'PaperPosition', [0 0 H(2)-H(1)+0.85 W(2)-W(1)]*5);

    title('Step PEPs', 'FontSize', 12);
    s2pxl = xlabel('perpendicular distance from body center [normalized to body length]');
    s2pyl = ylabel('parallel distance from body center [normalized to body length]');
    
    set(s2pxl, 'FontSize', 8); 
    set(s2pyl, 'FontSize', 9);
    
    grid on;
    box on;
    hold off;
    ind = find(filename == '\' | filename == '/');
    
    % RICARDO (REVERSE) CHANGE
    %set(gca, 'FontSize', 12);
    %set(gca, 'FontSize', 8);
    
    set(h, 'unit', 'inches');
    figure_size = get(h, 'position');
    set(L,'Interpreter','none', 'FontSize', 7, 'Location', 'EastOutside');
    set(L, 'unit', 'inches');
    legend_size = get(L, 'position');
    figure_size(3) = figure_size(3) + legend_size(3);
    set(h, 'position', figure_size);
    
     
    
    outputfilename = sprintf('%sStepStopRelativePosition_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
    saveas(h,outputfilename,'png');
    close(h);

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;    
 
  %% Added 27/03/2013 
    % plot leg positions
    g = figure('visible', 'off'); % create plot for this
    hold off;
    % plot starting points
    for j = 1:6 % loop over legs
        Sign = 1;
        if j > 3, Sign = -1; end; 
        plot(Sign*PerpDist(j,StartStep(j,1:counter(j))) / BodyLength, ParaDist(j,StartStep(j,1:counter(j))) / BodyLength, 'o','color',[1,1,1], 'MarkerSize', 6, 'MarkerFaceColor',[1,1,1]);
        hold on;
    end;

    % plot leg tracks with brighter colors
    for i = 1:6
        if counter(i) > 0
          ind = find(PerpDist(i,:) ~= -1);
          ind = ind(ind >= StartStep(i,1) & ind <= StopStep(i,counter(i))); % this makes sure that only those parts are taken into account that are not part of the steps that are present at the very first or last frames with the body on        
          for j = 1:length(ind)-1
              if ind(j+1) - ind(j) == 1
                  I = [ind(j) ind(j+1)];
                  Sign = 1;
                  if i > 3, Sign = -1; end;
                  plot(Sign*PerpDist(i,I) / BodyLength, ParaDist(i,I) / BodyLength,'color', RGB(6,:), 'LineWidth', 2); % Line thickness
              end
          end
        end;
    end;
    
    
    % plot starting points again for the sake of the legend
    for j = 1:6 % loop over legs
        Sign = 1;
        StartPositionXAvg(j) = mean(PerpDist(j,StartStep(j,1:counter(j))) / BodyLength);
        StartPositionYAvg(j) = mean(ParaDist(j,StartStep(j,1:counter(j))) / BodyLength);
        StopPositionXAvg(j)  = mean(PerpDist(j, StopStep(j,1:counter(j))) / BodyLength);
        StopPositionYAvg(j)  = mean(ParaDist(j, StopStep(j,1:counter(j))) / BodyLength);
        StartPositionXSTD(j) =  std(PerpDist(j,StartStep(j,1:counter(j))) / BodyLength);
        StartPositionYSTD(j) =  std(ParaDist(j,StartStep(j,1:counter(j))) / BodyLength);
        StopPositionXSTD(j)  =  std(PerpDist(j, StopStep(j,1:counter(j))) / BodyLength);
        StopPositionYSTD(j)  =  std(ParaDist(j, StopStep(j,1:counter(j))) / BodyLength);
        if j > 3, Sign = -1; end; 
    end;

% Calculate the distance difference between the AEP and PEP of left-right leg pairs
  AEPFrontDiff  = sqrt((StartPositionXAvg(1) - StartPositionXAvg(4))^2 + (StartPositionYAvg(1) - StartPositionYAvg(4))^2);
  PEPFrontDiff  = sqrt(( StopPositionXAvg(1) -  StopPositionXAvg(4))^2 + ( StopPositionYAvg(1) -  StopPositionYAvg(4))^2);
  AEPMiddleDiff = sqrt((StartPositionXAvg(2) - StartPositionXAvg(5))^2 + (StartPositionYAvg(2) - StartPositionYAvg(5))^2);
  PEPMiddleDiff = sqrt(( StopPositionXAvg(2) -  StopPositionXAvg(5))^2 + ( StopPositionYAvg(2) -  StopPositionYAvg(5))^2);
  AEPHindDiff   = sqrt((StartPositionXAvg(3) - StartPositionXAvg(6))^2 + (StartPositionYAvg(3) - StartPositionYAvg(6))^2);
  PEPHindDiff   = sqrt(( StopPositionXAvg(3) -  StopPositionXAvg(6))^2 + ( StopPositionYAvg(3) -  StopPositionYAvg(6))^2);

    % set picture limits (CESAR)
      XLIMIT = [-1 +1];
      YLIMIT = [-1.2 1.2];
    
      xlim(XLIMIT);
      ylim(YLIMIT);
      
    % set picture size to have correct ratio
    H = xlim;
    W = ylim;
    set(g,'PaperPosition', [0 0 H(2)-H(1) W(2)-W(1)]*5);
    set(gca,'Layer','Top'); % put grid on top
    title('Step AEPs');
    s3pxl = xlabel('perpendicular distance from body center [normalized to body length]');
    s3pyl = ylabel('parallel distance from body center [normalized to body length]');
   
    set(s3pxl, 'FontSize', 8); 
    set(s3pyl, 'FontSize', 9);
    
    
    
    %set(gca, 'FontSize', 12)
    box on;
    hold off;
    ind = find(filename == '\' | filename == '/');
    
   
    
    outputfilename = sprintf('%sStanceTraces_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
    saveas(g,outputfilename,'png');
    close(g);
     
  % check for ABORT
    if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;    
 
    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALCULATE LEG POSITION JITTER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Jitter = zeros(1,6);    
    for i = 1:6
      Jittercount = 0;
      if counter(i) > 0
        ind = find(PerpDist(i,:) ~= -1);
        ind = ind(ind >= StartStep(i,1) & ind <= StopStep(i,counter(i))); % this makes sure that only those parts are taken into account that are not part of the steps that are present at the very first or last frames with the body on
        Para = [];
        Perp = [];
        for j = 1:length(ind)-1
            if ind(j+1) - ind(j) == 1
                I = [ind(j) ind(j+1)];
                Para(end+1) = ParaDist(i,I(2)) / BodyLength;
                Perp(end+1) = PerpDist(i,I(2)) / BodyLength;
            else
                if length(Perp) > 0
                    % Calculate moving average
                      Jittercount = Jittercount + 1;
                      PerpMovingAvg(Jittercount) = sum(abs(smooth(Perp,5)' - Perp));
                      Para = [];
                      Perp = [];
                end;
            end
        end
        Jitter(i)     = mean(PerpMovingAvg) * 1000;
      end;
    end;

%Added by Inês
%Substitutes all 0's with NaN's to prevent 0's of middles legs influencing mean value 
Jitter(find(~Jitter))=NaN;

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;
    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALCULATE BODY POSITION JITTER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
BodyJitter = 0;    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> old code is commmented
ind = find(TCx > 0);
% ind = find(BodyX > 0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> old code is commmented
SmoothBodyX = smooth(TCx(ind),5);
% SmoothBodyX = smooth(BodyX(ind),5);
SmoothBodyY = smooth(TCy(ind),5);
% SmoothBodyY = smooth(BodyY(ind),5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> old code is commmented
BodyJitter = mean(sqrt((SmoothBodyX - TCx(ind)').^2 + (SmoothBodyY - TCy(ind)').^2)) * 1000;
% BodyJitter = mean(sqrt((SmoothBodyX - BodyX(ind)').^2 + (SmoothBodyY - BodyY(ind)').^2)) * 1000;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALCULATE TRIPOD INDEX AND TETRAPOD INDEX AND OTHERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate ratio of frames where N number of legs are present versus total
% number of frames where at least one leg is present.
%Xana: Added Non compliance index that indicates if the walking patterns
%don't break rules of movement

Total(1:7) = 0;
TripodIndex = 0;
TetrapodIndex = 0;
WaveGaitIndex = 0;
PaceIndex = 0; % Pace:  Ipsilateral (same side) fore and hind leg only in stance phase
TrotIndex = 0; % Trot:  Contralateral (opposite side) fore and hind leg only in stance phase
WalkIndex = 0; % Walk: Three of the four corner legs only in stance phase
NoncomplianceIndex = 0; %Noncompliance: Two ipsilateral consecutive legs or two contralateral legs in swing
for i = 1:length(time)
    N = 0;
    if LeftFrontLegX(i)   > 0, N = N+1; end;
    if RightFrontLegX(i)  > 0, N = N+1; end;
    if LeftMiddleLegX(i)  > 0, N = N+1; end;
    if RightMiddleLegX(i) > 0, N = N+1; end;
    if LeftBackLegX(i)    > 0, N = N+1; end;
    if RightBackLegX(i)   > 0, N = N+1; end;    
    Total(N+1) = Total(N+1) + 1;
    % initialize CombinationCode. It is 0 for non-canonical combinations,
    % while it will be 1 or -1 for tri and tetrapods, respectively.
      CombinationCode(i) = 0;
    % only if this is four-leg mode
      if FourFeetOn == 1
        % identify pace events
          if  LeftFrontLegX(i)  > 0 & RightFrontLegX(i)  < 0                                                    & LeftBackLegX(i)  > 0 & RightBackLegX(i)  < 0, PaceIndex     = PaceIndex     + 1;  CombinationCode(i) =  3; end;
          if  LeftFrontLegX(i)  < 0 & RightFrontLegX(i)  > 0                                                    & LeftBackLegX(i)  < 0 & RightBackLegX(i)  > 0, PaceIndex     = PaceIndex     + 1;  CombinationCode(i) =  3; end;
        % identify trot events
          if  LeftFrontLegX(i)  > 0 & RightFrontLegX(i)  < 0                                                    & LeftBackLegX(i)  < 0 & RightBackLegX(i)  > 0, TrotIndex     = TrotIndex     + 1;  CombinationCode(i) =  4; end;
          if  LeftFrontLegX(i)  < 0 & RightFrontLegX(i)  > 0                                                    & LeftBackLegX(i)  > 0 & RightBackLegX(i)  < 0, TrotIndex     = TrotIndex     + 1;  CombinationCode(i) =  4; end;
        % identify walk events
          if  LeftFrontLegX(i)  > 0 & RightFrontLegX(i)  > 0                                                    & LeftBackLegX(i)  > 0 & RightBackLegX(i)  < 0, WalkIndex     = WalkIndex     + 1;  CombinationCode(i) =  5; end;
          if  LeftFrontLegX(i)  > 0 & RightFrontLegX(i)  > 0                                                    & LeftBackLegX(i)  < 0 & RightBackLegX(i)  > 0, WalkIndex     = WalkIndex     + 1;  CombinationCode(i) =  5; end;
          if  LeftFrontLegX(i)  > 0 & RightFrontLegX(i)  < 0                                                    & LeftBackLegX(i)  > 0 & RightBackLegX(i)  > 0, WalkIndex     = WalkIndex     + 1;  CombinationCode(i) =  5; end;
          if  LeftFrontLegX(i)  < 0 & RightFrontLegX(i)  > 0                                                    & LeftBackLegX(i)  > 0 & RightBackLegX(i)  > 0, WalkIndex     = WalkIndex     + 1;  CombinationCode(i) =  5; end;      
      else
        % Identify tripod events
          if  LeftFrontLegX(i)  > 0 & RightFrontLegX(i) <= 0 & LeftMiddleLegX(i) <= 0 & RightMiddleLegX(i)  > 0 & LeftBackLegX(i)  > 0 & RightBackLegX(i) <= 0, TripodIndex = TripodIndex + 1;      CombinationCode(i) = 1; end;
          if  LeftFrontLegX(i) <= 0 & RightFrontLegX(i)  > 0 & LeftMiddleLegX(i)  > 0 & RightMiddleLegX(i) <= 0 & LeftBackLegX(i) <= 0 & RightBackLegX(i)  > 0, TripodIndex = TripodIndex + 1;      CombinationCode(i) = 1; end;
        % Identify tetrapod events
          if  LeftFrontLegX(i) <= 0 & RightFrontLegX(i)  > 0 & LeftMiddleLegX(i)  > 0 & RightMiddleLegX(i) <= 0 & LeftBackLegX(i)  > 0 & RightBackLegX(i)  > 0, TetrapodIndex = TetrapodIndex + 1;  CombinationCode(i) = -1; end;
          if  LeftFrontLegX(i) <= 0 & RightFrontLegX(i)  > 0 & LeftMiddleLegX(i)  > 0 & RightMiddleLegX(i)  > 0 & LeftBackLegX(i)  > 0 & RightBackLegX(i) <= 0, TetrapodIndex = TetrapodIndex + 1;  CombinationCode(i) = -1; end;
          if  LeftFrontLegX(i)  > 0 & RightFrontLegX(i) <= 0 & LeftMiddleLegX(i) <= 0 & RightMiddleLegX(i)  > 0 & LeftBackLegX(i)  > 0 & RightBackLegX(i)  > 0, TetrapodIndex = TetrapodIndex + 1;  CombinationCode(i) = -1; end;
          if  LeftFrontLegX(i)  > 0 & RightFrontLegX(i)  > 0 & LeftMiddleLegX(i) <= 0 & RightMiddleLegX(i)  > 0 & LeftBackLegX(i)  > 0 & RightBackLegX(i) <= 0, TetrapodIndex = TetrapodIndex + 1;  CombinationCode(i) = -1; end;
          if  LeftFrontLegX(i)  > 0 & RightFrontLegX(i) <= 0 & LeftMiddleLegX(i)  > 0 & RightMiddleLegX(i)  > 0 & LeftBackLegX(i) <= 0 & RightBackLegX(i)  > 0, TetrapodIndex = TetrapodIndex + 1;  CombinationCode(i) = -1; end;
          if  LeftFrontLegX(i)  > 0 & RightFrontLegX(i)  > 0 & LeftMiddleLegX(i)  > 0 & RightMiddleLegX(i) <= 0 & LeftBackLegX(i) <= 0 & RightBackLegX(i)  > 0, TetrapodIndex = TetrapodIndex + 1;  CombinationCode(i) = -1; end;
        % Identify wave gait events
          if  LeftFrontLegX(i) <= 0 & RightFrontLegX(i)  > 0 & LeftMiddleLegX(i)  > 0 & RightMiddleLegX(i)  > 0 & LeftBackLegX(i)  > 0 & RightBackLegX(i)  > 0, WaveGaitIndex = WaveGaitIndex + 1;  CombinationCode(i) =  2; end;
          if  LeftFrontLegX(i)  > 0 & RightFrontLegX(i) <= 0 & LeftMiddleLegX(i)  > 0 & RightMiddleLegX(i)  > 0 & LeftBackLegX(i)  > 0 & RightBackLegX(i)  > 0, WaveGaitIndex = WaveGaitIndex + 1;  CombinationCode(i) =  2; end;
          if  LeftFrontLegX(i)  > 0 & RightFrontLegX(i)  > 0 & LeftMiddleLegX(i) <= 0 & RightMiddleLegX(i)  > 0 & LeftBackLegX(i)  > 0 & RightBackLegX(i)  > 0, WaveGaitIndex = WaveGaitIndex + 1;  CombinationCode(i) =  2; end;
          if  LeftFrontLegX(i)  > 0 & RightFrontLegX(i)  > 0 & LeftMiddleLegX(i)  > 0 & RightMiddleLegX(i) <= 0 & LeftBackLegX(i)  > 0 & RightBackLegX(i)  > 0, WaveGaitIndex = WaveGaitIndex + 1;  CombinationCode(i) =  2; end;
          if  LeftFrontLegX(i)  > 0 & RightFrontLegX(i)  > 0 & LeftMiddleLegX(i)  > 0 & RightMiddleLegX(i)  > 0 & LeftBackLegX(i)  <=0 & RightBackLegX(i)  > 0, WaveGaitIndex = WaveGaitIndex + 1;  CombinationCode(i) =  2; end;
          if  LeftFrontLegX(i)  > 0 & RightFrontLegX(i)  > 0 & LeftMiddleLegX(i)  > 0 & RightMiddleLegX(i)  > 0 & LeftBackLegX(i)  > 0 & RightBackLegX(i) <= 0, WaveGaitIndex = WaveGaitIndex + 1;  CombinationCode(i) =  2; end;      
      end;
end

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;

 
for i = 1:length(time)
    CombinationCodeCompliance(i) = 0;
    % Identify non compliance events
         if LeftFrontLegX(i) < 0 & RightFrontLegX(i) < 0 & LeftMiddleLegX(i) < 0 & RightMiddleLegX(i) < 0 & LeftBackLegX(i) < 0 & RightBackLegX(i) < 0; CombinationCodeCompliance(i) = 6;
         elseif LeftFrontLegX(i) <   0 & RightFrontLegX(i) <   0 & LeftMiddleLegX(i) >= -1 & RightMiddleLegX(i) >= -1 & LeftBackLegX(i) >= -1 & RightBackLegX(i) >= -1, NoncomplianceIndex = NoncomplianceIndex + 1;  CombinationCodeCompliance(i) =  7; CombinationCode(i) =  7;
         elseif LeftFrontLegX(i) >= -1 & RightFrontLegX(i) >= -1 & LeftMiddleLegX(i) <   0 & RightMiddleLegX(i) <   0 & LeftBackLegX(i) >= -1 & RightBackLegX(i) >= -1, NoncomplianceIndex = NoncomplianceIndex + 1;  CombinationCodeCompliance(i) =  8; CombinationCode(i) =  8;
         elseif LeftFrontLegX(i) >= -1 & RightFrontLegX(i) >= -1 & LeftMiddleLegX(i) >= -1 & RightMiddleLegX(i) >= -1 & LeftBackLegX(i) <   0 & RightBackLegX(i) <   0, NoncomplianceIndex = NoncomplianceIndex + 1;  CombinationCodeCompliance(i) =  9; CombinationCode(i) =  9;
         elseif LeftFrontLegX(i) <   0 & RightFrontLegX(i) >= -1 & LeftMiddleLegX(i) <   0 & RightMiddleLegX(i) >= -1 & LeftBackLegX(i) >= -1 & RightBackLegX(i) >= -1, NoncomplianceIndex = NoncomplianceIndex + 1;  CombinationCodeCompliance(i) =  10; CombinationCode(i) =  10;
         elseif LeftFrontLegX(i) >= -1 & RightFrontLegX(i) >= -1 & LeftMiddleLegX(i) <   0 & RightMiddleLegX(i) >= -1 & LeftBackLegX(i) <   0 & RightBackLegX(i) >= -1, NoncomplianceIndex = NoncomplianceIndex + 1;  CombinationCodeCompliance(i) =  11; CombinationCode(i) =  11;
         elseif LeftFrontLegX(i) >= -1 & RightFrontLegX(i) <   0 & LeftMiddleLegX(i) >= -1 & RightMiddleLegX(i) <   0 & LeftBackLegX(i) >= -1 & RightBackLegX(i) >= -1, NoncomplianceIndex = NoncomplianceIndex + 1;  CombinationCodeCompliance(i) =  12; CombinationCode(i) =  12;
         elseif LeftFrontLegX(i) >= -1 & RightFrontLegX(i) >= -1 & LeftMiddleLegX(i) >= -1 & RightMiddleLegX(i) <   0 & LeftBackLegX(i) >= -1 & RightBackLegX(i) <   0, NoncomplianceIndex = NoncomplianceIndex + 1;  CombinationCodeCompliance(i) =  13; CombinationCode(i) =  13;
      end;
end

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CALCULATE MIN,MAX,MEAN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate extreme and mean values
ind = 1:length(time);


% calculate min, max and mean distances from center of body
% disp( '---------------------------------')
disp('')
disp('Calculating distance min,max,mean...')
% disp(' ')
% disp( '        LF       LM        LH        RF       RM        RH')
for i = 1:6
    if counter(i) > 0
      % Distance
      D = Distance(i,ind);
      IND = find(D ~= -1);
      MinDist(i) = min(D(IND));
      MaxDist(i) = max(D(IND));
      MeanDist(i) = mean(D(IND));
      % Perpendicular distance
      D = PerpDist(i,ind);
      IND = find(D ~= -1);
      MinPerpDist(i) = min(D(IND));
      MaxPerpDist(i) = max(D(IND));
      MeanPerpDist(i) = mean(D(IND));
      % Distance
      D = ParaDist(i,ind);
      IND = find(D ~= -1);
      MinParaDist(i) = min(D(IND));
      MaxParaDist(i) = max(D(IND));
      MeanParaDist(i) = mean(D(IND));
      % Angle
      D = Angle(i,ind);
      IND = find(D ~= -1);
      MinAngle(i) = min(D(IND));
      MaxAngle(i) = max(D(IND));
      MeanAngle(i) = mean(D(IND));
    end;
end;

% disp(['min  =   ' num2str(MIN(1)) '  ' num2str(MIN(2)) '  ' num2str(MIN(3)) '  ' num2str(MIN(4)) '  ' num2str(MIN(5)) '  ' num2str(MIN(6))])
% disp(['max  =   ' num2str(MAX(1)) '  ' num2str(MAX(2)) '  ' num2str(MAX(3)) '  ' num2str(MAX(4)) '  ' num2str(MAX(5)) '  ' num2str(MAX(6))])
% disp(['mean =   ' num2str(MEAN(1)) '  ' num2str(MEAN(2)) '  ' num2str(MEAN(3)) '  ' num2str(MEAN(4)) '  ' num2str(MEAN(5)) '  ' num2str(MEAN(6))])

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot Results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot only those for which the body is fully in the picture. This is
% determined by requiring the BodySTD to reach 85% of the median.
% MedianBodyStdX = median(BodyStdX);
% MedianBodyStdY = median(BodyStdY);
% ind = find(BodyStdX > MedianBodyStdX*0.85 & BodyStdY > MedianBodyStdY*0.85);
ind = 1:length(time);

if PLOT == 1
    PlotResults(Distance(:,ind), time(ind), 'Leg distances from the center of the body', 'distance [mm]', 1, [foldername 'FlyLegDistance.png']);
    PlotResults(PerpDist(:,ind), time(ind), 'Leg perpendicular distances from the center of the body', 'distance [mm]', 2, [foldername 'FlyLegPerpDistance.png']);
    PlotResults(ParaDist(:,ind), time(ind), 'Leg parallel distances from the center of the body', 'distance [mm]', 3, [foldername 'FlyLegParaDistance.png']);
    PlotResults(Angle(:,ind), time(ind), 'Leg angles from the center of the body compared to the direction of the body', 'angle [degrees]', 4, [foldername 'FlyLegAngle.png']);


%system([foldername 'FlyLegParaDistance.png']);    
%system([foldername 'FlyLegParaDistance.png &']);

%     plot(time, BodyStdX, 'r', time, BodyStdY, 'b')
%     hold on;
%     MedianBodyStdX = median(BodyStdX);
%     MedianBodyStdY = median(BodyStdY);
%     indX = find(BodyStdX > MedianBodyStdX*0.85);
%     indY = find(BodyStdY > MedianBodyStdY*0.85);
%     plot(time(indX), BodyStdX(indX), 'k', time(indY), BodyStdY(indY), 'g')
%     hold off;
    % PlotResults(BodyStdX, time, 'BodyStdY', 'distance [um]', 6, 'FlyBodyStdY.png');
end

% fclose(fid);

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Measure which leg combination is down for how long and sort results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEXT = ['LF'; 'LM'; 'LH'; 'RH'; 'RM'; 'RF'];
% AllLegsX = [LeftFrontLegX; LeftMiddleLegX; LeftBackLegX; RightBackLegX; RightMiddleLegX; RightFrontLegX];
% AllLegsY = [LeftFrontLegY; LeftMiddleLegY; LeftBackLegY; RightBackLegY; RightMiddleLegY; RightFrontLegY];
disp(' ')
disp('Calculating most common leg combinations')
disp(' ')

TEXT = ['LF'; 'LM'; 'LH'; 'RF'; 'RM'; 'RH'];
AllLegsX = [LeftFrontLegX; LeftMiddleLegX; LeftBackLegX; RightFrontLegX; RightMiddleLegX; RightBackLegX];
AllLegsY = [LeftFrontLegY; LeftMiddleLegY; LeftBackLegY; RightFrontLegY; RightMiddleLegY; RightBackLegY];
LegDown(1:64) = 0; % each represents a combination of legs. This will be a count of how many times that combination is down.
for i = 1:length(time)
    % loop over legs. Each leg is represented with 2^i where i is the leg
    % number
    LegCombination = 0;
    NumberofLegs = 0;
    for j = 1:6
        % convert leg combination into number from 1 to 64
        if AllLegsX(j,i) ~= -1
            LegCombination = LegCombination + 2^(6-j);
            NumberofLegs = NumberofLegs + 1;
        end;
    end;
    % save legcombinations in an array
      LegCombinationArray(i) = LegCombination;
      
    % make the empty legcombination be 64 so Matlab can store it
    if LegCombination  == 0
        LegCombination = 64;
    end;
    % consider only those combinations where there are at least 3 legs
    if NumberofLegs >= 1
        LegDown(LegCombination) = LegDown(LegCombination) + 1;
    end;
end;
% cut out no legs
LegDown = LegDown(1:63);
% choose the most common ones
[B, CommonLegDown] = sort(LegDown);
B = B(63:-1:1);
CommonLegDown = CommonLegDown(63:-1:1);
MostCommonCombinations = dec2bin(CommonLegDown,6)

NumbersofCombinations = B;


% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot triangles based on which is most common
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
disp('Plotting triangles...')
disp(' ')

TEXT = ['LF'; 'LM'; 'LH'; 'RH'; 'RM'; 'RF'];
AllLegsX = [LeftFrontLegX; LeftMiddleLegX; LeftBackLegX; RightBackLegX; RightMiddleLegX; RightFrontLegX];
AllLegsY = [LeftFrontLegY; LeftMiddleLegY; LeftBackLegY; RightBackLegY; RightMiddleLegY; RightFrontLegY];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre

% initialize table to store polygon area, stability ratio and the shortest 
% distance to any of the polygon edges. Start by creating cells containing 
% 'No data' strings, meaning the polygon was not plotted for that particular 
% instant. Then, replace them with real data, if there's any (at a given
% frame i).

no_data = cell(length(time),1);
no_data(1:end) = {'No data'};
% empty_cell = cell(length(time),1);
tri_table = table([1:length(time)]',no_data,no_data,no_data,no_data,no_data,no_data,'VariableNames', {'Frame','State','Points_of_contact','Center_to_edge_dist','Centroid_to_edge_dist','Stability_ratio','Polygon_area'});




%%%%%
color_vector = zeros(length(time),3);
indexes = zeros(length(time),1);
%%%%%

if PLOT == 1
    NumberofMostCommon = 5;
    triang_figure = figure('visible', 'off');
    hold off;
    
    RGB = [1   0   0; ...
           1   0.5 0; ...
           0   1   0; ...
           0.5 1   1; ...
           0   0   1; ...
           0   0   0];
    for i = 1:length(time) % loop over time
        % convert legs that are down to format of the most common combinations
        LegCombination = 0;
        for j = 1:6
            % convert leg combination into number from 1 to 64
            if AllLegsX(j,i) ~= -1
                LegCombination = LegCombination + 2^(j-1);
            end;
        end;

        % determine whether LegCombination is one of the most common
        Common = 0;
        for j = 1:NumberofMostCommon % loop over most common leg combinations
            if LegCombination == CommonLegDown(j)
                Common = j;
                Color = RGB(j,:);
            end;
        end;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Alexandre        
        % first column of tri_table indicates the frame number
        tri_table.Frame(i,1) = i;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % if it is one of the most common, plot it
        if Common ~= 0
            X = [];
            Y = [];
    %         Color = 'g';
    %         if AllLegsX(1,i) ~= -1
    %             Color = 'r';
    %         end;
            for j = 1:6
                % convert leg combination into number from 1 to 64
                if AllLegsX(j,i) ~= -1
                    X = [X AllLegsX(j,i)];
                    Y = [Y AllLegsY(j,i)];
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Alexandre -> added tag for post processing
                    text(AllLegsX(j,i) + 3*p.distcal, AllLegsY(j,i) + (-3+50*(Common-1))/p.distcal,TEXT(j,:),'Interpreter','none', 'Color',Color,'FontSize', 8,'tag',strcat(strcat('leg_text_',num2str(i),num2str(j))));
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                 text(AllLegsX(j,i) + 3+150*Common, AllLegsY(j,i),TEXT(j,:),'Interpreter','none', 'Color',Color,'FontSize', 8);
    %                 text(AllLegsX(j,i) + 3, AllLegsY(j,i),TEXT(j,:),'Interpreter','none', 'Color',Color,'FontSize', 8);
                    hold on;
                end;
            end;
            % plot leg positions
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Alexandre -> added tag for post processing
            plot([X X(1)],[Y Y(1)]+50*(Common-1)/p.distcal,'Color', Color,'tag',strcat('polygon_',num2str(i)));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Alexandre
            color_vector(i,:) = Color;
            indexes(i) = 1;
            % Determine nb. of points of contact
            if length(X) == 3
                tri_table.Points_of_contact(i) = num2cell(3);
            elseif length(X) == 4
                tri_table.Points_of_contact(i) = num2cell(4);
            else
                disp('Neither 3 nor 4 points of contact in frame nb:')
                disp(i)
                disp('')
                disp('Nb of points of contact in this frame:')
                disp(length(X))
                tri_table.Points_of_contact(i) = num2cell(length(X));
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %         plot([X X(1)]+150*Common,[Y Y(1)],'Color', Color);
    %         plot(BodyX(i)+150*Common,BodyY(i),'co');
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Alexandre -> old code is commmented; added tag for post processing   
            plot(TCx(i),TCy(i)+50*(Common-1)/p.distcal,'co','tag',strcat('blue_circle_',num2str(i)));
%           plot(BodyX(i),BodyY(i)+50*(Common-1)/p.distcal,'co');
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %         plot(mean(X)+150*Common,mean(Y),'rx');
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Alexandre -> added tag for post processing
            plot(mean(X),mean(Y)+50*(Common-1)/p.distcal,'rx','tag',strcat('red_cross_',num2str(i)));
    %         text(BodyX(i) + 3+150*Common, BodyY(i),num2str(i),'Interpreter','none', 'Color',[0 0 1],'FontSize', 8);
%             text(BodyX(i), BodyY(i) + 50*(Common-1),num2str(i),'Interpreter','none', 'Color',[0 0 1],'FontSize', 8);

    %         plot([X X(1)],[Y Y(1)],'Color', Color);
            
        %%%%% Alexandre -> Fly axis
        
        % Define the polygon's vectors:
        poly_X = [X X(1)];
        poly_Y = [Y Y(1)]+50*(Common-1)/p.distcal;
        
        if BodyDirection3(i) == 1
            angle = atan(BodyDirection1(i));
            % Multiply by 4 to make sure the axis intersects the polygon
            FrontX = BodyX(i) + 4*BodyStdY(i)*cos(angle);
            FrontY = BodyY(i) + 4*BodyStdY(i)*sin(angle);
            X_axis = [FrontX 2*BodyX(i) - FrontX];
            Y_axis = [FrontY 2*BodyY(i) - FrontY];
            [~,~,ii] = polyxpoly(X_axis+p.cut.left-1,Y_axis+p.cut.up-1+50*(Common-1)/p.distcal,poly_X,poly_Y);
%             if isempty(ii)
%                 plot(X_axis+p.cut.left-1,Y_axis+p.cut.up-1+50*(Common-1)/p.distcal,'Color',Color,'LineWidth', 1.5);
%             end
%             if Orientation(i) == 1
%               plot(X(1)+p.cut.left-1,Y(1)+p.cut.up-1+50*(Common-1)/p.distcal,'yd','MarkerSize', 5, 'MarkerFaceColor','y');
%             elseif Orientation(i) == -1 
%               plot(X(2)+p.cut.left-1,Y(2)+p.cut.up-1+50*(Common-1)/p.distcal,'yd','MarkerSize', 5, 'MarkerFaceColor','y');
%             end;
        else
            angle = atan(BodyDirection1(i));
            % Multiply by 4 to make sure the axis intersects the polygon
            % Ricardo changed the next two lines 
            %FrontX = BodyX(i) + 6*BodyStdX(i)*sin(angle);
            %FrontY = BodyY(i) + 6*BodyStdX(i)*cos(angle);
            FrontX = BodyX(i) + 4*BodyStdY(i)*cos(angle);
            FrontY = BodyY(i) + 4*BodyStdY(i)*sin(angle);
          
            X_axis = [FrontX 2*BodyX(i) - FrontX];
            Y_axis = [FrontY 2*BodyY(i) - FrontY];
            [~,~,ii] = polyxpoly(X_axis+p.cut.left-1,Y_axis+p.cut.up-1+50*(Common-1)/p.distcal,poly_X,poly_Y);
%             if isempty(ii)
%                 plot(X_axis+p.cut.left-1,Y_axis+p.cut.up-1+50*(Common-1)/p.distcal,'Color',Color);
%             end
%             if Orientation(i) == 1
%               plot(X(1)+p.cut.left-1,Y(1)+p.cut.up-1+50*(Common-1)/p.distcal,'yd','MarkerSize', 5, 'MarkerFaceColor','y');
%             elseif Orientation(i) == -1            
%               plot(X(2)+p.cut.left-1,Y(2)+p.cut.up-1+50*(Common-1)/p.distcal,'yd','MarkerSize', 5, 'MarkerFaceColor','y');
%             end;
        end;
        %%%% 

            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Alexandre
            
            % Determine if the fly's centroid is located on the inside or
            % outside of the polygon
            
%             [d_TC,closest_x,closest_y] = p_poly_dist(TCx(i),TCy(i)+50*(Common-1)/p.distcal,[X X(1)],[Y Y(1)]+50*(Common-1)/p.distcal);
            
            if ~inpolygon(TCx(i),TCy(i)+50*(Common-1)/p.distcal,[X X(1)],[Y Y(1)]+50*(Common-1)/p.distcal)
                % disp('Unstable')
                tri_table.State(i) = {'Unstable'};
                % if the centroid is located on the outside, color it red
                set(findobj('tag',strcat('blue_circle',num2str(i))),'Color','r')
            else
                tri_table.State(i) = {'Stable'};
            end
            
            
            if isempty(ii)
                disp('No intersections at frame:')
                disp(i)
                disp('Skipping to the next frame...')
                % Update indexes vector and delete data
                color_vector(i,:) = 0;
                indexes(i) = 0;
                tri_table.State(i) = {'No data'};
                tri_table.Points_of_contact(i) = {'No data'};
                tri_table.Center_to_edge_dist(i) = {'No data'};
                tri_table.Centroid_to_edge_dist(i) = {'No data'};
                tri_table.Stability_ratio(i) = {'No data'};
                tri_table.Polygon_area(i) = {'No data'};
            else
                
                % compute metrics based on the reference side (note that we
                % need to compute both the onset and offset distances here)
                % disp(ii)
                if size(ii,1)>2
                    % Only compute metrics for triangles and quadrilateral polygons
                    disp('Alexandre, check line 1181 hexa. There are more than 2 intersections.')
                    return;
                else
                    
                    % We also need to decide which side to use (it should be the closest one to
                    % the fly's COM). This, however, implies that we need to
                    % compute both onset and offset metrics, and then compare
                    % the two.
                    
                    % Onset metrics:
                    if ii(1,2) == 1
                        d_ref_on = line_dist(poly_X(1),poly_Y(1),poly_X(2),poly_Y(2),mean(X),mean(Y)+50*(Common-1)/p.distcal);
                        d_TC_on = line_dist(poly_X(1),poly_Y(1),poly_X(2),poly_Y(2),TCx(i),TCy(i)+50*(Common-1)/p.distcal);
                    elseif ii(1,2) == 2
                        d_ref_on = line_dist(poly_X(2),poly_Y(2),poly_X(3),poly_Y(3),mean(X),mean(Y)+50*(Common-1)/p.distcal);
                        d_TC_on = line_dist(poly_X(2),poly_Y(2),poly_X(3),poly_Y(3),TCx(i),TCy(i)+50*(Common-1)/p.distcal);
                    elseif ii(1,2) == 3
                        d_ref_on = line_dist(poly_X(3),poly_Y(3),poly_X(4),poly_Y(4),mean(X),mean(Y)+50*(Common-1)/p.distcal);
                        d_TC_on = line_dist(poly_X(3),poly_Y(3),poly_X(4),poly_Y(4),TCx(i),TCy(i)+50*(Common-1)/p.distcal);
                    elseif ii(1,2) == 4
                        d_ref_on = line_dist(poly_X(4),poly_Y(4),poly_X(5),poly_Y(5),mean(X),mean(Y)+50*(Common-1)/p.distcal);
                        d_TC_on = line_dist(poly_X(4),poly_Y(4),poly_X(5),poly_Y(5),TCx(i),TCy(i)+50*(Common-1)/p.distcal);
                    % We need to take into account that there can be more
                    % than 4 sides in the polygon (if the fly has more than
                    % 4 feet ON in the same frame:
                    elseif ii(1,2) == 5
                        d_ref_on = line_dist(poly_X(5),poly_Y(5),poly_X(6),poly_Y(6),mean(X),mean(Y)+50*(Common-1)/p.distcal);
                        d_TC_on = line_dist(poly_X(5),poly_Y(5),poly_X(6),poly_Y(6),TCx(i),TCy(i)+50*(Common-1)/p.distcal);
                    elseif ii(1,2) == 6
                        d_ref_on = line_dist(poly_X(6),poly_Y(6),poly_X(7),poly_Y(7),mean(X),mean(Y)+50*(Common-1)/p.distcal);
                        d_TC_on = line_dist(poly_X(6),poly_Y(6),poly_X(7),poly_Y(7),TCx(i),TCy(i)+50*(Common-1)/p.distcal);
                    end
                    
                    % Offset metrics:
                    if ii(2,2) == 1
                        d_ref_off = line_dist(poly_X(1),poly_Y(1),poly_X(2),poly_Y(2),mean(X),mean(Y)+50*(Common-1)/p.distcal);
                        d_TC_off = line_dist(poly_X(1),poly_Y(1),poly_X(2),poly_Y(2),TCx(i),TCy(i)+50*(Common-1)/p.distcal);
                    elseif ii(2,2) == 2
                        d_ref_off = line_dist(poly_X(2),poly_Y(2),poly_X(3),poly_Y(3),mean(X),mean(Y)+50*(Common-1)/p.distcal);
                        d_TC_off = line_dist(poly_X(2),poly_Y(2),poly_X(3),poly_Y(3),TCx(i),TCy(i)+50*(Common-1)/p.distcal);
                    elseif ii(2,2) == 3
                        d_ref_off = line_dist(poly_X(3),poly_Y(3),poly_X(4),poly_Y(4),mean(X),mean(Y)+50*(Common-1)/p.distcal);
                        d_TC_off = line_dist(poly_X(3),poly_Y(3),poly_X(4),poly_Y(4),TCx(i),TCy(i)+50*(Common-1)/p.distcal);
                    elseif ii(2,2) == 4
                        d_ref_off = line_dist(poly_X(4),poly_Y(4),poly_X(5),poly_Y(5),mean(X),mean(Y)+50*(Common-1)/p.distcal);
                        d_TC_off = line_dist(poly_X(4),poly_Y(4),poly_X(5),poly_Y(5),TCx(i),TCy(i)+50*(Common-1)/p.distcal);
                    % We need to take into account that there can be more
                    % than 4 sides in the polygon (if the fly has more than
                    % 4 feet ON in the same frame:
                    elseif ii(2,2) == 5
                        d_ref_off = line_dist(poly_X(5),poly_Y(5),poly_X(6),poly_Y(6),mean(X),mean(Y)+50*(Common-1)/p.distcal);
                        d_TC_off = line_dist(poly_X(5),poly_Y(5),poly_X(6),poly_Y(6),TCx(i),TCy(i)+50*(Common-1)/p.distcal);
                    elseif ii(2,2) == 6
                        d_ref_off = line_dist(poly_X(6),poly_Y(6),poly_X(7),poly_Y(7),mean(X),mean(Y)+50*(Common-1)/p.distcal);
                        d_TC_off = line_dist(poly_X(6),poly_Y(6),poly_X(7),poly_Y(7),TCx(i),TCy(i)+50*(Common-1)/p.distcal);
                    end
                end
            end
             
%             if 79<i && 86>i
%                 disp(d_ref_on)
%                 disp(d_ref_off)
%                 disp(d_TC_on)
%                 disp(d_TC_off)
%             end
            
             % Compare on and off distances and decide which one to use
             if d_TC_on < d_TC_off
                 d_ref = d_ref_on;
                 d_TC = d_TC_on;
             else
                 d_ref = d_ref_off;
                 d_TC = d_TC_off;
             end
             
             % Update tri_table
             d_ref_body_units = d_ref/(p.fixed_body_length_value/p.distcal);
             d_TC_body_units = d_TC/(p.fixed_body_length_value/p.distcal);
             tri_table.Center_to_edge_dist(i) = num2cell(d_ref_body_units);
             tri_table.Centroid_to_edge_dist(i) = num2cell(d_TC_body_units);
             tri_table.Stability_ratio(i) = num2cell(d_TC/d_ref);
             
            % Area:
%              polygon_area = polyarea([X X(1)],[Y Y(1)]+50*(Common-1)/p.distcal);
             poly_area_body_units = polyarea([X X(1)]./(p.fixed_body_length_value/p.distcal),([Y Y(1)]+50*(Common-1)/p.distcal)./(p.fixed_body_length_value/p.distcal));
             tri_table.Polygon_area(i) = num2cell(poly_area_body_units);

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        end;
    end;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Alexandre
    % delete last row of tri_table (time vector has one extra frame)
    tri_table(end,:)=[];
    
    % xlim([0 600])
    % ylim([0 600])
    set(gca, 'YDir', 'reverse')
%     Title = [filename];
    Title = 'Gait Configurations';
    title(Title)
    xlabel('x [um]')
    ylabel('y [um]')
    hold off;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%/////////\\\\\\\%%%%%%%%%%%%%%%%%%%%%%%%%%
    % IMPORTANT: JUMP TO '20. TRIANGLES' FOR POST PROCESSING (DELETION OF
    % SEQUENCES WITH LESS THAN 3 FRAMES) -> this is why the code below is
    % commented
    
%     ind = find(filename == '\' | filename == '/');
%     outputfilename = sprintf('%striangles_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
%     saveas(h,outputfilename,'png');
%     close(h);
end;

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMBINATION COLOR CODE + STATISTICS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot combination color code as a function of time. 
%  tripod         +1
%  tetrapod       -1
%  non-canonical   0
%
% calculate moving average using parameter CombinationBinSize that defines
% over how many frames one should average

% define parameters
  % window size of moving average [frames]
    CombinationBinSize = 8;
        
  % colors [RGB]
    % tripod (green)
      RGB_tripod = [204 204 4]/255;
    % tetrapod (blue (bluish green))
      RGB_tetrapod = [4 4 208]/255;
    % non-canonical (gray)
      RGB_nc = [210 210 210]/255;
    % non-canonical (red)
      RGB_wavegait = [86 86 86]/255;

% calculate combination statistics
  SIDEcomb = round(CombinationBinSize/2);
  combtrace = CombinationCode(LegCombinationArray ~= 0);
  combtrace = smooth(combtrace, CombinationBinSize);
  combtrace = combtrace(SIDEcomb:end-SIDEcomb);
  AVGcombtrace = mean(combtrace);
  STDcombtrace = std(combtrace);

      
% plot
    h = figure('visible', 'off');
    axes('position', [0 0 1 1])
    hold off;
    for i = 2:length(time)
        % plot patch only if at least 1 leg is down
          if LegCombinationArray(i) ~= 0
            if CombinationCode(i) == 1
              P = patch('Faces', [1 2 3 4], 'Vertices', [time(i-1)+(time(2)-time(1))/2 0; time(i)+(time(2)-time(1))/2 0; time(i)+(time(2)-time(1))/2 1; time(i-1)+(time(2)-time(1))/2 1], 'FaceColor', RGB_tripod, 'EdgeColor', 'none');
            elseif CombinationCode(i) == -1
              P = patch('Faces', [1 2 3 4], 'Vertices', [time(i-1)+(time(2)-time(1))/2 0; time(i)+(time(2)-time(1))/2 0; time(i)+(time(2)-time(1))/2 1; time(i-1)+(time(2)-time(1))/2 1], 'FaceColor', RGB_tetrapod, 'EdgeColor', 'none');
            elseif CombinationCode(i) == 2
              P = patch('Faces', [1 2 3 4], 'Vertices', [time(i-1)+(time(2)-time(1))/2 0; time(i)+(time(2)-time(1))/2 0; time(i)+(time(2)-time(1))/2 1; time(i-1)+(time(2)-time(1))/2 1], 'FaceColor', RGB_wavegait, 'EdgeColor', 'none');
            else
              P = patch('Faces', [1 2 3 4], 'Vertices', [time(i-1)+(time(2)-time(1))/2 0; time(i)+(time(2)-time(1))/2 0; time(i)+(time(2)-time(1))/2 1; time(i-1)+(time(2)-time(1))/2 1], 'FaceColor', RGB_nc, 'EdgeColor', 'none');
            end;
            hold on;
          end;
    end;

    %Title = [filename];
    %title(Title)
%     xlabel('t [sec]')
    hold off;
    axis tight;
    set(gca,'YTick', []);
    set(gca,'XTick', []);
    box on;
    set(h,'PaperUnits', 'normalized');
    set(h,'PaperPosition', [0 0 1 0.09]);
  % define StartIndex
      [temp StartIndex] = find(AllLegsX ~= -1);
    ind = find(filename == '\' | filename == '/');
    outputfilename = sprintf('%scombination_color_code_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
    saveas(h,outputfilename,'png');
    
    % draw the same thing but with fixed x scale
      XLIM = xlim;
      set(h,'PaperPosition', [0 0 2*(XLIM(2) - XLIM(1)) 0.09]);
      ind = find(filename == '\' | filename == '/');
      outputfilename = sprintf('%scombination_color_code_fixed_scale_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
      saveas(h,outputfilename,'png');
    
    close(h);

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;
    


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMBINATION COLOR CODE NON Compliance + STATISTICS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Alexandra

% plot combination color code for compliance/noncompliance as a function of time. 
%  NC Contralateral Front   7
%  NC Contralateral Mid     8
%  NC Contralateral Back    9
%  NC Ipsilateral Left FM   10
%  NC Ipsilateral Left MB   11
%  NC Ipsilateral Right FM  12
%  NC Ipsilateral Right MB  13
%
% calculate moving average using parameter CombinationBinSize that defines
% over how many frames one should average

% define parameters
  % window size of moving average [frames]
    CombinationBinSize = 8;
        
  % colors [RGB]
    % Canonical (green)
      RGB_Compliance = [0.4660, 0.6740, 0.1880];
    % Non Canonical (red)
      RGB_NonCompliance = [0.6350, 0.0780, 0.1840];

% calculate combination statistics
% REVERSE change: do not overwrite these vars, since they are not used in
% this section
%   SIDEcomb = round(CombinationBinSize/2);
%   combtrace = CombinationCodeCompliance(LegCombinationArray ~= 0);
%   combtrace = smooth(combtrace, CombinationBinSize);
%   combtrace = combtrace(SIDEcomb:end-SIDEcomb);
%   AVGcombtrace = mean(combtrace);
%   STDcombtrace = std(combtrace);

      
% plot
    h = figure('visible', 'off');
    axes('position', [0 0 1 1])
    hold off;
    for i = 2:length(time)
        % plot patch only if at least 1 leg is down
          if LegCombinationArray(i) ~= 0
            if CombinationCodeCompliance(i)== 0 
              P = patch('Faces', [1 2 3 4], 'Vertices', [time(i-1)+(time(2)-time(1))/2 0; time(i)+(time(2)-time(1))/2 0; time(i)+(time(2)-time(1))/2 1; time(i-1)+(time(2)-time(1))/2 1], 'FaceColor', RGB_Compliance, 'EdgeColor', 'none');
            elseif CombinationCodeCompliance(i) > 6
              P = patch('Faces', [1 2 3 4], 'Vertices', [time(i-1)+(time(2)-time(1))/2 0; time(i)+(time(2)-time(1))/2 0; time(i)+(time(2)-time(1))/2 1; time(i-1)+(time(2)-time(1))/2 1], 'FaceColor', RGB_NonCompliance, 'EdgeColor', 'none');
            end;
            hold on;
          end;
    end;

    %Title = [filename];
    %title(Title)
%     xlabel('t [sec]')
    hold off;
    axis tight;
    set(gca,'YTick', []);
    set(gca,'XTick', []);
    box on;
    set(h,'PaperUnits', 'normalized');
    set(h,'PaperPosition', [0 0 1 0.09]);
  % define StartIndex
      [temp StartIndex] = find(AllLegsX ~= -1);
    ind = find(filename == '\' | filename == '/');
    outputfilename = sprintf('%scombination_color_compliance_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
    saveas(h,outputfilename,'png');
    
    % draw the same thing but with fixed x scale
      XLIM = xlim;
      set(h,'PaperPosition', [0 0 2*(XLIM(2) - XLIM(1)) 0.09]);
      ind = find(filename == '\' | filename == '/');
      outputfilename = sprintf('%scombination_color_compliance_fixed_scale_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
      saveas(h,outputfilename,'png');
    
    close(h);

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;

  
  
  
  
  
  
  %% find intervals that are tripod combinations
  % define minimum number of frames with tripod that are considered a step
    mintripodnum = 3;
  % find step lengths
    % define combinationCode vector that is one advanced and behind
      CombinationCodePast = [0 CombinationCode(1:end-1)];
      CombinationCodeNext = [CombinationCode(2:end) 0];
    % find start times (i.e. the first frames that are tripods)
      ind_start = find(CombinationCode == 1 & CombinationCodePast ~= 1);
      STARTframe=ind_start
      % if first frame is tripod already that should work too
        if CombinationCode(1) == 1 & ~isempty(ind_start) & ind_start(1) ~= 1, ind_start = [1 ind_start]; end;
    % find stop times (i.e. the last frames that are tripods)
      ind_stop  = find(CombinationCode == 1 & CombinationCodeNext ~= 1);
      STOPframe = ind_stop
      % if last frame is tripod that should work too
        if CombinationCode(end) == 1 & ~isempty(ind_stop) & ind_stop(end)~=length(CombinationCode), ind_stop = [ind_stop length(CombinationCode)]; end;
    % continue only if there is data to work with
      if ~isempty(ind_start) & ~isempty(ind_stop)
        % determine start and stop times  
          TripodStart = time(ind_start);
          TripodStop = time(ind_stop);
        % find lengths of tripods
          TripodStepLength = ind_stop - ind_start + 1;
        % find time between tripods that are longer than "mintripodnum"
          ind_tripod = find(TripodStepLength >= mintripodnum);
          TimeBetweenTripods = time(ind_start(ind_tripod(2:end))-1) - time(ind_stop(ind_tripod(1:end-1))+1) + 1/p.fps;
          TripodDuration     = time(ind_stop(ind_tripod)) - time(ind_start(ind_tripod)) + 1/p.fps;
        % delete those intervals where there is a mini tripod in between
          ind_consecutive = find(ind_tripod(1:end-1) + 1 == ind_tripod(2:end));
          TimeBetweenTripods = TimeBetweenTripods(ind_consecutive);
      else
        % initialize times
          TripodStart        = -1;
          TripodStop         = -1;
          TimeBetweenTripods = -1;
          TripodDuration     = -1;
      end;
  
% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;

      
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Measure leg times
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if PLOT == 1
    disp(' ')
    disp('Plotting leg times Checker Plot...')
    disp(' ')

    FrameRate = p.fps;
    TEXT = ['LF'; 'LM'; 'LH'; 'RF'; 'RM'; 'RH'; 'LF'; 'LM'; 'LH'; 'RF'; 'RM'; 'RH'];
    AllLegsX = [LeftFrontLegX; LeftMiddleLegX; LeftBackLegX; RightFrontLegX; RightMiddleLegX; RightBackLegX; LeftFrontLegX; LeftMiddleLegX; LeftBackLegX; RightFrontLegX; RightMiddleLegX; RightBackLegX];
    AllLegsY = [LeftFrontLegY; LeftMiddleLegY; LeftBackLegY; RightFrontLegY; RightMiddleLegY; RightBackLegY; LeftFrontLegY; LeftMiddleLegY; LeftBackLegY; RightFrontLegY; RightMiddleLegY; RightBackLegY];

    h = figure('visible', 'off');
    
    % find earliest footprint so empty data before this does not show up in
    % the data.
    earliestfootprint = length(time);
    for i = 1:6 % loop over legs
      if counter(i) > 0
        ind = find(AllLegsX(i,:) ~= -1);
        earliestfootprint = min(ind(1), earliestfootprint);
      end;
    end;    
    for i = 1:6 % loop over legs
      if counter(i) > 0
        % text(time(1) - (time(2)-time(1))*2, 50+(i-1)*100,TEXT(i,:),'Interpreter','none', 'Color','b','FontSize', 12);
        starttime = earliestfootprint;
        stoptime = -1;
        for j = earliestfootprint:length(time) % loop over time
            if AllLegsX(i,j) == -1
                if starttime == 0
                    starttime = j;
                end;
                stoptime = j+1;
            else
                if starttime ~= 0 & stoptime ~= -1;
                    P = patch([time(starttime) time(stoptime) time(stoptime) time(starttime)], [0 0 100 100]+(i-1)*100 - 150,'k');
                    hold on;
                  %   plot([time(starttime) time(stoptime)], [1 1].*(i-1)*100,'b', 'LineWidth', 3)
              end;
                starttime = 0;
            end;
        end;
      end;
    end;
     xlim([time(1) 2]);
    ylim([-150 450]);
    xlabel('t [sec]');
    % grid on;;
    set(gca,'YTickLabel',TEXT);
    box on;
%     for i = 0:6
%         plot([time(1) time(end)],[-150 -150]+i*100,'k');
%     end;
%     for i = 1:length(time)
%         plot([time(i) time(i)], [-150+6*100 -150],'k');
%     end;
    hold off;
    ind = find(filename == '\' | filename == '/');
    outputfilename = sprintf('%slegtime_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
    saveas(h,outputfilename,'png');
    close(h);
    
% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;
    
    % Plot leg times together with body speed ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    h = figure('visible', 'off');
    
    % find earliest footprint so empty data before this does not show up in
    % the data.
    h1 = subplot(2,1,1);
    subplot('Position',[0.14 0.46 0.83 0.5])
%     earliestfootprint = length(time);
%     for i = 1:6 % loop over legs
%         ind = find(AllLegsX(i,:) ~= -1);
%         earliestfootprint = min(ind(1), earliestfootprint);
%     end;    
    for i = 1:6 % loop over legs
      if counter(i) > 0
    %     text(time(1) - (time(2)-time(1))*2, 50+(i-1)*100,TEXT(i,:),'Interpreter','none', 'Color','b','FontSize', 12);
        starttime = earliestfootprint;
        stoptime = -1;
        for j = earliestfootprint:length(time) % loop over time
            if AllLegsX(i,j) == -1
                if starttime == 0
                    starttime = j;
                end;
                stoptime = j+1;
            else
                if starttime ~= 0 & stoptime ~= -1;
                    P = patch([time(starttime) time(stoptime) time(stoptime) time(starttime)], [0 0 100 100]+(i-1)*100 - 150,'k');
                    hold on;
    %                 plot([time(starttime) time(stoptime)], [1 1].*(i-1)*100,'b', 'LineWidth', 3)
              end;
                starttime = 0;
            end;
        end;
      end;
    end;
%     xlim([time(1) time(end)]);
    [temp StartIndex] = find(AllLegsX ~= -1);
    xlim([time(StartIndex(1)) time(StartIndex(end))]);
    ylim([-150 450]);
    grid on;
    set(gca,'XTickLabel',[])
    set(gca,'YTickLabel',TEXT);
    box on;
    hold off;
    Xlim = get(gca, 'XLim');
    
    h2 = subplot(2,1,2);
    subplot('Position',[0.14 0.15 0.83 0.28])
    % place body velocity with running average
    plot(time((BodyVelocity > 0)), smooth(BodyVelocity(BodyVelocity > 0)/1000,round(FrameRate/40)),'--','color', [0 0 0], 'LineWidth', 2); 
    hold on;
    % plot body velocity without smoothing too
    plot(time((BodyVelocity > 0)), smooth(BodyVelocity(BodyVelocity > 0)/1000,round(FrameRate/80)),'--','color', [0.3 0.3 0.3], 'LineWidth', 0.5);
    set(gca, 'XLim', Xlim);
    
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     disp('size(time)')
%     disp(size(time))
%     disp('size(BodyVelocity)')
%     disp(size(BodyVelocity))
%     disp('time')
%     disp(time)
%     disp('BodyVelocity')
%     disp(BodyVelocity)
%     disp('time((BodyVelocity > 0))')
%     disp(time((BodyVelocity > 0)))
%     disp('size(time((BodyVelocity > 0)))')
%     disp(size(time((BodyVelocity > 0))))
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    xlabel('t [sec]');
    ylabel('Body velocity [mm/s]')
    grid on;
    box on;
    hold off;

    
    ind = find(filename == '\' | filename == '/');
    outputfilename = sprintf('%slegtime_bodyspeed_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
    saveas(h,outputfilename,'png');

    % save the same plot but with fixed scale
      % set picture size to have correct ratio, such that 0.5 sec is the original size
        set(h,'PaperUnits', 'normalized');
        XLIM = xlim;
        set(h,'PaperPosition', [0 0 2*(XLIM(2) - XLIM(1)) 1]);

      ind = find(filename == '\' | filename == '/');
      outputfilename = sprintf('%slegtime_bodyspeed_fixed_scale_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
      saveas(h,outputfilename,'png');
    close(h);
   
% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;
    
    % plot legtime, bodyspeed and smoothed combination ~~~~~~~~~~~~~~~~~~~~

    h = figure('visible', 'off');
    
    % find earliest footprint so empty data before this does not show up in
    % the data.
    h1 = subplot(4,1,1);
%     subplot('Position',[0.14 0.63 0.83 0.35]);
    subplot('Position',[0.14 0.71 0.83 0.28]);
    for i = 1:6 % loop over legs
        if counter(i) > 0
          starttime = earliestfootprint;
          stoptime = -1;
          for j = earliestfootprint:length(time) % loop over time
              if AllLegsX(i,j) == -1
                  if starttime == 0
                      starttime = j;
                  end;
                  stoptime = j+1;
              else
                  if starttime ~= 0 & stoptime ~= -1;
                      P = patch([time(starttime) time(stoptime) time(stoptime) time(starttime)], [0 0 100 100]+(i-1)*100 - 150,'k');
                      hold on;
                end;
                  starttime = 0;
              end;
          end;
        end;
    end;
    [temp StartIndex] = find(AllLegsX ~= -1);
    xlim([time(StartIndex(1)) time(StartIndex(end))]);
    ylim([-150 450]);
    grid on;
    set(gca,'XTickLabel',[])
    set(gca,'YTickLabel',TEXT);
    box on;
    hold off;
    Xlim = get(gca, 'XLim');
    
    h2 = subplot(4,1,2);
%     subplot('Position',[0.14 0.46 0.83 0.15]);
    subplot('Position',[0.14 0.56 0.83 0.14]);
    % place body velocity with running average
    plot(time((BodyVelocity > 0)), smooth(BodyVelocity(BodyVelocity > 0)/1000,round(FrameRate/40)),'--','color', [0 0 0], 'LineWidth', 2);
    hold on;
    % plot body velocity without smoothing too
    plot(time((BodyVelocity > 0)), smooth(BodyVelocity(BodyVelocity > 0)/1000,round(FrameRate/80)),'--','color', [0.3 0.3 0.3], 'LineWidth', 0.5);
    set(gca, 'XLim', Xlim);
    set(gca,'XTickLabel',[]);
    ylabel('Body velocity [mm/s]', 'FontSize', 10);
    grid on;
    box on;
    hold off;
    
    h3 = subplot(4,1,3);
%     subplot('Position',[0.14 0.29 0.83 0.1]); %originally with the trace: subplot('Position',[0.14 0.29 0.83 0.15]);
    subplot('Position',[0.14 0.41 0.83 0.14]);
    set(gca, 'XLim', Xlim);
set(gca,'YTick', []); % this removes the Y units from the color code
    set(gca,'XTickLabel',[])
  % introduce transparent colors [RGB]
    % tripod (vermillion)
      RGB_tripod_white = [204 204 4]/255; %clear settings: [255 201 157]
    % tetrapod (bluish green)
      RGB_tetrapod_white = [4 4 208]/255;  %clear settings: [155 251 226]
    % non-canonical (yellow)
      RGB_nc_white = [210 210 210]/255;  %clear settings: [248 241 167]  
   
  % plot patches in the background
    hold off;
    for i = 2:length(time)
        % plot patch only if at least 1 leg is down
          if LegCombinationArray(i) ~= 0
            if CombinationCode(i) == 1
              P = patch('Faces', [1 2 3 4], 'Vertices', [time(i-1)+(time(2)-time(1))/2 -1; time(i)+(time(2)-time(1))/2 -1; time(i)+(time(2)-time(1))/2 1; time(i-1)+(time(2)-time(1))/2 1], 'FaceColor', RGB_tripod_white, 'EdgeColor', 'none');
            elseif CombinationCode(i) == -1
              P = patch('Faces', [1 2 3 4], 'Vertices', [time(i-1)+(time(2)-time(1))/2 -1; time(i)+(time(2)-time(1))/2 -1; time(i)+(time(2)-time(1))/2 1; time(i-1)+(time(2)-time(1))/2 1], 'FaceColor', RGB_tetrapod_white, 'EdgeColor', 'none');
            else
            P = patch('Faces', [1 2 3 4], 'Vertices', [time(i-1)+(time(2)-time(1))/2 -1; time(i)+(time(2)-time(1))/2 -1; time(i)+(time(2)-time(1))/2 1; time(i-1)+(time(2)-time(1))/2 1], 'FaceColor', RGB_nc_white, 'EdgeColor', 'none');
            end;
            hold on;
          end;
    end;    
    
  % plot combination binned traces
    % plot
    h4 = subplot(4,1,4);
    subplot('Position',[0.14 0.26 0.83 0.14]);

    % make sure to cut off sides so we only use points that are calculated
    % as the average of the max number of points
      TIME = time(LegCombinationArray ~= 0);
      COMB = smooth(CombinationCode(LegCombinationArray ~= 0),CombinationBinSize);
      plot(TIME(SIDEcomb:end-SIDEcomb), COMB(SIDEcomb:end-SIDEcomb), 'Color', [0 0 128]/255, 'LineWidth', 2);
      
  
    xlabel('t [sec]');
%     ylim([min(COMB)-1 1])
    set(gca, 'XLim', Xlim);    
    grid on;
    box on;
    hold off;

    
    ind = find(filename == '\' | filename == '/');
    outputfilename = sprintf('%slegtime_bodyspeed_combination_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
    saveas(h,outputfilename,'png');

    % save the same plot but with fixed scale
      % set picture size to have correct ratio, such that 0.5 sec is the original size
        set(h,'PaperUnits', 'normalized');
        XLIM = xlim;
        set(h,'PaperPosition', [0 0 2*(XLIM(2) - XLIM(1)) 1]);
    
      ind = find(filename == '\' | filename == '/');
      outputfilename = sprintf('%slegtime_bodyspeed_combination_fixed_scale_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
      saveas(h,outputfilename,'png');
    close(h);

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;
    
    
    % plot binned traces separately ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    h = figure('visible', 'off');    
  % plot combination binned traces
    % plot
      TIME = time(LegCombinationArray ~= 0);
      SMOOTH = smooth(CombinationCode(LegCombinationArray ~= 0),CombinationBinSize);
      SIDE = round(CombinationBinSize/2);
      plot(TIME(SIDE:end-SIDE), SMOOTH(SIDE:end-SIDE),'Color', [0 0 128]/255, 'LineWidth', 2);
      
    xlabel('t [sec]');
    xlim([time(StartIndex(1)) time(StartIndex(end))]);    
%     ylim([-1 1])
    grid on;
    box on;
    hold off;

    
    ind = find(filename == '\' | filename == '/');
    outputfilename = sprintf('%scombination_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
    saveas(h,outputfilename,'png');

    % save the same plot but with fixed scale
      % set picture size to have correct ratio, such that 0.5 sec is the original size
        set(h,'PaperUnits', 'normalized');
        XLIM = xlim;
        set(h,'PaperPosition', [0 0 2*(XLIM(2) - XLIM(1)) 1]);
    
      ind = find(filename == '\' | filename == '/');
      outputfilename = sprintf('%scombination_fixed_scale_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
      saveas(h,outputfilename,'png');    
    close(h);

 % check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;
   
    % Plot body speed by itself ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    h = figure('visible', 'off');
    plot(time((BodyVelocity > 0)), smooth(BodyVelocity(BodyVelocity > 0)/1000,round(FrameRate/40)),'--','color', [0 0 0], 'LineWidth', 2);
    hold on;
    % plot body velocity without smoothing too
    plot(time((BodyVelocity > 0)), smooth(BodyVelocity(BodyVelocity > 0)/1000,round(FrameRate/80)),'--','color', [0.3 0.3 0.3], 'LineWidth', 0.5);
%     xlim([time(1) time(end)]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     disp('time')
%     disp(time)
%     disp('body velocity')
%     disp(BodyVelocity)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    xlabel('t [sec]');
    ylabel('Body velocity [mm/s]')
    grid on;
    box on;
    hold off;
    ind = find(filename == '\' | filename == '/');
    outputfilename = sprintf('%sbodyspeed_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
    saveas(h,outputfilename,'png');
    close(h);
    
    
 % check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;
   
    
    
    
end;



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot with leg times and non canonical
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Xana

if PLOT == 1
    disp(' ')
    disp('Plotting leg times...')
    disp(' ')

    FrameRate = p.fps;
    TEXT = ['LF'; 'LM'; 'LH'; 'RF'; 'RM'; 'RH'; 'LF'; 'LM'; 'LH'; 'RF'; 'RM'; 'RH'];
    AllLegsX = [LeftFrontLegX; LeftMiddleLegX; LeftBackLegX; RightFrontLegX; RightMiddleLegX; RightBackLegX; LeftFrontLegX; LeftMiddleLegX; LeftBackLegX; RightFrontLegX; RightMiddleLegX; RightBackLegX];
    AllLegsY = [LeftFrontLegY; LeftMiddleLegY; LeftBackLegY; RightFrontLegY; RightMiddleLegY; RightBackLegY; LeftFrontLegY; LeftMiddleLegY; LeftBackLegY; RightFrontLegY; RightMiddleLegY; RightBackLegY];

    h = figure('visible', 'off');
    
    % find earliest footprint so empty data before this does not show up in
    % the data.
    earliestfootprint = length(time);
    for i = 1:6 % loop over legs
      if counter(i) > 0
        ind = find(AllLegsX(i,:) ~= -1);
        earliestfootprint = min(ind(1), earliestfootprint);
      end;
    end;    
    for i = 1:6 % loop over legs
      if counter(i) > 0
    %     text(time(1) - (time(2)-time(1))*2, 50+(i-1)*100,TEXT(i,:),'Interpreter','none', 'Color','b','FontSize', 12);
        starttime = earliestfootprint;
        stoptime = -1;
        for j = earliestfootprint:length(time) % loop over time
            if AllLegsX(i,j) == -1
                if starttime == 0
                    starttime = j;
                end;
                stoptime = j+1;
            else
                if starttime ~= 0 & stoptime ~= -1;
                    P = patch([time(starttime) time(stoptime) time(stoptime) time(starttime)], [0 0 100 100]+(i-1)*100 - 150,'k');
                    hold on;
    %                 plot([time(starttime) time(stoptime)], [1 1].*(i-1)*100,'b', 'LineWidth', 3)
              end;
                starttime = 0;
            end;
        end;
      end;
    end;
%     xlim([time(1) time(end)]);
    ylim([-150 450]);
    xlabel('t [sec]');
    % grid on;;
    set(gca,'YTickLabel',TEXT);
    box on;
%     for i = 0:6
%         plot([time(1) time(end)],[-150 -150]+i*100,'k');
%     end;
%     for i = 1:length(time)
%         plot([time(i) time(i)], [-150+6*100 -150],'k');
%     end;
    hold off;
    ind = find(filename == '\' | filename == '/');
    outputfilename = sprintf('%slegtime_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
    saveas(h,outputfilename,'png');
    close(h);
    
% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;
    
    % Plot leg times together with body speed ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    h = figure('visible', 'off');
    
    % find earliest footprint so empty data before this does not show up in
    % the data.
    h1 = subplot(2,1,1);
    subplot('Position',[0.14 0.46 0.83 0.5])
%     earliestfootprint = length(time);
%     for i = 1:6 % loop over legs
%         ind = find(AllLegsX(i,:) ~= -1);
%         earliestfootprint = min(ind(1), earliestfootprint);
%     end;    
    for i = 1:6 % loop over legs
      if counter(i) > 0
    %     text(time(1) - (time(2)-time(1))*2, 50+(i-1)*100,TEXT(i,:),'Interpreter','none', 'Color','b','FontSize', 12);
        starttime = earliestfootprint;
        stoptime = -1;
        for j = earliestfootprint:length(time) % loop over time
            if AllLegsX(i,j) == -1
                if starttime == 0
                    starttime = j;
                end;
                stoptime = j+1;
            else
                if starttime ~= 0 & stoptime ~= -1;
                    P = patch([time(starttime) time(stoptime) time(stoptime) time(starttime)], [0 0 100 100]+(i-1)*100 - 150,'k');
                    hold on;
    %                 plot([time(starttime) time(stoptime)], [1 1].*(i-1)*100,'b', 'LineWidth', 3)
              end;
                starttime = 0;
            end;
        end;
      end;
    end;
%     xlim([time(1) time(end)]);
    [temp StartIndex] = find(AllLegsX ~= -1);
    xlim([time(StartIndex(1)) time(StartIndex(end))]);
    ylim([-150 450]);
    grid on;
    set(gca,'XTickLabel',[])
    set(gca,'YTickLabel',TEXT);
    box on;
    hold off;
    Xlim = get(gca, 'XLim');
    
    h2 = subplot(2,1,2);
    subplot('Position',[0.14 0.15 0.83 0.28])
    % place body velocity with running average
    plot(time((BodyVelocity > 0)), smooth(BodyVelocity(BodyVelocity > 0)/1000,round(FrameRate/40)),'--','color', [0 0 0], 'LineWidth', 2); 
    hold on;
    % plot body velocity without smoothing too
    plot(time((BodyVelocity > 0)), smooth(BodyVelocity(BodyVelocity > 0)/1000,round(FrameRate/80)),'--','color', [0.3 0.3 0.3], 'LineWidth', 0.5);
    set(gca, 'XLim', Xlim);
    
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     disp('size(time)')
%     disp(size(time))
%     disp('size(BodyVelocity)')
%     disp(size(BodyVelocity))
%     disp('time')
%     disp(time)
%     disp('BodyVelocity')
%     disp(BodyVelocity)
%     disp('time((BodyVelocity > 0))')
%     disp(time((BodyVelocity > 0)))
%     disp('size(time((BodyVelocity > 0)))')
%     disp(size(time((BodyVelocity > 0))))
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    xlabel('t [sec]');
    ylabel('Body velocity [mm/s]')
    grid on;
    box on;
    hold off;

    
    %ind = find(filename == '\' | filename == '/');
    %outputfilename = sprintf('%slegtime_bodyspeed_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
   % saveas(h,outputfilename,'png');

    % save the same plot but with fixed scale
      % set picture size to have correct ratio, such that 0.5 sec is the original size
        set(h,'PaperUnits', 'normalized');
        XLIM = xlim;
        set(h,'PaperPosition', [0 0 2*(XLIM(2) - XLIM(1)) 1]);

      %ind = find(filename == '\' | filename == '/');
      %outputfilename = sprintf('%slegtime_bodyspeed_fixed_scale_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
      %saveas(h,outputfilename,'png');
    close(h);
   
% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;
    
    % plot legtime, bodyspeed and smoothed combination ~~~~~~~~~~~~~~~~~~~~

    h = figure('visible', 'off');
    
    % find earliest footprint so empty data before this does not show up in
    % the data.
    h1 = subplot(4,1,1);
%     subplot('Position',[0.14 0.63 0.83 0.35]);
    subplot('Position',[0.14 0.71 0.83 0.28]);
    for i = 1:6 % loop over legs
        if counter(i) > 0
          starttime = earliestfootprint;
          stoptime = -1;
          for j = earliestfootprint:length(time) % loop over time
              if AllLegsX(i,j) == -1
                  if starttime == 0
                      starttime = j;
                  end;
                  stoptime = j+1;
              else
                  if starttime ~= 0 & stoptime ~= -1;
                      P = patch([time(starttime) time(stoptime) time(stoptime) time(starttime)], [0 0 100 100]+(i-1)*100 - 150,'k');
                      hold on;
                end;
                  starttime = 0;
              end;
          end;
        end;
    end;
    [temp StartIndex] = find(AllLegsX ~= -1);
    xlim([time(StartIndex(1)) time(StartIndex(end))]);
    ylim([-150 450]);
    grid on;
    set(gca,'XTickLabel',[])
    set(gca,'YTickLabel',TEXT);
    box on;
    hold off;
    Xlim = get(gca, 'XLim');
    
    h2 = subplot(4,1,2);
%     subplot('Position',[0.14 0.46 0.83 0.15]);
    subplot('Position',[0.14 0.56 0.83 0.14]);
    % place body velocity with running average
    plot(time((BodyVelocity > 0)), smooth(BodyVelocity(BodyVelocity > 0)/1000,round(FrameRate/40)),'--','color', [0 0 0], 'LineWidth', 2);
    hold on;
    % plot body velocity without smoothing too
    plot(time((BodyVelocity > 0)), smooth(BodyVelocity(BodyVelocity > 0)/1000,round(FrameRate/80)),'--','color', [0.3 0.3 0.3], 'LineWidth', 0.5);
    set(gca, 'XLim', Xlim);
    set(gca,'XTickLabel',[]);
    ylabel('Body velocity [mm/s]', 'FontSize', 10);
    grid on;
    box on;
    hold off;
    
    h3 = subplot(4,1,3);
%     subplot('Position',[0.14 0.29 0.83 0.1]); %originally with the trace: subplot('Position',[0.14 0.29 0.83 0.15]);
    subplot('Position',[0.14 0.41 0.83 0.14]);
    set(gca, 'XLim', Xlim);
set(gca,'YTick', []); % this removes the Y units from the color code
    set(gca,'XTickLabel',[])
  % introduce transparent colors [RGB]
  % colors [RGB]
    % Canonical (green)
      RGB_Compliance = [0.4660, 0.6740, 0.1880];
    % Non Canonical (red)
      RGB_NonCompliance = [0.6350, 0.0780, 0.1840];
    %alllegs out
      RGB_nc_white = [1 1 1];
   
  % plot patches in the background
    hold off;
    for i = 2:length(time)
        % plot patch only if at least 1 leg is down
          if LegCombinationArray(i) ~= 0
            if CombinationCodeCompliance(i) == 0
              P = patch('Faces', [1 2 3 4], 'Vertices', [time(i-1)+(time(2)-time(1))/2 -1; time(i)+(time(2)-time(1))/2 -1; time(i)+(time(2)-time(1))/2 1; time(i-1)+(time(2)-time(1))/2 1], 'FaceColor', RGB_Compliance, 'EdgeColor', 'none');
            elseif CombinationCodeCompliance(i) > 6
              P = patch('Faces', [1 2 3 4], 'Vertices', [time(i-1)+(time(2)-time(1))/2 -1; time(i)+(time(2)-time(1))/2 -1; time(i)+(time(2)-time(1))/2 1; time(i-1)+(time(2)-time(1))/2 1], 'FaceColor', RGB_NonCompliance, 'EdgeColor', 'none');
            else
            P = patch('Faces', [1 2 3 4], 'Vertices', [time(i-1)+(time(2)-time(1))/2 -1; time(i)+(time(2)-time(1))/2 -1; time(i)+(time(2)-time(1))/2 1; time(i-1)+(time(2)-time(1))/2 1], 'FaceColor', RGB_nc_white, 'EdgeColor', 'none');
            end;
            hold on;
          end;
    end;     
    
  % plot combination binned traces
    % plot
    h4 = subplot(4,1,4);
    subplot('Position',[0.14 0.26 0.83 0.14]);

    % make sure to cut off sides so we only use points that are calculated
    % as the average of the max number of points
      TIME = time(LegCombinationArray ~= 0);
      COMB = smooth(CombinationCode(LegCombinationArray ~= 0),CombinationBinSize);
      plot(TIME(SIDEcomb:end-SIDEcomb), COMB(SIDEcomb:end-SIDEcomb), 'Color', [0 0 128]/255, 'LineWidth', 2);
      
  
    xlabel('t [sec]');
%     ylim([min(COMB)-1 1])
    set(gca, 'XLim', Xlim);    
    grid on;
    box on;
    hold off;

    
    ind = find(filename == '\' | filename == '/');
    outputfilename = sprintf('%slegtime_Compliance_combination_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
    saveas(h,outputfilename,'png');

    % save the same plot but with fixed scale
      % set picture size to have correct ratio, such that 0.5 sec is the original size
        set(h,'PaperUnits', 'normalized');
        XLIM = xlim;
        set(h,'PaperPosition', [0 0 2*(XLIM(2) - XLIM(1)) 1]);
    
      ind = find(filename == '\' | filename == '/');
      outputfilename = sprintf('%slegtime_Compliance_combination_fixed_scale_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
      saveas(h,outputfilename,'png');
    close(h);

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;
    
    
    % plot binned traces separately ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    h = figure('visible', 'off');    
  % plot combination binned traces
    % plot
      TIME = time(LegCombinationArray ~= 0);
      SMOOTH = smooth(CombinationCode(LegCombinationArray ~= 0),CombinationBinSize);
      SIDE = round(CombinationBinSize/2);
      plot(TIME(SIDE:end-SIDE), SMOOTH(SIDE:end-SIDE),'Color', [0 0 128]/255, 'LineWidth', 2);
      
    xlabel('t [sec]');
    xlim([time(StartIndex(1)) time(StartIndex(end))]);    
%     ylim([-1 1])
    grid on;
    box on;
    hold off;

    
    ind = find(filename == '\' | filename == '/');
    outputfilename = sprintf('%scombination_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
    saveas(h,outputfilename,'png');

    % save the same plot but with fixed scale
      % set picture size to have correct ratio, such that 0.5 sec is the original size
        set(h,'PaperUnits', 'normalized');
        XLIM = xlim;
        set(h,'PaperPosition', [0 0 2*(XLIM(2) - XLIM(1)) 1]);
    
      ind = find(filename == '\' | filename == '/');
      outputfilename = sprintf('%scombination_fixed_scale_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
      saveas(h,outputfilename,'png');    
    close(h);

 % check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;
   
    % Plot body speed by itself ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    h = figure('visible', 'off');
    plot(time((BodyVelocity > 0)), smooth(BodyVelocity(BodyVelocity > 0)/1000,round(FrameRate/40)),'--','color', [0 0 0], 'LineWidth', 2);
    hold on;
    % plot body velocity without smoothing too
    plot(time((BodyVelocity > 0)), smooth(BodyVelocity(BodyVelocity > 0)/1000,round(FrameRate/80)),'--','color', [0.3 0.3 0.3], 'LineWidth', 0.5);
%     xlim([time(1) time(end)]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     disp('time')
%     disp(time)
%     disp('body velocity')
%     disp(BodyVelocity)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    xlabel('t [sec]');
    ylabel('Body velocity [mm/s]')
    grid on;
    box on;
    hold off;
    ind = find(filename == '\' | filename == '/');
    outputfilename = sprintf('%sbodyspeed_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
    saveas(h,outputfilename,'png');
    close(h);
    
    
 % check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;
   
    
    
    
end;


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot with leg times and non canonical +tripod trapod (Xana)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Xana

if PLOT == 1
    disp(' ')
    disp('Plotting leg times...')
    disp(' ')

    FrameRate = p.fps;
    TEXT = ['LF'; 'LM'; 'LH'; 'RF'; 'RM'; 'RH'; 'LF'; 'LM'; 'LH'; 'RF'; 'RM'; 'RH'];
    AllLegsX = [LeftFrontLegX; LeftMiddleLegX; LeftBackLegX; RightFrontLegX; RightMiddleLegX; RightBackLegX; LeftFrontLegX; LeftMiddleLegX; LeftBackLegX; RightFrontLegX; RightMiddleLegX; RightBackLegX];
    AllLegsY = [LeftFrontLegY; LeftMiddleLegY; LeftBackLegY; RightFrontLegY; RightMiddleLegY; RightBackLegY; LeftFrontLegY; LeftMiddleLegY; LeftBackLegY; RightFrontLegY; RightMiddleLegY; RightBackLegY];

    h = figure('visible', 'off');
    
    % find earliest footprint so empty data before this does not show up in
    % the data.
    earliestfootprint = length(time);
    for i = 1:6 % loop over legs
      if counter(i) > 0
        ind = find(AllLegsX(i,:) ~= -1);
        earliestfootprint = min(ind(1), earliestfootprint);
      end;
    end;    
    for i = 1:6 % loop over legs
      if counter(i) > 0
    %     text(time(1) - (time(2)-time(1))*2, 50+(i-1)*100,TEXT(i,:),'Interpreter','none', 'Color','b','FontSize', 12);
        starttime = earliestfootprint;
        stoptime = -1;
        for j = earliestfootprint:length(time) % loop over time
            if AllLegsX(i,j) == -1
                if starttime == 0
                    starttime = j;
                end;
                stoptime = j+1;
            else
                if starttime ~= 0 & stoptime ~= -1;
                    P = patch([time(starttime) time(stoptime) time(stoptime) time(starttime)], [0 0 100 100]+(i-1)*100 - 150,'k');
                    hold on;
    %                 plot([time(starttime) time(stoptime)], [1 1].*(i-1)*100,'b', 'LineWidth', 3)
              end;
                starttime = 0;
            end;
        end;
      end;
    end;
%     xlim([time(1) time(end)]);
    ylim([-150 450]);
    xlabel('t [sec]');
    % grid on;;
    set(gca,'YTickLabel',TEXT);
    box on;
%     for i = 0:6
%         plot([time(1) time(end)],[-150 -150]+i*100,'k');
%     end;
%     for i = 1:length(time)
%         plot([time(i) time(i)], [-150+6*100 -150],'k');
%     end;
    hold off;
    ind = find(filename == '\' | filename == '/');
    outputfilename = sprintf('%slegtime_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
    saveas(h,outputfilename,'png');
    close(h);
    
% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;
    
    % Plot leg times together with body speed ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    h = figure('visible', 'off');
    
    % find earliest footprint so empty data before this does not show up in
    % the data.
    h1 = subplot(2,1,1);
    subplot('Position',[0.14 0.46 0.83 0.5])
%     earliestfootprint = length(time);
%     for i = 1:6 % loop over legs
%         ind = find(AllLegsX(i,:) ~= -1);
%         earliestfootprint = min(ind(1), earliestfootprint);
%     end;    
    for i = 1:6 % loop over legs
      if counter(i) > 0
    %     text(time(1) - (time(2)-time(1))*2, 50+(i-1)*100,TEXT(i,:),'Interpreter','none', 'Color','b','FontSize', 12);
        starttime = earliestfootprint;
        stoptime = -1;
        for j = earliestfootprint:length(time) % loop over time
            if AllLegsX(i,j) == -1
                if starttime == 0
                    starttime = j;
                end;
                stoptime = j+1;
            else
                if starttime ~= 0 & stoptime ~= -1;
                    P = patch([time(starttime) time(stoptime) time(stoptime) time(starttime)], [0 0 100 100]+(i-1)*100 - 150,'k');
                    hold on;
    %                 plot([time(starttime) time(stoptime)], [1 1].*(i-1)*100,'b', 'LineWidth', 3)
              end;
                starttime = 0;
            end;
        end;
      end;
    end;
%     xlim([time(1) time(end)]);
    [temp StartIndex] = find(AllLegsX ~= -1);
    xlim([time(StartIndex(1)) time(StartIndex(end))]);
    ylim([-150 450]);
    grid on;
    set(gca,'XTickLabel',[])
    set(gca,'YTickLabel',TEXT);
    box on;
    hold off;
    Xlim = get(gca, 'XLim');
    
    h2 = subplot(2,1,2);
    subplot('Position',[0.14 0.15 0.83 0.28])
    % place body velocity with running average
    plot(time((BodyVelocity > 0)), smooth(BodyVelocity(BodyVelocity > 0)/1000,round(FrameRate/40)),'--','color', [0 0 0], 'LineWidth', 2); 
    hold on;
    % plot body velocity without smoothing too
    plot(time((BodyVelocity > 0)), smooth(BodyVelocity(BodyVelocity > 0)/1000,round(FrameRate/80)),'--','color', [0.3 0.3 0.3], 'LineWidth', 0.5);
    set(gca, 'XLim', Xlim);
    
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     disp('size(time)')
%     disp(size(time))
%     disp('size(BodyVelocity)')
%     disp(size(BodyVelocity))
%     disp('time')
%     disp(time)
%     disp('BodyVelocity')
%     disp(BodyVelocity)
%     disp('time((BodyVelocity > 0))')
%     disp(time((BodyVelocity > 0)))
%     disp('size(time((BodyVelocity > 0)))')
%     disp(size(time((BodyVelocity > 0))))
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    xlabel('t [sec]');
    ylabel('Body velocity [mm/s]')
    grid on;
    box on;
    hold off;

    
    %ind = find(filename == '\' | filename == '/');
    %outputfilename = sprintf('%slegtime_bodyspeed_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
   % saveas(h,outputfilename,'png');

    % save the same plot but with fixed scale
      % set picture size to have correct ratio, such that 0.5 sec is the original size
        set(h,'PaperUnits', 'normalized');
        XLIM = xlim;
        set(h,'PaperPosition', [0 0 2*(XLIM(2) - XLIM(1)) 1]);

      %ind = find(filename == '\' | filename == '/');
      %outputfilename = sprintf('%slegtime_bodyspeed_fixed_scale_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
      %saveas(h,outputfilename,'png');
    close(h);
   
% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;
    
    % plot legtime, bodyspeed and smoothed combination ~~~~~~~~~~~~~~~~~~~~

    h = figure('visible', 'off');
    
    % find earliest footprint so empty data before this does not show up in
    % the data.
    h1 = subplot(4,1,1);
%     subplot('Position',[0.14 0.63 0.83 0.35]);
    subplot('Position',[0.14 0.71 0.83 0.28]);
    for i = 1:6 % loop over legs
        if counter(i) > 0
          starttime = earliestfootprint;
          stoptime = -1;
          for j = earliestfootprint:length(time) % loop over time
              if AllLegsX(i,j) == -1
                  if starttime == 0
                      starttime = j;
                  end;
                  stoptime = j+1;
              else
                  if starttime ~= 0 & stoptime ~= -1;
                      P = patch([time(starttime) time(stoptime) time(stoptime) time(starttime)], [0 0 100 100]+(i-1)*100 - 150,'k');
                      hold on;
                end;
                  starttime = 0;
              end;
          end;
        end;
    end;
    [temp StartIndex] = find(AllLegsX ~= -1);
    xlim([time(StartIndex(1)) time(StartIndex(end))]);
    ylim([-150 450]);
    grid on;
    set(gca,'XTickLabel',[])
    set(gca,'YTickLabel',TEXT);
    box on;
    hold off;
    Xlim = get(gca, 'XLim');
    
    h2 = subplot(4,1,2);
%     subplot('Position',[0.14 0.46 0.83 0.15]);
    subplot('Position',[0.14 0.56 0.83 0.14]);
    % place body velocity with running average
    plot(time((BodyVelocity > 0)), smooth(BodyVelocity(BodyVelocity > 0)/1000,round(FrameRate/40)),'--','color', [0 0 0], 'LineWidth', 2);
    hold on;
    % plot body velocity without smoothing too
    plot(time((BodyVelocity > 0)), smooth(BodyVelocity(BodyVelocity > 0)/1000,round(FrameRate/80)),'--','color', [0.3 0.3 0.3], 'LineWidth', 0.5);
    set(gca, 'XLim', Xlim);
    set(gca,'XTickLabel',[]);
    ylabel('Body velocity [mm/s]', 'FontSize', 10);
    grid on;
    box on;
    hold off;
    
    h3 = subplot(4,1,3);
%     subplot('Position',[0.14 0.29 0.83 0.1]); %originally with the trace: subplot('Position',[0.14 0.29 0.83 0.15]);
    subplot('Position',[0.14 0.41 0.83 0.14]);
    set(gca, 'XLim', Xlim);
set(gca,'YTick', []); % this removes the Y units from the color code
    set(gca,'XTickLabel',[])
  % introduce transparent colors [RGB]
  % colors [RGB]
    % Canonical (green)
      RGB_Compliance = [0.4660, 0.6740, 0.1880];
    % Non Canonical (red)
      RGB_NonCompliance = [0.6350, 0.0780, 0.1840];
     % tripod (vermillion)
      RGB_tripod_white = [204 204 4]/255; %clear settings: [255 201 157]
    % tetrapod (bluish green)
      RGB_tetrapod_white = [4 4 208]/255;  %clear settings: [155 251 226]
    % non-canonical (yellow)
      RGB_nc_white = [210 210 210]/255;  %clear settings: [248 241 167]
    % non-canonical (red)
      RGB_wavegait = [86 86 86]/255;
   
  % plot patches in the background
    hold off;
    for i = 2:length(time)
        % plot patch only if at least 1 leg is down
          if LegCombinationArray(i) ~= 0
          %if CombinationCode(i) == 0
            %P = patch('Faces', [1 2 3 4], 'Vertices', [time(i-1)+(time(2)-time(1))/2 -1; time(i)+(time(2)-time(1))/2 -1; time(i)+(time(2)-time(1))/2 1; time(i-1)+(time(2)-time(1))/2 1], 'FaceColor', RGB_Compliance, 'EdgeColor', 'none');
          if CombinationCode(i) > 6
            P = patch('Faces', [1 2 3 4], 'Vertices', [time(i-1)+(time(2)-time(1))/2 -1; time(i)+(time(2)-time(1))/2 -1; time(i)+(time(2)-time(1))/2 1; time(i-1)+(time(2)-time(1))/2 1], 'FaceColor', RGB_NonCompliance, 'EdgeColor', 'none');
          elseif CombinationCode(i) == 1
            P = patch('Faces', [1 2 3 4], 'Vertices', [time(i-1)+(time(2)-time(1))/2 -1; time(i)+(time(2)-time(1))/2 -1; time(i)+(time(2)-time(1))/2 1; time(i-1)+(time(2)-time(1))/2 1], 'FaceColor', RGB_tripod_white, 'EdgeColor', 'none');
          elseif CombinationCode(i) == -1
            P = patch('Faces', [1 2 3 4], 'Vertices', [time(i-1)+(time(2)-time(1))/2 -1; time(i)+(time(2)-time(1))/2 -1; time(i)+(time(2)-time(1))/2 1; time(i-1)+(time(2)-time(1))/2 1], 'FaceColor', RGB_tetrapod_white, 'EdgeColor', 'none');
          elseif CombinationCode(i) == 2
            P = patch('Faces', [1 2 3 4], 'Vertices', [time(i-1)+(time(2)-time(1))/2 -1; time(i)+(time(2)-time(1))/2 -1; time(i)+(time(2)-time(1))/2 1; time(i-1)+(time(2)-time(1))/2 1], 'FaceColor', RGB_Compliance, 'EdgeColor', 'none');
          else
          P = patch('Faces', [1 2 3 4], 'Vertices', [time(i-1)+(time(2)-time(1))/2 -1; time(i)+(time(2)-time(1))/2 -1; time(i)+(time(2)-time(1))/2 1; time(i-1)+(time(2)-time(1))/2 1], 'FaceColor', RGB_Compliance, 'EdgeColor', 'none');
          end;
          hold on;
        end;
    end;
  
    
  % plot combination binned traces
    % plot
    h4 = subplot(4,1,4);
    subplot('Position',[0.14 0.26 0.83 0.14]);

    % make sure to cut off sides so we only use points that are calculated
    % as the average of the max number of points
      TIME = time(LegCombinationArray ~= 0);
      COMB = smooth(CombinationCode(LegCombinationArray ~= 0),CombinationBinSize);
      plot(TIME(SIDEcomb:end-SIDEcomb), COMB(SIDEcomb:end-SIDEcomb), 'Color', [0 0 128]/255, 'LineWidth', 2);
      
  
    xlabel('t [sec]');
%     ylim([min(COMB)-1 1])
    set(gca, 'XLim', Xlim);    
    grid on;
    box on;
    hold off;    
    
    ind = find(filename == '\' | filename == '/');
    outputfilename = sprintf('%slegtime_Compliance_tripodtetra_combination_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
    saveas(h,outputfilename,'png');

    % save the same plot but with fixed scale
      % set picture size to have correct ratio, such that 0.5 sec is the original size
        set(h,'PaperUnits', 'normalized');
        XLIM = xlim;
        set(h,'PaperPosition', [0 0 2*(XLIM(2) - XLIM(1)) 1]);
    
      ind = find(filename == '\' | filename == '/');
      outputfilename = sprintf('%slegtime_Compliance_combination_tripodtetra_fixed_scale_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
      saveas(h,outputfilename,'png');
    close(h);

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;
    
    
    % plot binned traces separately ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    h = figure('visible', 'off');    
  % plot combination binned traces
    % plot
      TIME = time(LegCombinationArray ~= 0);
      SMOOTH = smooth(CombinationCode(LegCombinationArray ~= 0),CombinationBinSize);
      SIDE = round(CombinationBinSize/2);
      plot(TIME(SIDE:end-SIDE), SMOOTH(SIDE:end-SIDE),'Color', [0 0 128]/255, 'LineWidth', 2);
      
    xlabel('t [sec]');
    xlim([time(StartIndex(1)) time(StartIndex(end))]);    
%     ylim([-1 1])
    grid on;
    box on;
    hold off;

    
    ind = find(filename == '\' | filename == '/');
    outputfilename = sprintf('%scombination_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
    saveas(h,outputfilename,'png');

    % save the same plot but with fixed scale
      % set picture size to have correct ratio, such that 0.5 sec is the original size
        set(h,'PaperUnits', 'normalized');
        XLIM = xlim;
        set(h,'PaperPosition', [0 0 2*(XLIM(2) - XLIM(1)) 1]);
    
      ind = find(filename == '\' | filename == '/');
      outputfilename = sprintf('%scombination_fixed_scale_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
      saveas(h,outputfilename,'png');    
    close(h);

 % check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;
   
    % Plot body speed by itself ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    h = figure('visible', 'off');
    plot(time((BodyVelocity > 0)), smooth(BodyVelocity(BodyVelocity > 0)/1000,round(FrameRate/40)),'--','color', [0 0 0], 'LineWidth', 2);
    hold on;
    % plot body velocity without smoothing too
    plot(time((BodyVelocity > 0)), smooth(BodyVelocity(BodyVelocity > 0)/1000,round(FrameRate/80)),'--','color', [0.3 0.3 0.3], 'LineWidth', 0.5);
%     xlim([time(1) time(end)]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     disp('time')
%     disp(time)
%     disp('body velocity')
%     disp(BodyVelocity)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    xlabel('t [sec]');
    ylabel('Body velocity [mm/s]')
    grid on;
    box on;
    hold off;
    ind = find(filename == '\' | filename == '/');
    outputfilename = sprintf('%sbodyspeed_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
    saveas(h,outputfilename,'png');
    close(h);
    
    
 % check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;
   
    
    
    
end;



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Measure leg distances
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if PLOT == 1
%     h = figure('visible', 'off');
%     hold on;
%     RGB = [1   0   0; ...
%            1   0.5 0; ...
%            0   1   0; ...
%            0.5 1   1; ...
%            0   0   1; ...
%            0   0   0];
%     for i = 1:5 % loop over leg 1
%         for j = i+1:6 % loop over leg 2
%             Distance = sqrt((AllLegsX(i,:) - AllLegsX(j,:)).^2 + (AllLegsY(i,:) - AllLegsY(j,:)).^2);
%             ind = find(AllLegsX(i,:) ~= -1 & AllLegsX(j,:) ~= -1);
%             % plot results
%             plot(time(ind), Distance(ind),'Color',RGB(i,:));
%     %         for k = 1:length(ind)-1
%     %             if ind(k+1)-ind(k) == 1
%     %                 plot([time(ind(k)) time(ind(k+1))], [Distance(ind(k)) Distance(ind(k))],'r');
%     %             end;
%     %         end;
%         end;
%     end;
% 
% end;


% Added by Clare Howard 02_13_17
% ceh2172@columbia.edu

% This defines a parameter called "stance straightness index", which is a ratio
% of the displacement that occurs over a particular stance trace and the
% "path length" of that stance trace from frame to frame

%   disp('  18.Stance Straightness Index');

%calculate the displacement (in um???) from the start to the end of a stance trace
    for i=1:6 % loop over each of the 6 legs
        for j = 1:(counter(i)) %loop over each step for each leg
            startframe = StartStep(i,j); %find the first frame of a step
            stopframe = StopStep(i,j); %find the last frame of the step
            parastart = ParaDist(i,startframe); %take the parallel distance from the body at the start
            parastop = ParaDist(i,stopframe); %parallel distance from the body at the end
            perpstart = PerpDist(i,startframe); %perpendicular distance from the body at the start
            perpstop = PerpDist(i,stopframe); %perpendicular distance from the center at the end
            xDisp = abs(parastop-parastart); %X displacement is the difference in the parallel distances
            yDisp = abs(perpstop-perpstart); %Y displacement is the difference in the perpendicular distances
            Displacement(i,j) = sqrt(xDisp^2 + yDisp^2); %The "stance displacement" is the distance between these two points
        end;
    end;
    
%caculate the path length for each stance trace, the sum of the
%displacement over each frame of the stance
    %loop over legs
    for i=1:6
        %loop over steps
        for j = 1:(counter(i))
            startframe = StartStep(i,j);
            stopframe = StopStep(i,j);
            pathlength(i,j)=0;
            %loop over frames of each step
            for k = startframe:stopframe-1
                parastart = ParaDist(i,k); %paralell distance at frame 1
                parastop = ParaDist(i,k+1); %paralell distance at frame 2
                perpstart = PerpDist(i,k); %perpendicular distance at frame 1
                perpstop = PerpDist(i,k+1); %perpendicular distance at frame 2
                xDisp = abs(parastop-parastart); %x displacement
                yDisp = abs(perpstop-perpstart); %y displacement
                Displacementpartial = sqrt(xDisp^2 + yDisp^2); %displacement from frame 1 to 2
                pathlength(i,j) = pathlength(i,j)+Displacementpartial; %add that displacement to the path
            end;
        end;
    end;
    
%new stance linearity is the ratio of stance displacement to pathlength
    %loop over legs
    for i=1:6
        %loop over steps
        for j = 1:(counter(i))
            StanceStraightness(i,j)=Displacement(i,j)/pathlength(i,j);
        end;
    end;
    
%replace all 0 values (which come up because some legs have more steps
%than others, with NaN so they will not be included in calculation of
%the mean values
    StanceStraightness(find(~StanceStraightness))=NaN;
    
%Calculate the average for each leg individual, pairs of F, M, H and overall
    AvgStStrLF = nanmean(StanceStraightness(1,:),2);
    AvgStStrLM = nanmean(StanceStraightness(2,:),2);
    AvgStStrLH = nanmean(StanceStraightness(3,:),2);
    AvgStStrRF = nanmean(StanceStraightness(4,:),2);
    AvgStStrRM = nanmean(StanceStraightness(5,:),2);
    AvgStStrRH = nanmean(StanceStraightness(6,:),2);
    AvgStStrF = nanmean([AvgStStrLF AvgStStrRF],2);
    AvgStStrM = nanmean([AvgStStrLM AvgStStrRM],2);
    AvgStStrH = nanmean([AvgStStrLH AvgStStrRH],2);
    AvgStStrAll = nanmean([AvgStStrF AvgStStrM AvgStStrH],2);

    %Calculate the averages of displacement and path length
    
    AvgDispLF = nanmean(Displacement(1,:),2);
    AvgDispLM = nanmean(Displacement(2,:),2);
    AvgDispLH = nanmean(Displacement(3,:),2);
    AvgDispRF = nanmean(Displacement(4,:),2);
    AvgDispRM = nanmean(Displacement(5,:),2);
    AvgDispRH = nanmean(Displacement(6,:),2);
    AvgDispF = nanmean([AvgDispLF AvgDispRF],2);
    AvgDispM = nanmean([AvgDispLM AvgDispRM],2);
    AvgDispH = nanmean([AvgDispLH AvgDispRH],2);
    AvgDispAll = nanmean([AvgDispF AvgDispM AvgDispH],2);
    
    AvgPathLF = nanmean(pathlength(1,:),2);
    AvgPathLM = nanmean(pathlength(2,:),2);
    AvgPathLH = nanmean(pathlength(3,:),2);
    AvgPathRF = nanmean(pathlength(4,:),2);
    AvgPathRM = nanmean(pathlength(5,:),2);
    AvgPathRH = nanmean(pathlength(6,:),2);
    AvgPathF = nanmean([AvgPathLF AvgPathRF],2);
    AvgPathM = nanmean([AvgPathLM AvgPathRM],2);
    AvgPathH = nanmean([AvgPathLH AvgPathRH],2);
    AvgPathAll = nanmean([AvgPathF AvgPathM AvgPathH],2);
    
    %Write these values into their own sheet in the excel data
    
    Data = num2cell(StanceStraightness)';
    Data(2:end+1,3:3:end+12) = Data;
    Data(2:end,1:3:end) = num2cell(Displacement)';
    Data(2:end,2:3:end) = num2cell(pathlength)';
    
    
     % add header
    Data(1,1:3:end) = {'Displacement LF (um)' 'Displacement LM' 'Displacement LH' 'Displacement RF' 'Displacement RM' 'Displacement RH'};
    Data(1,2:3:end) = {'Path Length LF (um)' 'Path Length LM' 'Path Length LH' 'Path Length RF' 'Path Length RM' 'Path Length RH'};
    Data(1,3:3:end) = {'Straightness LF' 'Straightness LM' 'Straightness LH' 'Straightness RF' 'Straightness RM' 'Straightness RH'};
    
    % add average values for each leg
    Data(end+2,:) = {'Avg Disp LF' 'Avg Path LF' 'Avg Straightness LF' 'Avg Disp LM' 'Avg Path LM' 'Avg Straightness LM' 'Avg Disp LH' 'Avg Path LH' 'Avg Straightness LH' 'Avg Disp RF' 'Avg Path RF' 'Avg Straightness RF' 'Avg Disp RM' 'Avg Path RM' 'Avg Straightness RM' 'Avg Disp RH' 'Avg Path RH' 'Avg Straightness RH'};
    Data(end+1,:) = {AvgDispLF AvgPathLF AvgStStrLF AvgDispLM AvgPathLM AvgStStrLM AvgDispLH AvgPathLH AvgStStrLH AvgDispRF AvgPathRF AvgStStrRF AvgDispRM AvgPathRM AvgStStrRM AvgDispRH AvgPathRH AvgStStrRH};
    
    %add average values for each leg
    Data(end+2,1:9) = {'Avg Disp F' 'Avg Path F' 'Avg Straightness F' 'Avg Disp M' 'Avg Path M' 'Avg Straightness M' 'Avg Disp H' 'Avg Path H' 'Avg Straightness H'};
    Data(end+1,1:9) = {AvgDispF AvgPathF AvgStStrF AvgDispM AvgPathM AvgStStrM AvgDispH AvgPathH AvgStStrH};
    
    %add overal averages
    Data(end+2, 1:3) = {'Overall Avg Disp' 'Overall Avg Path' 'Overall Avg Straightness'};
    Data(end+1, 1:3) = {AvgDispAll AvgPathAll AvgStStrAll};
    
%     %write out to excel
%     xlswrite([foldername ExcelFileName '.xlsx'], Data,'18.Stance_Straightness_Index');

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUMMARY PLOT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Plot leg times together with body speed ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    h = figure('visible', 'off','PaperPosition', [0 0 22 14], 'Units', 'inches');

    % find earliest footprint so empty data before this does not show up in
    % the data.
    h1 = subplot(4,2,[1 3]);
    subplot('Position',[0.05 0.6 0.45 0.35], 'FontSize', 14)
%     earliestfootprint = length(time);
%     for i = 1:6 % loop over legs
%         ind = find(AllLegsX(i,:) ~= -1);
%         earliestfootprint = min(ind(1), earliestfootprint);
%     end;    
    for i = 1:6 % loop over legs
    %     text(time(1) - (time(2)-time(1))*2, 50+(i-1)*100,TEXT(i,:),'Interpreter','none', 'Color','b','FontSize', 12);
        starttime = earliestfootprint;
        stoptime = -1;
        for j = earliestfootprint:length(time) % loop over time
            if AllLegsX(i,j) == -1
                if starttime == 0
                    starttime = j;
                end;
                stoptime = j+1;
            else
                if starttime ~= 0 & stoptime ~= -1;
                    P = patch([time(starttime) time(stoptime) time(stoptime) time(starttime)], [0 0 100 100]+(i-1)*100 - 150,'k');
                    hold on;
    %                 plot([time(starttime) time(stoptime)], [1 1].*(i-1)*100,'b', 'LineWidth', 3)
              end;
                starttime = 0;
            end;
        end;
    end;
    [temp StartIndex] = find(AllLegsX ~= -1);
    xlim([time(StartIndex(1)) time(StartIndex(end))]);
    Xlim  = get(gca, 'XLim');
    ylim([-150 450]);
    grid on;
    set(gca,'YTickLabel',TEXT);
    box on;
    hold off;
    set(gca,'XTickLabel',[]);
    
    h2 = subplot(4,2,5);
    subplot('Position',[0.05 0.43 0.45 0.15], 'FontSize', 14);
    % place body velocity with running average
    plot(time((BodyVelocity > 0)), smooth(BodyVelocity(BodyVelocity > 0)/1000,round(FrameRate/40)),'--','color', [0 0 0], 'LineWidth', 2);
    hold on;
    % plot body velocity without smoothing too
    plot(time((BodyVelocity > 0)), smooth(BodyVelocity(BodyVelocity > 0)/1000,round(FrameRate/80)),'--','color', [0.3 0.3 0.3], 'LineWidth', 0.5);
    xlabel('t [sec]');
    ylabel('Body velocity [mm/s]');
    grid on;
    box on;
    hold off;
    set(gca, 'XLim',  Xlim);
%     Xlim  = get(gca, 'XLim');
  
    
    
% PLOT StepStartRelativePosition ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    h3 = subplot(4,2,[2 4 6 8]);
    subplot('Position',[0.55 0.1 0.4 0.85], 'FontSize', 14)    
    RGBbright = [1      0.75  0.75; ...
                 1      0.85  0.75; ...
                 0.75   1     0.75; ...
                 0.85   1     1; ...
                 0.75   0.75  1; ...
                 0.75   0.75  0.75];
               
    % calculate body size and direction for start legs
    if BodyDirection3(StartStep(1,1)) == 1
        BodyLength =  2 * median(BodyStdY(BodyStdY > 0));
        if length(BodyStdX(BodyStdX > 0)) > 0
            BodyWidth =  2 * median(BodyStdX(BodyStdX > 0));
        else
            BodyWidth =  0;
        end;
    else
        % Ricardo Changed this
%         BodyLength =  median(BodyStdX(BodyStdY > 0));
%         if ~isempty(BodyStdY(BodyStdY > 0))
%             BodyWidth =  2 * median(BodyStdY(BodyStdY > 0));
%         else
%             BodyWidth =  0;
%         end;
        BodyLength = 2* median(BodyStdY(BodyStdY > 0));
        if ~isempty(BodyStdX(BodyStdX > 0))
            BodyWidth =  median(BodyStdX(BodyStdX > 0));
        else
            BodyWidth =  0;
        end;
    end;

% STARTING POSITIONS    
    % plot leg positions
    
    hold off;
    % plot starting points
    for j = 1:6 % loop over legs
        Sign = 1;
        if j > 3, Sign = -1; end; 
        plot(Sign*PerpDist(j,StartStep(j,1:counter(j))) / BodyLength, ParaDist(j,StartStep(j,1:counter(j))) / BodyLength, 'o','color', RGB(j,:), 'MarkerSize', 8, 'MarkerFaceColor',RGB(j,:));  % CESAR EDIT HERE! - circle 
        hold on;
    end;
    L = legend('Left Fore', 'Left Middle', 'Left Hind', 'Right Fore', 'Right Middle', 'Right Hind');

    % load fruitfly image
%     fruitflypic = imread('drosophila.png');
%     image([-1.29 1.49],[1.1 -1.55],fruitflypic);
%     image([-1.29 1.49]/4,[1.1 -1.55]/4,fruitflypic);

    % plot leg tracks with brighter colors
    for i = 1:6
      if counter(i) > 0
        ind = find(PerpDist(i,:) ~= -1);
        ind = ind(ind >= StartStep(i,1) & ind <= StopStep(i,counter(i))); % this makes sure that only those parts are taken into account that are not part of the steps that are present at the very first or last frames with the body on        

        for j = 1:length(ind)-1
            if ind(j+1) - ind(j) == 1
                I = [ind(j) ind(j+1)];
                Sign = 1;
                if i > 3, Sign = -1; end; 
                auxh = plot(Sign*PerpDist(i,I) / BodyLength, ParaDist(i,I) / BodyLength,'color', RGB(i,:), 'LineWidth', 2); % CESAR EDIT HERE! - path           
                set(get(get(auxh,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
 
            end
        end
      end;
    end;
    % plot starting points again for the sake of the legend
    for j = 1:6 % loop over legs
      if counter(i) > 0
        Sign = 1;
        StartPositionXAvg(j) = mean(PerpDist(j,StartStep(j,1:counter(j))) / BodyLength);
        StartPositionYAvg(j) = mean(ParaDist(j,StartStep(j,1:counter(j))) / BodyLength);
        StopPositionXAvg(j)  = mean(PerpDist(j, StopStep(j,1:counter(j))) / BodyLength);
        StopPositionYAvg(j)  = mean(ParaDist(j, StopStep(j,1:counter(j))) / BodyLength);
        StartPositionXSTD(j) =  std(PerpDist(j,StartStep(j,1:counter(j))) / BodyLength);
        StartPositionYSTD(j) =  std(ParaDist(j,StartStep(j,1:counter(j))) / BodyLength);
        StopPositionXSTD(j)  =  std(PerpDist(j, StopStep(j,1:counter(j))) / BodyLength);
        StopPositionYSTD(j)  =  std(ParaDist(j, StopStep(j,1:counter(j))) / BodyLength);
        if j > 3, Sign = -1; end; 
        auxh = plot(Sign*PerpDist(j,StartStep(j,1:counter(j))) / BodyLength, ParaDist(j,StartStep(j,1:counter(j))) / BodyLength, 'o','color', RGB(j,:), 'MarkerSize', 6, 'MarkerFaceColor',RGB(j,:));
        set(get(get(auxh,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

        hold on;
      end;
    end;

% Calculate the distance difference between the AEP and PEP of left-right leg pairs
  AEPFrontDiff  = sqrt((StartPositionXAvg(1) - StartPositionXAvg(4))^2 + (StartPositionYAvg(1) - StartPositionYAvg(4))^2);
  PEPFrontDiff  = sqrt(( StopPositionXAvg(1) -  StopPositionXAvg(4))^2 + ( StopPositionYAvg(1) -  StopPositionYAvg(4))^2);
  AEPMiddleDiff = sqrt((StartPositionXAvg(2) - StartPositionXAvg(5))^2 + (StartPositionYAvg(2) - StartPositionYAvg(5))^2);
  PEPMiddleDiff = sqrt(( StopPositionXAvg(2) -  StopPositionXAvg(5))^2 + ( StopPositionYAvg(2) -  StopPositionYAvg(5))^2);
  AEPHindDiff   = sqrt((StartPositionXAvg(3) - StartPositionXAvg(6))^2 + (StartPositionYAvg(3) - StartPositionYAvg(6))^2);
  PEPHindDiff   = sqrt(( StopPositionXAvg(3) -  StopPositionXAvg(6))^2 + ( StopPositionYAvg(3) -  StopPositionYAvg(6))^2);
    
    % plot ellipse
    t = 0:0.001:2*pi;
    auxh1 = plot(BodyWidth/BodyLength*cos(t)/2,sin(t)/2,'color',[0.5,0.5,0.5],'LineWidth',2)
%     plot(cos(t),sin(t),'color',[0.5,0.5,0.5],'LineWidth',2)
    % plot little arrow
    auxh2 = plot([0 0],    [-0.15 0.15],'color',[0.5,0.5,0.5],'LineWidth',2)
    auxh3 = plot([0  0.01],[0.15 0.01] ,'color',[0.5,0.5,0.5],'LineWidth',1)
    auxh4 = plot([0 -0.01],[0.15 0.01] ,'color',[0.5,0.5,0.5],'LineWidth',1)
        set(get(get(auxh1,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        set(get(get(auxh2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        set(get(get(auxh3,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        set(get(get(auxh4,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');

    set(L,'Interpreter','none', 'FontSize', 8, 'Location', 'NorthEastOutside');

    % set picture limits (CESAR)
      XLIMIT = [-1 +1];
      YLIMIT = [-1.2 1.2];
    
      xlim(XLIMIT);
      ylim(YLIMIT);
      
    % set picture size to have correct ratio
    H = xlim;
    W = ylim;

    set(gca,'Layer','Top'); % put grid on top
%     title('Step Starting Positions');
    xlabel('perpendicular distance from body center [normalized to body length]');
    ylabel('parallel distance from body center [normalized to body length]')
    grid on;
    box on;
    hold off;
        
    
% TEXT ON SCREEN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  subplot(4,2,7);
  subplot('Position',[0.05 0.1 0.45 0.27], 'FontSize', 14)
%   box on;
  set(gca,'xcolor',get(gcf,'color'));
  set(gca,'ycolor',get(gcf,'color'));
  set(gca,'ytick',[]);
  set(gca,'xtick',[]);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Things have to be between 0 and 1 (both x and y coordinates)
    LineWidth = 0.12;      
    if FourFeetOn == 0
      text(0,1-2*LineWidth,['Speed [mm/s]:           ' num2str(   mean(BodyVelocity(BodyVelocity > 0)/1000)     )],'FontSize', 10,'FontName','FixedWidth');
      text(0,1-3*LineWidth,['Tripod index:           ' num2str(   TripodIndex/sum(Total(2:end))                 )],'FontSize', 10,'FontName','FixedWidth');
      text(0,1-4*LineWidth,['Tetrapod index:         ' num2str(   TetrapodIndex/sum(Total(2:end))               )],'FontSize', 10,'FontName','FixedWidth');
      %text(0,1-4*LineWidth,['Body size:             ' num2str(   2*median(v.bodystdPar(:))                     )],'FontSize', 10,'FontName','FixedWidth');
      text(0,1-5*LineWidth,['Wave gait index:        ' num2str(   WaveGaitIndex/sum(Total(2:end))               )],'FontSize', 10,'FontName','FixedWidth');
      text(0,1-6*LineWidth,['Non-canonical index:    ' num2str(   1- (TripodIndex + TetrapodIndex + WaveGaitIndex)/sum(Total(2:end))                                    )],'FontSize', 10,'FontName','FixedWidth');
      ind = find(filename == '\' | filename == '/');
      text(0,1-7*LineWidth,['Stance straightness:    ' num2str(   mean(AvgStStrAll)                             )],'FontSize', 10,'FontName','FixedWidth');
            ind = find(filename == '\' | filename == '/');
      text(0,1-8*LineWidth,['Data name: ' num2str(   filename(ind(end-2)+1:ind(end-1)-1)                      )],'FontSize', 10,'FontName','FixedWidth', 'Interpreter', 'None');

      AvgStepDist=mean([StepLength(1,1:StepCounter(1)-1) StepLength(2,1:StepCounter(2)-1) StepLength(3,1:StepCounter(3)-1) StepLength(4,1:StepCounter(4)-1) StepLength(5,1:StepCounter(5)-1) StepLength(6,1:StepCounter(6)-1)]);
      text(0,1-9*LineWidth,['Average Step Dist [um]: ' num2str(   AvgStepDist                                   )],'FontSize', 10,'FontName','FixedWidth')      
      
    else
      text(0,1-1*LineWidth,['Speed [mm/s]:          ' num2str(   mean(BodyVelocity(BodyVelocity > 0)/1000)   )],'FontSize', 10,'FontName','FixedWidth');
      text(0,1-2*LineWidth,['Walk index:            ' num2str(   WalkIndex/sum(Total(2:end))                 )],'FontSize', 10,'FontName','FixedWidth');
      text(0,1-3*LineWidth,['Trot index:            ' num2str(   TrotIndex/sum(Total(2:end))                 )],'FontSize', 10,'FontName','FixedWidth');
      text(0,1-4*LineWidth,['Pace index:            ' num2str(   PaceIndex/sum(Total(2:end))                 )],'FontSize', 10,'FontName','FixedWidth');
      %text(0,1-4*LineWidth,['Body size:             ' num2str(   2*median(v.bodystdPar(:))                     )],'FontSize', 20,'FontName','FixedWidth');
      text(0,1-5*LineWidth,['Stance straightness:   ' num2str(   mean(AvgStStrAll)                           )],'FontSize', 10,'FontName','FixedWidth');
      
            ind = find(filename == '\' | filename == '/');
      text(0,1-6*LineWidth,['Data name: ' num2str(   filename(ind(end-2)+1:ind(end-1)-1)                     )],'FontSize', 10,'FontName','FixedWidth', 'Interpreter', 'None');

      AvgStepDist=mean([StepLength(1,1:StepCounter(1)-1) StepLength(2,1:StepCounter(2)-1) StepLength(3,1:StepCounter(3)-1) StepLength(4,1:StepCounter(4)-1) StepLength(5,1:StepCounter(5)-1) StepLength(6,1:StepCounter(6)-1)]);
      text(0,1-7*LineWidth,['Average Step Dist:  ' num2str(   AvgStepDist                                   )],'FontSize', 10,'FontName','FixedWidth');
    end;
    
    %text(0.55,1-7*LineWidth,['Average Step Dist:  ' num2str(   AvgStepDist                                   )],'FontSize', 20,'FontName','FixedWidth');
    

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  
% save output  
    ind = find(filename == '\' | filename == '/');
    outputfilename = sprintf('%ssummary_plot_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
    saveas(h,outputfilename,'png');
    close(h);

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;
   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FRACTION OF FRAMES WITH 2 OR MORE FOOTPRINTS TURNING ON
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate the fraction of frames when two or more footprints turn on


% consider only parts when the body is on
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> old code is commmented
  ind = find(TCx > 0);
%   ind = find(BodyX > 0);
  
  turnoncounter = 0;
  turnoncounterTotal = length(ind);

  for i = ind(2:end)
    
      turnons = 0;
      if LeftFrontLegX(i-1)   <= 0 & LeftFrontLegX(i)    > 0, turnons = turnons + 1; end;
      if RightFrontLegX(i-1)  <= 0 & RightFrontLegX(i)   > 0, turnons = turnons + 1; end;
      if LeftMiddleLegX(i-1)  <= 0 & LeftMiddleLegX(i)   > 0, turnons = turnons + 1; end;
      if RightMiddleLegX(i-1) <= 0 & RightMiddleLegX(i)  > 0, turnons = turnons + 1; end;
      if LeftBackLegX(i-1)    <= 0 & LeftBackLegX(i)     > 0, turnons = turnons + 1; end;
      if RightBackLegX(i-1)   <= 0 & RightBackLegX(i)    > 0, turnons = turnons + 1; end;
    
      if turnons >= 2
          turnoncounter = turnoncounter + 1;
      end;
  end;

FractionOf2OrMoreTurnons = turnoncounter / max(turnoncounterTotal,1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output data to separate files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
disp('Saving data in Excel file...')
disp(' ')


% Determine excel file's name based on name of data file:
ind = find(foldername == '/' | foldername == '\' | foldername == ' ' | foldername == '.' | foldername == ':');
ExcelFileName = foldername;
ExcelFileName(ind) = '_';
ExcelFileName = ExcelFileName(max(1,end-30):end);

% first delete excel file to avoid overwriting issues
delete([foldername ExcelFileName '.xlsx'])



MedianBodyStdX = median(BodyStdX);
MedianBodyStdY = median(BodyStdY);
ind = find(BodyStdX > MedianBodyStdX*0.85 | BodyStdY > MedianBodyStdY*0.85);
TIME = time(ind);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> old code is commmented
Body_x = TCx(ind);
% Body_x = BodyX(ind);
Body_y = TCy(ind);
% Body_y = BodyY(ind);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Body_direction1 = BodyDirection1(ind);
Body_direction2 = BodyDirection2(ind);
Body_direction3 = BodyDirection3(ind);
Body_orientation = Orientation(ind);
Body_STDy = BodyStdY(ind);
Body_STDx = BodyStdX(ind);

DistanceLF = Distance(1,ind);
DistanceRF = Distance(4,ind);
DistanceLM = Distance(2,ind);
DistanceRM = Distance(5,ind);
DistanceLB = Distance(3,ind);
DistanceRB = Distance(6,ind);

PerpDistLF = PerpDist(1,ind);
PerpDistRF = PerpDist(4,ind);
PerpDistLM = PerpDist(2,ind);
PerpDistRM = PerpDist(5,ind);
PerpDistLB = PerpDist(3,ind);
PerpDistRB = PerpDist(6,ind);

ParaDistLF = ParaDist(1,ind);
ParaDistRF = ParaDist(4,ind);
ParaDistLM = ParaDist(2,ind);
ParaDistRM = ParaDist(5,ind);
ParaDistLB = ParaDist(3,ind);
ParaDistRB = ParaDist(6,ind);

AngleLF = Angle(1,ind);
AngleRF = Angle(4,ind);
AngleLM = Angle(2,ind);
AngleRM = Angle(5,ind);
AngleLB = Angle(3,ind);
AngleRB = Angle(6,ind);

% Information sheet
  disp('  1.Info_Sheet')
InfoData = [{'INFORMATION SHEET'};...
            {''};...
            {'Sheet  1: Information'};...
            {'Sheet  2: Parameters'};...
            {'Sheet  3: Body'};...
            {'Sheet  4: LF'};...
            {'Sheet  5: LM'};...
            {'Sheet  6: LH'};...
            {'Sheet  7: RF'};...
            {'Sheet  8: RM'};...
            {'Sheet  9: RH'};...
            {'Sheet 10: Leg Combinations'};...
            {'Sheet 11: Minimum/Maximum/Mean Leg Distance and Angle Information'};...
            {'Sheet 12: Full FlyTable data'};...
            {'Sheet 13: Step size and velocity'};...
            {'Sheet 14: Body velocity'};...
            {'Sheet 15: Leg alignment'};...
            {''};...
            {''};...
            {''};...
            {'Columns in sheet 3:'};...
            {'1: time'};...
            {': x coordinate'};...
            {': y coordinate'};...
            {': directional parameter #1'};...
            {': directional parameter #2'};...
            {': directional parameter #3'};...
            {': orientation'};...
            {': STD x'};...
            {': STD y'};...
            {''};...
            {'Columns in sheets 4-9:'};...
            {'1: time'};...
            {'2: distance'};...
            {'3: parallel distance'};...
            {'4: perpendicular distance'};...
            {'5: angle between leg and body direction'}];
        
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> activex

% start Excel
exl = actxserver('excel.application');
exlWkbk = exl.Workbooks;
% Add workbook
exlFile = invoke(exlWkbk, 'Add');
% get the sheets for this workbook
sheets = exl.ActiveWorkBook.Sheets;
nbSheets = 20;

% make sure we have enough sheets
if sheets.Count < nbSheets
    sheetLast = get(sheets, 'Item', sheets.Count);
    invoke(sheetLast, 'Activate');
    invoke(sheets,'Add',[],sheetLast,nbSheets-sheets.Count);
end

sheet = get(sheets, 'Item', 1);
invoke(sheet, 'Activate');
% rename sheet
exl.Activesheet.Name = '1.Info_Sheet';
% write data
ActivesheetRange = get(sheet,'Range','A1:A37');
set(ActivesheetRange, 'Value', InfoData);

% xlswrite([foldername ExcelFileName '.xlsx'], InfoData,'1.Info_Sheet');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;

% PARAMETERS
  disp('  2.Parameters');
Data = { 'PARAMETERS' '';...
    '' '';...
    'Frame settings--------------------------------------------------' '';...
    'Video frame per second [fps]: ' num2str(p.fps);...
    'Distance calibration [pixel/um]: ' num2str(p.distcal);...
    '' '';...
    'Analysis parameters for AutoFind--------------------------------' '';...
    'Fixed body length [pixel,0-not fixed]: ' num2str(p.fixed_body_length_value*p.fixed_body_length);...
    '' '';...
    '' '';...
    'Number of frames where the fly''s body is on: ' num2str(BodyOnNumber)};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> activex

sheet = get(sheets, 'Item', 2);
invoke(sheet, 'Activate');
% rename sheet
exl.Activesheet.Name = '2.Parameters';
% write data
ActivesheetRange = get(sheet,'Range','A1:B11');
set(ActivesheetRange, 'Value', Data);

% xlswrite([foldername ExcelFileName '.xlsx'], Data,'2.Parameters');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;

% BODY
  disp('  3.Body');
Data = [TIME' Body_x' Body_y' Body_direction1' Body_direction2' Body_direction3' Body_orientation' Body_STDx' Body_STDy'];
if length(Data) == 0, Data = {'No data...'}; end;   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> activex

sheet = get(sheets, 'Item', 3);
invoke(sheet, 'Activate');
% rename sheet
exl.Activesheet.Name = '3.Body';
% write data
Range = strcat('A1:I',num2str(size(Data,1)));
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', Data);

% xlswrite([foldername ExcelFileName '.xlsx'], Data,'3.Body');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;

% LF
disp('  4.LF')
Ind = find(DistanceLF ~= -1);
% Data = [{'Time'; TIME(Ind)'} {'Distance'; DistanceLF(Ind)'} {'Para. Dist.'; ParaDistLF(Ind)'} {'Perp. Dist.'; PerpDistLF(Ind)'} ]
Data = [TIME(Ind)' DistanceLF(Ind)' ParaDistLF(Ind)' PerpDistLF(Ind)' AngleLF(Ind)'];
if length(Data) == 0, Data = {'No data...'}; end;   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> activex

sheet = get(sheets, 'Item', 4);
invoke(sheet, 'Activate');
% rename sheet
exl.Activesheet.Name = '4.LF';
% write data
Range = strcat('A1:E',num2str(size(Data,1)));
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', Data);

% xlswrite([foldername ExcelFileName '.xlsx'], Data,'4.LF');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;

% LM
  disp('  5.LM')
Ind = find(DistanceLM ~= -1);
Data = [TIME(Ind)' DistanceLM(Ind)' ParaDistLM(Ind)' PerpDistLM(Ind)' AngleLM(Ind)'];
if length(Data) == 0, Data = {'No data...'}; end;   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> activex

sheet = get(sheets, 'Item', 5);
invoke(sheet, 'Activate');
% rename sheet
exl.Activesheet.Name = '5.LM';
% write data
Range = strcat('A1:E',num2str(size(Data,1)));
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', Data);

% xlswrite([foldername ExcelFileName '.xlsx'], Data,'5.LM');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;

% LH
  disp('  6.LH');
Ind = find(DistanceLB ~= -1);
Data = [TIME(Ind)' DistanceLB(Ind)' ParaDistLB(Ind)' PerpDistLB(Ind)' AngleLB(Ind)'];
if length(Data) == 0, Data = {'No data...'}; end;  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> activex

sheet = get(sheets, 'Item', 6);
invoke(sheet, 'Activate');
% rename sheet
exl.Activesheet.Name = '6.LH';
% write data
Range = strcat('A1:E',num2str(size(Data,1)));
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', Data);

% xlswrite([foldername ExcelFileName '.xlsx'], Data,'6.LH');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;

% RF
  disp('  7.RF');
Ind = find(DistanceRF ~= -1);
Data = [TIME(Ind)' DistanceRF(Ind)' ParaDistRF(Ind)' PerpDistRF(Ind)' AngleRF(Ind)'];
if length(Data) == 0, Data = {'No data...'}; end;    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> activex

sheet = get(sheets, 'Item', 7);
invoke(sheet, 'Activate');
% rename sheet
exl.Activesheet.Name = '7.RF';
% write data
Range = strcat('A1:E',num2str(size(Data,1)));
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', Data);

% xlswrite([foldername ExcelFileName '.xlsx'], Data,'7.RF');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;

% RM
  disp('  8.RM');
Ind = find(DistanceRM ~= -1);
Data = [TIME(Ind)' DistanceRM(Ind)' ParaDistRM(Ind)' PerpDistRM(Ind)' AngleRM(Ind)'];
if length(Data) == 0, Data = {'No data...'}; end;  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> activex

sheet = get(sheets, 'Item', 8);
invoke(sheet, 'Activate');
% rename sheet
exl.Activesheet.Name = '8.RM';
% write data
Range = strcat('A1:E',num2str(size(Data,1)));
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', Data);

% xlswrite([foldername ExcelFileName '.xlsx'], Data,'8.RM');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;

% RH
  disp('  9.RH');
Ind = find(DistanceRB ~= -1);
Data = [TIME(Ind)' DistanceRB(Ind)' ParaDistRB(Ind)' PerpDistRB(Ind)' AngleRB(Ind)'];
if length(Data) == 0, Data = {'No data...'}; end;    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> activex

sheet = get(sheets, 'Item', 9);
invoke(sheet, 'Activate');
% rename sheet
exl.Activesheet.Name = '9.RH';
% write data
Range = strcat('A1:E',num2str(size(Data,1)));
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', Data);

% xlswrite([foldername ExcelFileName '.xlsx'], Data,'9.RH');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;

% Most Common Leg Combinations
  disp('  10.Leg_combinations');
Data = {'Most common leg combinations and numbers of occurrences for each combination:' ''; ...
        '' ''; ...
        '1 - leg is present in combination' ''; ...
        '0 - leg is notpresent in combination' ''; ...
        '' ''; ...
        'Leg order in combination:' ''; ...
        'LF LM LH RF RM RH' ''; ...
        '' ''; ...
        MostCommonCombinations(1,:)   NumbersofCombinations(1); ...
        MostCommonCombinations(2,:)   NumbersofCombinations(2); ...
        MostCommonCombinations(3,:)   NumbersofCombinations(3); ...
        MostCommonCombinations(4,:)   NumbersofCombinations(4); ...
        MostCommonCombinations(5,:)   NumbersofCombinations(5); ...
        MostCommonCombinations(6,:)   NumbersofCombinations(6); ...
        MostCommonCombinations(7,:)   NumbersofCombinations(7); ...
        MostCommonCombinations(8,:)   NumbersofCombinations(8); ...
        MostCommonCombinations(9,:)   NumbersofCombinations(9); ...
        MostCommonCombinations(10,:)  NumbersofCombinations(10); ...
        MostCommonCombinations(11,:)  NumbersofCombinations(11); ...
        MostCommonCombinations(12,:)  NumbersofCombinations(12); ...
        MostCommonCombinations(13,:)  NumbersofCombinations(13); ...
        MostCommonCombinations(14,:)  NumbersofCombinations(14); ...
        MostCommonCombinations(15,:)  NumbersofCombinations(15); ...
        MostCommonCombinations(16,:)  NumbersofCombinations(16); ...
        MostCommonCombinations(17,:)  NumbersofCombinations(17); ...
        MostCommonCombinations(18,:)  NumbersofCombinations(18); ...
        MostCommonCombinations(19,:)  NumbersofCombinations(19); ...
        MostCommonCombinations(20,:)  NumbersofCombinations(20); ...
        MostCommonCombinations(21,:)  NumbersofCombinations(21); ...
        MostCommonCombinations(22,:)  NumbersofCombinations(22); ...
        MostCommonCombinations(23,:)  NumbersofCombinations(23); ...
        MostCommonCombinations(24,:)  NumbersofCombinations(24); ...
        MostCommonCombinations(25,:)  NumbersofCombinations(25); ...
        MostCommonCombinations(26,:)  NumbersofCombinations(26); ...
        MostCommonCombinations(27,:)  NumbersofCombinations(27); ...
        MostCommonCombinations(28,:)  NumbersofCombinations(28); ...
        MostCommonCombinations(29,:)  NumbersofCombinations(29); ...
        MostCommonCombinations(30,:)  NumbersofCombinations(30); ...
        MostCommonCombinations(31,:)  NumbersofCombinations(31); ...
        MostCommonCombinations(32,:)  NumbersofCombinations(32); ...
        MostCommonCombinations(33,:)  NumbersofCombinations(33); ...
        MostCommonCombinations(34,:)  NumbersofCombinations(34); ...
        MostCommonCombinations(35,:)  NumbersofCombinations(35); ...
        MostCommonCombinations(36,:)  NumbersofCombinations(36); ...
        MostCommonCombinations(37,:)  NumbersofCombinations(37); ...
        MostCommonCombinations(38,:)  NumbersofCombinations(38); ...
        MostCommonCombinations(39,:)  NumbersofCombinations(39); ...
        MostCommonCombinations(40,:)  NumbersofCombinations(40); ...
        MostCommonCombinations(41,:)  NumbersofCombinations(41); ...
        MostCommonCombinations(42,:)  NumbersofCombinations(42); ...
        MostCommonCombinations(43,:)  NumbersofCombinations(43); ...
        MostCommonCombinations(44,:)  NumbersofCombinations(44); ...
        MostCommonCombinations(45,:)  NumbersofCombinations(45); ...
        MostCommonCombinations(46,:)  NumbersofCombinations(46); ...
        MostCommonCombinations(47,:)  NumbersofCombinations(47); ...
        MostCommonCombinations(48,:)  NumbersofCombinations(48); ...
        MostCommonCombinations(49,:)  NumbersofCombinations(49); ...
        MostCommonCombinations(50,:)  NumbersofCombinations(50); ...
        MostCommonCombinations(51,:)  NumbersofCombinations(51); ...
        MostCommonCombinations(52,:)  NumbersofCombinations(52); ...
        MostCommonCombinations(53,:)  NumbersofCombinations(53); ...
        MostCommonCombinations(54,:)  NumbersofCombinations(54); ...
        MostCommonCombinations(55,:)  NumbersofCombinations(55); ...
        MostCommonCombinations(56,:)  NumbersofCombinations(56); ...
        MostCommonCombinations(57,:)  NumbersofCombinations(57); ...
        MostCommonCombinations(58,:)  NumbersofCombinations(58); ...
        MostCommonCombinations(59,:)  NumbersofCombinations(59); ...
        MostCommonCombinations(60,:)  NumbersofCombinations(60); ...
        MostCommonCombinations(61,:)  NumbersofCombinations(61); ...
        MostCommonCombinations(62,:)  NumbersofCombinations(62); ...
        MostCommonCombinations(63,:)  NumbersofCombinations(63); ...
        '' ''; ...
        '' ''; ...
        'Leg Number Index (ratio of frames where the fly has N leg present):' ''; ...
        '' ''; ...
        'N=1' num2str(Total(2)/sum(Total(2:end))); ...
        'N=2' num2str(Total(3)/sum(Total(2:end))); ...
        'N=3' num2str(Total(4)/sum(Total(2:end))); ...
        'N=4' num2str(Total(5)/sum(Total(2:end))); ...
        'N=5' num2str(Total(6)/sum(Total(2:end))); ...
        'N=6' num2str(Total(7)/sum(Total(2:end))); ...
        '' ''; ...
        'Tripod index' num2str(TripodIndex/sum(Total(2:end))); ...
        'Tetrapod index' num2str(TetrapodIndex/sum(Total(2:end))); ...
        'Wave gait index' num2str(WaveGaitIndex/sum(Total(2:end))); ...
        'Pace index' num2str(PaceIndex/sum(Total(2:end))); ...
        'Trot index' num2str(TrotIndex/sum(Total(2:end))); ...
        'Walk index' num2str(WalkIndex/sum(Total(2:end))); ...
        'Noncompliancenumber' NoncomplianceIndex;...
        'Noncompliance index' num2str(NoncomplianceIndex/sum(Total(2:end))); ...
        '' ''; ...
        '' ''; ...        
        'Fraction of 2+ FP turnons' num2str(FractionOf2OrMoreTurnons); ...
        '' ''; ...
        '' ''; ...        
        'Average combination trace code' num2str(AVGcombtrace); ...
        'STD combination trace code' num2str(STDcombtrace)};
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> activex

sheet = get(sheets, 'Item', 10);
invoke(sheet, 'Activate');
% rename sheet
exl.Activesheet.Name = '10.Leg_combinations';
% write data
Range = strcat('A1:B',num2str(size(Data,1)));
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', Data);

% xlswrite([foldername ExcelFileName '.xlsx'], Data,'10.Leg_combinations');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;



% min max information
  disp('  11.Pos. stat.');
% disp( '        LF       LM        LH        RH       RM        RF')
Data = {' ' 'LF' 'RF' 'LM' 'RM' 'LH' 'RH'; ...
        'distance min               '           MinDist(1)           MinDist(4)           MinDist(2)           MinDist(5)           MinDist(3)           MinDist(6); ...
        'distance max               '           MaxDist(1)           MaxDist(4)           MaxDist(2)           MaxDist(5)           MaxDist(3)           MaxDist(6); ...
        'distance mean              '          MeanDist(1)          MeanDist(4)          MeanDist(2)          MeanDist(5)          MeanDist(3)          MeanDist(6); ...
        'parallel distance min      '       MinParaDist(1)       MinParaDist(4)       MinParaDist(2)       MinParaDist(5)       MinParaDist(3)       MinParaDist(6); ...
        'parallel distance max      '       MaxParaDist(1)       MaxParaDist(4)       MaxParaDist(2)       MaxParaDist(5)       MaxParaDist(3)       MaxParaDist(6); ...
        'parallel distance mean     '      MeanParaDist(1)      MeanParaDist(4)      MeanParaDist(2)      MeanParaDist(5)      MeanParaDist(3)      MeanParaDist(6); ...
        'perpendicular distance min '       MinPerpDist(1)       MinPerpDist(4)       MinPerpDist(2)       MinPerpDist(5)       MinPerpDist(3)       MinPerpDist(6); ...
        'perpendicular distance max '       MaxPerpDist(1)       MaxPerpDist(4)       MaxPerpDist(2)       MaxPerpDist(5)       MaxPerpDist(3)       MaxPerpDist(6); ...
        'perpendicular distance mean'      MeanPerpDist(1)      MeanPerpDist(4)      MeanPerpDist(2)      MeanPerpDist(5)      MeanPerpDist(3)      MeanPerpDist(6); ...
        'angle min                  '          MinAngle(1)          MinAngle(4)          MinAngle(2)          MinAngle(5)          MinAngle(3)          MinAngle(6); ...
        'angle max                  '          MaxAngle(1)          MaxAngle(4)          MaxAngle(2)          MaxAngle(5)          MaxAngle(3)          MaxAngle(6); ...
        'angle mean                 '         MeanAngle(1)         MeanAngle(4)         MeanAngle(2)         MeanAngle(5)         MeanAngle(3)         MeanAngle(6); ...
        'AEP X avg       ' StartPositionXAvg(1) StartPositionXAvg(4) StartPositionXAvg(2) StartPositionXAvg(5) StartPositionXAvg(3) StartPositionXAvg(6); ...
        'AEP X std       ' StartPositionXSTD(1) StartPositionXSTD(4) StartPositionXSTD(2) StartPositionXSTD(5) StartPositionXSTD(3) StartPositionXSTD(6); ...
        'AEP Y avg       ' StartPositionYAvg(1) StartPositionYAvg(4) StartPositionYAvg(2) StartPositionYAvg(5) StartPositionYAvg(3) StartPositionYAvg(6); ...
        'AEP Y std       ' StartPositionYSTD(1) StartPositionYSTD(4) StartPositionYSTD(2) StartPositionYSTD(5) StartPositionYSTD(3) StartPositionYSTD(6); ...
        'PEP X avg       '  StopPositionXAvg(1)  StopPositionXAvg(4)  StopPositionXAvg(2)  StopPositionXAvg(5)  StopPositionXAvg(3)  StopPositionXAvg(6); ...
        'PEP X std       '  StopPositionXSTD(1)  StopPositionXSTD(4)  StopPositionXSTD(2)  StopPositionXSTD(5)  StopPositionXSTD(3)  StopPositionXSTD(6); ...
        'PEP Y avg       '  StopPositionYAvg(1)  StopPositionYAvg(4)  StopPositionYAvg(2)  StopPositionYAvg(5)  StopPositionYAvg(3)  StopPositionYAvg(6); ...  
        'PEP Y std       '  StopPositionYSTD(1)  StopPositionYSTD(4)  StopPositionYSTD(2)  StopPositionYSTD(5)  StopPositionYSTD(3)  StopPositionYSTD(6); ...
        'AEP left-right diff' AEPFrontDiff ' ' AEPMiddleDiff ' ' AEPHindDiff ' '; ...
        'PEP left-right diff' PEPFrontDiff ' ' PEPMiddleDiff ' ' PEPHindDiff ' '; ...
        'Stance instability' Jitter(1) Jitter(4)  Jitter(2)  Jitter(5)  Jitter(3)  Jitter(6); ...
        'Body stability' BodyJitter ' ' ' ' ' ' ' ' ' '};
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> activex

sheet = get(sheets, 'Item', 11);
invoke(sheet, 'Activate');
% rename sheet
exl.Activesheet.Name = '11.Pos. stat.';
% write data
Range = strcat('A1:G',num2str(size(Data,1)));
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', Data);

% xlswrite([foldername ExcelFileName '.xlsx'], Data,'11.Pos. stat.');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;

% Whole FlyTable Information sheet
  disp('  12.Full Data');
  Data = num2cell(FlyTable');
  Data(2:end+1,:) = Data;
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> Added TCx, TCy to full data
% 'TCx' 'TCy'
%Xana: ->Added Combination code 2 to full data

  % add header
    Data(1,1:end+3) = {'time' 'BodyX' 'BodyY' 'BodyDirection1' 'BodyDirection2' 'BodyDirection3' 'BodyOrientation' 'BodyStdX' 'BodyStdY' 'LeftFrontLegX' 'LeftFrontLegY' 'RightFrontLegX' 'RightFrontLegY' 'LeftMiddleLegX' 'LeftMiddleLegY' 'RightMiddleLegX' 'RightMiddleLegY' 'LeftBackLegX' 'LeftBackLegY' 'RightBackLegX' 'RightBackLegY' 'TCx' 'TCy' 'LegCombinations (LF LM LH RF RM RH)' 'Combination Code' 'Compliance Code'};

  % add leg combinations to here
    for i = 1:length(LegCombinationArray)
        Data(i+1,end-2) = mat2cell(str2mat(dec2bin(LegCombinationArray(i),6)),1);
    end;

  % add CombinationCode
  %Xana % add combinationcodeCompliance
    Data(2:end,end-1) = num2cell(CombinationCode');
    Data(2:end,end) = num2cell(CombinationCodeCompliance');
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> activex

sheet = get(sheets, 'Item', 12);
invoke(sheet, 'Activate');
% rename sheet
exl.Activesheet.Name = '12.Full Data';
% write data
Range = strcat('A1:Z',num2str(size(Data,1)));
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', Data);    

% xlswrite([foldername ExcelFileName '.xlsx'], Data,'12.Full Data');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;

% calculate phases ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  disp('  13.Step_stat.');
    % extract fore and hind step times
      LeftForeStepTimes    = time(StopStep(1,1:StepCounter(1)));
      LeftMiddleStepTimes  = time(StopStep(2,1:StepCounter(2)));
      LeftHindStepTimes    = time(StopStep(3,1:StepCounter(3)));
      RightForeStepTimes   = time(StopStep(4,1:StepCounter(4)));
      RightMiddleStepTimes = time(StopStep(5,1:StepCounter(5)));
      RightHindStepTimes   = time(StopStep(6,1:StepCounter(6)));
  % FORE
    PhaseF = [];
    for i = 1:StepCounter(1)
        % find left fore swing starts that are before the current right fore swing start
          ind_after = find(RightForeStepTimes < LeftForeStepTimes(i));
        % assign value only if there is such
          if ~isempty(ind_after)
              % calculate new value
                if length(TotalStepCycle(4,:)) >= ind_after(end) & TotalStepCycle(4,ind_after(end)) ~= 0
                    NewLag = (LeftForeStepTimes(i) - RightForeStepTimes(ind_after(end))) / TotalStepCycle(4,ind_after(end));
                    % assign
                      PhaseF = [PhaseF NewLag];
                end;
          end;
    end  

  % MIDDLE
    PhaseM = [];
    for i = 1:StepCounter(2)
        % find left fore swing starts that are before the current right fore swing start
          ind_after = find(RightMiddleStepTimes < LeftMiddleStepTimes(i));
        % assign value only if there is such
          if ~isempty(ind_after)
              % calculate new value
                if length(TotalStepCycle(5,:)) >= ind_after(end) & TotalStepCycle(5,ind_after(end)) ~= 0
                    NewLag = (LeftMiddleStepTimes(i) - RightMiddleStepTimes(ind_after(end))) / TotalStepCycle(5,ind_after(end));
                    % assign
                      PhaseM = [PhaseM NewLag];
                end;
          end;
    end    
  % HIND
    PhaseH = [];
    for i = 1:StepCounter(3)
        % find left fore swing starts that are before the current right fore swing start
          ind_after = find(RightHindStepTimes < LeftHindStepTimes(i));
        % assign value only if there is such
          if ~isempty(ind_after)
              % calculate new value
                if length(TotalStepCycle(6,:)) >= ind_after(end) & TotalStepCycle(6,ind_after(end)) ~= 0
                    NewLag = (LeftHindStepTimes(i) - RightHindStepTimes(ind_after(end))) / TotalStepCycle(6,ind_after(end));
                    % assign
                      PhaseH = [PhaseH NewLag];
                end;
          end;
    end    
  % LH vs LM
    PhaseLMvsLH = [];
    for i = 1:StepCounter(2)
        % find left fore swing starts that are before the current right fore swing start
          ind_after = find(LeftHindStepTimes < LeftMiddleStepTimes(i));
        % assign value only if there is such
          if ~isempty(ind_after)
              % calculate new value
                if length(TotalStepCycle(3,:)) >= ind_after(end) & TotalStepCycle(3,ind_after(end)) ~= 0
                    NewLag = (LeftMiddleStepTimes(i) - LeftHindStepTimes(ind_after(end))) / TotalStepCycle(3,ind_after(end));
                    % assign
                      PhaseLMvsLH = [PhaseLMvsLH NewLag];
                end;
          end;
    end     

  % LM vs LF
    PhaseLMvsLF = [];
    for i = 1:StepCounter(1)
        % find left fore swing starts that are before the current right fore swing start
          ind_after = find(LeftMiddleStepTimes < LeftForeStepTimes(i));
        % assign value only if there is such
          if ~isempty(ind_after)
              % calculate new value
                if length(TotalStepCycle(2,:)) >= ind_after(end) & TotalStepCycle(2,ind_after(end)) ~= 0
                    NewLag = (LeftForeStepTimes(i) - LeftMiddleStepTimes(ind_after(end))) / TotalStepCycle(2,ind_after(end));
                    % assign
                      PhaseLMvsLF = [PhaseLMvsLF NewLag];
                end;
          end;
    end     
  % RH vs RM
    PhaseRMvsRH = [];
    for i = 1:StepCounter(5)
        % find left fore swing starts that are before the current right fore swing start
          ind_after = find(RightHindStepTimes < RightMiddleStepTimes(i));
        % assign value only if there is such
          if ~isempty(ind_after)
              % calculate new value
                if length(TotalStepCycle(6,:)) >= ind_after(end) & TotalStepCycle(6,ind_after(end)) ~= 0
                    NewLag = (RightMiddleStepTimes(i) - RightHindStepTimes(ind_after(end))) / TotalStepCycle(6,ind_after(end));
                    % assign
                      PhaseRMvsRH = [PhaseRMvsRH NewLag];
                end;
          end;
    end    
  % RM vs RF
    PhaseRMvsRF = [];
    for i = 1:StepCounter(4)
        % find left fore swing starts that are before the current right fore swing start
          ind_after = find(RightMiddleStepTimes < RightForeStepTimes(i));
        % assign value only if there is such
          if ~isempty(ind_after)
              % calculate new value
                if length(TotalStepCycle(5,:)) >= ind_after(end) & TotalStepCycle(5,ind_after(end)) ~= 0
                    NewLag = (RightForeStepTimes(i) - RightMiddleStepTimes(ind_after(end))) / TotalStepCycle(5,ind_after(end));
                    % assign
                      PhaseRMvsRF = [PhaseRMvsRF NewLag];
                end;
          end;
    end     
  % Metachronal lag LEFT 3L1
    % initialize
      MetachronalLeft3L1 = [];
    for i = 1:StepCounter(3)
        % find fore swing starts that are after the current hind swing start
          ind_after = find(LeftForeStepTimes > LeftHindStepTimes(i) + TotalStepCycle(3,1)/3);
        % assign value only if there is such
          if ~isempty(ind_after)
              % calculate new value
                NewLag = min(LeftForeStepTimes(ind_after) - LeftHindStepTimes(i));
              % assign
              MetachronalLeft3L1 = [MetachronalLeft3L1 NewLag];
          end;
    end
  % Metachronal lag RIGHT 3L1
    % initialize
      MetachronalRight3L1 = [];
    for i = 1:StepCounter(6)
        % find fore swing starts that are after the current hind swing start
          ind_after = find(RightForeStepTimes > RightHindStepTimes(i) + TotalStepCycle(6,1)/3);
        % assign value only if there is such
          if ~isempty(ind_after)
              % calculate new value
                NewLag = min(RightForeStepTimes(ind_after) - RightHindStepTimes(i));
              % assign
              MetachronalRight3L1 = [MetachronalRight3L1 NewLag];
          end;
    end

% step size and velocity information
Data = zeros(39,length(StepCounter(1,:)));
Data( 1,1:StepCounter(1)-1) =  time(StopStep(1,1:StepCounter(1)-1));
Data( 2,1:StepCounter(1)-1) =     StanceTime(1,1:StepCounter(1)-1) ;
Data( 3,1:StepCounter(1)-1) =      StepCycle(1,1:StepCounter(1)-1) ;
Data( 4,1:StepCounter(1)-1) = TotalStepCycle(1,1:StepCounter(1)-1) ;
Data( 5,1:StepCounter(1)-1) =   StepVelocity(1,1:StepCounter(1)-1) ;
Data( 6,1:StepCounter(1)-1) =     StepLength(1,1:StepCounter(1)-1) ;
Data( 7,1:StepCounter(2)-1) =  time(StopStep(2,1:StepCounter(2)-1));
Data( 8,1:StepCounter(2)-1) =     StanceTime(2,1:StepCounter(2)-1) ;
Data( 9,1:StepCounter(2)-1) =      StepCycle(2,1:StepCounter(2)-1) ;
Data(10,1:StepCounter(2)-1) = TotalStepCycle(2,1:StepCounter(2)-1) ;
Data(11,1:StepCounter(2)-1) =   StepVelocity(2,1:StepCounter(2)-1) ;
Data(12,1:StepCounter(2)-1) =     StepLength(2,1:StepCounter(2)-1) ;
Data(13,1:StepCounter(3)-1) =  time(StopStep(3,1:StepCounter(3)-1));
Data(14,1:StepCounter(3)-1) =     StanceTime(3,1:StepCounter(3)-1) ;
Data(15,1:StepCounter(3)-1) =      StepCycle(3,1:StepCounter(3)-1) ;
Data(16,1:StepCounter(3)-1) = TotalStepCycle(3,1:StepCounter(3)-1) ;
Data(17,1:StepCounter(3)-1) =   StepVelocity(3,1:StepCounter(3)-1) ;
Data(18,1:StepCounter(3)-1) =     StepLength(3,1:StepCounter(3)-1) ;
Data(19,1:StepCounter(4)-1) =  time(StopStep(4,1:StepCounter(4)-1));
Data(20,1:StepCounter(4)-1) =     StanceTime(4,1:StepCounter(4)-1) ;
Data(21,1:StepCounter(4)-1) =      StepCycle(4,1:StepCounter(4)-1) ;
Data(22,1:StepCounter(4)-1) = TotalStepCycle(4,1:StepCounter(4)-1) ;
Data(23,1:StepCounter(4)-1) =   StepVelocity(4,1:StepCounter(4)-1) ;
Data(24,1:StepCounter(4)-1) =     StepLength(4,1:StepCounter(4)-1) ;
Data(25,1:StepCounter(5)-1) =  time(StopStep(5,1:StepCounter(5)-1));
Data(26,1:StepCounter(5)-1) =     StanceTime(5,1:StepCounter(5)-1) ;
Data(27,1:StepCounter(5)-1) =      StepCycle(5,1:StepCounter(5)-1) ;
Data(28,1:StepCounter(5)-1) = TotalStepCycle(5,1:StepCounter(5)-1) ;
Data(29,1:StepCounter(5)-1) =   StepVelocity(5,1:StepCounter(5)-1) ;
Data(30,1:StepCounter(5)-1) =     StepLength(5,1:StepCounter(5)-1) ;
Data(31,1:StepCounter(6)-1) =  time(StopStep(6,1:StepCounter(6)-1));
Data(32,1:StepCounter(6)-1) =     StanceTime(6,1:StepCounter(6)-1) ;
Data(33,1:StepCounter(6)-1) =      StepCycle(6,1:StepCounter(6)-1) ;
Data(34,1:StepCounter(6)-1) = TotalStepCycle(6,1:StepCounter(6)-1) ;
Data(35,1:StepCounter(6)-1) =   StepVelocity(6,1:StepCounter(6)-1) ;
Data(36,1:StepCounter(6)-1) =     StepLength(6,1:StepCounter(6)-1) ;
Data(37,1:length(PhaseF))      = PhaseF;
Data(38,1:length(PhaseM))      = PhaseM;
Data(39,1:length(PhaseH))      = PhaseH;
Data(40,1:length(PhaseLMvsLH)) = PhaseLMvsLH;
Data(41,1:length(PhaseLMvsLF)) = PhaseLMvsLF;
Data(42,1:length(PhaseRMvsRH)) = PhaseRMvsRH;
Data(43,1:length(PhaseRMvsRF)) = PhaseRMvsRF;
Data(44,1:length(MetachronalLeft3L1))  = MetachronalLeft3L1;
Data(45,1:length(MetachronalRight3L1)) = MetachronalRight3L1;


S = size(Data');
DataCell(2:S(1)+1,1:S(2)) = num2cell(Data');
DataCell(1,1:S(2)) = {'Stance Offset(LF)' 'StanceTime(LF)' 'SwingTime(LF)' 'StepCycle(LF)' 'SwingSpeed(LF)' 'StepDist(LF)' 'Stance Offset(LM)' 'StanceTime(LM)' 'SwingTime(LM)' 'StepCycle(LM)' 'SwingSpeed(LM)' 'StepDist(LM)' 'Stance Offset(LH)' 'StanceTime(LH)' 'SwingTime(LH)' 'StepCycle(LH)' 'SwingSpeed(LH)' 'StepDist(LH)' 'Stance Offset(RF)' 'StanceTime(RF)' 'SwingTime(RF)' 'StepCycle(RF)' 'SwingSpeed(RF)' 'StepDist(RF)' 'Stance Offset(RM)' 'StanceTime(RM)' 'SwingTime(RM)' 'StepCycle(RM)' 'SwingSpeed(RM)' 'StepDist(RM)' 'Stance Offset(RH)' 'StanceTime(RH)' 'SwingTime(RH)' 'StepCycle(RH)' 'SwingSpeed(RH)' 'StepDist(RH)' 'Phase F' 'Phase M' 'Phase H' 'Phase LH vs LM'  'Phase LM vs LF'  'Phase RH vs RM'  'Phase RM vs RF' 'Metachronal Left 3L1' 'Metachronal Right 3L1'};

% make all the values that are smaller or equal to zero ' '
S = size(DataCell);
for i = 1:S(1)
    for j = 1:S(2)
        if cell2mat(DataCell(i,j)) <= 0
            DataCell(i,j) = {' '};
        end;
    end
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> activex

sheet = get(sheets, 'Item', 13);
invoke(sheet, 'Activate');
% rename sheet
exl.Activesheet.Name = '13.Step_stat.';
% write data
Range = strcat('A1:AS',num2str(size(DataCell,1)));
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', DataCell);  

% xlswrite([foldername ExcelFileName '.xlsx'], DataCell,'13.Step_stat.');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;


% leg alignment
  disp('  14.Body velocity stat.');
  % Body Velocity information
  Data = [time((BodyVelocity > 0)); BodyVelocity(BodyVelocity > 0)/1000];
  DataCell = num2cell(Data');
  DataCell(2:end+1,1:end) = DataCell;
  DataCell(1,1:2) = {'t [s]' 'v [mm/s]'};
  DataCell(end+2,1:2) = {'Average' num2str(mean(BodyVelocity(BodyVelocity > 0)/1000))};
  DataCell(end+3,1:2) = {'STD' num2str(std(BodyVelocity(BodyVelocity > 0)/1000))};
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> activex

sheet = get(sheets, 'Item', 14);
invoke(sheet, 'Activate');
% rename sheet
exl.Activesheet.Name = '14.Body velocity stat.';
% write data
Range = strcat('A1:B',num2str(size(DataCell,1)));
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', DataCell);  

% xlswrite([foldername ExcelFileName '.xlsx'], DataCell,'14.Body velocity stat.');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;

% Leg alignment info
  disp('  15.Leg_alignment');  
  Data = [LeftLegSTD; LFLMParaDist; LFLHParaDist; RightLegSTD; RFRMParaDist; RFRHParaDist];
  DataCell = num2cell(Data');
  DataCell(2:end+1,2:end+1) = DataCell;
  DataCell(1,1:end) = {' '};
  DataCell(1:end,1) = {' '};
  DataCell(1,1:7) = {' ' 'Left STD' 'LF-LM' 'LF-LH' 'Right STD' 'RF-RM' 'RF-RH'};
  DataCell(end+2,1:7) = {'Average' num2str(mean(LeftLegSTD(LeftLegSTD ~= -1))) num2str(mean(LFLMParaDist(LFLMParaDist ~= -1))) num2str(mean(LFLHParaDist(LFLHParaDist ~= -1))) num2str(mean(RightLegSTD(RightLegSTD ~= -1))) num2str(mean(RFRMParaDist(RFRMParaDist ~= -1))) num2str(mean(RFRHParaDist(RFRHParaDist ~= -1)))};
  %DataCell(end+2,1:7) = {'|Average|' num2str(mean(abs(LeftLegSTD(LeftLegSTD ~= -1)))) num2str(mean(abs(LFLMParaDist(LFLMParaDist ~= -1)))) num2str(mean(abs(LFLHParaDist(LFLHParaDist ~= -1)))) num2str(mean(abs(RightLegSTD(RightLegSTD ~= -1)))) num2str(mean(abs(RFRMParaDist(RFRMParaDist ~= -1)))) num2str(mean(abs(RFRHParaDist(RFRHParaDist ~= -1))))};

  % make all the values that are smaller or equal to zero ' '
  S = size(DataCell);
  for i = 1:S(1)
      for j = 1:S(2)
          if cell2mat(DataCell(i,j)) <= 0
              DataCell(i,j) = {' '};
          end;
      end
  end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> activex

sheet = get(sheets, 'Item', 15);
invoke(sheet, 'Activate');
% rename sheet
exl.Activesheet.Name = '15.Leg_alignment';
% write data
Range = strcat('A1:G',num2str(size(DataCell,1)));
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', DataCell);   
  
% xlswrite([foldername ExcelFileName '.xlsx'], DataCell,'15.Leg_alignment');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;



% 16 - AEP_PP
  disp('  16.AEP_PEP');
  clear DataCell;
  DataCell(1,:) = {'LF AEP(x)'	'LF AEP(y)'	'RF AEP(x)'	'RF AEP(y)' 'LM AEP(x)' 'LM AEP(y)' 'RM AEP(x)' 'RM AEP(y)' 'LH AEP(x)' 'LH AEP(y)' 'RH AEP(x)' 'RH AEP(y)' 'LF PEP(x)' 'LF PEP(y)' 'RF PEP(x)' 'RF PEP(y)' 'LM PEP(x)' 'LM PEP(y)' 'RM PEP(x)' 'RM PEP(y)' 'LH PEP(x)' 'LH PEP(y)' 'RH PEP(x)' 'RH PEP(y)'};
  DataNum = zeros(max(counter),24);


      for j = 1:6 % loop over legs
          if j == 1 % LF
              DataNum(1:counter(j),1)  = PerpDist(j,StartStep(j,1:counter(j))) / BodyLength;
              DataNum(1:counter(j),2)  = ParaDist(j,StartStep(j,1:counter(j))) / BodyLength;
              DataNum(1:counter(j),13) = PerpDist(j, StopStep(j,1:counter(j))) / BodyLength;
              DataNum(1:counter(j),14) = ParaDist(j, StopStep(j,1:counter(j))) / BodyLength;
          end;
          if j == 4 % RF
              DataNum(1:counter(j),3)  = PerpDist(j,StartStep(j,1:counter(j))) / BodyLength;
              DataNum(1:counter(j),4)  = ParaDist(j,StartStep(j,1:counter(j))) / BodyLength;
              DataNum(1:counter(j),15) = PerpDist(j, StopStep(j,1:counter(j))) / BodyLength;
              DataNum(1:counter(j),16) = ParaDist(j, StopStep(j,1:counter(j))) / BodyLength;
          end;
          if j == 2 % LM
              DataNum(1:counter(j),5)  = PerpDist(j,StartStep(j,1:counter(j))) / BodyLength;
              DataNum(1:counter(j),6)  = ParaDist(j,StartStep(j,1:counter(j))) / BodyLength;
              DataNum(1:counter(j),17) = PerpDist(j, StopStep(j,1:counter(j))) / BodyLength;
              DataNum(1:counter(j),18) = ParaDist(j, StopStep(j,1:counter(j))) / BodyLength;
          end;
          if j == 5 % RM
              DataNum(1:counter(j),7)  = PerpDist(j,StartStep(j,1:counter(j))) / BodyLength;
              DataNum(1:counter(j),8)  = ParaDist(j,StartStep(j,1:counter(j))) / BodyLength;
              DataNum(1:counter(j),19) = PerpDist(j, StopStep(j,1:counter(j))) / BodyLength;
              DataNum(1:counter(j),20) = ParaDist(j, StopStep(j,1:counter(j))) / BodyLength;
          end;
          if j == 3 % LH
              DataNum(1:counter(j),9)  = PerpDist(j,StartStep(j,1:counter(j))) / BodyLength;
              DataNum(1:counter(j),10) = ParaDist(j,StartStep(j,1:counter(j))) / BodyLength;
              DataNum(1:counter(j),21) = PerpDist(j, StopStep(j,1:counter(j))) / BodyLength;
              DataNum(1:counter(j),22) = ParaDist(j, StopStep(j,1:counter(j))) / BodyLength;
          end;
          if j == 6 % RH
              DataNum(1:counter(j),11) = PerpDist(j,StartStep(j,1:counter(j))) / BodyLength;
              DataNum(1:counter(j),12) = ParaDist(j,StartStep(j,1:counter(j))) / BodyLength;
              DataNum(1:counter(j),23) = PerpDist(j, StopStep(j,1:counter(j))) / BodyLength;
              DataNum(1:counter(j),24) = ParaDist(j, StopStep(j,1:counter(j))) / BodyLength;
          end;

      end;
  DataCell(2:size(DataNum,1)+1,:) = num2cell(DataNum);    

  % make all the values that are smaller or equal to zero ' '
  S = size(DataCell);
  for i = 1:S(1)
      for j = 1:S(2)
          if cell2mat(DataCell(i,j)) == 0
              DataCell(i,j) = {' '};
          end;
      end
  end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> activex

sheet = get(sheets, 'Item', 16);
invoke(sheet, 'Activate');
% rename sheet
exl.Activesheet.Name = '16.AEP_PEP';
% write data
Range = strcat('A1:X',num2str(size(DataCell,1)));
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', DataCell);   
  
% xlswrite([foldername ExcelFileName '.xlsx'], DataCell,'16.AEP_PEP');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;


% Output TimeBetweenTripods in separate sheet
  disp('  17.Tripod');
  clear DataCell;
  DataCell(1,:) = {'Tripod start'	'Tripod end'	'Tripod duration'	'Inter-tripod duration'};
  DataNum = zeros(length(TripodStart),4);

  DataNum(2:length(TripodStart)+1,1)        = TripodStart;
  DataNum(2:length(TripodStop)+1,2)         = TripodStop;
  DataNum(2:length(TripodDuration)+1,3)     = TripodDuration;
  DataNum(2:length(TimeBetweenTripods)+1,4) = TimeBetweenTripods;

  DataCell(2:size(DataNum,1)+1,:) = num2cell(DataNum); 
  
  % make all the values that are smaller or equal to zero ' '
  S = size(DataCell);
  for i = 1:S(1)
      for j = 1:S(2)
          if cell2mat(DataCell(i,j)) == 0
              DataCell(i,j) = {' '};
          end;
      end
  end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> activex

sheet = get(sheets, 'Item', 17);
invoke(sheet, 'Activate');
% rename sheet
exl.Activesheet.Name = '17.Tripod';
% write data
Range = strcat('A1:D',num2str(size(DataCell,1)));
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', DataCell);   
  
% xlswrite([foldername ExcelFileName '.xlsx'], DataCell,'17.Tripod');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;

% Added by Clare Howard 02_13_17
% ceh2172@columbia.edu
% This defines a parameter called "stance straightness index", which is a ratio
% of the displacement that occurs over a particular stance trace and the
% "path length" of that stance trace from frame to frame

  disp('  18.Stance Straightness Index');

%calculate the displacement (in um???) from the start to the end of a stance trace
    for i=1:6 % loop over each of the 6 legs
        for j = 1:(counter(i)) %loop over each step for each leg
            startframe = StartStep(i,j); %find the first frame of a step
            stopframe = StopStep(i,j); %find the last frame of the step
            parastart = ParaDist(i,startframe); %take the parallel distance from the body at the start
            parastop = ParaDist(i,stopframe); %parallel distance from the body at the end
            perpstart = PerpDist(i,startframe); %perpendicular distance from the body at the start
            perpstop = PerpDist(i,stopframe); %perpendicular distance from the center at the end
            xDisp = abs(parastop-parastart); %X displacement is the difference in the parallel distances
            yDisp = abs(perpstop-perpstart); %Y displacement is the difference in the perpendicular distances
            Displacement(i,j) = sqrt(xDisp^2 + yDisp^2); %The "stance displacement" is the distance between these two points
        end;
    end;
    
%caculate the path length for each stance trace, the sum of the
%displacement over each frame of the stance
    %loop over legs
    for i=1:6
        %loop over steps
        for j = 1:(counter(i))
            startframe = StartStep(i,j);
            stopframe = StopStep(i,j);
            pathlength(i,j)=0;
            %loop over frames of each step
            for k = startframe:stopframe-1
                parastart = ParaDist(i,k); %paralell distance at frame 1
                parastop = ParaDist(i,k+1); %paralell distance at frame 2
                perpstart = PerpDist(i,k); %perpendicular distance at frame 1
                perpstop = PerpDist(i,k+1); %perpendicular distance at frame 2
                xDisp = abs(parastop-parastart); %x displacement
                yDisp = abs(perpstop-perpstart); %y displacement
                Displacementpartial = sqrt(xDisp^2 + yDisp^2); %displacement from frame 1 to 2
                pathlength(i,j) = pathlength(i,j)+Displacementpartial; %add that displacement to the path
            end;
        end;
    end;
    
%new stance linearity is the ratio of stance displacement to pathlength
    %loop over legs
    for i=1:6
        %loop over steps
        for j = 1:(counter(i))
            StanceStraightness(i,j)=Displacement(i,j)/pathlength(i,j);
        end;
    end;
%replace all 0 values (which come up because some legs have more steps
%than others, with NaN so they will not be included in calculation of
%the mean values
    %StanceStraightness(find(~StanceStraightness))=NaN;
    
%Calculate the average for each leg individual, pairs of F, M, H and overall
    AvgStStrLF = nanmean(StanceStraightness(1,:),2);
    AvgStStrLM = nanmean(StanceStraightness(2,:),2);
    AvgStStrLH = nanmean(StanceStraightness(3,:),2);
    AvgStStrRF = nanmean(StanceStraightness(4,:),2);
    AvgStStrRM = nanmean(StanceStraightness(5,:),2);
    AvgStStrRH = nanmean(StanceStraightness(6,:),2);
    AvgStStrF = nanmean([AvgStStrLF AvgStStrRF],2);
    AvgStStrM = nanmean([AvgStStrLM AvgStStrRM],2);
    AvgStStrH = nanmean([AvgStStrLH AvgStStrRH],2);
    AvgStStrAll = nanmean([AvgStStrF AvgStStrM AvgStStrH],2);

    %Calculate the averages of displacement and path length
    
    AvgDispLF = nanmean(Displacement(1,:),2);
    AvgDispLM = nanmean(Displacement(2,:),2);
    AvgDispLH = nanmean(Displacement(3,:),2);
    AvgDispRF = nanmean(Displacement(4,:),2);
    AvgDispRM = nanmean(Displacement(5,:),2);
    AvgDispRH = nanmean(Displacement(6,:),2);
    AvgDispF = nanmean([AvgDispLF AvgDispRF],2);
    AvgDispM = nanmean([AvgDispLM AvgDispRM],2);
    AvgDispH = nanmean([AvgDispLH AvgDispRH],2);
    AvgDispAll = nanmean([AvgDispF AvgDispM AvgDispH],2);
    
    AvgPathLF = nanmean(pathlength(1,:),2);
    AvgPathLM = nanmean(pathlength(2,:),2);
    AvgPathLH = nanmean(pathlength(3,:),2);
    AvgPathRF = nanmean(pathlength(4,:),2);
    AvgPathRM = nanmean(pathlength(5,:),2);
    AvgPathRH = nanmean(pathlength(6,:),2);
    AvgPathF = nanmean([AvgPathLF AvgPathRF],2);
    AvgPathM = nanmean([AvgPathLM AvgPathRM],2);
    AvgPathH = nanmean([AvgPathLH AvgPathRH],2);
    AvgPathAll = nanmean([AvgPathF AvgPathM AvgPathH],2);
    
    %Write these values into their own sheet in the excel data
    
    Data = num2cell(StanceStraightness)';
    Data(2:end+1,3:3:end+12) = Data;
    Data(2:end,1:3:end) = num2cell(Displacement)';
    Data(2:end,2:3:end) = num2cell(pathlength)';
    
    
     % add header
    Data(1,1:3:end) = {'Displacement LF (um)' 'Displacement LM' 'Displacement LH' 'Displacement RF' 'Displacement RM' 'Displacement RH'};
    Data(1,2:3:end) = {'Path Length LF (um)' 'Path Length LM' 'Path Length LH' 'Path Length RF' 'Path Length RM' 'Path Length RH'};
    Data(1,3:3:end) = {'Straightness LF' 'Straightness LM' 'Straightness LH' 'Straightness RF' 'Straightness RM' 'Straightness RH'};
    
    % add average values for each leg
    Data(end+2,:) = {'Avg Disp LF' 'Avg Path LF' 'Avg Straightness LF' 'Avg Disp LM' 'Avg Path LM' 'Avg Straightness LM' 'Avg Disp LH' 'Avg Path LH' 'Avg Straightness LH' 'Avg Disp RF' 'Avg Path RF' 'Avg Straightness RF' 'Avg Disp RM' 'Avg Path RM' 'Avg Straightness RM' 'Avg Disp RH' 'Avg Path RH' 'Avg Straightness RH'};
    Data(end+1,:) = {AvgDispLF AvgPathLF AvgStStrLF AvgDispLM AvgPathLM AvgStStrLM AvgDispLH AvgPathLH AvgStStrLH AvgDispRF AvgPathRF AvgStStrRF AvgDispRM AvgPathRM AvgStStrRM AvgDispRH AvgPathRH AvgStStrRH};
    
    %add average values for each leg
    Data(end+2,1:9) = {'Avg Disp F' 'Avg Path F' 'Avg Straightness F' 'Avg Disp M' 'Avg Path M' 'Avg Straightness M' 'Avg Disp H' 'Avg Path H' 'Avg Straightness H'};
    Data(end+1,1:9) = {AvgDispF AvgPathF AvgStStrF AvgDispM AvgPathM AvgStStrM AvgDispH AvgPathH AvgStStrH};
    
    %add overal averages
    Data(end+2, 1:3) = {'Overall Avg Disp' 'Overall Avg Path' 'Overall Avg Straightness'};
    Data(end+1, 1:3) = {AvgDispAll AvgPathAll AvgStStrAll};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> activex

sheet = get(sheets, 'Item', 18);
invoke(sheet, 'Activate');
% rename sheet
exl.Activesheet.Name = '18.Stance_Straightness_Index';
% write data
Range = strcat('A1:R',num2str(size(Data,1)));
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', Data);   

% %write out to excel
% xlswrite([foldername ExcelFileName '.xlsx'], Data,'18.Stance_Straightness_Index');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check for ABORT
  if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre
% Displacement ratio: this parameter serves as a measure of the overall 
% straightness of the fly's path. It is defined as the ratio between the 
% total (cumulative) distance travelled and the distance between 
% the starting and finishing positions.

disp ('  19. Body track straightness')

% % if the  body determination is front based, use values stored in TCx/TCy
% if p.CenterFromFront == 1 && isfield(handles.v, 'TC_x') && isfield(handles.v, 'TC_y')
    
% number of valid elements in TCx, TCy (excluding negative values and extra
% 0's)
nbCoord = find(TCx>0,1,'last');
% nbCoord = size(TCx(TCx>0),2);
% nbCoordy = size(TCy(TCy>=0),2);

% compute the distance between the starting and finishing positions
% (exclude negative values and extra 0's)
index_x = find(TCx>0,1,'first');
index_y = find(TCy>0,1,'first');
lin_dist = sqrt((TCx(nbCoord)-TCx(index_x))^2+(TCy(nbCoord)-TCy(index_y))^2);

% compute the total distance
dist_vector = zeros(1,nbCoord);

% initialize q as the first non zero index (which corresponds to either
% index_x or index_y)
q=index_x;
while q<nbCoord
    dist_vector(q) = sqrt((TCx(q+1)-TCx(q))^2+(TCy(q+1)-TCy(q))^2);
    q=q+1;
end

% ignore the last row when computing the total distance, to compensante for
% auto-tracking's uncertainity in the last frame (the fly's position
% "jumps" to the upper left corner)
total_dist = sum(dist_vector(1:end-1));

% compute the ratio
DispRatio = lin_dist/total_dist;

% write values to new Excel sheet
Data_cell = num2cell(dist_vector)';
Data_cell(2:end+1,1) = Data_cell;
Data_cell(2,end+2) = num2cell(lin_dist);
Data_cell(5,end) = num2cell(total_dist);
Data_cell(8,end) = num2cell(DispRatio);

Data_cell(1,1) = {'Distance vector (um)'};
Data_cell(1,3) = {'Body displacement (um)'};
Data_cell(4,3) = {'Total body path (um)'};
Data_cell(7,3) = {'Body displacement ratio'};

% plot trajectory and shortest path
% traj = figure('visible', 'off','Position',[100 100 1200 300]);
traj = figure('visible', 'off');
hold on
plot(TCx(TCx>=0),TCy(TCy>=0),'-r')
plot([TCx(nbCoord),TCx(index_x)],[TCy(nbCoord),TCy(index_y)],'--k')
hold off

% save to folder as .png
% xlim([0 20000])
% ylim([1500 3400])
set(gca, 'YDir', 'reverse')
axis equal
Title = 'Body Track Straightness';
title(Title)
xlabel('x [um]')
ylabel('y [um]')
legend('Path','Displacement','Location', 'Northwest')
hold off;
ind = find(filename == '\' | filename == '/');
outputfilename = sprintf('%strajectory_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
saveas(traj,outputfilename,'png');
close(traj);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> activex

sheet = get(sheets, 'Item', 19);
invoke(sheet, 'Activate');
% rename sheet
exl.Activesheet.Name = '19.Body_Track_Straightness';
% write data
Range = strcat('A1:C',num2str(size(Data_cell,1)));
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', Data_cell); 

% write out to excel
% xlswrite([foldername ExcelFileName '.xlsx'], Data_cell,'19.Displacement_ratio');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check for ABORT
if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre
% One last sheet containing data regarding the plotted triangles: polygon
% area, stability_ratio and whether or not the centroid is located on the
% outside of the plotted polygon (i.e., check if the fly is stable or not)

disp ('  20. Triangles')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> activex

sheet = get(sheets, 'Item', 20);
invoke(sheet, 'Activate');
% rename sheet
exl.Activesheet.Name = '20.Triangles';
% write data
Range = strcat('A1:G',num2str(size(tri_table,1)));
ActivesheetRange = get(sheet,'Range',Range);
triangles_header = {'Frame' 'State' 'Points of contact' 'Centroid to edge distance (BodyUnits)' 'COM to edge distance (BodyUnits)' 'Stability ratio' 'Polygon area (BodyUnits^2)'};


% write out to excel
% writetable(tri_table,[foldername ExcelFileName '.xlsx'],'Sheet', '20.Triangles');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% change text color to match the plotted polygons, using activex

% initialize maximum, minimum stability ratio and counters (to determine
% whether the fly was more stable or unstable over the analysis)
% max_ratio = -inf;
% max_frame = 0;
% min_ratio = inf;
% min_frame = 0;
stab_counter = 0;
% avg_counter = 0;

% POST PROCESSING AND COLORING

% Get starting and ending indexes
starting_frames = [];
ending_frames = [];
for i=1:length(indexes)
    if indexes(i)~=0
        % first frame of the sequence
        if i==1 || sum(color_vector(i-1,:) == color_vector(i,:)) ~= 3
            starting_frames = [starting_frames i];
        end
        % last frame of the sequence
        if i==length(indexes) || sum(color_vector(i+1,:) == color_vector(i,:)) ~= 3
            ending_frames = [ending_frames i];
        end
    end
end

% Check which sequences have less than 3 frames; update the indexes vector;
% delete plotted triangles
onset_sum = 0;
offset_sum = 0;
on_off_counter = 0;
three_point_sum = 0;
three_point_counter = 0;
four_point_sum = 0;
four_point_counter = 0;
for i=1:length(starting_frames)
    if (ending_frames(i)-starting_frames(i)) < 2
        % update indexes vector
        indexes(starting_frames(i):ending_frames(i)) = 0;
        % delete plotted triangles, leg text, red crosses and blue circles;
        % overwrite data with 'No data' (in tri_table)
        for j=starting_frames(i):ending_frames(i)
            % delete plotted polygon
            set(findobj('tag',strcat('polygon_',num2str(j))),'visible','off')
            % delete blue circle
            set(findobj('tag',strcat('blue_circle_',num2str(j))),'visible','off')
            % delete red cross
            set(findobj('tag',strcat('red_cross_',num2str(j))),'visible','off')
            % delete leg text
            for k=1:6
                if ~isempty(findobj('tag',strcat(strcat('leg_text_',num2str(j),num2str(k)))))
                    set(findobj('tag',strcat(strcat('leg_text_',num2str(j),num2str(k)))),'visible','off')
                end
            end
            % replace data with 'No data' (in tri_table)
            tri_table.State(j) = {'No data'};
            tri_table.Center_to_edge_dist(j) = {'No data'};
            tri_table.Centroid_to_edge_dist(j) = {'No data'};
            tri_table.Stability_ratio(j) = {'No data'};
            tri_table.Polygon_area(j) = {'No data'};
            tri_table.Points_of_contact(j) = {'No data'};
        end
    else
        % save info for onset and offset ratios and average areas
        onset_sum = onset_sum + real(cell2mat(tri_table.Stability_ratio(starting_frames(i))));
        offset_sum = offset_sum + real(cell2mat(tri_table.Stability_ratio(ending_frames(i))));
        on_off_counter = on_off_counter + 1;
        if cell2mat(tri_table.Points_of_contact(starting_frames(i))) == 3
            three_point_sum = three_point_sum + sum(cell2mat(tri_table.Polygon_area(starting_frames(i):ending_frames(i))));
            three_point_counter = three_point_counter + (ending_frames(i)-starting_frames(i)+1);
        elseif cell2mat(tri_table.Points_of_contact(starting_frames(i))) == 4
            four_point_sum = four_point_sum + sum(cell2mat(tri_table.Polygon_area(starting_frames(i):ending_frames(i))));
            four_point_counter = four_point_counter + (ending_frames(i)-starting_frames(i)+1);
%         else
%             disp('You know nothing, Alexandre (line 3378)')
        end
    end
end

for z=1:length(indexes)
    
    if indexes(z)~=0
        
            % count "Stable"
            if isequal(tri_table.State(z),{'Stable'}) == 1
                stab_counter = stab_counter+1;
            end
        
            % set color
            range = strcat(strcat(strcat('A',num2str(z+1)),':'),strcat('G',num2str(z+1)));
            if color_vector(z,:)==RGB(1,:)
                sheet.Range(range).Font.ColorIndex = 3;
            elseif color_vector(z,:)==RGB(2,:)
                sheet.Range(range).Font.ColorIndex = 45;
            elseif color_vector(z,:)==RGB(3,:)
                sheet.Range(range).Font.ColorIndex = 4;
            elseif color_vector(z,:)==RGB(4,:)
                sheet.Range(range).Font.ColorIndex = 8;
            elseif color_vector(z,:)==RGB(5,:)
                sheet.Range(range).Font.ColorIndex = 5;
            elseif color_vector(z,:)==RGB(6,:)
                sheet.Range(range).Font.ColorIndex = 1;
            end
            
    end
end

% Saving the processed triangles plot
ind = find(filename == '\' | filename == '/');
outputfilename = sprintf('%striangles_%s.png', foldername, filename(ind(end-2)+1:ind(end-1)-1));
saveas(triang_figure,outputfilename,'png');
close(triang_figure);

% Info strings
set(ActivesheetRange, 'Value', [triangles_header;table2cell(tri_table)]); 

Stable_frames = 'Nb. of stable frames:';

Stable_frames_nb = num2str(stab_counter);

Total_frames =  'Nb. of analysed frames:';

total_frames_nb = num2str(sum(indexes));

% infoString2 = strcat(strcat(sprintf('%s %s','The fly was the most stable at frame',num2str(min_frame)),sprintf('%s %s','','with a stability ratio of')),sprintf('%s %s','',num2str(min_ratio)));
% 
% infoString3 = strcat(strcat(sprintf('%s %s','The fly was the least stable at frame',num2str(max_frame)),sprintf('%s %s','','with a stability ratio of')),sprintf('%s %s','',num2str(max_ratio)));
% 
% infoString4 = sprintf('%s %s','The average stability ratio was ',num2str(avg_counter/sum(indexes)));

% write infoStrings to excel
Range1 = 'N1:Q1';
sheet.Range(Range1).MergeCells = 1;
sheet.Range(Range1).Value = Stable_frames;

Range2 = 'R1';
sheet.Range(Range2).Value = Stable_frames_nb;

Range3 = 'N3:Q3';
sheet.Range(Range3).MergeCells = 1;
sheet.Range(Range3).Value = Total_frames;

Range4 = 'R3';
sheet.Range(Range4).Value = total_frames_nb;

sheet.Range('N5:Q5').MergeCells = 1;
sheet.Range('N5:Q5').Value = 'Stability index:';
sheet.Range('R5').Value = num2str(stab_counter/sum(indexes));

sheet.Range('N8:Q8').MergeCells = 1;
sheet.Range('N8:Q8').Value = 'Average onset ratio:';
avg_onset = onset_sum/on_off_counter;
sheet.Range('R8').Value = num2str(avg_onset);

sheet.Range('N10:Q10').MergeCells = 1;
sheet.Range('N10:Q10').Value = 'Average offset ratio:';
avg_offset = offset_sum/on_off_counter;
sheet.Range('R10').Value = num2str(avg_offset);

sheet.Range('N12:Q12').MergeCells = 1;
sheet.Range('N12:Q12').Value = 'Average stability ratio:';
sheet.Range('R12').Value = num2str((avg_onset+avg_offset)/2);

sheet.Range('N15:Q15').MergeCells = 1;
sheet.Range('N15:Q15').Value = 'Average area of all 3-point contacts:';
sheet.Range('R15').Value = num2str(three_point_sum/three_point_counter);

sheet.Range('N17:Q17').MergeCells = 1;
sheet.Range('N17:Q17').Value = 'Average area of all 4-point contacts:';
sheet.Range('R17').Value = num2str(four_point_sum/four_point_counter);

sheet.Range('N19:Q19').MergeCells = 1;
sheet.Range('N19:Q19').Value = 'Average area of all configurations:';
sheet.Range('R19').Value = num2str((three_point_sum+four_point_sum)/(three_point_counter+four_point_counter));

sheet.Range('H1').Value = {'1'};
sheet.Range('H1').Font.ColorIndex = 2;

% check for ABORT
if isfield(handles,'evaluate_togglebutton') & get(handles.evaluate_togglebutton,'Value') == 0; return; end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% OTHER
  disp('  OTHERS');
  %on sheet 1 Info sheet:
 %Cesar did this 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> activex
sheet = get(sheets, 'Item', 1);
invoke(sheet, 'Activate');

Range = 'A40:EB40';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'label','speed','trip index','tetrapod index','trip/tetra','freq','period','avr FP STD','avr perp M','sw v(AVR)','sw v(SD)','sw v(F)','sw v(M)','sw v(H)','sw s(AVR)','sw s(SD)','sw s(F)','sw s(M)','sw s(H)','sw t(AVR)','sw t(SD)','sw t(F)','sw t(M)','sw t(H)','period SD','stc t(F)','stc t(M)','stc t(H)','stc t(AVR)','stc t(SD)','varAEP_F','varAEP_M','varAEP_H','varPEP_F','varPEP_M','varPEP_H','stnc stabl','SD AEP','SD PEP','body size','F AEP','M AEP','H AEP','F PEP','M PEP','H PEP','F AEPy','M AEPy','H AEPy','F PEPy','M PEPy','H PEPy','F AEPySD','M AEPySD','H AEPySD','F PEPySD','M PEPySD','H PEPySD','F AEPx','M AEPx','H AEPx','F PEPx','M PEPx','H PEPx','F AEPxSD','M AEPxSD','H AEPxSD','F PEPxSD','M PEPxSD','H PEPxSD','PeriodSD1000','Speed SD','6feetON','framesON','body stbl','2+ pfON','F_AEP STD','M_AEP_AEP STD','H_AEP STD','F_PEP STD','M_PEP STD','H_PEP STD','(empty)','SwingV STD','F_deltaEP','M_deltaEP','H_deltaEP','non-can.','AVRcombTrace','STDcombTrace','AVR perpM','Max Mdist','swT+stT','duty Fact','Phase F','Phase M','Phase H','Phase LH vs LM','Phase LM vs LF','Phase RH vs RM','Phase RM vs RF','wave indexBODA','tTripod','tTransition','Stc Str F','Stc Str M','Stc Str H','Overall Stc Str','Overall Avg Disp','Overall Avg Path','Body displacement (um)', 'Total body path (um)', 'Body displacement ratio', 'Stability index', 'Average onset ratio', 'Average offset ratio', 'Average stability ratio', 'Average area of all 3-point contacts', 'Average area of all 4-point contacts', 'Average area of all configurations', ...
    'Stc trace cluster LF', ...
    'Stc trace cluster LM', ...
    'Stc trace cluster LH', ...
    'Stc trace cluster RF', ...
    'Stc trace cluster RM', ...
    'Stc trace cluster RH', ...
    'Stc trace cluster mean front', ...
    'Stc trace cluster mean hind', ...
    'Stc trace cluster mean', ...    
    'Non Compliance Index'...
    'Calibration(pixel/um)'...
    'Body size um'}); 
% xlswrite([foldername ExcelFileName '.xlsx'], {'label','speed','trip index','tetrapod index','trip/tetra','freq','period','avr FP STD','avr perp M','sw v(AVR)','sw v(SD)','sw v(F)','sw v(M)','sw v(H)','sw s(AVR)','sw s(SD)','sw s(F)','sw s(M)','sw s(H)','sw t(AVR)','sw t(SD)','sw t(F)','sw t(M)','sw t(H)','period SD','stc t(F)','stc t(M)','stc t(H)','stc t(AVR)','stc t(SD)','varAEP_F','varAEP_M','varAEP_H','varPEP_F','varPEP_M','varPEP_H','stnc stabl','SD AEP','SD PEP','body size','F AEP','M AEP','H AEP','F PEP','M PEP','H PEP','F AEPy','M AEPy','H AEPy','F PEPy','M PEPy','H PEPy','F AEPySD','M AEPySD','H AEPySD','F PEPySD','M PEPySD','H PEPySD','F AEPx','M AEPx','H AEPx','F PEPx','M PEPx','H PEPx','F AEPxSD','M AEPxSD','H AEPxSD','F PEPxSD','M PEPxSD','H PEPxSD','PeriodSD1000','Speed SD','6feetON','framesON','body stbl','2+ pfON','F_AEP STD','M_AEP_AEP STD','H_AEP STD','F_PEP STD','M_PEP STD','H_PEP STD','(empty)','SwingV STD','F_deltaEP','M_deltaEP','H_deltaEP','non-can.','AVRcombTrace','STDcombTrace','AVR perpM','Max Mdist','swT+stT','duty Fact','Phase F','Phase M','Phase H','Phase LH vs LM','Phase LM vs LF','Phase RH vs RM','Phase RM vs RF','wave indexBODA','tTripod','tTransition','Stc Str F','Stc Str M','Stc Str H','Overall Stc Str','Overall Avg Disp','Overall Avg Path'},'1.Info_Sheet', 'A40');

%%%Added by Inês
%auxialiary declaration of variables

distance_cal=p.distcal; %pixel/um
fixed_body_size=p.fixed_body_length_value*p.fixed_body_length; %pixel
body_size_um=fixed_body_size/distance_cal; %um

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 14-08-2021 - Ines -> new new parameters

Range = 'DQ41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', { stc_traces_cluster(1) });

Range = 'DR41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', { stc_traces_cluster(2) });

Range = 'DS41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', { stc_traces_cluster(3) });

Range = 'DT41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', { stc_traces_cluster(4) });

Range = 'DU41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', { stc_traces_cluster(5) });

Range = 'DV41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', { stc_traces_cluster(6) });

Range = 'DW41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', { stc_trace_cluster_mean_front });

Range = 'DX41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', { stc_trace_cluster_mean_hind });

Range = 'DY41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', { stc_trace_cluster_mean_all });

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Alexandre -> new parameters

Range = 'DG41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=''19.Body_Track_Straightness''!C2'});

Range = 'DH41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=''19.Body_Track_Straightness''!C5'});

Range = 'DI41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=''19.Body_Track_Straightness''!C8'});

Range = 'DJ41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=''20.Triangles''!R5'});

Range = 'DK41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=''20.Triangles''!R8'});

Range = 'DL41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=''20.Triangles''!R10'});

Range = 'DM41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=''20.Triangles''!R12'});

Range = 'DN41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=''20.Triangles''!R15'});

Range = 'DO41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=''20.Triangles''!R17'});

Range = 'DP41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=''20.Triangles''!R19'});

%Xana new parameter: Non compliance index
Range = 'DZ41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange,'Value',{'=''10.Leg_combinations''!B90'});

Range = 'EA41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange,'Value',{distance_cal});

Range = 'EB41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange,'Value',{body_size_um});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Range = 'A41';
ActivesheetRange = get(sheet,'Range',Range)
set(ActivesheetRange, 'Value', {'=MID(CELL("filename"),SEARCH("[",CELL("filename"))+1, SEARCH("]",CELL("filename"))-SEARCH("[",CELL("filename"))-1)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=MID(CELL("filename"),SEARCH("[",CELL("filename"))+1, SEARCH("]",CELL("filename"))-SEARCH("[",CELL("filename"))-1)'},'1.Info_Sheet', 'A41');

Range = 'B41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=SUMIF(''14.Body velocity stat.''!A:A,"Average",''14.Body velocity stat.''!B:B)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=SUMIF(''14.Body velocity stat.''!A:A,"Average",''14.Body velocity stat.''!B:B)'},'1.Info_Sheet', 'B41');

Range = 'C41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=''10.Leg_combinations''!B83'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=''10.Leg_combinations''!B83'},'1.Info_Sheet', 'C41');

Range = 'D41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=''10.Leg_combinations''!B84'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=''10.Leg_combinations''!B84'},'1.Info_Sheet', 'D41');

Range = 'L41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=''11.Pos. stat.''!D10'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=''11.Pos. stat.''!D10'},'1.Info_Sheet', 'L41');

Range = 'H41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=''15.Leg_alignment''!A13'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=''15.Leg_alignment''!A13'},'1.Info_Sheet', 'H41');

Range = 'I41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=''11.Pos. stat.''!B27'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=''11.Pos. stat.''!B27'},'1.Info_Sheet', 'I41');

Range = 'F41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=''13.Step_stat.''!A18'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=''13.Step_stat.''!A18'},'1.Info_Sheet', 'F41');

Range = 'G41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=''13.Step_stat.''!B21'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=''13.Step_stat.''!B21'},'1.Info_Sheet', 'G41');

% add the new stance linearity parameter information to the end of the data
% line
Range = 'DA41:DF41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {AvgStStrF AvgStStrM AvgStStrH AvgStStrAll AvgDispAll AvgPathAll });
% xlswrite([foldername ExcelFileName '.xlsx'], {AvgStStrF AvgStStrM AvgStStrH AvgStStrAll AvgDispAll AvgPathAll },'1.Info_Sheet', 'DA41');

Range = 'J41:CZ41';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=''13.Step_stat.''!D27','=''13.Step_stat.''!E27','=''13.Step_stat.''!A27','=''13.Step_stat.''!B27','=''13.Step_stat.''!C27','=''13.Step_stat.''!D31','=''13.Step_stat.''!E31','=''13.Step_stat.''!A31','=''13.Step_stat.''!B31','=''13.Step_stat.''!C31','=''13.Step_stat.''!D35','=''13.Step_stat.''!E35','=''13.Step_stat.''!A35','=''13.Step_stat.''!B35','=''13.Step_stat.''!C35','=''13.Step_stat.''!C21','=''13.Step_stat.''!A39','=''13.Step_stat.''!B39','=''13.Step_stat.''!C39','=''13.Step_stat.''!D39','=''13.Step_stat.''!E39','=''11.Pos. stat.''!B22','=''11.Pos. stat.''!D22','=''11.Pos. stat.''!F22','=''11.Pos. stat.''!B23','=''11.Pos. stat.''!D23','=''11.Pos. stat.''!F23','=''11.Pos. stat.''!H24','=''16.AEP_PEP''!B17','=''16.AEP_PEP''!B18','=''2.Parameters''!B8','=''16.AEP_PEP''!C17','=''16.AEP_PEP''!G17','=''16.AEP_PEP''!K17','=''16.AEP_PEP''!O17','=''16.AEP_PEP''!S17','=''16.AEP_PEP''!W17','=''16.AEP_PEP''!B21','=''16.AEP_PEP''!F21','=(''16.AEP_PEP''!J21)','=''16.AEP_PEP''!N21','=(''16.AEP_PEP''!R21)','=(''16.AEP_PEP''!V21)','=''16.AEP_PEP''!B22','=''16.AEP_PEP''!F22','=''16.AEP_PEP''!J22','=''16.AEP_PEP''!N22','=''16.AEP_PEP''!R22','=''16.AEP_PEP''!V22','=''16.AEP_PEP''!A21','=''16.AEP_PEP''!E21','=''16.AEP_PEP''!I21','=''16.AEP_PEP''!M21','=''16.AEP_PEP''!Q21','=''16.AEP_PEP''!U21','=''16.AEP_PEP''!A22','=''16.AEP_PEP''!E22','=''16.AEP_PEP''!I22','=''16.AEP_PEP''!M22','=''16.AEP_PEP''!Q22','=''16.AEP_PEP''!U22','=Y41*1000','=SUMIF(''14.Body velocity stat.''!A:A,"STD",''14.Body velocity stat.''!B:B)','=''10.Leg_combinations''!B81','=''2.Parameters''!B11','=''11.Pos. stat.''!B25','=''10.Leg_combinations''!B93','=''16.AEP_PEP''!B13','=''16.AEP_PEP''!F13','=''16.AEP_PEP''!J13','=''16.AEP_PEP''!N13','=''16.AEP_PEP''!R13','=''16.AEP_PEP''!V13','(nd)','=K41/1000','=CB41-BY41','=CC41-BZ41','=CD41-CA41','=1-C41-D41-CX41','=''10.Leg_combinations''!B96','=''10.Leg_combinations''!B97','=''11.Pos. stat.''!B27','=''11.Pos. stat.''!H3','=T41+AC41','=AC41/(AC41+T41)','=''13.Step_stat.''!A44','=''13.Step_stat.''!B44','=''13.Step_stat.''!C44','=''13.Step_stat.''!D44','=''13.Step_stat.''!E44','=''13.Step_stat.''!F44','=''13.Step_stat.''!G44','=''10.Leg_combinations''!B85','=''17.Tripod''!C23','=''17.Tripod''!E23'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=''13.Step_stat.''!D27','=''13.Step_stat.''!E27','=''13.Step_stat.''!A27','=''13.Step_stat.''!B27','=''13.Step_stat.''!C27','=''13.Step_stat.''!D31','=''13.Step_stat.''!E31','=''13.Step_stat.''!A31','=''13.Step_stat.''!B31','=''13.Step_stat.''!C31','=''13.Step_stat.''!D35','=''13.Step_stat.''!E35','=''13.Step_stat.''!A35','=''13.Step_stat.''!B35','=''13.Step_stat.''!C35','=''13.Step_stat.''!C21','=''13.Step_stat.''!A39','=''13.Step_stat.''!B39','=''13.Step_stat.''!C39','=''13.Step_stat.''!D39','=''13.Step_stat.''!E39','=''11.Pos. stat.''!B22','=''11.Pos. stat.''!D22','=''11.Pos. stat.''!F22','=''11.Pos. stat.''!B23','=''11.Pos. stat.''!D23','=''11.Pos. stat.''!F23','=''11.Pos. stat.''!H24','=''16.AEP_PEP''!B17','=''16.AEP_PEP''!B18','=''2.Parameters''!B8','=''16.AEP_PEP''!C17','=''16.AEP_PEP''!G17','=''16.AEP_PEP''!K17','=''16.AEP_PEP''!O17','=''16.AEP_PEP''!S17','=''16.AEP_PEP''!W17','=''16.AEP_PEP''!B21','=''16.AEP_PEP''!F21','=(''16.AEP_PEP''!J21)','=''16.AEP_PEP''!N21','=(''16.AEP_PEP''!R21)','=(''16.AEP_PEP''!V21)','=''16.AEP_PEP''!B22','=''16.AEP_PEP''!F22','=''16.AEP_PEP''!J22','=''16.AEP_PEP''!N22','=''16.AEP_PEP''!R22','=''16.AEP_PEP''!V22','=''16.AEP_PEP''!A21','=''16.AEP_PEP''!E21','=''16.AEP_PEP''!I21','=''16.AEP_PEP''!M21','=''16.AEP_PEP''!Q21','=''16.AEP_PEP''!U21','=''16.AEP_PEP''!A22','=''16.AEP_PEP''!E22','=''16.AEP_PEP''!I22','=''16.AEP_PEP''!M22','=''16.AEP_PEP''!Q22','=''16.AEP_PEP''!U22','=Y41*1000','=SUMIF(''14.Body velocity stat.''!A:A,"STD",''14.Body velocity stat.''!B:B)','=''10.Leg_combinations''!B81','=''2.Parameters''!B11','=''11.Pos. stat.''!B25','=''10.Leg_combinations''!B93','=''16.AEP_PEP''!B13','=''16.AEP_PEP''!F13','=''16.AEP_PEP''!J13','=''16.AEP_PEP''!N13','=''16.AEP_PEP''!R13','=''16.AEP_PEP''!V13','(nd)','=K41/1000','=CB41-BY41','=CC41-BZ41','=CD41-CA41','=1-C41-D41-CX41','=''10.Leg_combinations''!B96','=''10.Leg_combinations''!B97','=''11.Pos. stat.''!B27','=''11.Pos. stat.''!H3','=T41+AC41','=AC41/(AC41+T41)','=''13.Step_stat.''!A44','=''13.Step_stat.''!B44','=''13.Step_stat.''!C44','=''13.Step_stat.''!D44','=''13.Step_stat.''!E44','=''13.Step_stat.''!F44','=''13.Step_stat.''!G44','=''10.Leg_combinations''!B85','=''17.Tripod''!C23','=''17.Tripod''!E23'},'1.Info_Sheet', 'J41');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sheet = get(sheets, 'Item', 13);
invoke(sheet, 'Activate');

%on sheet 13. Step stat:
%xlswrite([foldername ExcelFileName '.xlsx'], {'average swing distance'},'13.Step_stat.', 'A14');
%xlswrite([foldername ExcelFileName '.xlsx'], {'=AVERAGE(F2:F5,L2:L5,R2:R5,X2:X5,AD2:AD5,AJ2:AJ5)'},'13.Step_stat.', 'A15');

Range = 'A17';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'Hz, average frequency'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'Hz, average frequency'},'13.Step_stat.', 'A17');

%xlswrite([foldername ExcelFileName '.xlsx'], {'Step Cycles'},'13.Step_stat.', 'A9');

Range = 'A20';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'average step Cycle/ in miliseconds/ SD'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'average step Cycle/ in miliseconds/ SD'},'13.Step_stat.', 'A20');

Range = 'A21';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=AVERAGE(D2:D6,J2:J6,P2:P6,V2:V6,AB2:AB6,AH2:AH6)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=AVERAGE(D2:D6,J2:J6,P2:P6,V2:V6,AB2:AB6,AH2:AH6)'},'13.Step_stat.', 'A21');

Range = 'A10:P10';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=(A3-A2)','','','=(D3-D2)','','','=(G3-G2)','','','=(J3-J2)','','','=(M3-M2)','','','=(P3-P2)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=(A3-A2)','','','=(D3-D2)','','','=(G3-G2)','','','=(J3-J2)','','','=(M3-M2)','','','=(P3-P2)'},'13.Step_stat.', 'A10');

Range = 'A11:P11';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=(A4-A3)','','','=(D4-D3)','','','=(G4-G3)','','','=(J4-J3)','','','=(M4-M3)','','','=(P4-P3)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=(A4-A3)','','','=(D4-D3)','','','=(G4-G3)','','','=(J4-J3)','','','=(M4-M3)','','','=(P4-P3)'},'13.Step_stat.', 'A11');

Range = 'A12:P12';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=(A5-A4)','','','=(D5-D4)','','','=(G5-G4)','','','=(J5-J4)','','','=(M5-M4)','','','=(P5-P4)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=(A5-A4)','','','=(D5-D4)','','','=(G5-G4)','','','=(J5-J4)','','','=(M5-M4)','','','=(P5-P4)'},'13.Step_stat.', 'A12');

Range = 'A18';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=1/A21'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=1/A21'},'13.Step_stat.', 'A18');

Range = 'B21:C21';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=A21*1000','=1000*(STDEV(D2:D6,J2:J6,P2:P6,V2:V6,AB2:AB6,AH2:AH6))'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=A21*1000','=1000*(STDEV(D2:D6,J2:J6,P2:P6,V2:V6,AB2:AB6,AH2:AH6))'},'13.Step_stat.','B21');

Range = 'A25';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'swing speed (v)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'swing speed (v)'},'13.Step_stat.', 'A25');

Range = 'A26:E26';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'F','M','H','average','SD'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'F','M','H','average','SD'},'13.Step_stat.', 'A26');

Range = 'A27:E27';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=AVERAGE(E2:E7,W2:W7)','=AVERAGE(K2:K7,AC2:AC7)','=AVERAGE(Q2:Q7,AI2:AI7)','=AVERAGE(E2:E7,K2:K7,Q2:Q7,W2:W7,AC2:AC7,AI2:AI7)','=STDEV(E2:E7,K2:K7,Q2:Q7,W2:W7,AC2:AC7,AI2:AI7)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=AVERAGE(E2:E7,W2:W7)','=AVERAGE(K2:K7,AC2:AC7)','=AVERAGE(Q2:Q7,AI2:AI7)','=AVERAGE(E2:E7,K2:K7,Q2:Q7,W2:W7,AC2:AC7,AI2:AI7)','=STDEV(E2:E7,K2:K7,Q2:Q7,W2:W7,AC2:AC7,AI2:AI7)'},'13.Step_stat.', 'A27');

Range = 'A29:C29';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'step lenght (s)','',''});
% xlswrite([foldername ExcelFileName '.xlsx'], {'step lenght (s)','',''},'13.Step_stat.', 'A29');

Range = 'A30:E30';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'F','M','H','average','SD'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'F','M','H','average','SD'},'13.Step_stat.', 'A30');

Range = 'A31:E31';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=AVERAGE(F2:F7,X2:X7)','=AVERAGE(L2:L7,AD2:AD7)','=AVERAGE(R2:R7,AJ2:AJ7)','=AVERAGE(F2:F7,X2:X7,L2:L7,AD2:AD7,R2:R7,AJ2:AJ7)','=STDEV(F2:F7,X2:X7,L2:L7,AD2:AD7,R2:R7,AJ2:AJ7)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=AVERAGE(F2:F7,X2:X7)','=AVERAGE(L2:L7,AD2:AD7)','=AVERAGE(R2:R7,AJ2:AJ7)','=AVERAGE(F2:F7,X2:X7,L2:L7,AD2:AD7,R2:R7,AJ2:AJ7)','=STDEV(F2:F7,X2:X7,L2:L7,AD2:AD7,R2:R7,AJ2:AJ7)'},'13.Step_stat.', 'A31');

Range = 'A33:C33';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'step duration (t; miliseconds)','',''});
% xlswrite([foldername ExcelFileName '.xlsx'], {'step duration (t; miliseconds)','',''},'13.Step_stat.', 'A33');

Range = 'A34:E34';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'F','M','H','average','SD'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'F','M','H','average','SD'},'13.Step_stat.', 'A34');

Range = 'A35:E35';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=AVERAGE(C2:C7,U2:U7)','=AVERAGE(I2:I7,AA2:AA7)','=AVERAGE(O2:O7,AG2:AG7)','=AVERAGE(C2:C7,U2:U7,I2:I7,AA2:AA7,O2:O7,AG2:AG7)','=STDEV(C2:C7,U2:U7,I2:I7,AA2:AA7,O2:O7,AG2:AG7)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=AVERAGE(C2:C7,U2:U7)','=AVERAGE(I2:I7,AA2:AA7)','=AVERAGE(O2:O7,AG2:AG7)','=AVERAGE(C2:C7,U2:U7,I2:I7,AA2:AA7,O2:O7,AG2:AG7)','=STDEV(C2:C7,U2:U7,I2:I7,AA2:AA7,O2:O7,AG2:AG7)'},'13.Step_stat.', 'A35');

Range = 'A37:C37';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'stance time','',''});
% xlswrite([foldername ExcelFileName '.xlsx'], {'stance time','',''},'13.Step_stat.', 'A37');

Range = 'A38:E38';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'F','M','H','average','SD'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'F','M','H','average','SD'},'13.Step_stat.', 'A38');

Range = 'A39:E39';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=AVERAGE(B2:B7,T2:T7)','=AVERAGE(H2:H7,Z2:Z7)','=AVERAGE(N2:N7,AF2:AF7)','=AVERAGE(B2:B7,T2:T7,H2:H7,Z2:Z7,N2:N7,AF2:AF7)','=STDEV(B2:B7,T2:T7,H2:H7,Z2:Z7,N2:N7,AF2:AF7)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=AVERAGE(B2:B7,T2:T7)','=AVERAGE(H2:H7,Z2:Z7)','=AVERAGE(N2:N7,AF2:AF7)','=AVERAGE(B2:B7,T2:T7,H2:H7,Z2:Z7,N2:N7,AF2:AF7)','=STDEV(B2:B7,T2:T7,H2:H7,Z2:Z7,N2:N7,AF2:AF7)'},'13.Step_stat.', 'A39');

Range = 'A13';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=HYPERLINK("#1.Info_Sheet!A1","Click to 1.Info_Sheet")'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=HYPERLINK("#1.Info_Sheet!A1","Click to 1.Info_Sheet")'},'13.Step_stat.', 'A13');

Range = 'A42:C42';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'average phases'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'average phases'},'13.Step_stat.', 'A42');

Range = 'A43:G43';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'Phase F','Phase M','Phase H','Phase LH vs LM','Phase LM vs LF','Phase RH vs RM','Phase RM vs RF'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'Phase F','Phase M','Phase H','Phase LH vs LM','Phase LM vs LF','Phase RH vs RM','Phase RM vs RF'},'13.Step_stat.', 'A43');

Range = 'A44:G44';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=AVERAGE(AK2:AK11)','=AVERAGE(AL2:AL11)','=AVERAGE(AM2:AM11)','=AVERAGE(AN2:AN11)','=AVERAGE(AO2:AO11)','=AVERAGE(AP2:AP11)','=AVERAGE(AQ2:AQ11)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=AVERAGE(AK2:AK11)','=AVERAGE(AL2:AL11)','=AVERAGE(AM2:AM11)','=AVERAGE(AN2:AN11)','=AVERAGE(AO2:AO11)','=AVERAGE(AP2:AP11)','=AVERAGE(AQ2:AQ11)'},'13.Step_stat.', 'A44');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sheet = get(sheets, 'Item', 11);
invoke(sheet, 'Activate');

%on 11.Pos. stat.

Range = 'A27';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'avr perpend middle'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'avr perpend middle'},'11.Pos. stat.', 'A27');

Range = 'B27';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=AVERAGE(D10:E10)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=AVERAGE(D10:E10)'},'11.Pos. stat.', 'B27');
% xlswrite([foldername ExcelFileName '.xlsx'], {'=AVERAGE(D10:E10)'},'11.Pos. stat.', 'B27');

Range = 'H24';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=AVERAGE(B24:G24)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=AVERAGE(B24:G24)'},'11.Pos. stat.', 'H24');

Range = 'H3';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=AVERAGE(D3:E3)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=AVERAGE(D3:E3)'},'11.Pos. stat.', 'H3');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sheet = get(sheets, 'Item', 16);
invoke(sheet, 'Activate');

% on 16.AEP_PEP

Range = 'A13:W13';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=SQRT(A15^2+B15^2)','=AVERAGE(A13,C13)','=SQRT(C15^2+D15^2)','','=SQRT(E15^2+F15^2)','=AVERAGE(E13,G13)','=SQRT(G15^2+H15^2)','','=SQRT(I15^2+J15^2)','=AVERAGE(I13,K13)','=SQRT(K15^2+L15^2)','','=SQRT(M15^2+N15^2)','=AVERAGE(M13,O13)','=SQRT(O15^2+P15^2)','','=SQRT(Q15^2+R15^2)','=AVERAGE(Q13,S13)','=SQRT(S15^2+T15^2)','','=SQRT(U15^2+V15^2)','=AVERAGE(U13,W13)','=SQRT(W15^2+X15^2)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=SQRT(A15^2+B15^2)','=AVERAGE(A13,C13)','=SQRT(C15^2+D15^2)','','=SQRT(E15^2+F15^2)','=AVERAGE(E13,G13)','=SQRT(G15^2+H15^2)','','=SQRT(I15^2+J15^2)','=AVERAGE(I13,K13)','=SQRT(K15^2+L15^2)','','=SQRT(M15^2+N15^2)','=AVERAGE(M13,O13)','=SQRT(O15^2+P15^2)','','=SQRT(Q15^2+R15^2)','=AVERAGE(Q13,S13)','=SQRT(S15^2+T15^2)','','=SQRT(U15^2+V15^2)','=AVERAGE(U13,W13)','=SQRT(W15^2+X15^2)'},'16.AEP_PEP', 'A13');

Range = 'A14:X14';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=AVERAGE(A2:A10)','=AVERAGE(B2:B10)','=AVERAGE(C2:C10)','=AVERAGE(D2:D10)','=AVERAGE(E2:E10)','=AVERAGE(F2:F10)','=AVERAGE(G2:G10)','=AVERAGE(H2:H10)','=AVERAGE(I2:I10)','=AVERAGE(J2:J10)','=AVERAGE(K2:K10)','=AVERAGE(L2:L10)','=AVERAGE(M2:M10)','=AVERAGE(N2:N10)','=AVERAGE(O2:O10)','=AVERAGE(P2:P10)','=AVERAGE(Q2:Q10)','=AVERAGE(R2:R10)','=AVERAGE(S2:S10)','=AVERAGE(T2:T10)','=AVERAGE(U2:U10)','=AVERAGE(V2:V10)','=AVERAGE(W2:W10)','=AVERAGE(X2:X10)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=AVERAGE(A2:A10)','=AVERAGE(B2:B10)','=AVERAGE(C2:C10)','=AVERAGE(D2:D10)','=AVERAGE(E2:E10)','=AVERAGE(F2:F10)','=AVERAGE(G2:G10)','=AVERAGE(H2:H10)','=AVERAGE(I2:I10)','=AVERAGE(J2:J10)','=AVERAGE(K2:K10)','=AVERAGE(L2:L10)','=AVERAGE(M2:M10)','=AVERAGE(N2:N10)','=AVERAGE(O2:O10)','=AVERAGE(P2:P10)','=AVERAGE(Q2:Q10)','=AVERAGE(R2:R10)','=AVERAGE(S2:S10)','=AVERAGE(T2:T10)','=AVERAGE(U2:U10)','=AVERAGE(V2:V10)','=AVERAGE(W2:W10)','=AVERAGE(X2:X10)'},'16.AEP_PEP','A14');

Range = 'A15:X15';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=STDEV(A2:A10)','=STDEV(B2:B10)','=STDEV(C2:C10)','=STDEV(D2:D10)','=STDEV(E2:E10)','=STDEV(F2:F10)','=STDEV(G2:G10)','=STDEV(H2:H10)','=STDEV(I2:I10)','=STDEV(J2:J10)','=STDEV(K2:K10)','=STDEV(L2:L10)','=STDEV(M2:M10)','=STDEV(N2:N10)','=STDEV(O2:O10)','=STDEV(P2:P10)','=STDEV(Q2:Q10)','=STDEV(R2:R10)','=STDEV(S2:S10)','=STDEV(T2:T10)','=STDEV(U2:U10)','=STDEV(V2:V10)','=STDEV(W2:W10)','=STDEV(X2:X10)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=STDEV(A2:A10)','=STDEV(B2:B10)','=STDEV(C2:C10)','=STDEV(D2:D10)','=STDEV(E2:E10)','=STDEV(F2:F10)','=STDEV(G2:G10)','=STDEV(H2:H10)','=STDEV(I2:I10)','=STDEV(J2:J10)','=STDEV(K2:K10)','=STDEV(L2:L10)','=STDEV(M2:M10)','=STDEV(N2:N10)','=STDEV(O2:O10)','=STDEV(P2:P10)','=STDEV(Q2:Q10)','=STDEV(R2:R10)','=STDEV(S2:S10)','=STDEV(T2:T10)','=STDEV(U2:U10)','=STDEV(V2:V10)','=STDEV(W2:W10)','=STDEV(X2:X10)'},'16.AEP_PEP', 'A15');
%xlswrite([foldername ExcelFileName '.xlsx'], {'=HYPERLINK("#1.Info_Sheet!A1","Click to 1.Info_Sheet")'},'16.AEP_PEP', 'A21');

Range = 'A16:W16';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'=SQRT(A14^2+B14^2)','','=SQRT(C14^2+D14^2)','','=SQRT(E14^2+F14^2)','','=SQRT(G14^2+H14^2)','','=SQRT(I14^2+J14^2)','','=SQRT(K14^2+L14^2)','','=SQRT(M14^2+N14^2)','','=SQRT(O14^2+P14^2)','','=SQRT(Q14^2+R14^2)','','=SQRT(S14^2+T14^2)','','=SQRT(U14^2+V14^2)','','=SQRT(W14^2+X14^2)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=SQRT(A14^2+B14^2)','','=SQRT(C14^2+D14^2)','','=SQRT(E14^2+F14^2)','','=SQRT(G14^2+H14^2)','','=SQRT(I14^2+J14^2)','','=SQRT(K14^2+L14^2)','','=SQRT(M14^2+N14^2)','','=SQRT(O14^2+P14^2)','','=SQRT(Q14^2+R14^2)','','=SQRT(S14^2+T14^2)','','=SQRT(U14^2+V14^2)','','=SQRT(W14^2+X14^2)'},'16.AEP_PEP', 'A16');

Range = 'A17:W17';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'SD AEP','=AVERAGE(A13:K13)','=AVERAGE(A16,C16)','','','','=AVERAGE(E16,G16)','','','','=AVERAGE(I16,K16)','','','','=AVERAGE(M16,O16)','','','','=AVERAGE(Q16,S16)','','','','=AVERAGE(U16,W16)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'SD AEP','=AVERAGE(A13:K13)','=AVERAGE(A16,C16)','','','','=AVERAGE(E16,G16)','','','','=AVERAGE(I16,K16)','','','','=AVERAGE(M16,O16)','','','','=AVERAGE(Q16,S16)','','','','=AVERAGE(U16,W16)'},'16.AEP_PEP', 'A17');

Range = 'A18:B18';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value', {'SD PEP','=AVERAGE(M13:W13)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'SD PEP','=AVERAGE(M13:W13)'},'16.AEP_PEP', 'A18');

Range = 'A20';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value',  {'xy component and xySD'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'xy component and xySD'},'16.AEP_PEP', 'A20');

Range = 'A21:V21';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value',  {'=AVERAGE(A14,C14)','=AVERAGE(B14,D14)','','','=AVERAGE(E14,G14)','=AVERAGE(F14,H14)','','','=AVERAGE(I14,K14)','=AVERAGE(J14,L14)','','','=AVERAGE(M14,O14)','=AVERAGE(N14,P14)','','','=AVERAGE(Q14,S14)','=AVERAGE(R14,T14)','','','=AVERAGE(U14,W14)','=AVERAGE(V14,X14)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=AVERAGE(A14,C14)','=AVERAGE(B14,D14)','','','=AVERAGE(E14,G14)','=AVERAGE(F14,H14)','','','=AVERAGE(I14,K14)','=AVERAGE(J14,L14)','','','=AVERAGE(M14,O14)','=AVERAGE(N14,P14)','','','=AVERAGE(Q14,S14)','=AVERAGE(R14,T14)','','','=AVERAGE(U14,W14)','=AVERAGE(V14,X14)'},'16.AEP_PEP', 'A21');

Range = 'A22:V22';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value',  {'=AVERAGE(A15,C15)','=AVERAGE(B15,D15)','','','=AVERAGE(E15,G15)','=AVERAGE(F15,H15)','','','=AVERAGE(I15,K15)','=AVERAGE(J15,L15)','','','=AVERAGE(M15,O15)','=AVERAGE(N15,P15)','','','=AVERAGE(Q15,S15)','=AVERAGE(R15,T15)','','','=AVERAGE(U15,W15)','=AVERAGE(V15,X15)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=AVERAGE(A15,C15)','=AVERAGE(B15,D15)','','','=AVERAGE(E15,G15)','=AVERAGE(F15,H15)','','','=AVERAGE(I15,K15)','=AVERAGE(J15,L15)','','','=AVERAGE(M15,O15)','=AVERAGE(N15,P15)','','','=AVERAGE(Q15,S15)','=AVERAGE(R15,T15)','','','=AVERAGE(U15,W15)','=AVERAGE(V15,X15)'},'16.AEP_PEP', 'A22');

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sheet = get(sheets, 'Item', 10);
invoke(sheet, 'Activate');

%on sheet 10.Leg_combinations

Range = 'C9';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value',  {'=B9/SUM($B$9:$B$71)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=B9/SUM($B$9:$B$71)'},'10.Leg_combinations', 'C9');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sheet = get(sheets, 'Item', 17);
invoke(sheet, 'Activate');

%on sheet 17.Tripod

Range = 'C23:F23';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value',  {'=AVERAGE(C3:C21)*1000','=AVERAGE(D3:D21)*1000','=IF(AND(''1.Info_Sheet''!C41>=0.2,''1.Info_Sheet''!D41<=0.4),D23,"")','=HYPERLINK("#1.Info_Sheet!A41:DP41","Click to 1.Info_Sheet")'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=AVERAGE(C3:C21)*1000','=AVERAGE(D3:D21)*1000','=IF(AND(''1.Info_Sheet''!C41>=0.2,''1.Info_Sheet''!D41<=0.4),D23,"")','=HYPERLINK("#1.Info_Sheet!A41:DF41","Click to 1.Info_Sheet")'},'17.Tripod', 'C23');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sheet = get(sheets, 'Item', 1);
invoke(sheet, 'Activate');

% Again, on 1. Info Sheet 

%xlswrite([foldername ExcelFileName '.xlsx'], {'=HYPERLINK("#10.Leg_combinations!A1","Click to 10.Leg_combinations")'},'1.Info_Sheet', 'J1');
%xlswrite([foldername ExcelFileName '.xlsx'], {'=HYPERLINK("#13.Step_stat.!A1","Click to 13.Step_stat.")'},'1.Info_Sheet', 'J2');

Range = 'J3';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value',  {'=HYPERLINK("#15.Leg_alignment!A13","Click to 15.Leg_alignment")'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=HYPERLINK("#15.Leg_alignment!A13","Click to 15.Leg_alignment")'},'1.Info_Sheet', 'J3');

%xlswrite([foldername ExcelFileName '.xlsx'], {'=HYPERLINK("#16.AEP_PEP!A1","Click to 16.AEP_PEP")'},'1.Info_Sheet', 'J4');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sheet = get(sheets, 'Item', 15);
invoke(sheet, 'Activate');

%on sheet 15.Leg_alignment

Range = 'A12';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value',  {'AVR FP STD'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'AVR FP STD'},'15.Leg_alignment', 'A12');

Range = 'A16';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value',  {'=HYPERLINK("#17.Tripod!C23","Click to 17.Tripod")'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=HYPERLINK("#17.Tripod!C23","Click to 17.Tripod")'},'15.Leg_alignment', 'A16');

Range = 'A13';
ActivesheetRange = get(sheet,'Range',Range);
set(ActivesheetRange, 'Value',  {'=AVERAGE(B2:B5,E2:E5)'});
% xlswrite([foldername ExcelFileName '.xlsx'], {'=AVERAGE(B2:B5,E2:E5)'},'15.Leg_alignment', 'A13');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% activate sheet 1 (so it's the first thing we see as we open the file)
sheet = get(sheets, 'Item', 1);
invoke(sheet, 'Activate');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% now save the workbook
% invoke(exlFile, 'SaveAs', [foldername ExcelFileName '.xlsx']);
output_file_name_excel = [foldername ExcelFileName '.xlsx'];
% [foldername ExcelFileName '.xlsx'];
exlFile.SaveAs(output_file_name_excel);
% exlFile.Save;
% quit exl
exlFile.Close(false);
invoke(exl, 'Quit');
% end process
delete(exl);


% catch
%   FinishState = -1;
% end;

toc
return;


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [Dist, PerpDist, ParaDist, Angle] = LegDistance(BodyX, BodyY, LegX, LegY, m, b, direction, orientation)
    if LegX ~= -1
        if direction == 1
            [d, x0, y0]  = point_to_line(LegX,LegY,m,b);
        else
            [d, y0, x0]  = point_to_line(LegY,LegX,m,b);
        end;

        Dist2 = (BodyX - LegX)^2 + (BodyY - LegY)^2;   
        PerpDist = d;
        ParaDist = sqrt(Dist2 - d^2);
        if direction == 1
            ParaDist = ParaDist * orientation * sign(x0 - BodyX);
        else
            ParaDist = ParaDist * orientation * sign(y0 - BodyY);
        end;
        
        Dist = sqrt(Dist2);
        Angle = acos(ParaDist/Dist)/pi*180;
    else
        PerpDist = -1;
        ParaDist = -1;
        Dist = -1;
        Angle = -1;
    end;
return;
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [d, x0, y0]  = point_to_line(x1,y1,m,b)
% calculate distance between line y=mx+b and point (x1,y1).
% d        - distance
% (x0,y0)  - coordinates of the closest point on the line to the point

    x0 = (m*y1 + x1 - m*b)   / (m^2 + 1);
    y0 = (m^2*y1 + m*x1 + b) / (m^2 + 1);
    d = abs(y1 - m*x1 - b)   / sqrt(m^2+1);

return;

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function PlotResults(Variable, time, Title, YAxisName, figurenumber, outputfilename)
% plot Variable as a function of time with given title, axisnames and figurenumber

R = [1 1 0 0 0];
G = [0 0.5 1 1 0];
B = [0 0 0 1 1];
RGB = [1   0   0; ...
       1   0.5 0; ...
       0   1   0; ...
       0.5 1   1; ...
       0   0   1; ...
       0   0   0];

h = figure('visible', 'off');
hold off;
for i = 1:6
    ind = find(Variable(i,:) ~= -1);
    plot(time(ind), Variable(i,ind), 'o','color', RGB(i,:), 'MarkerSize', 5, 'MarkerFaceColor',RGB(i,:));
    hold on;
end;
for i = 1:6
    ind = find(Variable(i,:) ~= -1);
    for j = 1:length(ind)-1
        if ind(j+1) - ind(j) == 1
            I = [ind(j) ind(j+1)];
            plot(time(I), Variable(i,I),'color', RGB(i,:), 'LineWidth', 2);
        end
    end
end;
for i = 1:6
    ind = find(Variable(i,:) ~= -1);
    plot(time(ind), Variable(i,ind), ':','color', RGB(i,:));
end;
L = legend('Left Fore', 'Left Middle', 'Left Hind', 'Right Fore', 'Right Middle', 'Right Hind');

set(gcf, 'unit', 'inches');
figure_size =  get(gcf, 'position');

set(L,'Interpreter','none', 'FontSize', 8, 'Location', 'EastOutside');
set(L, 'unit', 'inches');
legend_size = get(L, 'position');
figure_size(3) = figure_size(3) + legend_size(3);
set(gcf, 'position', figure_size);

    

title(Title);
xlabel('time [sec]');
ylabel(YAxisName);
grid on;
box on;
hold off;

saveas(h,outputfilename,'png');

close(h);

return;




