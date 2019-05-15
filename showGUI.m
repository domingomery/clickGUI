function op = showGUI(T,op)

if sum(op.refresh) > 0
    T.include = and(T.include,op.refresh);
    
    
    N = op.figheight;
    M = op.figwidth;
    
    if op.new == 1
        
        VD = zeros(N,M,3);
        if isfield(op,'figcolor')
            VD(:,:,1) = op.figcolor(1)/255;
            VD(:,:,2) = op.figcolor(2)/255;
            VD(:,:,3) = op.figcolor(3)/255;
        end
        
        
        CK = zeros(N,M,1);
    else
        CK = op.CK;
        VD = op.VD;
    end
    n = height(T);
    for i=1:n
        
        if T.include(i)==1
            qtype   = char(T.type(i));
            xmin   = readNumber(T.xmin(i),op);
            ymin   = readNumber(T.ymin(i),op);
            h      = readNumber(T.height(i),op);
            w      = readNumber(T.width(i),op);
            
            i1      = ymin;
            i2      = i1+h;
            j1      = xmin;
            j2      = j1+w;
            qoutput = T.output(i);
            switch qtype
                case 'button'
                    CK(i1:i2,j1:j2,:) = qoutput;
                case 'image'
                    nn = i2-i1+1; mm = j2-j1+1;
                    QI = readImage(T.value(i),op);
                    VD(i1:i2,j1:j2,:) = imresize(QI,[nn mm]);
            end
        end
    end
    if op.new == 1
        hold off
        imshow(VD)
        hold on
        h1 = figure(1);
        if isfield(op,'figposition')
            set(h1,'Position',op.figposition);
        end
    end
    for i=1:n
        if T.include(i)==1
            qtype   = char(T.type(i));
            xmin   = readNumber(T.xmin(i),op);
            ymin   = readNumber(T.ymin(i),op);
            h      = readNumber(T.height(i),op);
            w      = readNumber(T.width(i),op);
            
            i1      = ymin;
            i2      = i1+h;
            j1      = xmin;
            j2      = j1+w;
            
            it      = readNumber(T.dy(i),op);
            jt      = readNumber(T.dx(i),op);
            fs      = readNumber(T.fontsize(i),op);
            switch qtype
                case {'button','text'}
                    qtext   = readString(T.value(i),op);
                    Color_Text = readColor(T.color3(i),op);
                    Color_Face = readColor(T.color1(i),op);
                    Color_Edge = readColor(T.color2(i),op);
                    putRectangle(i1,i2,j1,j2,Color_Face,Color_Edge,0.3)
                    text(j1+jt,i1+it,qtext,'Color',Color_Text,'FontSize',fs);
                case 'rectangle'
                    Color_Face = readColor(T.color1(i),op);
                    Color_Edge = readColor(T.color2(i),op);
                    putRectangle(i1,i2,j1,j2,Color_Face,Color_Edge,0)
                case 'bar'
                    Color_Face = readColor(T.color1(i),op);
                    Color_Edge = readColor(T.color2(i),op);
                    putRectangle(i1,i2,j1,j2,Color_Face,Color_Edge,0)
                    Color_Face = readColor(T.color3(i),op);
                    pb = readNumber(T.value(i),op);
                    if ((j2-j1)>(i2-i1)) % horizontal bar
                        dj = j2-j1;
                        jn = round(j1 + pb*dj);
                        putRectangle(i1,i2,j1,jn,Color_Face,[],0)
                    else % vertical bar
                        di = i2-i1;
                        in = round(i1 + pb*di);
                        putRectangle(i1,in,j1,j2,Color_Face,[])
                    end
                case 'barline'
                    Color_Face = readColor(T.color1(i),op);
                    Color_Edge = readColor(T.color2(i),op);
                    putRectangle(i1,i2,j1,j2,Color_Face,Color_Edge,0)
                    Color_Mark = readColor(T.color3(i),op);
                    pb = readNumber(T.value(i),op);
                    if ((j2-j1)>(i2-i1)) % horizontal bar
                        dj = j2-j1;
                        jn = round(j1 + pb*dj);
                        plot(jn,(i1+i2)/2,'o','Color',Color_Mark)
                    else % vertical bar
                        di = i2-i1;
                        in = round(i1 + pb*di);
                        plot((j1+j2)/2,in,'o','Color',Color_Mark)
                    end
            end
        end
    end
else
    VD = op.VD;
    CK = op.CK;
end

try
    p = round(vl_click);
    op.output = CK(p(2),p(1));
    op.click  = p;
    op.VD     = VD;
    op.CK     = CK;
catch
    beep
    op.output = 0;
    op.click = [];
    op.VD    = [];
    op.CK    = [];
end

if op.output > 0
    [ii,jj] = find(CK==op.output);
    i1 = min(ii);i2 = max(ii);
    j1 = min(jj);j2 = max(jj);
    op.relx = (p(1)-j1)/(j2-j1);
    op.rely = (p(2)-i1)/(i2-i1);
end




function x = readNumber(val,op)
if iscell(val)
    s = char(val);
    if isempty(s)
        x = 0;
    else
        if s(1)=='*'
            eval(['x = op.' s(2:end) ';' ]);
        else
            if or(length(s)>1,num2str(s)>0)
                eval(['x = ' s ';' ]);
            else
                x = 0;
            end
        end
    end
else
    x = val;
end






function c = readColor(val,op)
s = char(val);
if ~isempty(s)
    if s(1)=='*'
        eval(['c = op.' s(2:end) '/255;' ]);
    else
        if length(s)>1
            eval(['c = ' s '/255;' ]);
        else
            c = [];
        end
    end
else
    c = [];
end
function J = readImage(val,op)
img = char(val);
if img(1)=='*'
    eval(['J = op.' img(2:end) ';']);
else
    J = imread(img);
end
J = double(J);
if max(J(:)) > 2
    J = J/255;
end
if size(J,3) == 1
    J = repmat(J,[1 1 3]);
end


function st = readString(val,op)
s = char(val);
if ~isempty(s)
    if s(1)=='*'
        eval(['st = op.' s(2:end) ';' ]);
    else
        st = s;
    end
else
    st = ' ';
end


function   putRectangle(i1,i2,j1,j2,Color_Face,Color_Edge,Curvature)
if ~isempty(Color_Face)
    rectangle('Position',[j1,i1,j2-j1,i2-i1],'FaceColor',Color_Face,'Curvature',Curvature)
end
if ~isempty(Color_Edge)
    rectangle('Position',[j1,i1,j2-j1,i2-i1],'EdgeColor',Color_Edge,'LineWidth',2,'Curvature',Curvature)
end

