close all

T = readtable('test.xls');
NT = height(T);
op.refresh = ones(NT,1);
op.new = 1;

op.figwidth    = 1000;
op.figheight   = 900;
op.figcolor    = [32 32 0]; % background
op.figposition = [50   50   500   500];

th = 128;

while(1)
    
    op.image = imread('test.png');
    op.bw    = op.image>th;
    x        = op.bw(:);
    op.black = sum(x==0)/length(x);
    op.white = sum(x==1)/length(x);
    op.thpr  = th/255;
    op.thstr = num2str(th);
    op.title = 'clickGUI';
    op.thx   = round(730 - 2.4*th);
    
    op = showGUI(T,op);
    q = op.output;

    switch q
        case 1
            disp('Exit');
            break
        case 2 % previous
            th = max([0 th-8]);
        case 3 % next
            th = min([255 th+8]);
        case 4
            th = round(op.relx*255);
            
    end
end
