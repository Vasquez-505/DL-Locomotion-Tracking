function pic = FilterImage(v,p)
% filters image with masks defined in Masks(p)

% % identify background and make frame 0 there
% %   % remove background symmetrically around the average
% %       indR = find(abs(v.pic.R - v.picAVG.R) < p.BGoffset.R + p.BGoffset.sigma*v.picSTD.R);
% %       indG = find(abs(v.pic.G - v.picAVG.G) < p.BGoffset.G + p.BGoffset.sigma*v.picSTD.G);
% %       indB = find(abs(v.pic.B - v.picAVG.B) < p.BGoffset.B + p.BGoffset.sigma*v.picSTD.B);
%   % remove backround just below the average
%     indR = find(v.pic.R - v.picAVG.R - p.BGoffset.sigma*v.picSTD.R - p.BGoffset.R <= 0);
%     indG = find(v.pic.G - v.picAVG.G - p.BGoffset.sigma*v.picSTD.G - p.BGoffset.G <= 0);
%     indB = find(v.pic.B - v.picAVG.B - p.BGoffset.sigma*v.picSTD.B - p.BGoffset.B <= 0);
%   
%   pic = v.pic;
%   pic.R(indR) = 0;
%   pic.R(indG) = 0;
%   pic.R(indB) = 0;
%   pic.G(indR) = 0;
%   pic.G(indG) = 0;
%   pic.G(indB) = 0;
%   pic.B(indR) = 0;
%   pic.B(indG) = 0;
%   pic.B(indB) = 0;
% % subtract mask
%   ind = find(v.DPM > 0);
%   pic.R(ind) = 0;
%   pic.G(ind) = 0;
%   pic.B(ind) = 0;
% 
% % put pic between constraints
%   pic.R = min(255,max(0,pic.R));
%   pic.G = min(255,max(0,pic.G));
%   pic.B = min(255,max(0,pic.B));

  
% old subtraction
    % subtract masks
    %   pic = v.pic - v.picAVG - 2*v.picSTD - v.DPM;
      pic.R = v.pic.R - v.picAVG.R - 2*v.picSTD.R - v.DPM;
      pic.G = v.pic.G - v.picAVG.G - 2*v.picSTD.G - v.DPM;
      pic.B = v.pic.B - v.picAVG.B - 2*v.picSTD.B - v.DPM;

    % put pic between constraints
    %   pic = min(255,max(0,pic));
      pic.R = min(255,max(0,pic.R));
      pic.G = min(255,max(0,pic.G));
      pic.B = min(255,max(0,pic.B));
  
  
return;