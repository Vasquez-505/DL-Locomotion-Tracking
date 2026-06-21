function MultiDeeepLearning(root_dir)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function MultiDeepLearning(root_dir)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Performs deep learning evaluation for a series of input videos, listed in
% root_dir
% Reverse
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INPUT:
%    root_dir - dir containing all the videos
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

files = dir(root_dir);
dirFlags = [files.isdir];
subFoldersRaw = files(dirFlags);
subFolders = [];

% generate table data
tcols = ["Video" "GPU" "Res Exists" "Progress" "Time" "Success" "Status"];
tarr = [];

canUseGPU = false;
gpu_support_label = "No";

try
    canUseGPU = parallel.gpu.GPUDevice.isAvailable;
    gpu_support_label = "Yes";
catch ME
    canUseGPU = false;
    gpu_support_label = "No";

end
         

for i = 1:numel(subFoldersRaw)    
    video_dir = subFoldersRaw(i).name;
    if video_dir ~= "." & video_dir ~= ".."
        subFolders = [subFolders string(video_dir)];
        full_video_dir = [root_dir filesep video_dir];    
        % check to see if dl_postions file exists
        dl_positions_file = [full_video_dir filesep 'Results' filesep 'dl_positions.txt'];    
        if isfile(dl_positions_file)        
            tarr = [tarr; video_dir gpu_support_label "Yes" "0%" "?" "-" "Waiting"];
        else
            tarr = [tarr; video_dir gpu_support_label "No" "0%" "?" "-" "Waiting"];
        end
    end
end

disp(["Starting Multi Deep Learning Evaluation..."]);
disp(["Launching data table..."]);

fig = uifigure;
fig.Position = [34 142 1114 520];
refresh;
drawnow;

tdata = array2table(tarr, 'VariableNames', tcols);
uit = uitable(fig,'Data', tdata, 'FontSize',18);
uit.Position = [50 50 1014 470];
%set(fig,'color','k');
refresh(fig);

disp(["Starting deep learning prediction engine..."]);
disp(["Please wait..."]);
drawnow;

load detector_13maimatlab.mat

if canUseGPU
    disp("Predicting on GPU.");
else
    disp("GPU not found/incompatible. Predicting on CPU.");
end


for i = 1:numel(subFolders)  
    
    video_dir = subFolders(i);
    full_video_dir = [root_dir filesep video_dir];
    full_video_dir = strjoin(full_video_dir,'');
    % check to see if dl_postions file exists
    dl_positions_file = [full_video_dir filesep 'Results' filesep 'dl_positions.txt'];
    dl_positions_file = strjoin(dl_positions_file,'');
    if isfile(dl_positions_file)        
        tdata{i, 4} = "100%"; 
        tdata{i, 5} = "0 secs.";
        tdata{i, 6} = "Yes";
        tdata{i, 7} = "Skipping. dl_positions.txt file already exists.";
        set(uit, 'Data', tdata);
        continue
    end

    tdata{i, 7} = "Processing...";
    drawnow;

    dl_positions = [];
    disp(['Processing video: ' strjoin(full_video_dir,'') ]);
    
    if canUseGPU
        dl_positions = yoloFlyDetectionGPUMulti(full_video_dir, detector_aux, true, 5, false, 0, uit, tdata, i);             
    else
        dl_positions = yoloFlyDetectionMulti(full_video_dir, detector_aux, true, 5, false, 0, uit, tdata, i);             
    end
    drawnow;
    dl_positions = double(dl_positions);
    
    results_dir = [full_video_dir filesep 'Results'];
    results_dir = strjoin(results_dir,'');
    mk_dir_res = mkdir(results_dir);
    
    save(dl_positions_file, 'dl_positions', '-ascii');
    
    if isfile(dl_positions_file)
        tdata{i, 4} = "100%"; 
        tdata{i, 5} = "0 secs.";
        tdata{i, 6} = "Yes";
        tdata{i, 7} = "File dl_positions.txt generated with success.";
        drawnow;

    else
        tdata{i, 4} = "100%"; 
        tdata{i, 5} = "'0 secs.";
        tdata{i, 6} = "No";
        tdata{i, 7} = "Error saving dl_positions.txt file.";
    end
    drawnow;
end

drawnow;
disp(["Finished. Press ENTER to continue"]);
pause();
