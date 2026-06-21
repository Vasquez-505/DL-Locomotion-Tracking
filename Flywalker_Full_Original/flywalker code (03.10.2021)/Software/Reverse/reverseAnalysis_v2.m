function [flyPoints, ellipseData, rad_extras] = reverseAnalysis_v2(v, p, positions, FrameNumber, bl, cl, Itres)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function [flyPoints, ellipseData, rad_extras] = reverseAnalysis_v2(v, p, positions, FrameNumber, bl, cl)
% Outputs new frontal, central and back points
% Also outputs the drawing ellipse
% rad_extras - struct with debug data, not used anywhere else (just for drawing and visualization purposes)
% Called from AutoFootPrintAnalysis()
%
% Parameters:
% v,p - fly data and parameters
% positions - deep learning predictions initial estimates
% FrameNumber - current frame under analysis
% bl - body length (assumes fixed)
% cl - front to center length (assumed fixed)
% Reverse Engineering, 2020.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

flyPoints = [];
rad_extras = struct();


% Novo algoritmo background
if p.UseBackgroundSubtraction & FrameNumber <= size(Itres,3)
    I = Itres(:,:,FrameNumber);
else    
    % reload images
    [vaux.pic, vaux.rawpic, vaux.nopic] = PictureReader_02(FrameNumber, p);
    pic.R = vaux.pic.R - v.picAVG.R - 2*v.picSTD.R - v.DPM;
    pic.R = min(255,max(0,pic.R));

    % This is the based image used through out the function
    I = pic.R;
end
  
% Further parameters
open_thr = 10;         


%set debug mode
debug = 0;

% get positions from deep learnign results
if(FrameNumber <= size(positions,1))
    dldata = positions(FrameNumber, :);
    
    if dldata(3) < 0 & FrameNumber > 2
        % as a temporary fix, if dl data is not availble, use that last one
        % availabel
        
        last_available_dl_frame = max(find(positions(1:FrameNumber-1,3) > 0))
        dldata = positions(last_available_dl_frame,:);
    end
else
    flyPoints = [-1 -1 -1 -1 -1 -1];
    ellipseData.y = 0;
    ellipseData.x = 0;
    ellipseData.a = 0;
    ellipseData.b = 0;
    ellipseData.angle = -1;
    return;
end

if numel(dldata) ~= 11
    flyPoints = [-1 -1 -1 -1 -1 -1];
    ellipseData.y = 0;
    ellipseData.x = 0;
    ellipseData.a = 0;
    ellipseData.b = 0;
    ellipseData.angle = -1;
    return;
end

% lateral segment midpoints (will be the radii center)
Xdl = [dldata(4) dldata(6) dldata(8) dldata(10)];
Ydl = [dldata(5) dldata(7) dldata(9) dldata(11)];


realdist = bl;
xc_add = 0.25*(max(Xdl) - min(Xdl));
yc_add = 20;

xcl = round(min(Xdl));
ycl = round(min(Ydl));
xcr = round(max(Xdl));
ycr = round(max(Ydl));

if(xcl < 0)
    if FrameNumber == 1
        xcl = 20;
        xcr = xcl + bl + 5;
        ycl = 20;
        ycr =  size(I,2) - 20;
        xc_add = 10;
        yc_add = 10;    
    end
end



leftpt = [];
rightpt = [];
angle_out = 0;
use_radon = ~p.UseFitEllipse;

