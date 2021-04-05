%% --- Internal Function
function update_waitbar(value,output)
global Myhandles;
handles = Myhandles;
if isempty(handles); return; end;
% Update waitbar
h=handles.axis_waitbar;
if ~ishandle(h);return;end;
set(h,'Visible','On');
%set(h,'Outerposition',[-13.832, -3.368, 212.56, 7.495]);
axes(h);
cla;
patch([0,value,value,0],[0,0,1,1],'b');
axis([0,1,0,1]);
axis off;
%% Other information
set(handles.percent_text,'String',strcat(num2str(floor(value*100)),'%'));
time_lapse = etime(clock,handles.t0);
if value~=0
    time_eta=(time_lapse/value)*(1-value);
else return; end;
time_lapse = round(time_lapse);
time_eta=round(time_eta);
str_lapse= get_timestr(time_lapse);
str_eta= get_timestr(time_eta);
set(handles.elapsObj,'String',['Elapsed Time: ' str_lapse]);
set(handles.etaObj,'String',['Estimated Time Remaining: ' str_eta]);
set(handles.jobObj,'String',['Started: ' datestr(handles.t0)]);
set(handles.msg_uipanel,'Title',output);
drawnow;