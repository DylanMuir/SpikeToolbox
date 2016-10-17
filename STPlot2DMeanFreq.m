function mMeanFreq = STPlot2DMeanFreq(stTrain, bPlot, tBin_0, tBin_f)

% STPlot2DMeanFreq - FUNCTION Make a 2D plot of the mean frequency over a time interval of each pixel in a 2D array.
% $Id: STPlot2DMeanFreq.m 4230 2006-06-07 19:56:58Z chiara $
%
% Usage: STPlot2DMeanFreq(stTrain)
%        STPlot2DMeanFreq(stTrain, bPlot)
%        STPlot2DMeanFreq(stTrain, tBin_0, tBin_f)
%         STPlot2DMeanFreq(stTrain, bPlot, tBin_0, tBin_f)
%
% Where: 'stTrain' is a mapped spike train. If bPlot = 1 a imagesc type of
% plot will be created in the current axes (or a new figure created) showing
% the mean frequency of each pixel.
% If bPlot  = 0, the figure is not created and the function will return
% the mean frequency of each pixel.
% If not specified the plot is created

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 2nd April, 2004 (modified from STPlotRaster by Chiara)
% Copyright (c) 2004, 2005 Chiara Bartolozzi

% -- Check arguments
  
warning off MATLAB:divideByZero
mMeanFreq = [];

if (nargin > 4)
  disp('--- STPlot2DMeanFreq: Extra arguments ignored');
end

if (nargin < 1)
  disp('*** STPlot2DMeanFreq: Would you like help?');
  help STPlot2DMeanFreq; 
  return;
end

% -- Default

if (nargin == 3)
  tBin_f = tBin_0; 
  tBin_0 = bPlot;
  bPlot = 1;
end

if (nargin == 1)
  bPlot = 1;
end

% -- Handle cell arrays of spike trains

if (iscell(stTrain))
   hFig = gcf;
   clf;
   set(hFig, 'UserData', 'CellPlot');
   
  for (nRowIndex = 1:size(stTrain, 1))
    for (nColIndex = 1:size(stTrain, 2))
      subplot(size(stTrain, 1), size(stTrain, 2), ((nColIndex-1) * size(stTrain, 1)) + nRowIndex);
      STPlot2DMeanFreq(stTrain{nRowIndex, nColIndex}, bPlot, tBin_0, tBin_f);
    end
  end
  
  return;
end

if (~FieldExists(stTrain, 'mapping'))        % check for mapping
  disp('*** STPlot2DMeanFreq: Can only plot mapped spike trains');
  return;
end

% - Detect zero-duration spike trains
if (STIsZeroDuration(stTrain))
   disp('*** STPlot2DMeanFreq: Cannot plot a zero-duration spike train');
   return;
end

% - Extract the mapping
stMap = stTrain.mapping;
    	 				  
% -- CHIARA 
% -- find range of Y neurons and X neurons:
nNumAddrFields = sum(~[stMap.stasSpecification.bIgnore]);

if nNumAddrFields ~= 2    %check for 2D spike trains
  disp('*** STPlot2DMeanFreq: This function supports only 2D arrays');
  return;
end


stasSpecValid = stMap.stasSpecification(~[stMap.stasSpecification.bIgnore]);

nMajorFieldIndices = find([stasSpecValid.bMajorField]);

nYAddrIndex = nMajorFieldIndices(2);
nXAddrIndex = nMajorFieldIndices(1);

nMaxY = 2^stasSpecValid(nMajorFieldIndices(2)).nWidth - 1; % row
nMaxX = 2^stasSpecValid(nMajorFieldIndices(1)).nWidth - 1; % col
% initialization for the matrix of the Frequencies 
%mMeanFreq = NaN*ones(nMaxY+1,nMaxX+1); % frequency of each pixel

% -- Are we using chunked mode?
if (stMap.bChunkedMode)
  spikeList = stMap.spikeList;
else
  spikeList = {stMap.spikeList};
end
mMeanFreq =  zeros((nMaxY+1),(nMaxX+1));
%tISI = 0;
sListTime = [];
sListAddr = [];

for (nChunkIndex = 1:length(spikeList))
    % - Get spike list
  sListTime =[sListTime spikeList{nChunkIndex}(:, 1)]; %time stamps
  sListAddr =[sListAddr spikeList{nChunkIndex}(:, 2)]; %addr
end
if (nargin == 3) % bin mode
    % -- check time interval
    if tBin_0 < (sListTime(1)* stMap.fTemporalResolution)
        disp('***STPlot2DMeanFreq: invalid intial time')
        return;
    end
    if tBin_f > (sListTime(end) * stMap.fTemporalResolution)
        disp('***STPlot2DMeanFreq: invalid final time')
        return;
    end
    index = find(sListTime>=tBin_0 & sListTime<=tBin_f)
    [addr{1:nNumAddrFields}] = STAddrLogicalExtract(sListAddr(tBin_0:tBin_f), stMap.stasSpecification);
else % mean over the entire acquisition
    % -- convert the address into x and y
    [addr{1:nNumAddrFields}] = STAddrLogicalExtract(sListAddr(:), stMap.stasSpecification);
end

nNeuronY = addr{nYAddrIndex};
nNeuronX = addr{nXAddrIndex};

for row = 0:nMaxY
    for col = 0:nMaxX
        index = find(nNeuronY==row & nNeuronX==col);
        if ~isempty(index)
            train = sListTime(index) .* stMap.fTemporalResolution;
            % if the pixel sent out the address I calculate the delta t
            % between two spikes of the same pixel, then I calculate the
            % mean and the 1/mean is the mean freq.
            tISI = diff(train);
            if isempty(tISI)
                tISI = stMap.tDuration;
            else
                fMeanISI = mean(tISI);
                if (train(1) >2*fMeanISI)
                    tISI = [train(1); tISI];
                end

                if (stMap.tDuration - train(end) > 2*fMeanISI)
                    tISI = [tISI; stMap.tDuration - train(end)];
                end
            end
            % -- Calculate mean and std deviation
            nMeanISI = mean(tISI);
            mMeanFreq(row+1,col+1)= 1/nMeanISI;

            %[infx infy] = find(isinf(mMeanFreq));

            %if ~isempty(infx)
            %    mMeanFreq(infx,infy) = mMeanFreq(infx,infy) + 0;
            %end

        end
    end
end
  
% -- Do the plot
if bPlot == 1
   hFig = gcf;
   if (~strcmp(get(hFig, 'UserData'), 'CellPlot'))
      clf;
   end
   hold on;
   imagesc(mMeanFreq);
   axis equal;
   axis tight;

   colormap(cool);
   xlabel('Neuron X');
   ylabel('Neuron Y');

   colorbar;
   title('Mean {\it f} Hz')
end

return;

% --- END of STPlot2DMeanFreq.m ---
