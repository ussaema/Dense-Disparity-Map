%% --- Internal Function
function write(varargin)
global Myhandles

str = sprintf(varargin{:});
disp(str);
if isempty(Myhandles); return; end;
h=Myhandles.console;
if ~ishandle(h); return;end
currString= get(Myhandles.console,'String');
currString = [ { str }; currString ];
set(Myhandles.console, 'Value', length(currString)); set(Myhandles.console,'String',currString ); 

end