function [stNullTrain] = STNullTrain(strTrainLevel, stasSpecification)

% STNullTrain - FUNCTION Create a zero-duration spike train
% $Id: STNullTrain.m 11412 2009-04-06 13:51:16Z dylan $
%
% Usage: [stNullTrain] = STNullTrain
%                        STNullTrain('instance')
%                        STNullTrain('mapping' <, stasSpecification>)
%
% 'stNullTrain' will be a zero-duration spike train.  By default, a train with
% only an instance will be created.  If 'mapping' is specified as an argument,
% then a mapping will be created instead.  The addressing specification for the
% mapping can optionally be provided in 'stasSPecification'.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 18th February, 2005
% Copyright (c) 2005, 2006, 2007, 2008, 2009 Dylan Richard Muir

% -- Defaults

DEF_stasSpecification = STAddrSpecIgnoreSynapseNeuron(1, 0, 0);
DEF_strTrainLevel = 'instance';


% -- Check arguments

if (~exist('strTrainLevel', 'var') || isempty(strTrainLevel))
   strTrainLevel = DEF_strTrainLevel;
end

if (~strcmp(strTrainLevel, 'instance') && ~strcmp(strTrainLevel, 'mapping'))
   disp('*** STNullTrain: ''strTrainLevel'' must be one of [''instance'', ''mapping''].');
   return;
end

if (~exist('stasSpecifcation', 'var') || isempty(stasSpecification))
   stasSpecification = DEF_stasSpecification;
end

if (~STIsValidAddrSpec(stasSpecification))
   disp('*** STNullTrain: The spike train addressing specification was invalid.');
   return;
end


% - Provide help if the user didn't keep the returned spike train
if (nargout == 0)
   help STNullTrain;
   return;
end


% -- Create the zero-duration train

if (strcmp(stasSpecification, 'instance'))
   stNullTrain.instance.fTemporalResolution = 0;
   stNullTrain.instance.tDuration = 0;
   stNullTrain.instance.bChunkedMode = false;
   stNullTrain.instance.spikeList = [];

else % must be a mapping
   mapping.tDuration = 0;
   mapping.fTemporalResolution = 0;
   mapping.stasSpecification = stasSpecification;
   mapping.spikeList = [];
   mapping.bChunkedMode = false;
   stNullTrain.mapping = mapping;
end

% --- END of STNullTrain.m ---
