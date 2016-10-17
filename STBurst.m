function [nMeanAct nStdAct nMeanSuppr nStdSuppr] =  STBurst(stTrain,nThr)

% STBurst - FUNCTION Returns the mean duration of bursts (activity) and
% suppression from a spike train
% $Id: STBurst.m 8602 2008-02-27 17:49:21Z dylan $
%
% Usage:  STBurst(stTrain,nThr)
%
% Where: 'stTrain' is a mapped spike train relative to a single
% address. This function returns the mean duration of the time interval
% of the activation and suppression of the neuron
% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 2nd April, 2004 (Modified from STPlot2DISI by Chiara)
% Copyright (c) 2004, 2005 Chiara Bartolozzi

% -- Check arguments

if (nargin > 2)
   disp('--- STBurst: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STBurst: Would you like help?');
   help STBurst;
   return;
end

if (nargin < 2)
   nThr = 0.002;
end

% -- Handle cell arrays of spike trains

if (iscell(stTrain))
  for (nRowIndex = 1:size(stTrain, 1))
    for (nColIndex = 1:size(stTrain, 2))
      [nMeanAct(nRowIndex,nColIndex) nStdAct(nRowIndex,nColIndex) nMeanSuppr(nRowIndex,nColIndex) nStdSuppr(nRowIndex,nColIndex)] = STBurst(stTrain{nRowIndex, nColIndex},nThr);
    end
  end
  return;
end

if (~isfield(stTrain, 'mapping'))        % check for mapping
  disp('This function supports only mapped trains');
  return;
end

stMap = stTrain.mapping;

if (stMap.tDuration == 0)                % check for zero dimension spike
                                         % trains
   disp('*** STBurst: Cannot plot a zero-duration spike train');
   return;
end

if (isempty(stMap.spikeList))            % check for zero dimension spike
                                         % trains
   disp('*** STBurst: Cannot plot a zero-duration spike train');
   return;
end	 				  
% -- CHIARA 
% -- Extract ISIs, find bursts

vTime = STGetSpikeTimes(stTrain);
vISI = diff(stTrain.mapping.spikeList(:,1)).*1e-6;

vIndex = find(vISI>nThr);

if isempty(vIndex) % no suppression
  nMeanSuppr = 0;
  nStdSuppr = 0;
  nMeanAct = stMap.tDuration;
  nStdAct = 0;
else
  nMeanSuppr = mean(vISI(vIndex));
  nStdSuppr = std(vISI(vIndex));
  indexStartsBurst = vIndex(1:end-1) + 1;
  indexEndsBurst = vIndex(2:end);
  vAct = vTime(indexEndsBurst)-vTime(indexStartsBurst);
  % single spikes
  vAct(find(vAct == 0)) = 1e-6;
  nMeanAct = mean(vAct);
  nStdAct = std(vAct);
end
return;

% --- END of STBurst.m ---
