function varargout = start_gui(varargin)
clearvars -except varargin
addpath('./functions');
%% --- Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @start_gui_OpeningFcn, ...
                       'gui_OutputFcn',  @start_gui_OutputFcn, ...
                       'gui_LayoutFcn',  [], ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
       gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
% End initialization code - DO NOT EDIT

%% --- plot stereo images
function plot_stereo_images(handles)
    global stereo_images
    axes(handles.stereo_images);
    cla reset;
    if (get(handles.red_cyan_stereo_radiobutton, 'Value'))
        imshowpair(uint8(stereo_images{1}),uint8(stereo_images{2}),'ColorChannels','red-cyan');
    elseif (get(handles.color_stereo_radiobutton, 'Value'))
        image(uint8(stereo_images{1}))
        hold on;
        h = image(uint8(stereo_images{2}));
        set(h, 'AlphaData', 0.5)
        hold off;
    end
%     if (~isstring(cmapStereo))
%         colorbar;
%     end
    axis image;
    set(gca,'xtick',[])
    set(gca,'ytick',[])

%% --- plot disparity map
function plot_disparity_map(handles, hObject)
    global dispmap;
    global cmapDisparity;
    global stereo_images;
    global scene_path;
    axes(handles.disparity_map);
    cla reset;
    if (get(handles.bw_dp_radiobutton, 'Value'))
        rotate3d(handles.disparity_map,'off')
        image(dispmap);
        colormap(gray(256));
        colorbar
    elseif (get(handles.color_dp_radiobutton, 'Value'))
        rotate3d(handles.disparity_map,'off')
        image(dispmap);
        colormap(jet(256));
        colorbar
    elseif (get(handles.three_dp_radiobutton, 'Value'))
        rotate3d(handles.disparity_map,'on');
        filePattern = fullfile(scene_path, '*calib.txt');
        txtFiles = dir(filePattern);
        if isempty(txtFiles)
            write('Error: No calib.txt files in directory found./n')
            write('Continuing without 3D plot')
        else
            baseFileName = txtFiles.name;
            fullFileName = fullfile(scene_path, baseFileName);
            write('Now reading %s\n', fullFileName);
            data = importdata(fullFileName);
            for i = 1:size(data,1)
                eval(data{i});
            end
            reconstruct3d(dispmap,cam0(1),baseline,doffs,cam0,stereo_images{1})
        end
        % rotate3d(handles.disparity_map,'on')
        % left_im = stereo_images{1};
        % left_im_gray = rgb_to_gray(left_im);
        % [xx,yy]=meshgrid(1:size(left_im_gray,2),1:size(left_im_gray,1));
        % surf(xx,yy,dispmap,im2double(left_im));
        % shading interp
    end
    
    axis image;
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    
%% --- initialize plot stereo images
function init_plot_stereo_images(handles)
    %call axis
    axes(handles.stereo_images);
    % setup
    cla reset;
    axis image;
    set(gca,'xtick',[])
    set(gca,'ytick',[])

%% --- initialize plot disparity map
function init_plot_disparity_map(handles)
    %call axis
    axes(handles.disparity_map);
    % setup
    cla reset;
    axis image;
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    
%%  --- plot stereo images buttons
function update_stereo_buttons(handles, color, red_cyan)
    if color
        set(handles.red_cyan_stereo_radiobutton, 'Value', 0);
    end
    if red_cyan
        set(handles.color_stereo_radiobutton, 'Value', 0);
    end
    if ~color && ~red_cyan
    end
    
%%  --- plot stereo disparity map
function update_disparity_buttons(handles, bw, color, threeD)
    if bw
        set(handles.color_dp_radiobutton, 'Value', 0);
        set(handles.three_dp_radiobutton, 'Value', 0);
    end
    if color
        set(handles.bw_dp_radiobutton, 'Value', 0);
        set(handles.three_dp_radiobutton, 'Value', 0);
    end
    if threeD
        set(handles.bw_dp_radiobutton, 'Value', 0);
        set(handles.color_dp_radiobutton, 'Value', 0);
    end

%% --- Executes just before start_gui is made visible.
function start_gui_OpeningFcn(hObject, eventdata, handles, varargin)
    
    % Choose default command line output for start_gui
    handles.output = hObject;
    %set waitbar axis
    h=handles.axis_waitbar;
    axes(h)
    axis off;
    % set the default type of the map (buttons)
    update_stereo_buttons(handles, true, false);
    update_disparity_buttons(handles, true, false, false);
    %initialize disparity map and stereo images axis
    init_plot_stereo_images(handles);
    init_plot_disparity_map(handles);
    % Update handles structure
    guidata(hObject, handles);
    %create global handles
    global Myhandles;
    Myhandles = handles;
    % stereo images in workspace ? display them in GUI
    global stereo_images;
    if ~isempty(stereo_images)
        plot_stereo_images(handles)
    end
    % disparity map in workspace ? display it in GUI
    global dispmap;
    if ~isempty(dispmap)
        plot_disparity_map(handles)
    end

