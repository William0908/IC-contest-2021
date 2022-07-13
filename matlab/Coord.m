clc;clear;

x0 = 503;
y0 = 521;
x = [302, 10, 43, 694, 694];
y = [423, 664, 1003, 1023, 768];

for i = 1:5
  x(i,1) = x0;
  y(i,1) = y0;
  x(i,2) = x(i);
  y(i,2) = y(i);
  plot(x(i,:),y(i,:));
  hold on
end
hold off

