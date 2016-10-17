function [mMeanSuppr, mVarSuppr, mMeanAct, mVarAct] =  STPlot2DISI(stTrain, nThreshold)

% STPlot2DISI - FUNCTION Make a raster plot of the spike train, differentiating between rows
% $Id: STPlot2DISI.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage:  STPlot2DISI(stTrain,nThreshold)
%
% Where: 'stTrain' is a mapped spike train. This function calculates the
% mean and variance of the duration of the inactivation time and of the
% activation time of each pixel in the 2D array. Threshold excludes the
% smaller ISIs so that the ISI dependent on the spike frequency during
% the activation time are not taken in account.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 2nd April, 2004 (Modified from STPlotISI by Chiara)
% Copyright (c) 2004, 2005 Chiara Bartolozzi

% -- Check arguments
warning off MATLAB:divideByZero
if (nargin > 2)
   disp('--- STPlotISI: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** STPlotISI: Would you like help?');
   help STPlot2DISI;
   return;
end

% -- Handle cell arrays of spike trains

if (iscell(stTrain))
   hFig = gcf;
   clf;
   set(hFig, 'UserData', 'CellPlot');
   
   for (nRowIndex = 1:size(stTrain, 1))
      for (nColIndex = 1:size(stTrain, 2))
         clf;
         subplot(size(stTrain, 1), size(stTrain, 2), ((nColIndex-1) * size(stTrain, 1)) + nRowIndex);
            STPlot2DISI(stTrain{nRowIndex, nColIndex}, nThreshold);
      end
   end
   return;
end

% - Clear the current figure if necessary
hFig = gcf;
if (~strcmp(get(hFig, 'UserData'), 'CellPlot'))
   clf;
end

if (~isfield(stTrain, 'mapping'))        % check for mapping
  disp('This function supports only mapped trains');
  return;
end

stMap = stTrain.mapping;

if (stMap.tDuration == 0)                % check for zero dimension spike
                                         % trains
   disp('*** STPlotISI: Cannot plot a zero-duration spike train');
   return;
end

if (isempty(stMap.spikeList))            % check for zero dimension spike
                                         % trains
   disp('*** STPlotISI: Cannot plot a zero-duration spike train');
   return;
end	 				  
% -- CHIARA 
% -- find range of Y neurons and X neurons:
nDim = sum([stMap.stasSpecification.bMajorField]);

if nDim ~= 2    %check for 2D spike trains
  disp('***STPlot2DISI: This function supports only 2D arrays');
  return;
end

nNumAddrFields = sum(~[stMap.stasSpecification.bIgnore]);

stasSpecValid = stMap.stasSpecification(~[stMap.stasSpecification.bIgnore]);

nMajorFieldIndices = find([stasSpecValid.bMajorField]);
nYAddrIndex = nMajorFieldIndices(2);
nXAddrIndex = nMajorFieldIndices(1);

nMaxY = 2^stMap.stasSpecification(nMajorFieldIndices(2)).nWidth - 1; % rows
nMaxX = 2^stMap.stasSpecification(nMajorFieldIndices(1)).nWidth - 1; % rows

% -- Are we using chunked mode?
if (stMap.bChunkedMode)
  spikeList = stMap.spikeList;
else
  spikeList = {stMap.spikeList};
end 

if length(spikeList) < 1
  disp('*** STPlot2DISI: Cannot plot a zero-duration spike train');
   return;
end

Suppression = cell([nMaxY+1, nMaxX+1]);
Activity = cell([nMaxY+1, nMaxX+1]);

for (nChunkIndex = 1:length(spikeList))
  % -- convert the address into x and y
  [addr{1:nNumAddrFields}] = STAddrLogicalExtract(spikeList{nChunkIndex}(:, 2));
  
  nNeuronY = addr{nYAddrIndex};
  nNeuronX = addr{nXAddrIndex};
  for nRows = 0:nMaxY
    for nCols = 0:nMaxX
      index = find(nNeuronX==nCols & nNeuronY==nRows);
      if ~isempty(index)
	tTime{nRows+1,nCols+1} = spikeList{nChunkIndex}(index, 1) .* stMap.fTemporalResolution;
	tISI{nRows+1,nCols+1} = diff(spikeList{nChunkIndex}(index, 1) .* stMap.fTemporalResolution);
	if ~isempty(tISI{nRows+1,nCols+1})
	  index_th{nRows+1,nCols+1} = find(tISI{nRows+1,nCols+1} > nThreshold);
	  n(1)=1;
	  if ~isempty(index_th{nRows+1,nCols+1}) 
	    for tLoop = 1:length(index_th{nRows+1,nCols+1})
	      n(tLoop+1) =  index_th{nRows+1,nCols+1}(tLoop);
	      Suppression{nRows+1,nCols+1}(tLoop) = tTime{nRows+1,nCols+1}(n(tLoop+1)+1) - tTime{nRows+1,nCols+1}(n(tLoop+1));
	      Activity{nRows+1,nCols+1}(tLoop) = tTime{nRows+1,nCols+1}(n(tLoop+1)) - tTime{nRows+1,nCols+1}(n(tLoop));
	    end
	  end
	end
      end
    end
  end
end

for nRows = 0:nMaxY
  for nCols = 0:nMaxX
    if (~isempty(Suppression{nRows+1,nCols+1}) && max(tISI{nRows+1,nCols+1})>0)
      mMeanSuppr(nRows+1,nCols+1) = mean(Suppression{nRows+1,nCols+1});
      mVarSuppr(nRows+1,nCols+1) = var(Suppression{nRows+1,nCols+1});
      mMeanAct(nRows+1,nCols+1) = mean(Activity{nRows+1,nCols+1});
      mVarAct(nRows+1,nCols+1) = var(Activity{nRows+1,nCols+1});
    end
  end
end


return;




% --- END of STPlot2DISI.m ---