%% --- Outputs from this function are returned to the command line.
function varargout = start_gui_OutputFcn(hObject, eventdata, handles)
    varargout{1} = handles.output;
    guidata(hObject, handles);

%% --- Executes on button press in Load folder
function OpenFolder_Callback(hObject, eventdata, handles)
    try
        % load images from folder
        global scene_path;
        scene_path = uigetdir(path, 'Stereo images folder');
        data = guidata(hObject);
        data.scene_path = scene_path;
        guidata(hObject,data);
        myFolder = scene_path;
        if ~isfolder(myFolder)
            error('Error: The following folder does not exist:\n%s', myFolder);
        end
        filePattern = fullfile(myFolder, '*.png');
        pngFiles = dir(filePattern);
        if length(pngFiles) ~= 2
            error('Error: Number of .png files in directory must be exactly 2.');
        end
        I = cell(2,1);
        Names = cell(2,1);
        for k = 1 : 2
            baseFileName = pngFiles(k).name;
            fullFileName = fullfile(myFolder, baseFileName);
            [~, filename, file_extension] = fileparts(fullFileName);
            write('now reading %s', fullFileName);
            Names{k} = fullFileName;
            I{k} = imread(fullFileName);
            data = guidata(hObject);
            guidata(hObject,data);
        end
        global stereo_images
        stereo_images = I;
        % display stereo images on GUI
        plot_stereo_images(handles)
        % update title text of the console
        set(handles.msg_uipanel,'Title','Ready to compute the disparity map!');
    catch errorObj
        errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
    end

%% --- Executes on button press in disparity map
function makeMap_Callback(hObject, eventdata, handles)
    data = guidata(hObject);
    % start timer
    tic();
     try
        % open scene path
        data.scene_path
        % record starting time
        handles.t0=clock;
        % make handles global
        global Myhandles;
        Myhandles = handles;
        
   
        % make dispmap global
        global dispmap
        % read parameters from GUI
        contents_preprocess = get(handles.par_preprocess,'String'); 
        contents_postprocess = get(handles.par_postprocess,'String');
        % compute disparity map, R and T
        [dispmap, R, T] = disparity_map(data.scene_path,...
            'blockSize', str2num(get(handles.par_seg_len,'String')), 'median_length',str2num(get(handles.par_med_len,'String')),'tauUnique',str2num(get(handles.par_tau_unique,'String')),...
            'tauDist',str2num(get(handles.par_tau_dist,'String')),'occlusionFill',(get(handles.occlusionFill,'Value') == 1), 'noiseFilter', (get(handles.noiseFilter,'Value') == 1), 'preprocess',string(contents_preprocess{get(handles.par_preprocess,'Value')}), 'postprocess', string(contents_postprocess{get(handles.par_postprocess,'Value')}), 'customMaxWidth', str2num(get(handles.par_custom_max_width,'String')), 'disparityInterval', str2num(get(handles.par_disparity_interval,'String')), 'do_plot', false);
        % display R and T on GUI
        R
        T
        R(abs(R)<1e-3)=0;
        T(abs(T)<1e-3)=0;
        set(handles.rotation_table,'data',round(R,2,'significant'));
        set(handles.translation_table,'data',round(T,2,'significant'));
        % plot disparity map
        plot_disparity_map(handles);
        % compute PSNR
        myFolder = data.scene_path;
        filePattern = fullfile(myFolder, '*.pfm');
        pngFiles = dir(filePattern);
        if length(pngFiles) ~= 1
            write('.pfm does not exist in directory. No PSNR value will be computed.');
            set(handles.psnr,'String',"no .pfm (GT) found");
        else
            baseFileName = pngFiles(1).name;
            fullFileName = fullfile(myFolder, baseFileName);
            psnr = verify_dmap(dispmap,readpfm(fullFileName));
            set(handles.psnr,'String',psnr);
        end
    catch errorObj
        errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
    end
    % elapsed time
    elapsed = toc();
    set(handles.runningtime,'string',num2str(elapsed));
    



% --- Executes on button press in bw_dp_radiobutton.
function bw_dp_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to bw_dp_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bw_dp_radiobutton
update_disparity_buttons(handles, true, false, false);
plot_disparity_map(handles);

% --- Executes on button press in color_dp_radiobutton.
function color_dp_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to color_dp_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of color_dp_radiobutton
update_disparity_buttons(handles, false, true, false);
plot_disparity_map(handles);

