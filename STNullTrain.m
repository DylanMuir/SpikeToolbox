function [stNullTrain] = STNullTrain

% STNullTrain - FUNCTION Create a zero-duration spike train instance
% $Id: STNullTrain.m 2411 2005-11-07 16:48:24Z dylan $
%
% Usage: [stNullTrain] = STNullTrain
%
% 'stNullTrain' will be a zero-duration spike train, with an instance only.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 18th February, 2005
% Copyright (c) 2005 Dylan Richard Muir

% -- Check arguments (snort)

if (nargin > 0)
   disp('--- STNullTrain: I don''t take any arguments');
end

% - Provide help if the user didn't keep the returned spike train
if (nargout == 0)
   help STNullTrain;
   return;
end


% -- Create the zero-duration train

stNullTrain.instance.fTemporalResolution = 0;
stNullTrain.instance.tDuration = 0;
stNullTrain.instance.bChunkedMode = false;
stNullTrain.instance.spikeList = [];

% --- END of STNullTrain.m ---
