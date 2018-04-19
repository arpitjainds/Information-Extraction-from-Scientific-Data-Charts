function varargout = tenacity(varargin)
% Tenacity M-file for tenacity.fig

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @tenacity_OpeningFcn, ...
                   'gui_OutputFcn',  @tenacity_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code


% --- Executes just before tenacity is made visible.
function tenacity_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for tenacity
handles.output = hObject;
handles.step=0;
handles.finish=0;
guidata(hObject, handles);
% Toolbar
    load('toolbar_icon');
    ut=uitoolbar(hObject);

    
    toolbar.open = uipushtool('cdata',       toolbar_icon.open_btn, ...
                                 'parent',          ut,...
                                 'clickedcallback', 'tenacity(''OpenMenuItem_Callback'',gcbo,[],guidata(gcbo))' ,...
                                 'tooltipstring',   'Open image');

    toolbar.save = uipushtool('cdata',       toolbar_icon.save, ...
                                 'parent',          ut,...
                                 'clickedcallback', 'tenacity(''SaveMenuItem_Callback'',gcbo,[],guidata(gcbo))' ,...
                                 'tooltipstring',   'Save curve');
    toolbar.debut = uipushtool('cdata',       toolbar_icon.forward_btn, ...
                                 'Enable',    'Off',... 
                                 'parent',          ut,...
                                 'clickedcallback', 'tenacity(''start_Callback'',gcbo,[],guidata(gcbo))' ,...
                                 'tooltipstring',   'beginning of reconstitution');
    toolbar.fin = uipushtool('cdata',       toolbar_icon.start_btn, ...
                                  'Enable',  'Off',...
                                 'parent',          ut,...
                                 'clickedcallback', 'tenacity(''finish_Callback'',gcbo,[],guidata(gcbo))' ,...
                                 'tooltipstring',   'build the curve');                               
% Initialisation of variables

handles.cut_hor=150;
handles.cut_ver=60;
handles.length_x=10;
handles.length_y=100;
handles.ladderx=[0 1];
handles.laddery=[0 1];
handles.ladderx_log=0;
handles.laddery_log=0;

handles.toolbar=toolbar;
handles.v=0;
set(handles.reconstitution,'Enable','Off');

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = tenacity_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,rep]=uigetfile({'*','All Files';'*.png','File png (*.png)';'*.jpg','File jpeg (*.jpg)';'*.tif','File Tiff (*.tif)';...
        '*.gif','File gif (*.gif)';'*.bmp','File bmp (*.bmp)'},'File name');

if isequal(file, 0)|isequal(rep,0)
   return;
end

file_dir(1,:)=cat(2,rep(1,:),file(1,:));        
set(gcf,'CurrentAxes',handles.axes1)
set(handles.text11,'Visible','Off')
set(handles.text12,'Visible','Off')
RGB=imread(file_dir);

%extraction of text using ocr
set(handles.text16,'Visible','On')
set(handles.text17,'Visible','On')
RGBocr=rgb2gray(RGB);
thresh = graythresh(RGBocr);
RGBocr = im2bw(RGBocr,thresh);
results=ocr(RGBocr);
set(handles.text16,'String',results.Text);

imshow(RGB);
set(handles.text14,'Visible','On')
zoom on;
I = rgb2gray(RGB);

threshold = graythresh(I);
% size of the image in pixels
handles.n=size(I,1);
handles.p=size(I,2);
% bw black and white image
bw = im2bw(I,threshold);
% complementary to the initial image
bw1=~bw;
handles.bw1=bw1;
Name=get(handles.figure1,'Name');
set(handles.figure1,'Name',[Name,' : ',file]);
set(handles.toolbar.debut,'Enable','On');
set(handles.reconstitution,'Enable','On');

% Update handles structure
guidata(hObject,handles);

% --------------------------------------------------------------------
function SaveMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to SaveMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Menu used to record the curve obtained after image processing
[filename, pathname] = uiputfile('*.txt', 'Save the curve');
% If the file is not good or if you want to cancel => return without error
% previous menu

if isequal(filename,0)|isequal(pathname,0)
    return
