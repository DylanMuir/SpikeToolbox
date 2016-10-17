function STPlot2DRaster(stTrain, bFreqOn)

% STPlot2DRaster - FUNCTION Make a raster plot of the spike train, differentiating between rows
% $Id: STPlot2DRaster.m 9708 2008-06-27 15:09:56Z chicca $
%
% Usage: STPlot2DRaster(stTrain)
%        STPlot2DRaster(stTrain, bFreqOn)    
%
% This function creates a raster plot and mean frequency histogram 
% in the current axes (or in a new figure) showing the spike train 'stTrain'.
% 'stTrain' is a mapped spike train.  
% Only major address fields contribute to the 2D address space, minor 
% address fields are ignored.
%
% The user can optionally specify bFreqOn. If this binary value is true,
% then the mean frequency histogram will be plotted.  By default, 
% the mean frequency histogram is plotted.
%
% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 2nd April, 2004 (modified from STPlotRaster by Chiara)
% Copyright (c) 2004, 2005 Chiara Bartolozzi

% -- Check arguments
warning off MATLAB:divideByZero
if (nargin > 2)
    disp('--- STPlot2DRaster: Extra arguments ignored');
end
if (nargin < 2)
    % default is to plot the frequency hystogram
    bFreqOn = 1;
end

if (nargin < 1)
    disp('*** STPlot2DRaster: Would you like help?');
    help STPlotRaster;
end


% -- Handle cell arrays of spike trains
if (iscell(stTrain))
    hFig = gcf;
    newplot;
    set(hFig, 'UserData', 'CellPlot');

    for (nRowIndex = 1:size(stTrain, 1))
        for (nColIndex = 1:size(stTrain, 2))
            subplot( size(stTrain, 1),size(stTrain, 2), ((nColIndex-1) * size(stTrain, 1)) + nRowIndex);
            STPlot2DRaster(stTrain{nRowIndex, nColIndex},bFreqOn);
        end
    end
    return;
end


% - Non-cell array of spike trains
% - Get the figure handle
hFig = gcf;
if (~strcmp(get(hFig, 'UserData'), 'CellPlot'))
   newplot;
end

% - Get current plotting extents
hAxes = gca;
vWindow = get(hAxes, 'Position');
fWidth = vWindow(3);
fHeight = vWindow(4);

% - Detect zero-duration spike trains
if (STIsZeroDuration(stTrain))
    disp('*** STPlot2DRaster: Cannot plot a zero-duration spike train');
    return;
end

% - Check that a mapping exists
if (~FieldExists(stTrain, 'mapping'))        % check for mapping
    disp('*** STPlot2DRaster: Can only plot mapped spike trains');
    return;
end

% - Extract the mapping
stMap = stTrain.mapping;


% -- CHIARA
% -- find range of Y neurons and X neurons:
nDim = sum([stMap.stasSpecification.bMajorField]);

if nDim ~= 2    %check for 2D spike trains
    disp('***STPlot2DRaster: This function supports only 2D arrays');
    return;
end

nNumAddrFields = sum(~[stMap.stasSpecification.bIgnore]);

stasSpecValid = stMap.stasSpecification(~[stMap.stasSpecification.bIgnore]);

nMajorFieldIndices = find([stasSpecValid.bMajorField]);
nYAddrIndex = nMajorFieldIndices(2);
nXAddrIndex = nMajorFieldIndices(1);

nMaxY = 2^stMap.stasSpecification(nMajorFieldIndices(2)).nWidth - 1; % rows
nMaxX = 2^stMap.stasSpecification(nMajorFieldIndices(1)).nWidth - 1; % rows

% -- create the color vector
nSize = ceil((nMaxY+1)/3); % 3 = number of colors
strColor = {'.c','.m','.y'};
strPlotOptions = strColor;
for i = 1:nSize
    strPlotOptions = {strPlotOptions{:},strColor{:}};
end
% -- Are we using chunked mode?
if (stMap.bChunkedMode)
    spikeList = stMap.spikeList;
else
    spikeList = {stMap.spikeList};
end

mMeanFreq =  zeros((nMaxY+1)*(nMaxX+1),1);
count = zeros((nMaxY+1)*(nMaxX+1),1);
%tISI = 0;
% -- Do the plot

% - Make a subplot inside the current window
if (bFreqOn)
    vNewSubplot = [0 0 .7 1] .* [fWidth fHeight fWidth fHeight];
else
    vNewSubplot = [0 0 1 1] .* [fWidth fHeight fWidth fHeight];
end

vNewSubplot(1:2) = vNewSubplot(1:2) + vWindow(1:2);

subplot('position',vNewSubplot);% Betta
axis([0 spikeList{length(spikeList)}(end,1).* stMap.fTemporalResolution 0 (nMaxX+1)*(nMaxY+1)]);


nNumChunks = length(spikeList);

hold on;
for (nChunkIndex = 1:nNumChunks)
    % -- convert the address into x and y
    [addr{1:nNumAddrFields}] = STAddrLogicalExtract(spikeList{nChunkIndex}(:, 2),stMap.stasSpecification);

    nNeuronY = addr{nYAddrIndex};
    nNeuronX = addr{nXAddrIndex};
    for row = 0:nMaxY
        index_row = find(nNeuronY == row);
        % -- Do the plot
        plot(spikeList{nChunkIndex}(index_row, 1) .* stMap.fTemporalResolution, ...
            spikeList{nChunkIndex}(index_row, 2),strPlotOptions{row+1});
        if bFreqOn
            for col = 0:nMaxX
                index = find(nNeuronX == col & nNeuronY == row);
                if ~isempty(index)
                    % if the pixel sent out the address I calculate the delta t
                    % between two spikes of the same pixel, then I calculate the
                    % mean and the 1/mean is the mean freq.
                    tISI = diff(spikeList{nChunkIndex}(index, 1) .* stMap.fTemporalResolution);

                    mMeanFreq(row*nMaxX+col+1) = mMeanFreq(row*nMaxX+col+1)+ 1/(mean(tISI));
                    count(row*nMaxX+col+1) = count(row*nMaxX+col+1) + 1;
                    infinity = isinf(mMeanFreq);
                    if ~isempty(infinity)
                        mMeanFreq(infinity) = 0;
                    end
                end
            end
        end
    end
end

hold off;

xlabel('Time (s)');
ylabel('Neurons');

if bFreqOn
    mMeanFreq = mMeanFreq./count;
    infinity = isinf(mMeanFreq);
    if ~isempty(infinity)
        mMeanFreq(infinity) = 0;
    end
    
    % - Make a new subplot
    vNewSubplot = [.8 0 .2 1] .* [fWidth fHeight fWidth fHeight];
    vNewSubplot(1:2) = vNewSubplot(1:2) + vWindow(1:2);

    subplot('position',vNewSubplot);

    barh(mMeanFreq,1);

    h = findobj(gca,'Type','patch');

    set(h,'FaceColor','w','EdgeColor','k','LineWidth',2);
    axis([0 max(mMeanFreq) 0 ((nMaxX+1)*(nMaxY+1))]);
    xlabel('Mean \it{f} (Hz)');

end

return;




% --- END of STPlot2DRaster.m ---
