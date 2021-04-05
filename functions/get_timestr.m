function timestr= get_timestr(s) 
% Return a time string, given seconds.

h = floor(s/3600);					% Hours.
s = s - h*3600;
m = floor(s/60);						% Minutes.
s = s - m*60;							% Seconds.
timestr = sprintf('%0d:%02d:%02d', h, m, floor(s));