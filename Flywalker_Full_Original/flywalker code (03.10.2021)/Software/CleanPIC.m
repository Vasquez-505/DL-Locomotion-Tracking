function OutputPic = CleanPIC(PIC, MinSize)

    % find connected parts on image
      CC = bwconncomp(PIC);

    % determine number of pixels in each group  
      numPixels = cellfun(@numel,CC.PixelIdxList);

    % erase objects whose size is smaller than body threshold
      ind = find(numPixels < MinSize);
      for k = ind
        PIC(CC.PixelIdxList{k}) = 0;
      end;

    % delineate (make things thicker)
      se90 = strel('line', 3, 90);
      se0 = strel('line', 3, 0);
      PIC = imdilate(PIC, [se90 se0]);

    % fill interior gaps
      PIC = imfill(PIC, 'holes');

    % smooth object
      seD = strel('diamond',1);
      OutputPic = imerode(PIC,seD);

return;
