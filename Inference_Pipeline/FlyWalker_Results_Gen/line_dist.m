function distance = line_dist(x1,y1,x2,y2,x0,y0)
% Distance from point (x0,y0) to line passing through (x1,y1) and (x2,y2)

distance = abs((y2-y1)*x0-(x2-x1)*y0+x2*y1-y2*x1)/sqrt((y2-y1)^2+(x2-x1)^2);

end