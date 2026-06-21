function [Itres] = computeNewBackground(v,p)

% Novo algoritmo background
Itres = [];


if 1
    total_fs = length(p.FileList); 
    %figure;
    %set(gcf,'color','k');

    % 1- GET ALL IMAGES
    Itres = [];
    Itraw = [];
    Itfilt = [];
    Itlab = [];
    all_medians = [];
    
    for FN = 1:total_fs
        [vaux.pic, vaux.rawpic, vaux.nopic] = PictureReader_02(FN, p);
       
        aux_raw = vaux.pic.R;
                
        Itraw(:,:,FN) = aux_raw;    
        rawf = filter2(ones(2,2), aux_raw)/4;
        Itfilt(:,:,FN) = rawf;    
        ot = -20+(otsuthresh(imhist(rawf/255)))*255;
        Itlab(:,:, FN) = bwlabel(rawf > ot); 
        
        all_medians(FN) = median(aux_raw(:));
        
        %imagesc(Itraw(:,:,FN));
        %disp(["image " num2str(FN)]);
        %k = waitforbuttonpress;

    end

    % 2 - GET THE BLOBS IN THE FIRST IMAGE AND THEIR INTENSITY
    
    Ilab1 = Itlab(:,:,1);
    total_labels = numel(unique(Ilab1(:)));
    pxs_per_lab = sum(Ilab1(:) == 1:total_labels);
    blobs_to_track = find(pxs_per_lab > 0 & pxs_per_lab < 400);
    blobs1_xy = [];
    avgs_per_blob = zeros(total_fs-1, numel(blobs_to_track));

    margin = 2; % a smaller margin might catch more blobs
   
    avg_intensities = [];
    for lb = 1:numel(blobs_to_track)
        [r,c] = find(Ilab1 == blobs_to_track(lb));
        crop_x = min(r)-margin:max(r)+margin;
        crop_y = min(c)-margin:max(c)+margin;

        crop_x = crop_x(crop_x > 0 & crop_x < size(Ilab1,1));
        crop_y = crop_y(crop_y > 0 & crop_y < size(Ilab1,2));    

        % save the positions of the center blobs
        blobs1_xy = [blobs1_xy; (max(r)+min(r))/2 (max(c)+min(c))/2];

        Ismall = Itfilt(crop_x, crop_y, 1);        
        avg_intensities(lb) = mean(Ismall(:));
    end  

    % 3 - FIND IF THE INTENSITIES OF THE BLOBS IN THE FIRST IMAGE; CHANGE
    % MUCH THROUGHOUT THE VIDEO
    
    
    %try to finbd the bw points
    % possibility: use random frames
    %randframes = randi([1, total_fs], 1,130);    
    %for FN = randframes
    for FN = 2:total_fs
        blobs_xy = [];
        for lb = 1:numel(blobs_to_track)
            [r,c] = find(Itlab(:,:,1) == blobs_to_track(lb));
            crop_x = min(r)-margin:max(r)+margin;
            crop_y = min(c)-margin:max(c)+margin;
            crop_x = crop_x(crop_x > 0 & crop_x < size(Itlab(:,:,FN),1));
            crop_y = crop_y(crop_y > 0 & crop_y < size(Itlab(:,:,FN),2));    

            blobs_xy = [blobs_xy; (max(r)+min(r))/2 (max(c)+min(c))/2];               
            Ismall = Itfilt(crop_x, crop_y, FN);        
            avgs_per_blob(FN,lb) = mean(Ismall(:));  
        end  
    end

    % increase to remove more blobs
    max_diff = 7;
    %susp_blobs_ind = find(abs(avg_intensities - mean(avgs_per_blob)) < max_diff);
    susp_blobs_ind = find(sum(abs(avgs_per_blob - avgs_per_blob) < max_diff) > total_fs/6);
    
    bg_labels = blobs_to_track(susp_blobs_ind);
    blobs_bg_xy = blobs1_xy(susp_blobs_ind, :);

   
    %imagesc(Itraw(:,:,1));
    %figure;
    %set(gcf,'color','k');

    FN = 2;
    margin_big = 6;
    margin_small = 3;
    while FN  < total_fs    
        % we will edit this ahead
        raw_clone = Itraw(:,:,FN);

        %IFNlab = Itlab(:,:,FN);
        
        for lb = 1:numel(bg_labels)
            [r,c] = find(Ilab1 == bg_labels(lb));
            crop_x = min(r)-margin_big:max(r)+margin_big;
            crop_y = min(c)-margin_big:max(c)+margin_big;
            crop_x = crop_x(crop_x > 0 & crop_x < size(Ilab1,1));
            crop_y = crop_y(crop_y > 0 & crop_y < size(Ilab1,2));    
           
            Ismall = Itfilt(crop_x, crop_y, FN);  
            
            small_crop_x = min(r)-margin_small:max(r)+margin_small;
            small_crop_y = min(c)-margin_small:max(c)+margin_small;
            small_crop_x = small_crop_x(small_crop_x > 0 & small_crop_x < size(Ilab1,1));
            small_crop_y = small_crop_y(small_crop_y > 0 & small_crop_y < size(Ilab1,2));    
           
            p50 = mean(all_medians); std50 = std(p50)/2;
            values = mean(p50) + std50*randn(numel(small_crop_x), numel(small_crop_y));
            raw_clone(small_crop_x, small_crop_y) = values;               

        end
        
        %raw_clone = min(255,max(0,raw_clone));        
        Itres(:,:,FN) = raw_clone;

        
        plotandwait = 0;
        disp(['Removing background: ' num2str(FN)]);

        if plotandwait
            disp(['FrameNumber: ' num2str(FN)]);
            imagesc([Itraw(:,:,FN) zeros(size(raw_clone,1),5) raw_clone]);        
            hold on; plot(blobs_bg_xy(:,2), blobs_bg_xy(:,1), 'yo', 'MarkerSize',18);
            hold off;
            title(['FrameNumber: ' num2str(FN)]);

            k = waitforbuttonpress;
            value = double(get(gcf,'CurrentCharacter'));
            if value == 28 & FN > 1
                FN = FN - 1;
            elseif value == 29
                FN = FN + 1;
            end
        end
        
        FN = FN + 1;
    end
end



