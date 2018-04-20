function mov = avi2mat(filename,tspan,newSize)
%Save a .avi file as a .mat file
%   Based off of 582 HW2, but updated for MATLAB 2016
%   Starts at the first entry in tspan, ends at the second

if ~exist('filename','var')
    filename = 'AVSS_PV_Easy_Divx.avi';
end
if ~exist('tspan','var')
    tspan = [0 obj.Duration/100];
end

obj = VideoReader(filename);
tspan(2) = min(tspan(2),obj.Duration);

startFrame = obj.FrameRate*tspan(1);
endFrame = obj.FrameRate*tspan(2);
if tspan(1)>obj.Duration || tspan(2)>obj.Duration
    error('tspan is not in the bounds of the video')
end
obj.CurrentTime = tspan(1);

if ~exist('newSize','var') %i.e. we don't want to resize the frames
    mov.cdata = uint8(zeros(...
        obj.Height,...
        obj.Width,...
        3,...
        round(endFrame-startFrame)));
else
    mov.cdata = uint8(zeros(...
        newSize(1),...
        newSize(2),...
        3,...
        round(endFrame-startFrame)));
end

jFrame = 1;
if ~exist('newSize','var') %i.e. we don't want to resize the frames
    while obj.CurrentTime < tspan(2)
        mov.cdata(:,:,:,jFrame) = readFrame(obj);
        jFrame = jFrame + 1;
    end
else
    while obj.CurrentTime < tspan(2)
        mov.cdata(:,:,:,jFrame) = ...
            imresize(readFrame(obj),newSize);
        jFrame = jFrame + 1;
    end
end

[foldername, filename] = fileparts(filename);
save(sprintf('%s/dat_%s.mat',...
    foldername,filename(1:10)),'mov');

end
%==========================================================================


