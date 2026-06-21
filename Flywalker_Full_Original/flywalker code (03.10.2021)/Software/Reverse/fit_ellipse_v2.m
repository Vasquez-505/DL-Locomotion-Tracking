function [I2,acumi,acumci,acumcj] = fit_ellipse_v2(I,c,h,m),
  % c - comprimento horizontal do retangulo = 2*c+1
  % h - altura do retangulo = 2*h+1
  
  ac=zeros(size(I,1),size(I,2));
  acum = -99999;

% ##  centroi=round(size(I,1)/2);
% ##  centroj=round(size(I,2)/2);
% ##  mask=zeros(size(I,1),size(I,2));
% ##  for i=1:size(mask,1)
% ##    for j=1:size(mask,2)
% ##      if ((i-centroi)^2/(h^2))+((j-centroj)^2/(c^2))<=1,
% ##        mask(i,j)=1;
% ##      end
% ##    end
% ##  end
% ##
% ##  m = zeros(size(mask,1),size(mask,2),180);
% ##
% ##for i=1:180,
% ##    m(:,:,i)=imrotate(mask,-i,'bilinear','crop');
% ##end

  
    
  for i=1:180,
    %I1=imrotate(I,i,'bilinear','crop');
    aux = conv2(I,m(:,:,i),'same');
    [ma,ci]=max(aux);
    [ac,cj]=max(ma);
    ci=ci(cj);
    if ac > acum,
     acum = ac;
     acumci = ci;
     acumcj = cj;
     acumi = i;
     end
  end

% ##  for i=1:4:180,
% ##    I1=imrotate(I,i,'bilinear','crop');
% ##    for ci=h+1:2:size(I,1)-h,
% ##      I11=shift(I1,centroi-ci);
% ##      for cj=c+1:2:size(I,2)-c,
% ##        I12=shift(I11',centroj-cj)';   
% ##        ac = sum(sum(I12.*mask));
% ##        if ac > acum,
% ##          acum = ac;
% ##          acumci = ci;
% ##          acumcj = cj;
% ##          acumi = i;
% ##        end
% ##      end
% ##    end
% ##  end
 

I2=I;
 
%  figure; imagesc(I);
%  hold on;
%  plot(acumcj, acumci, 'wx', 'LineWidth',2.3, 'MarkerSize', 8.0);
%  pause(5);

% I1=imrotate(I,acumi,'bilinear','crop');
 % I1=I(acumci-h:acumci+h,acumcj-c:acumcj+c);
 % I2=imrotate(I1,acumi,'bilinear','crop');
  
  return