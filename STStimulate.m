function [varargout] = STStimulate(stTrain, tMonDuration)

% STStimulate - FUNCTION Send a mapped spike train to the PCI-AER board
% $Id: STStimulate.m 3985 2006-05-09 13:03:02Z dylan $
%
% Usage: <stMonTrain1, ...> = STStimulate(stTrain)
%        <stMonTrain1, ...> = STStimulate(stTrain, tMonDuration)
%
% 'stTrain' is a spike train mapped to a neuron/synapse address, as created
% by STMap.  'tMonDuration' optionally specifies the duration during which to
% monitor the board for spikes.  If 'tMonDuration' is not supplied, it is
% assumed to be the same duration as 'stTrain', plus one second.
% The return arguments 'stMonTrain...' collect the spike trains monitored
% by the PCI-AER system.  The spike trains from each configured channel
% will be returned in a separate spike train object.  If these trains are
% not requested, monitoring will not be performed.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 3rd May, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Check arguments

if (nargin > 2)
   disp('--- STStimulate: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STStimulate: Incorrect usage');
   help STStimulate;
   return;
end

% - Check for a valid spike train
if (~STIsValidSpikeTrain(stTrain))
   disp('*** STStimulate: Invalid spike train supplied');
   return;
end

% - Should we monitor or not?
if ((nargout > 0) || (exist('tMonDuration', 'var') == 1))
   bMonitor = true;
else
   bMonitor = false;
end

% - Should we stimulate or not?
if (STIsZeroDuration(stTrain))
   bStimulate = false;
else
   bStimulate = true;
end

% - Detect pciaer_stim_mon link / executeable
if (exist(['pciaer_stim_mon.' mexext], 'file') ~= 3)
   disp('*** STStimulate: Cannot find PCI-AER mex stimulation link on the path.');
   disp('       Cannot stimulate.  Please run STWelcome to set up the toolbox.');
   return;
end


% -- Check spike train

if (bStimulate && ~isfield(stTrain, 'mapping'))
   disp('*** STStimulate: The spike train to use as stimulus must contain a mapping');
   return;
end


% -- Export spike train to PCI-AER format

if (bStimulate)
   mStimEvents = STPciaerExport(stTrain);
else
   mStimEvents = [];
end


% -- Get durations

if (bStimulate)
   tStimDuration = stTrain.mapping.tDuration;
else
   tStimDuration = 0;
end

if (bMonitor)
   if (~exist('tMonDuration', 'var') == 1)
      tMonDuration = tStimDuration + 1;	% Default is stim time + 1 second
   end
else
   tMonDuration = 0;
end


% -- Stimulate and monitor

mMonEvents = pciaer_stim_mon(mStimEvents, tStimDuration, tMonDuration);


% -- Import spike train

if (bMonitor && (nargout > 0))
	[varargout{1:nargout}] = STPciaerImport(mMonEvents);
end

% --- END of STStimulate.m ---