end
if (strfind(filename,'.txt')>=1)
  file_dir(1,:)=cat(2,pathname(1,:),filename(1,:));
 else
  file_dir(1,:)=cat(2,pathname(1,:),filename(1,:),'.txt');
 end 

 if isfield(handles,'v')
     v=handles.v
     naa=num2str(v);
     set(handles.text19,'Visible','On')
     set(handles.text18,'Visible','On')
     set(handles.text18,'String',naa);
     save(file_dir,'v','-ASCII','-tabs');
 else
     errordlg('No curve in memory ! ');
 end    
 
% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['    Close ' get(handles.figure1,'Name') '?'],...
                     ['  Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
 if strcmp(selection,'No')
    return;
 end

 delete(handles.figure1)

% Elimination of horizontal grids

% --------------------------------------------------------------------
function reset_Callback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Reset the graphical display
set(gcf,'CurrentAxes',handles.axes1)
cla;
set(gcf,'CurrentAxes',handles.axes3)
cla;
set(handles.text11,'Visible','On')
set(handles.text14,'Visible','Off')
set(handles.text15,'Visible','Off')
% Initialisation of variables
handles.cut_hor=150;
handles.cut_ver=60;
handles.length_x=10;
handles.length_y=100;
handles.ladderx=[0 1];
handles.laddery=[0 1];
handles.ladderx_log=0;
handles.laddery_log=0;
set(handles.figure1,'Name','tenacity');
set(handles.toolbar.fin,'Enable','Off');
set(handles.toolbar.debut,'Enable','Off');
set(handles.reconstitution,'Enable','Off');
set(handles.text16,'Visible','Off')
set(handles.text17,'Visible','Off')
set(handles.text19,'Visible','Off')
set(handles.text18,'Visible','Off')
set(handles.text12,'Visible','On')

handles.step=0;
% Update handles structure
guidata(hObject,handles);

% --------------------------------------------------------------------
function rms_Callback(hObject, eventdata, handles)
% hObject    handle to rms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Calculating the RMS value for a PSD
if size(handles.v,1)>1
	x=handles.v(:,1);
	y=handles.v(:,2);
	n=size(x,1);
	q=0;
	for k=1:n-1
        q=q+(y(k)+y(k+1))/2*(x(k+1)-x(k)); 
	end
	q=sqrt(q);
    str=['RMS Value = ',num2str(q)];
	warndlg(str);
else
    errordlg('No curve in memory !');
end    

% --------------------------------------------------------------------
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
   
% Starts image processing
	cut_objet_hor=handles.cut_hor;
	cut_objet_ver=handles.cut_ver;
	lengthx=handles.length_x;
	lengthy=handles.length_y;
    bw1=handles.bw1;
    question(1)=cellstr('Do you want to eliminate the horizontal grid ?');
    question(2)=cellstr(' ');
    question(3)=cellstr('WARNING : the elimination of the grid may cause a loss of information');
	buttonh = questdlg(char(question),'Horizontal grid','Yes');
	if strcmp(buttonh,'Yes')
        % we remove the horizontal grids
        bw3=imtophat(bw1,strel('line',lengthx,0));
		bw4=imdilate(bw3,[strel('line',2,90)]);
        bw5=bwareaopen(bw4,cut_objet_hor);
	else
		% we remove objects of less than pixel_object_blocks (dashes of the grids)
        bw4=bw1;
		bw5=bwareaopen(bw4,cut_objet_hor);
	end
    question(1)=cellstr('Do you want to eliminate the vertical grid ?');
    question(2)=cellstr(' ');
    question(3)=cellstr('WARNING : the elimination of the grid may cause a loss of information');
	buttonv = questdlg(char(question),'Vertical grid','Yes');
	if strcmp(buttonv,'Yes')
        % we remove the vertical grids
		bw21=imtophat(bw1,strel('line',lengthy,90));
		bw41=imdilate(bw21,[strel('line',2,0)]);
        bw51=bwareaopen(bw41,cut_objet_ver);
	else
        % objects less than pixel_object_size are removed (grid dashes)
        bw41=bw1;
		bw51=bwareaopen(bw41,cut_objet_hor);
	end
    % Addition of the two previous images
	bw6=bw5 & bw51;
	bw6=bwareaopen(bw6,max(cut_objet_hor,cut_objet_ver));
	clear('bw4','bw5','bw41','bw51');
	set(gcf,'CurrentAxes',handles.axes3)
	imshow(bw6)
    set(handles.text15,'Visible','On')
	zoom on;
	handles.bw6=bw6;
    handles.step=1;
    set(handles.toolbar.fin,'Enable','On');
    % Update handles structure
	guidata(hObject, handles);

% --------------------------------------------------------------------
function finish_Callback(hObject, eventdata, handles)
% hObject    handle to finish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
logx=handles.ladderx_log;
logy=handles.laddery_log;
ladderx=handles.ladderx;
laddery=handles.laddery;
p=handles.p;
n=handles.n;
bw6=handles.bw6;

% We search the 0 in the matrix bw6. They represent useful info
[j i]=find(flipud(bw6));
% Multiple occurrences of 0 per column are suppressed to keep
% that a point representing a priori the maximum of the curve at this point.
	[b,m,k] = unique(i);
	i=b;
	j=j(m);
% Treatment of scales  
		if logy==0 & logx==0
            i= i./p.*(ladderx(2)-ladderx(1));
            j=(j)./n.*(laddery(2)-laddery(1));
		elseif logy==1 & logx==1
            i= ladderx(1)*(ladderx(2)/ladderx(1)).^(i./p) ;
            j= laddery(1)*(laddery(2)/laddery(1)).^((j)./n);
		elseif logy==0 & logx==1
            i= ladderx(1)*(ladderx(2)/ladderx(1)).^(i./p);
            j=(j)./n.*(laddery(2)-laddery(1));
		elseif logy==1 & logx==0
            i=(i)./p.*(ladderx(2)-ladderx(1)) ;
            j=laddery(1)*(laddery(2)/laddery(1)).^((j)./n);
		end    
  % Display on a 3rd curve    
		figure(3)
		if logy==0 & logx==0
           h=plot(i,j,'r','LineWidth',1);
		elseif logy==1 & logx==1
           h=loglog(i,j,'r','LineWidth',1);
		elseif logy==0 & logx==1
           h=semilogx(i,j,'r','LineWidth',1);
		elseif logy==1 & logx==0
           h=semilogy(i,j,'r','LineWidth',1);
		end   
		grid on;  
%         pntedit on;
%     i=get(h,'xdata')';
%     j=get(h,'ydata')';
	v=[i j];    
	handles.v=v;
    % Update handles structure
	guidata(hObject, handles);

% --------------------------------------------------------------------
function Scale_Callback(hObject, eventdata, handles)
% hObject    handle to Scale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = {'Scale X','Scale Y','Log scale X','Log Scale Y'};
dlg_title = 'Input for Scale';
num_lines= 1;
def     = {num2str(handles.ladderx),num2str(handles.laddery),num2str(handles.ladderx_log),num2str(handles.laddery_log)};
answer  = inputdlg(prompt,dlg_title,num_lines,def);
if isempty(answer)
    return;
else
	handles.ladderx=str2num(char(answer(1)));
	handles.laddery=str2num(char(answer(2)));
	handles.ladderx_log=str2num(char(answer(3)));
	handles.laddery_log=str2num(char(answer(4)));
end
% Update handles structure
	guidata(hObject, handles); 

% --------------------------------------------------------------------
function graph_param_Callback(hObject, eventdata, handles)
% hObject    handle to graph_param (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt = {'Horizontal object size','Vertical object size','Horizontal grid length','Vertical grid length'};
dlg_title = 'Input for image processing';
num_lines= 1;
def     = {num2str(handles.cut_hor),num2str(handles.cut_ver),num2str(handles.length_x),num2str(handles.length_y)};
answer  = inputdlg(prompt,dlg_title,num_lines,def);
if isempty(answer)
    return;
else    
	handles.cut_hor=str2num(char(answer(1)));
	handles.cut_ver=str2num(char(answer(2)));
	handles.length_x=str2num(char(answer(3)));
	handles.length_y=str2num(char(answer(4)));
end
% Update handles structure
	guidata(hObject, handles); 