if use_radon

    % create auxiliary crop locations
    crops = {};
    dists = [];
    for aux_xl = (xcl-xc_add):-xc_add:(xcl-3*xc_add)
        for aux_yl = (ycl-yc_add):-yc_add:(ycl-3*yc_add)
            aux_xr = xcr + abs(xcl - aux_xl);
            aux_yr = ycr + abs(ycl - aux_yl);
            crops = {crops{:}, [aux_xl aux_yl aux_xr aux_yr]};
        end
    end

    rad_res = {};
    best_rad_crop = [];
    best_rad_points = [];
    best_ang_radon = 0;
    best_BW = [];
    best_close_thr = 3;

    min_dist = 10000;

    % iterate over crop regions
    for ic = 1:size(crops,2)
        axl = round(crops{ic}(1)); ayl = round(crops{ic}(2));
        axr = round(crops{ic}(3)); ayr = round(crops{ic}(4));

        if(ayl < 1)
            ayl = 1;
        end
        if(ayr >= size(I,1))
            ayr = size(I,1) - 1;
        end
        if(axl < 1)
            axl = 1;
        end
        if(axr >= size(I,2))
            axr = size(I,2) - 1;
        end

        Icrop = I(ayl:ayr, axl:axr);

        % also iterate over various imclose thresholds
        for close_thr = 3:3:9    
            [M1, ang_radon_a, lrd_a, rrd_a, cc_a, BW] = my_radon(Icrop, 0:0.5:179.5, close_thr, open_thr, bl, cl, 0);

            if ang_radon_a == -1
                continue;
            end

            dist_diff = abs(pdist([lrd_a; rrd_a]) - realdist);

            if(dist_diff < min_dist)
                min_dist = dist_diff;
                best_rad_crop = [axl ayl axr ayr];
                best_rad_points = [lrd_a rrd_a cc_a];
                best_ang_radon = ang_radon_a;
                best_BW = BW;
                best_close_thr = close_thr;
            end   
        end
    end

    if length(best_rad_crop) < 1
        flyPoints = [-1 -1 -1 -1 -1 -1];
        ellipseData.y = 0;
        ellipseData.x = 0;
        ellipseData.a = 0;
        ellipseData.b = 0;
        ellipseData.angle = -1;

        return;
    end

    % data for output
    rad_extras.crop = best_rad_crop;
    rad_extras.points = best_rad_points;
    rad_extras.angle = best_ang_radon;
    rad_extras.BW = best_BW;
    rad_extras.close_threshold = best_close_thr;

    % limits of the best crop image
    xcl = best_rad_crop(1);
    ycl = best_rad_crop(2);
    xcr = best_rad_crop(3);
    ycr = best_rad_crop(4);

    Ibc = I(ycl:ycr, xcl:xcr);

    lrd = best_rad_points(1:2);
    rrd = best_rad_points(3:4);
    cc = best_rad_points(5:6);



%     final_dist = abs(pdist([lrd; rrd]));     
%     disp(['Frame Number ' num2str(FrameNumber)]);
%     disp(['Best Point: L: ' num2str(lrd + [xcl ycl]) ' R:' num2str(rrd + [xcl ycl])]);
%     disp(['Best dist: ' num2str(final_dist) ' Real Dist:' num2str(realdist) ]);

    ang_radon = best_ang_radon;
    angle_out = ang_radon;
    
    leftpt = [lrd(1)+xcl lrd(2)+ycl];
    rightpt = [rrd(1)+xcl rrd(2)+ycl];
else

    % NEW FIT ELLIPSE ALGOTRITHM
    angulo = 0;
    hh = bl/8;
    cc = bl;
    centroi = round((bl)/2);
    centroj = round((bl)/2);
    mask = zeros(bl,bl);
    for i = 1:size(mask,1)
        for j = 1:size(mask,2)
            if ((i-centroi)^2/(hh^2))+((j-centroj)^2/(cc^2))<=1,
                mask(i,j) = 1;
            end    
        end
    end

    mm = zeros(size(mask,1),size(mask,2),180);
    for i = 1:180,
        mm(:,:,i) = imrotate(mask,-i,'bilinear','crop');
    end

    Xdl = [dldata(4) dldata(6) dldata(8) dldata(10)];
    Ydl = [dldata(5) dldata(7) dldata(9) dldata(11)];
    xcle = max(1,round(min(Xdl))-10);
    ycle = max(1,round(min(Ydl))-10);
    xcre = min(size(I,2) - 1, round(max(Xdl))+10);
    ycre = min(size(I,1) - 1 , round(max(Ydl))+10);

    if ycle < 0 | ycre > size(I,1) | xcle < 0 | xcre > size(I,2),
        flyPoints = [-1 -1 -1 -1 -1 -1];
        ellipseData.y = 0;
        ellipseData.x = 0;
        ellipseData.a = 0;
        ellipseData.b = 0;
        ellipseData.angle = -1;
        return;
    end
    %I1=I(ycl:ycr,xcl:xcr);
    %[I2,angulo,ci,cj]=fit_ellipse(I1,27,7);

    I1 = I(ycle:ycre,xcle:xcre);
    [I2,angulo,ci,cj] = fit_ellipse_v2(I1,cc,hh,mm);

    % figure; imagesc(I1);
    % hold on;
    % plot(cj, ci, 'wx', 'LineWidth',2.3, 'MarkerSize', 8.0);


    %if angulo+90 > 180
    %    angulo = angulo - 180;
    %end
    %angulo = angulo + 180
    
    % cjon = (cj - size(I1,2)/2);
    % cion = (ci - size(I1,1)/2);    
    % cjo = (cjon*cosd(angulo) - cion*sind(angulo)) + size(I1,2)/2 + xcl;
    % cio = (cjon*sind(angulo) + cion*cosd(angulo)) + size(I1,1)/2 + ycl;

    cjo = cj + xcle;
    cio = ci + ycle;

    center_fitr = [cjo, cio];
    leftpt = center_fitr + cl*[cosd(angulo) sind(angulo)];
    rightpt = center_fitr - (bl-cl)*[cosd(angulo) sind(angulo)];
    angle_out = angulo + 90;
