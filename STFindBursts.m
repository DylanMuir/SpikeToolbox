function [vtBurstStarts, vtBurstEnds] = STFindBursts(stTrain, tThresh)

% STFindBursts - FUNCTION Locates bursts in a spike train
% $Id: STFindBursts.m 8603 2008-02-27 17:49:41Z dylan $
%
% Usage: [vtBurstStarts, vtBurstEnds] = STFindBursts(stTrain <, tThresh>)
%
% 'stTrain' is an instantiated or mapped spike train. 'tThresh' is a threshold
% ISI below which the spikes are considered to be bursting (default: 2 µs).
% 'vtBurstStarts' and 'vtBurstEnds' will be vectors of the same length, each
% corresponding entry identifiying the start and end of a single burst.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 4th February, 2008
% Copyright (c) 2008 Dylan Muir

% -- Defaults

DEF_tThresh = 0.002;


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
   tThresh = DEF_tThresh;
end


% -- Handle cell arrays of spike trains

if (iscell(stTrain))
	[nMeanAct, nStdAct, nMeanSuppr, nStdSuppr] = CellForEachCell(STBurst, stTrain, tThresh);
   return;
end


% -- Detailed argument check

% - Check that a mapped spike train was supplied
if (~STHasInstance(stTrain) && ~STHasMapping(stTrain))
	disp('*** STFindBursts: This function requires an instantiated or mapped spike train');
	return;
end

stMap = stTrain.mapping;

% - Check for zero-duration spike trains
if (STIsZeroDuration(stMap))
   vtBurstStarts = [];
   vtBurstEnds = [];
   return;
end


% -- Extract ISIs, find bursts

vtSpikeTimes = STGetSpikeTimes(stTrain);
vISI = diff(vtSpikeTimes);

bIsBursting = [0; vISI < tThresh; 0];
bIsBurstChange = diff(bIsBursting);

vSpikeStartsBurst = find(bIsBurstChange > 0);
vSpikeEndsBurst = find(bIsBurstChange < 0);

vtBurstStarts = spikeList(vSpikeStartsBurst);
vtBurstEnds = spikeList(vSpikeEndsBurst);

% --- END of STFindBursts.m ---