% --- Executes on button press in three_dp_radiobutton.
function three_dp_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to three_dp_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of three_dp_radiobutton
update_disparity_buttons(handles, false, false, true);
plot_disparity_map(handles);


% --- Executes on button press in color_stereo_radiobutton.
function color_stereo_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to color_stereo_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of color_stereo_radiobutton
update_stereo_buttons(handles, true, false);
plot_stereo_images(handles);

% --- Executes on button press in red_cyan_stereo_radiobutton.
function red_cyan_stereo_radiobutton_Callback(hObject, eventdata, handles)
% hObject    handle to red_cyan_stereo_radiobutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of red_cyan_stereo_radiobutton
update_stereo_buttons(handles, false, true);
plot_stereo_images(handles);


function console_Callback(hObject, eventdata, handles)
% hObject    handle to console (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of console as text
%        str2double(get(hObject,'String')) returns contents of console as a double


% --- Executes during object creation, after setting all properties.
function console_CreateFcn(hObject, eventdata, handles)
% hObject    handle to console (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in OpenFolder.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to OpenFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in makeMap.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to makeMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function runningtime_Callback(hObject, eventdata, handles)
% hObject    handle to runningtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of runningtime as text
%        str2double(get(hObject,'String')) returns contents of runningtime as a double


% --- Executes during object creation, after setting all properties.
function runningtime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to runningtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function psnr_Callback(hObject, eventdata, handles)
% hObject    handle to psnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of psnr as text
%        str2double(get(hObject,'String')) returns contents of psnr as a double


% --- Executes during object creation, after setting all properties.
function psnr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to psnr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function par_seg_len_Callback(hObject, eventdata, handles)
% hObject    handle to par_seg_len (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of par_seg_len as text
%        str2double(get(hObject,'String')) returns contents of par_seg_len as a double


% --- Executes during object creation, after setting all properties.
function par_seg_len_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_seg_len (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function par_med_len_Callback(hObject, eventdata, handles)
% hObject    handle to par_med_len (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of par_med_len as text
%        str2double(get(hObject,'String')) returns contents of par_med_len as a double


% --- Executes during object creation, after setting all properties.
function par_med_len_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_med_len (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function par_tau_unique_Callback(hObject, eventdata, handles)
% hObject    handle to par_tau_unique (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of par_tau_unique as text
%        str2double(get(hObject,'String')) returns contents of par_tau_unique as a double


% --- Executes during object creation, after setting all properties.
function par_tau_unique_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_tau_unique (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function par_tau_dist_Callback(hObject, eventdata, handles)
% hObject    handle to par_tau_dist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of par_tau_dist as text
%        str2double(get(hObject,'String')) returns contents of par_tau_dist as a double


% --- Executes during object creation, after setting all properties.
function par_tau_dist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_tau_dist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in par_smoothing.
function par_smoothing_Callback(hObject, eventdata, handles)
% hObject    handle to par_smoothing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns par_smoothing contents as cell array
%        contents{get(hObject,'Value')} returns selected item from par_smoothing


% --- Executes during object creation, after setting all properties.
function par_smoothing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_smoothing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in par_preprocess.
function par_preprocess_Callback(hObject, eventdata, handles)
% hObject    handle to par_preprocess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns par_preprocess contents as cell array
%        contents{get(hObject,'Value')} returns selected item from par_preprocess


% --- Executes during object creation, after setting all properties.
function par_preprocess_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_preprocess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in par_postprocess.
function par_postprocess_Callback(hObject, eventdata, handles)
% hObject    handle to par_postprocess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns par_postprocess contents as cell array
%        contents{get(hObject,'Value')} returns selected item from par_postprocess


% --- Executes during object creation, after setting all properties.
function par_postprocess_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_postprocess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function par_custom_max_width_Callback(hObject, eventdata, handles)
% hObject    handle to par_custom_max_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of par_custom_max_width as text
%        str2double(get(hObject,'String')) returns contents of par_custom_max_width as a double


% --- Executes during object creation, after setting all properties.
function par_custom_max_width_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_custom_max_width (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function par_disparity_interval_Callback(hObject, eventdata, handles)
% hObject    handle to par_disparity_interval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of par_disparity_interval as text
%        str2double(get(hObject,'String')) returns contents of par_disparity_interval as a double


% --- Executes during object creation, after setting all properties.
function par_disparity_interval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to par_disparity_interval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in occlusionFill.
function occlusionFill_Callback(hObject, eventdata, handles)
% hObject    handle to occlusionFill (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of occlusionFill


% --- Executes on button press in noiseFilter.
function noiseFilter_Callback(hObject, eventdata, handles)
% hObject    handle to noiseFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of noiseFilter
