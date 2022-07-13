clc;clear;

x0 = 321;
y0 = 870;
x = [567, 1010, 970, 432, 321];
y = [1003, 643, 280, 123, 127];
r = [724, 786, 561, 334, 230, 333];

AreaFence = zeros(1,4);
SumFence = 0;
AreaR = zeros(1,6);
SumR = 0;
sr = zeros(1,6);
is_inside = 0;
for i = 1:5
  vecx(i) = x(i) - x0;
  vecy(i) = y(i) - y0;
  len(i) = (vecx(i)^2 + vecy(i)^2)^0.5;
end
for i = 1:4
  xs(i) = x(i + 1) - x(i);
  ys(i) = y(i + 1) - y(i);
  side(i) = (xs(i)^2 + ys(i)^2)^0.5;
  s(i) = (len(i) + len(i + 1) + side(i))/2;
  s1(i) = s(i) - len(i);
  s2(i) = s(i) - len(i + 1);
  s3(i) = s(i) - side(i);
  AreaFence(i) = (s(i)*(s(i) - len(i))*(s(i) - len(i + 1))*(s(i) - side(i)))^0.5;
  SumFence = SumFence + AreaFence(i); 
end
sr(1,1) = len(1) + r(1) + r(2);
sr(1,2) = side(1) + r(2) + r(3);
sr(1,3) = side(2) + r(3) + r(4);
sr(1,4) = side(3) + r(4) + r(5);
sr(1,5) = side(4) + r(5) + r(6);
sr(1,6) = len(5) + r(6) + r(1);

sr(1,:) = sr(1,:)/2;
for i = 1:6
   sr2(i) = sr(i) - r(i);
   if i == 6
       sr1(i) = sr(i) - len(5);
       sr3(i) = sr(i) - r(1);
   elseif i == 1
       sr1(i) = sr(i) - len(1);
       sr3(i) = sr(i) - r(i + 1);
   else 
       sr3(i) = sr(i) - r(i + 1);
       sr1(i) = sr(i) - side(i - 1);
   end
       AreaR(i) = (sr(i) * sr1(i) * sr2(i) * sr3(i))^0.5;
       SumR = SumR + AreaR(i);
end

% disp("VectorLength: ");
% disp(len);
% disp("Side: ");
% disp(side);
disp("Fence: ");
disp(SumFence);
disp("R: ");
disp(SumR);
% disp(AreaFence);
% disp(AreaR);
disp("Is_side: ")
if SumFence > SumR
    is_inside = 1;
    disp("Yes");
else
    is_inside = 0;
    disp("No");
end



