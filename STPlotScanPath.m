function [mScanPath mDist mActSuppr] =  STPlotScanPath(stTrain,bPlot)

% STPlotScanPath - FUNCTION Returns and plots the "scanpath" from a spike
% train, it returns the list of address of the active neurons and the duration of
% the time interval of their activation.
% $Id: STPlotScanPath.m 8602 2008-02-27 17:49:21Z dylan $
%
% Usage:  STPlotScanPath(stTrain<,bPlot)
%
% Where: 'stTrain' is a mapped spike train. This function scans the spike
% train and returns the address and the time interval of the activation of
% the winning neuron, in the correct time sequence.
%
% mScanPath = [NeuronsAddresses tBurstsDurations tBurstsStart]
%
% mDist = [meanDist stdDist] distance between consecutive neurons; it is
% not a real distance, but the number of nodes in the path 
%
% mActSuppr = [uniqueAddress meanActivityDuration stdMeanActivityDuration
% meanSuppressionDuration stdMeanSuppressionDuration]
%
% 'bPlot' if one a plot of the scanpath is produced, the default is zero;
% the plot is created only for 2D neuron's arrays
% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 2nd April, 2004 (Modified from STPlot2DISI by Chiara)
% Copyright (c) 2004, 2005 Chiara Bartolozzi

% -- Check arguments

if (nargin > 3)
   disp('--- STPlotScanPath: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STPlotScanPath: Would you like help?');
   help STPlotScanPath;
   return;
end

if (nargin < 2)
   bPlot = 0;
end


% -- Handle cell arrays of spike trains

if (iscell(stTrain))
  if bPlot == 1
    hFig = gcf;
    clf;
    set(hFig, 'UserData', 'CellPlot');
  end
  for (nRowIndex = 1:size(stTrain, 1))
    for (nColIndex = 1:size(stTrain, 2))
      if bPlot == 1
	clf;
	subplot(size(stTrain, 1), size(stTrain, 2), ((nColIndex-1) * size(stTrain, 1)) + nRowIndex);
      end
      [mScanPath{nRowIndex, nColIndex} mDist{nRowIndex, nColIndex} mActSuppr{nRowIndex, nColIndex}] = STPlotScanPath(stTrain{nRowIndex, nColIndex}, bPlot);
    end
  end
  return;
end

if bPlot == 1
  % - Clear the current figure if necessary
  hFig = gcf;
  if (~strcmp(get(hFig, 'UserData'), 'CellPlot'))
    clf;
  end
end

if (~isfield(stTrain, 'mapping'))        % check for mapping
  disp('This function supports only mapped trains');
  return;
end

stMap = stTrain.mapping;

if (stMap.tDuration == 0)                % check for zero dimension spike
                                         % trains
   disp('*** STPlotScanPath: Cannot plot a zero-duration spike train');
   return;
end

if (isempty(stMap.spikeList))            % check for zero dimension spike
                                         % trains
   disp('*** STPlotScanPath: Cannot plot a zero-duration spike train');
   return;
end	 				  
% -- CHIARA 
% -- find range of Y neurons and X neurons:

nNumAddrFields = sum(~[stMap.stasSpecification.bIgnore]);

% -- Are we using chunked mode?
if (stMap.bChunkedMode)
  spikeList = stMap.spikeList;
else
  spikeList = {stMap.spikeList};
end 

if length(spikeList) < 1
  disp('*** STPlotScanPath: Cannot plot a zero-duration spike train');
   return;
end

% -- Extract ISIs, find bursts

for (nChunkIndex = 1:length(spikeList))
  cAddr{nChunkIndex} = spikeList{nChunkIndex}(:,2); 
  cTime{nChunkIndex} = spikeList{nChunkIndex}(:,1);
end
vAddr = vertcat(cAddr{:});
vTime = vertcat(cTime{:});

bIsBursting = [-1; vAddr];
bIsBurstStarts = diff(bIsBursting);

activeNeur = vAddr(find(bIsBurstStarts));
  
vSpikeStartsBurst = find(bIsBurstStarts ~= 0);

vSpikeEndsBurst = vSpikeStartsBurst - 1;
vSpikeEndsBurst(1) = [];

tBurstStarts = vTime(vSpikeStartsBurst).*1e-6;
tBurstEnds = [vTime(vSpikeEndsBurst); vTime(end)].*1e-6;

tBurstsDuration = (tBurstEnds - tBurstStarts); 
tBurstsDuration(find(tBurstsDuration == 0)) = 1e-6; % single spike

% output scanpath: [addr burstDuration start]
mScanPath = [activeNeur tBurstsDuration tBurstStarts];
 
% -- convert the address into x and y
[addr{1:nNumAddrFields}] = STAddrLogicalExtract(activeNeur);
mAddr = horzcat(addr{:});

% -- distance
dist = sum(abs(diff(mAddr)),2);
vMeanDist = mean(dist);
vStdDist = std(dist);
mDist = [vMeanDist vStdDist];
 
% -- mean activation and suppression duration
% for each active neuron
vAddr = unique(activeNeur);

for i = 1:length(vAddr)
  NeurIndex = find(activeNeur == vAddr(i));
  
  vDurationBursts = tBurstsDuration(NeurIndex);
  vMeanAct(i) = mean(vDurationBursts);
  vStdAct(i) = std(vDurationBursts);

  vDurationSuppr = diff(tBurstStarts(NeurIndex));
  if ~isempty(vDurationSuppr)
    vMeanSuppr(i) = mean(vDurationSuppr) - mean(vDurationBursts);
    vStdSuppr(i) = std(vDurationSuppr); %?????
  else % neuron emitted a single spike or burst
    vMeanSuppr(i) = stMap.tDuration - mean(vDurationBursts);
    vStdSuppr(i) = 0; %?????
  end
end

mActSuppr = [vAddr vMeanAct' vStdAct' vMeanSuppr' vStdSuppr']; 

% -- plot
if bPlot == 1
  nDim = sum([stMap.stasSpecification.bMajorField]);
  if nDim ~= 2    %check for 2D spike trains
    disp('***STPlotScanPath: This function supports only 2D arrays for plotting');
  end
  stasSpecValid = stMap.stasSpecification(~[stMap.stasSpecification.bIgnore]);
  nMajorFieldIndices = find([stasSpecValid.bMajorField]);
  nYAddrIndex = nMajorFieldIndices(2);
  nXAddrIndex = nMajorFieldIndices(1);
  nMaxY = 2^stMap.stasSpecification(nMajorFieldIndices(2)).nWidth - 1; % rows
  nMaxX = 2^stMap.stasSpecification(nMajorFieldIndices(1)).nWidth - 1; % rows
  
  
  temp = zeros(nMaxX,nMaxY);    
  for i = 1:size(mAddr,1) 
    hist = zeros(nMaxX,nMaxY);
    hist(mAddr(i,1),mAddr(i,2)) = 10+max(max(temp));     
    temp(mAddr(i,1),mAddr(i,2)) = temp(mAddr(i,1),mAddr(i,2)) + 1;
    pause(1)
    imagesc(hist+temp)  
    colormap cool
    colorbar
    refresh
  end
end
    
return;

% --- END of STPlotScanPath.m ---
