function [stTrain] = STInstantiate(stOldTrain, strTemporalType, tDuration)

% FUNCTION STInstantiate - Convert spike train definitions into concrete trains
%
% Usage: [stTrain] = STInstantiate(stTrain, 'regular', tDuration)
%        [stTrain] = STInstantiate(stTrain, 'poisson', tDuration)
%
% Where: 'stTrain' (input) is a spike train containing a simple train
% definition created by STCreate.  'tDuration' is the desired duration of the
% spike train in seconds.  The type of spike train is specified using either
% 'regular' or 'poisson'.  A regular train has equal inter-spike intervals
% based on the train freqeuncy.  A poisson train generates spikes according to
% a probability based on the train frequency.  'stTrain' (output) will have a
% 'instance' field added, containing the instantiated train.
%
% STInstantiate can also accept a cell array of spike trains for the 'stTrain'
% input.  In this case, 'stTrain' (output) will be a cell array of the same
% size as 'stTrain' (input).
%
% Note that changing frequencies and regular spike trains don't play well
% together.  Perhaps a better algorithm for creating regular trains is
% required.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004

% $Id: STInstantiate.m,v 1.1 2004/06/04 09:35:47 dylan Exp $

% -- Define globals

global INSTANCE_TEMPORAL_RESOLUTION SPIKE_CHUNK_LENGTH;


% -- Check arguments

if (nargin > 3)
    disp('--- STInstantiate: Extra arguments ignored');
end

if (nargin < 3)
    disp ('*** STInstantiate: Incorrect number of arguments');
    help STInstantiate;
    return;
end

if (tDuration == 0)
   disp('*** STInstantiate: Cannot instantiate a zero-length spiketrain');
   return;
end

stTrain = stOldTrain;

% -- Handle a cell array of spike trains

if (iscell(stTrain))
   for (nCellIndex = 1:prod(size(stTrain)))
      % - Send each cell individually to STInstantiate
      fprintf(1, 'Spike train [%02d/%02d]\n', nCellIndex, prod(size(stTrain)));
      stTrain{nCellIndex} = STInstantiate(stTrain{nCellIndex}, strTemporalType, tDuration);
   end
   return;
end


% -- Check that the train meets the criteria

if (~isfield(stTrain, 'definition'))
    disp('*** STInstantiate: stTrain must contain a simple spike train defintion.');
    disp('       This error may be caused my a multiplexed spike train.  Definitions');
    disp('       are stripped when trains are multiplexed.');
    return;
end


% -- Get / create default settings

STCreateDefaults;


% -- Check to see if we're overwriting anything

if (isfield(stTrain, 'instance'))
    disp('--- STInstantiate: Warning: overwriting a previously instantiated spike train');
end

if (isfield(stTrain, 'mapping'))
   disp('--- STInstance: Warning: re-instantiating a mapped spike train.  The previous');
   disp('       mapping will be erased.');
   stTrain = rmfield(stTrain, 'mapping');
end


% -- Find which sort of instance we're creating

switch lower(strTemporalType)
   case {'regular', 'r'}
      fhDoSpike = @STTestSpikeRegular;
        
   case {'poisson', 'p'}
      fhDoSpike = @STTestSpikePoisson;
        
   otherwise
      disp('*** STInstantiate: Unknown temporal spike train type.');
      disp('                   Must be one of {regular, poisson}');
      return;
end


% -- Create the instance

instance = [];
instance.fTemporalResolution = INSTANCE_TEMPORAL_RESOLUTION;
instance.tDuration = tDuration;

% - Check if we need to use chunked mode
bChunkedMode = (tDuration / INSTANCE_TEMPORAL_RESOLUTION) > SPIKE_CHUNK_LENGTH;
instance.bChunkedMode = bChunkedMode;

nNumChunks = 1;

if (bChunkedMode)
   % - Determine how many chunks are required
   nNumChunks = ceil((tDuration / INSTANCE_TEMPORAL_RESOLUTION) / SPIKE_CHUNK_LENGTH);
   instance.nNumChunks = nNumChunks;
   instance.spikeList = cell(1, nNumChunks);
   
   fprintf(1, 'Chunk [%02d/%02d]', 0, nNumChunks);
end

for (nChunkIndex = 1:nNumChunks)
   % - Get start and end times for the current chunk
   tTimeStart = (nChunkIndex-1) * INSTANCE_TEMPORAL_RESOLUTION * SPIKE_CHUNK_LENGTH;
   if (nChunkIndex == nNumChunks)
      tTimeEnd = tDuration;
   else
      tTimeEnd = (nChunkIndex) * INSTANCE_TEMPORAL_RESOLUTION * (SPIKE_CHUNK_LENGTH-1);
   end
   
   tTimeCurr = tTimeStart:INSTANCE_TEMPORAL_RESOLUTION:tTimeEnd;
   fInstFreq = feval(stTrain.definition.fhInstFreq, stTrain.definition, tTimeCurr);
    
   if ((max(fInstFreq) * INSTANCE_TEMPORAL_RESOLUTION) > 1.0)
      disp('--- STInstantiateRegular: Spike frequency is greater than the temporal resolution.');
      disp(sprintf('      Frequency [%.2f]MHz is clipped to [%.2f]MHz', ...
                   max(fInstFreq) / 1e3, (1/INSTANCE_TEMPORAL_RESOLUTION) / 1e3));
   end

   % - Find indices of tTimeCurr that correspond to a spike
   nSpikeIndices = feval(fhDoSpike, tTimeCurr, fInstFreq);
   spikeList = tTimeCurr(nSpikeIndices);

   if (bChunkedMode)
      % - Assign the chunk to the spike list
      instance.spikeList{nChunkIndex} = spikeList';
      fprintf(1, '\b\b\b\b\b\b%02d/%02d]', nChunkIndex, nNumChunks);
   else
      % - Just assign the spike list (non-chunked)
      instance.spikeList = spikeList';
   end
end

fprintf(1, '\n'); % Send a line termination

% - Assign instance to spike train
stTrain.instance = instance;


% --- END of STInstantiate.m ---

% $Log: STInstantiate.m,v $
% Revision 1.1  2004/06/04 09:35:47  dylan
% Reimported (nonote)
%
% Revision 1.9  2004/05/05 16:15:17  dylan
% Added handling for zero-length spike trains to various toolbox functions
%
% Revision 1.8  2004/05/04 09:40:07  dylan
% Added ID tags and logs to all version managed files
%