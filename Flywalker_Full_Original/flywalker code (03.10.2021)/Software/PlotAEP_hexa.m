function PlotAEP(filename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function PlotAEP(filename)
%
% Takes an excel file 'filename' whicH_has data on the AEP_and PEP_location
% and STD oF_a list oF_fly tracks, and plots these witH_colors also defined
% by 'filename'.
%
%
% Values are assumed to be given in units of body-length.
%
% Color is given in RGB, with each component defined in a separate column.
%
% For giving the line type, the options are solid ('-), dashed ('--),
% dotted (':) and dotted-dashed ('-.). In the parentheses we show what you
% should write in the excel spreadsheet.
%
%
% (c) Imre Bartos
% version 6_30_11
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 filename = 'C:\Users\marta.santos\Documents\MATLAB\hexa_2017_Mar_09\AEP_PEP plot.xlsx';

% PLOT ERRORBARS (1 - plot errorbars; 0 - plot little circles and no errorbars)
  PLOT_ERRORBARS = 1;
  
% DRAW LEGEND (1 - draw legend; 0 - don't draw anything)  
DRAW_LEGEND = 1;
  
  
% load data in file
  [num,txt,raw] = xlsread(filename,'Sheet1')
  [N,~] = size(num);

  find(cellfun(@(x)~ischar(x),raw(2:end,1)));
  Names           = cell(txt(2:end,1));
  AEP_F_y         = cell2mat(raw(2:end,2));	
  AEP_M_y         = cell2mat(raw(2:end,3));	
  AEP_H_y         = cell2mat(raw(2:end,4));	
  PEP_F_y         = cell2mat(raw(2:end,5));	
  PEP_M_y         = cell2mat(raw(2:end,6));	
  PEP_H_y         = cell2mat(raw(2:end,7));	
  AEP_F_STD_y     = cell2mat(raw(2:end,8));	
  AEP_M_STD_y     = cell2mat(raw(2:end,9));	
  AEP_H_STD_y     = cell2mat(raw(2:end,10));	
  PEP_F_STD_y     = cell2mat(raw(2:end,11));	
  PEP_M_STD_y     = cell2mat(raw(2:end,12));	
  PEP_H_STD_y     = cell2mat(raw(2:end,13));	
  AEP_F_x         = cell2mat(raw(2:end,14));	
  AEP_M_x         = cell2mat(raw(2:end,15));	
  AEP_H_x         = cell2mat(raw(2:end,16));	
  PEP_F_x         = cell2mat(raw(2:end,17));	
  PEP_M_x         = cell2mat(raw(2:end,18));	
  PEP_H_x         = cell2mat(raw(2:end,19));	
  AEP_F_STD_x     = cell2mat(raw(2:end,20));	
  AEP_M_STD_x     = cell2mat(raw(2:end,21));	
  AEP_H_STD_x     = cell2mat(raw(2:end,22));	
  PEP_F_STD_x     = cell2mat(raw(2:end,23));	
  PEP_M_STD_x     = cell2mat(raw(2:end,24));	
  PEP_H_STD_x     = cell2mat(raw(2:end,25));	
  AEP_F_color_R	  = cell2mat(raw(2:end,26));
  AEP_F_color_G	  = cell2mat(raw(2:end,27));
  AEP_F_color_B	  = cell2mat(raw(2:end,28));
  AEP_F_line      =          raw(2:end,29);	
  AEP_M_color_R	  = cell2mat(raw(2:end,30));
  AEP_M_color_G	  = cell2mat(raw(2:end,31));
  AEP_M_color_B	  = cell2mat(raw(2:end,32));
  AEP_M_line      =          raw(2:end,33);	
  AEP_H_color_R	  = cell2mat(raw(2:end,34));
  AEP_H_color_G	  = cell2mat(raw(2:end,35));
  AEP_H_color_B	  = cell2mat(raw(2:end,36));
  AEP_H_line      =          raw(2:end,37);	
  PEP_F_color_R	  = cell2mat(raw(2:end,38));
  PEP_F_color_G	  = cell2mat(raw(2:end,39));
  PEP_F_color_B	  = cell2mat(raw(2:end,40));
  PEP_F_line      =          raw(2:end,41);	
  PEP_M_color_R	  = cell2mat(raw(2:end,42));
  PEP_M_color_G	  = cell2mat(raw(2:end,43));
  PEP_M_color_B	  = cell2mat(raw(2:end,44));
  PEP_M_line      =          raw(2:end,45);	
  PEP_H_color_R	  = cell2mat(raw(2:end,46));
  PEP_H_color_G	  = cell2mat(raw(2:end,47));
  PEP_H_color_B   = cell2mat(raw(2:end,48));	
  PEP_H_line      =          raw(2:end,49);	

% plot results
  h = figure('visible', 'off','PaperPosition', [0 0 12 10], 'Units', 'inches');
  hold on;

% plot something for the sake of the legend
  if DRAW_LEGEND == 1
    % find unique names:
      [UniqueNames,m,~] = unique(Names);
      
    for i = m(end:-1:1)'  
        if PLOT_ERRORBARS == 1
            plot(0, 0, 'Color', [AEP_F_color_R(i) AEP_F_color_G(i) AEP_F_color_B(i)], 'LineWidth', 1);
        else
            plot(0, 0, 'o', 'Color', [AEP_F_color_R(i) AEP_F_color_G(i) AEP_F_color_B(i)], 'LineWidth', 2);
        end
    end
    %legend(UniqueNames(end:-1:1));
    % delete what you just drew as we don't need it
      plot(0, 0, 'o', 'Color', [1 1 1], 'LineWidth', 2);
  end
  
  % set picture limits
    %Marker = [0 0] ;
    XLIMIT = [-1 +1];
    YLIMIT = [-1.2 +1];
    xlim(XLIMIT);
    ylim(YLIMIT);    
    

  % draw horizontal line at zero
    plot(XLIMIT,[0 0], 'k', 'LineWidth', 1)
    
  % draw line between AEP and PEP
    plot([0 0], YLIMIT, 'k', 'LineWidth', 1)
    
  % draw X mark at zero
    grid on
    %plot(0,0,'kx', 'LineWidth', 2, 'MarkerSize', 20)
    
  % loop over lines in the xlsx file
    for i = 1:N
        if PLOT_ERRORBARS == 1
            % AEP FORE
              plot((-AEP_F_x(i)+AEP_F_STD_x(i)*[-1 1])', (AEP_F_y(i)+[0 0])', cell2mat(AEP_F_line(i)), 'Color', [AEP_F_color_R(i) AEP_F_color_G(i) AEP_F_color_B(i)], 'LineWidth', 2);
              plot((-AEP_F_x(i)+[0 0])', (AEP_F_y(i)+AEP_F_STD_y(i)*[-1 1])', cell2mat(AEP_F_line(i)), 'Color', [AEP_F_color_R(i) AEP_F_color_G(i) AEP_F_color_B(i)], 'LineWidth', 2);
            % AEP MIDDLE
              plot((-AEP_M_x(i)+AEP_M_STD_x(i)*[-1 1])', (AEP_M_y(i)+[0 0])', cell2mat(AEP_M_line(i)), 'Color', [AEP_M_color_R(i) AEP_M_color_G(i) AEP_M_color_B(i)], 'LineWidth', 2);
              plot((-AEP_M_x(i)+[0 0])', (AEP_M_y(i)+AEP_M_STD_y(i)*[-1 1])', cell2mat(AEP_M_line(i)), 'Color', [AEP_M_color_R(i) AEP_M_color_G(i) AEP_M_color_B(i)], 'LineWidth', 2);
            % AEP HIND
              plot((-AEP_H_x(i)+AEP_H_STD_x(i)*[-1 1])', (AEP_H_y(i)+[0 0])', cell2mat(AEP_H_line(i)), 'Color', [AEP_H_color_R(i) AEP_H_color_G(i) AEP_H_color_B(i)], 'LineWidth', 2);
              plot((-AEP_H_x(i)+[0 0])', (AEP_H_y(i)+AEP_H_STD_y(i)*[-1 1])', cell2mat(AEP_H_line(i)), 'Color', [AEP_H_color_R(i) AEP_H_color_G(i) AEP_H_color_B(i)], 'LineWidth', 2);
            % PEP FORE
              plot((PEP_F_x(i)+PEP_F_STD_x(i)*[-1 1])', (PEP_F_y(i)+[0 0])', cell2mat(PEP_F_line(i)), 'Color', [PEP_F_color_R(i) PEP_F_color_G(i) PEP_F_color_B(i)], 'LineWidth', 2);
              plot((PEP_F_x(i)+[0 0])', (PEP_F_y(i)+PEP_F_STD_y(i)*[-1 1])', cell2mat(PEP_F_line(i)), 'Color', [PEP_F_color_R(i) PEP_F_color_G(i) PEP_F_color_B(i)], 'LineWidth', 2);
            % PEP MIDDLE
              plot((PEP_M_x(i)+PEP_M_STD_x(i)*[-1 1])', (PEP_M_y(i)+[0 0])', cell2mat(PEP_M_line(i)), 'Color', [PEP_M_color_R(i) PEP_M_color_G(i) PEP_M_color_B(i)], 'LineWidth', 2);
              plot((PEP_M_x(i)+[0 0])', (PEP_M_y(i)+PEP_M_STD_y(i)*[-1 1])', cell2mat(PEP_M_line(i)), 'Color', [PEP_M_color_R(i) PEP_M_color_G(i) PEP_M_color_B(i)], 'LineWidth', 2)
            % PEP HIND
              plot((PEP_H_x(i)+PEP_H_STD_x(i)*[-1 1])', (PEP_H_y(i)+[0 0])', cell2mat(PEP_H_line(i)), 'Color', [PEP_H_color_R(i) PEP_H_color_G(i) PEP_H_color_B(i)], 'LineWidth', 2);
              plot((PEP_H_x(i)+[0 0])', (PEP_H_y(i)+PEP_H_STD_y(i)*[-1 1])', cell2mat(PEP_H_line(i)), 'Color', [PEP_H_color_R(i) PEP_H_color_G(i) PEP_H_color_B(i)], 'LineWidth', 2);
        else
            % AEP FORE
              plot(-AEP_F_x(i), AEP_F_y(i)+[0 0], 'o', 'MarkerSize',2 ,'Color', [AEP_F_color_R(i) AEP_F_color_G(i) AEP_F_color_B(i)], 'LineWidth', 1);
            % AEP MIDDLE
              plot(-AEP_M_x(i), AEP_M_y(i)+[0 0], 'o', 'MarkerSize',2, 'Color', [AEP_M_color_R(i) AEP_M_color_G(i) AEP_M_color_B(i)], 'LineWidth', 1);
            % AEP HIND
              plot(-AEP_H_x(i), AEP_H_y(i)+[0 0], 'o', 'MarkerSize',2, 'Color', [AEP_H_color_R(i) AEP_H_color_G(i) AEP_H_color_B(i)], 'LineWidth', 1);
            % PEP FORE
              plot( PEP_F_x(i), PEP_F_y(i)+[0 0], 'o', 'MarkerSize',2, 'Color', [PEP_F_color_R(i) PEP_F_color_G(i) PEP_F_color_B(i)], 'LineWidth', 1);
            % PEP MIDDLE
              plot( PEP_M_x(i), PEP_M_y(i)+[0 0], 'o', 'MarkerSize',2, 'Color', [PEP_M_color_R(i) PEP_M_color_G(i) PEP_M_color_B(i)], 'LineWidth', 1);

            % PEP HIND
              plot( PEP_H_x(i), PEP_H_y(i)+[0 0], 'o', 'MarkerSize',2, 'Color', [PEP_H_color_R(i) PEP_H_color_G(i) PEP_H_color_B(i)], 'LineWidth', 1);
        end
    end
    
% plots diagonal to show AEP and PEP of the same segment, like in Mendes et al. 2013 paper    
    x =[-0.58,0.55]
    y =[0.2,-0.33]
    plot(x,y,':k','LineWidth', 2)  
    
  % write AEP and PEP on top
    text(-0.57, 1.05, 'AEP', 'FontSize', 20)
    text( 0.44, 1.05, 'PEP', 'FontSize', 20)
    
    text(-0.020,0.005,'X','FontSize', 20)
    text(-0.1,0.6,'forelegs','FontSize', 20,'Background','white')
    text(-0.1,-0.1,'midlegs','FontSize', 20,'Background','white')
    text(-0.1,-0.6,'hindlegs','FontSize', 20,'Background','white')
           
    set(gca,'Layer','Top', 'FontSize', 14); % put grid on top
    

    xlabel('X Position (body units)', 'FontSize', 14);
    ylabel('Y Position (body units)', 'FontSize', 14)
%     grid on;
    box on;
    hold off;   
      
%   % make labels on the X axis absolute
%     Xticks = get(gca,'Xtick');
%     set(gca,'XTickMode', 'Manual', 'Xtick', [-5:0.2:5]);
%     Xticks = get(gca,'Xtick');
%     set(gca,'XTickMode', 'manual', 'XTickLabel',abs(Xticks));
    
      
 % save output  
    ind = find(filename == '.');
    outputfilename = sprintf('%s_AEP_PEP.png', filename(1:ind(end)-1));
    saveas(h,outputfilename,'png');
    close(h);     
  
  system(outputfilename);
  
return;