end

    
%get equation of the line uniting the centroid and extreme points
% coefficients = polyfit([lrd(1)+xcl, cc(1)+xcl], [lrd(2)+ycl, cc(2)+ycl], 1);
% ricardo change in 23/04/2020
coefficients = polyfit([leftpt(1), rightpt(1)], [leftpt(2), rightpt(2)], 1);
m = coefficients(1);
b = coefficients(2);


% threshold a definir
% se extremo frontal muito para a frente -> aumentar
% se muito para "dentro" da mosca -> baixar
threshold = p.FrontBodyThreshold;
If = filter2(ones(7,7), I)/49;

try_pts_front = [];
try_pts_back = [];


it = 0;
origptx = round(leftpt(2));
origpty = round(leftpt(1));

if origpty <= size(If,2) & origptx <= size(If,1) & origpty > 0 & origptx > 0

    orig_val = If(origptx, origpty);



    if(orig_val > threshold)  % MUDEI ISTO 
         direction = 1;
    else 
         direction = -1;
    end

    max_iters = 60;
    newleftpt = leftpt;

    while it < max_iters    
        xitnr = leftpt(1) + direction*it/6;
        yitnr = xitnr*m + b;

        %ricardo change
        %yit = round(xit*m + b);
        xit = round(leftpt(1) + direction*it/6);
        yit = round((leftpt(1) + direction*it/6)*m + b);

        try_pts_front = [try_pts_front; xitnr yitnr];

        if(xit > size(I,2))
            break;
        end
        if(yit > size(I,1))
            break;
        end

        if(yit > 0 & xit > 0 & yit < size(If, 1) & xit < size(If,2))
            val = If(yit, xit);
        else
            break;
        end

        %disp(['x:' num2str(xit) ' y:' num2str(yit) ' Val: ' num2str(val) ]);

        if direction > 0
            newleftpt = [xitnr yitnr];
            if (val < threshold)
                break;
            end
        else 
            newleftpt = [xitnr yitnr];
            if (val > threshold)
                break;
            end  
        end            

        it = it + 1;
    end

    leftpt = newleftpt;
    rightpt = leftpt + bl*[cosd(angle_out+90) sind(angle_out+90)];
end
   
centerpt = leftpt + cl*[cosd(angle_out+90) sind(angle_out+90)];

ellipseData.y = (leftpt(2)+rightpt(2))/2;
ellipseData.x = (leftpt(1)+rightpt(1))/2;
ellipseData.a = 0.5*abs(pdist([leftpt(2) leftpt(1); rightpt(2) rightpt(1)], 'euclidean'));
ellipseData.b = ellipseData.a/3.5;
ellipseData.angle = atand(-(rightpt(2) - leftpt(2))/(rightpt(1) - leftpt(1)));%-ang_radon+90;


% rad_extras.try_pts_front = try_pts_front;
% rad_extras.try_pts_back = try_pts_back;
% 
% disp(['Final points: Front:' num2str(leftpt) ' Center:'  num2str(centerpt) ' Back:' num2str(rightpt) ])
% final_rec_dist = abs(pdist([leftpt; rightpt]));
% final_center_dist = abs(pdist([leftpt; centerpt]));

disp(['[AUTO][' num2str(FrameNumber) ' Estimating positions: Ang fit_elip: ' num2str(angle_out-90) ' Ellipse: ' num2str(ellipseData.angle) ]);
%disp(['Center: ' num2str(centerpt(1)) ' ' num2str(centerpt(2))]);

flyPoints = [leftpt(2) leftpt(1) rightpt(2) rightpt(1) centerpt(2) centerpt(1)];
end