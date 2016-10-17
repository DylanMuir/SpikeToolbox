function [stTrain] = STInstantiate(stOldTrain, strTemporalType, tDuration, mCorrelation, fMemTau)

% STInstantiate - FUNCTION Convert spike train definitions into concrete trains
% $Id: STInstantiate.m 3987 2006-05-09 13:38:38Z dylan $
%
% Usage: [stTrain] = STInstantiate(stTrainDef, <'regular' / 'poisson'>, tDuration <, mCorrelation, fMemTau>)
%
% Where: 'stTrainDef' is a spike train containing a simple train
% definition created by STCreate.  'tDuration' is the desired duration of the
% spike train in seconds.  The type of spike train is specified using either
% 'regular' or 'poisson'.  A regular train has equal inter-spike intervals
% based on the train freqeuncy.  A poisson train generates spikes according to
% a probability based on the train frequency.  'stTrain' (output) will have a
% 'instance' field added, containing the instantiated train.
%
% Note: Changing frequencies and regular spike trains don't play well
% together.  Perhaps a better algorithm for creating regular trains is
% required.
%
% --- ARRAY ARGUMENTS
%
% STInstantiate can accept arrays for any and all input arguments.  In the
% case of 'stTrainDef' and the temporal type, these must be cellular arrays.
% In the case of 'tDuration', 'mCorrelation' and 'fMemTau', these should be
% standard matrices.  If one or more arguments are passed as arrays, multiple
% spike trains will be instantiated, each train with options taken from one
% element of each array.  If only some arguments are passed as arrays, the
% scalar arguments will be applied to all trains.  When arrays of arguments
% are supplied, 'stTrain' will be a cellular array of instantiated spike
% trains.
%
% Note: Although the calling syntax allows for an array of 'tDuration's
% specifying a separate duration for each train, in practice this is not
% supported.  Please use a common duration for all trains.
%
% Example: cellST = STInstantiate({stDef1 stDef2}, 'poisson', 5);
%
% 'stDef1' and 'stDef2' are two different spike train definitions.  'cellST'
% will be a cell array with two elements, each containing a separate
% instantiated spike train.  These trains will have frequency profiles
% corresponding to 'stDef1' and 'stDef2', but will both be poissonian and of 5
% seconds duration.
%
% --- CORRELATED SPIKE TRAINS
%
% The optional argument 'mCorrelation' can be used to generate correlated spike
% trains.  'mCorrelation' should be a correlation matrix specifying the pairwise
% correlations between each of a set of spike trains.  The matrix should be in
% upper-diagonal form, with unit diagonal elements.  In this matrix, '1'
% specifies the maximum possible correlation and '-1' specifies the maximum
% possible anti-correlation.  Note that 'mCorrelation' must be positive
% definite.  This means that if the matrix is made symmetric, it will have
% only positive eigenvalues.
%
% Example: mCorr = [1.0 0.9 0.8;
%                   0.0 1.0 0.7;
%                   0.0 0.0 1.0];
%
% Executing STInstantiate with this correlation matrix will produce three
% spike trains; the correlation coefficient between trains 'i' and 'j' (with
% 'i' <= 'j') is given by 'mCorr(i, j)'.
%
% --- NON-ERGODIC SPIKE TRAINS
%
% The optional argument 'fMemTau' can be used to generate spike trains from a
% non-ergodic process (ie a random process with memory).  'fMemTau' will be
% the time constant for an exponential smoothing function.  'fMemTau' will be
% the time for the memory effect to reduce to approximately 35%.
%
% When both 'mCorrelation' and 'fMemTau' are supplied, correlated random
% sequences will be generated before being made non-ergodic.
%
% To impose non-erogidicy without correlations, provide an empty matrix for
% 'mCorrelation'.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

% -- Get options

stOptions = STOptions;
InstanceTemporalResolution = stOptions.InstanceTemporalResolution;
SpikeChunkLength = stOptions.SpikeChunkLength;


% -- Perform argument number and basic checks

if (nargin > 5)
    disp('--- STInstantiate: Extra arguments ignored');
end

if (nargin < 3)
    disp ('*** STInstantiate: Incorrect number of arguments');
    help STInstantiate;
    return;
end

% - Should we correlate the output trains?
bCorrelate = exist('mCorrelation', 'var') && ~isempty(mCorrelation);

% - Check that 'mCorrelation' is square, at least
if (bCorrelate && (size(mCorrelation, 1) ~= size(mCorrelation, 2)))
   disp('*** STInstantiate: The cross-correlation matrix must be square');
   return;
end

% - Should we make non-ergodic spike trains?
bMemory = exist('fMemTau', 'var');


% -- Force cellular input, if necessary

if (~iscell(stOldTrain))
   stOldTrain = {stOldTrain};
end
bArrayTrain = numel(stOldTrain) > 1;

if (~iscell(strTemporalType))
   strTemporalType = {strTemporalType};
end
bArrayTempType = numel(strTemporalType) > 1;

% -- Determine output sizes

if (bCorrelate)
   nCorrSize = size(mCorrelation, 1);
else
   nCorrSize = [];
end

if (bMemory)
   nMemTauSize = numel(fMemTau);
   bArrayMemTau = nMemTauSize > 1;
else
   nMemTauSize = [];
   bArrayMemTau = false;
end

vArgSizes = [numel(stOldTrain) ...
   numel(strTemporalType) ...
   numel(tDuration) ...
   nCorrSize ...
   nMemTauSize];

bArrayDuration = numel(tDuration) > 1;
bArrayOutput = any(vArgSizes > 1);
nNumTrains = max(vArgSizes);


% -- Set up argument arrays nicely

if (bArrayOutput)
   % -- Convert non-array arguments into arrays
   
   if (~bArrayTrain)
      % - Convert spike train
      stTrain = cell(nNumTrains, 1);
      stTrain(:) = deal(stOldTrain);
   else
      stTrain = stOldTrain;
   end
   
   if (~bArrayTempType)
      % - Convert temporal type
      strTempTypeCell = cell(nNumTrains, 1);
      strTempTypeCell(:) = deal(strTemporalType);
      strTemporalType = strTempTypeCell;
      clear strTempTypeCell;
   end
   
   if (~bArrayDuration)
      % - Convert durations
      tDuration = repmat(tDuration, nNumTrains, 1);
   end
   
   if (bMemory && ~bArrayMemTau)
      fMemTau = repmat(fMemTau, nNumTrains, 1);
      nMemTauSize = numel(fMemTau);
   end
   
   % - Get new argument sizes
   vArgSizes = [numel(stTrain) ...
      numel(strTemporalType) ...
      numel(tDuration) ...
      nCorrSize ...
      nMemTauSize];


   % -- Check that all arguments are the same size
   if (any(vArgSizes ~= nNumTrains))
      disp('*** STInstantiate: When arrays are supplied for input arguments, they');
      disp('       must all be of the same size');
      return;
   end
   
else
   stTrain = stOldTrain;
end


% -- Perform a detailed argument check

% - Get cell array of definitions nodes
sRef.type = '.';
sRef.subs = 'definition';
cDefinitions = CellForEachCell(@subsref, stTrain, sRef);
clear sRef;

if (bCorrelate)
   % - Print a warning if we're trying to correlate 'regular' spike trains
   if (any(CellForEach(@strcmp, strTemporalType, 'regular')))
      disp('--- STInstantiate: Warning: Spike trains created with a temporal type of');
      disp('       ''regular'' will not participate in the cross-correlation pattern.');
      disp('       These affected instances will not be correlated.');
   end

   % - Print a warning if we're trying to correlate gamma ISI generated spike trains
   sRef.type = '.';
   sRef.subs = 'strType';
   cDefTypes = CellForEachCell(@subsref, cDefinitions, sRef);
   if (any(CellForEach(@strcmp, cDefTypes, 'gamma')))
      disp('--- STInstantiate: Warning: Spike trains created with a gamma ISI distribution');
      disp('       will not participate in the cross-correlation pattern.  These affected');
      disp('       instances will not be correlated.');
   end
end

% - Check durations for zeros
if (any(tDuration == 0))
   disp('*** STInstantiate: Cannot instantiate a zero-duration spiketrain.');
   disp('       Use STNullTrain to create a zero-duration train.');
   return;
end

% - Check that the trains have definitions
if (~all(CellForEach(@isfield, stTrain, 'definition')))
    disp('*** STInstantiate: stTrainDef must contain a spike train defintion.');
    disp('       This error may be caused by a multiplexed spike train.  Definitions');
    disp('       are stripped when trains are multiplexed.');
    return;
end

% - Find which sort of instances we're creating
for (nTrainIndex = 1:nNumTrains)
   switch lower(strTemporalType{nTrainIndex})
      case {'regular', 'r'}
         fhTestSpike{nTrainIndex} = @STTestSpikeRegular;
        
      case {'poisson', 'p'}
         fhTestSpike{nTrainIndex} = @STTestSpikePoisson;
        
      otherwise
         % - Invalid temporal type specified, so bail
         fprintf(1, '*** STInstantiate: Unknown temporal spike train type [%s].', strTemporalType{nTrainIndex});
         disp('       Must be one of {''regular'', ''poisson''}');
         return;
   end
end

% - If we're correlating spike trains, the durations must all be identical
tTestDuration = tDuration(1);
if (any(tDuration ~= tTestDuration))
   if (bCorrelate)
      disp('*** STInstantiate: It doesn''t make much sense to try to correlate spike')
      disp('       trains with different durations.  If you really want this, use')
      disp('       STCrop afterwards.');
      return;
   else
      disp('*** STInstantiate: Really, it''s so much easier for me to generate spike');
      disp('       trains with identical durations.  Just do them separately, or use');
      disp('       STCrop afterwards.');
      return;
   end
end


% -- Check to see if we're overwriting anything

if (any(CellForEach(@isfield, stTrain, 'instance')))
    disp('--- STInstantiate: Warning: overwriting a previously instantiated spike train');
end

vbHasMapping = reshape(CellForEach(@isfield, stTrain, 'mapping'), 1, nNumTrains);
if (any(vbHasMapping))
   disp('--- STInstantiate: Warning: re-instantiating a mapped spike train.  The');
   disp('       previous mapping will be erased.');
   
   % - Remove mappings from the affected trains
   for (nTrainIndex = find(vbHasMapping))
      stTrain{nTrainIndex} = rmfield(stTrain{nTrainIndex}, 'mapping');
   end
end


% -- Initialise algorithm for each spike train

for (nTrainIndex = 1:nNumTrains)
   % - Create the instance nodes
   instance{nTrainIndex} = [];
   instance{nTrainIndex}.fTemporalResolution = InstanceTemporalResolution;
   instance{nTrainIndex}.tDuration = tDuration(nNumTrains);
   
   % - Check if we need to use chunked mode
   bChunkedMode = (tDuration(nNumTrains) / InstanceTemporalResolution) > SpikeChunkLength;
   instance{nTrainIndex}.bChunkedMode = bChunkedMode;
   vbChunkedMode(nTrainIndex) = bChunkedMode;

   % - Determine how many chunks are required
   if (bChunkedMode)
      nNumChunks = ceil((tDuration(nNumTrains) / InstanceTemporalResolution) / SpikeChunkLength);
      instance{nTrainIndex}.nNumChunks = nNumChunks;
      instance{nTrainIndex}.spikeList = cell(1, nNumChunks);
      vnNumChunks(nNumTrains) = nNumChunks;
   else
      vnNumChunks(nNumTrains) = 1;
   end
end


% -- Instantiate for each chunk

% - Get list of definition InstFreq vectors
sRef.type = '.';
sRef.subs = 'fhInstFreq';
vfhInstFreq = CellForEachCell(@subsref, cDefinitions, sRef);

% - Get total number of chunks
nNumChunks = max(vnNumChunks);

% - Display some progress
if (any(vbChunkedMode))
   STProgress('Instantiating: Chunk [%02d/%02d]', 0, nNumChunks);
end

for (nChunkIndex = 1:nNumChunks)
   % - Display some progress
   if (any(vbChunkedMode))
         STProgress('\b\b\b\b\b\b%02d/%02d]', nChunkIndex, nNumChunks);
   end
   
   % - Get start and end times for the current chunk
   tTimeStart = (nChunkIndex-1) * InstanceTemporalResolution * SpikeChunkLength;
   if (nChunkIndex == nNumChunks)
      tTimeEnd = tDuration(1);      % For now, assume identical durations
   else
      tTimeEnd = (nChunkIndex) * InstanceTemporalResolution * (SpikeChunkLength-1);
   end
   
   % - Create time step vector
   tTimeCurr = tTimeStart:InstanceTemporalResolution:tTimeEnd;
   
   % - Get instantaneous frequency vector
   fInstFreq = cell(1, nNumTrains);
   for (nTrainIndex = 1:nNumTrains)
      fInstFreq{nTrainIndex} = feval(vfhInstFreq{nTrainIndex}, cDefinitions{nTrainIndex}, tTimeCurr);
   end

   % - Check that we're not under-sampling
   fMaxFreq = max(CellForEach(@max, fInstFreq));
   if ((fMaxFreq * InstanceTemporalResolution) > 1.0001)
      disp('--- STInstantiate: Spike frequency is greater than the temporal resolution.');
      disp(sprintf('       Frequency [%.2f]MHz is clipped to [%.2f]MHz', ...
                   fMaxFreq / 1e3, (1/InstanceTemporalResolution) / 1e3));
   end

   % - If we're making correlated trains, generate some correlated random
   %   sequences
   if (bCorrelate)
      STProgress(' Generating correlated sequence...');
      mSeq = CorrUniRand(mCorrelation, length(tTimeCurr));
      STProgress('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b                                  \b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b');
   end

   % - Generate spikes
   for (nTrainIndex = 1:nNumTrains)
      if (bCorrelate)
         % - Use the pre-generated correlated random sequence
         vfCorrSeq = mSeq(:, nTrainIndex)';
      else
         % - Let the toolbox function generate its own random sequence
         vfCorrSeq = [];
      end
      
      if (bMemory)
         % - Force non-ergodic filtering of the random sequence
         fMemTauItem = fMemTau(nTrainIndex);
      else
         % - Don't perform filering
         fMemTauItem = [];
      end
      
      % - Generate the spike train
      nSpikeIndices = feval(fhTestSpike{nTrainIndex}, tTimeCurr, fInstFreq{nTrainIndex}, vfCorrSeq, fMemTauItem);
      spikeList = tTimeCurr(nSpikeIndices);

      % - Assign the spike list
      if (vbChunkedMode(nTrainIndex))
         % - Assign the chunk to the spike list
         instance{nTrainIndex}.spikeList{nChunkIndex} = spikeList';
      else
         % - Just assign the spike list (non-chunked)
         instance{nTrainIndex}.spikeList = spikeList';
      end
   end

   % - Print a line feed if we're displaying staus
   if (any(vbChunkedMode) && (nChunkIndex == nNumChunks))
      STProgress('\n');
   end
end

% - Assign instances to spike trains
for (nTrainIndex = 1:nNumTrains)
   stTrain{nTrainIndex}.instance = instance{nTrainIndex};
end

% - If we only have one output, strip the cell wrapper
if (~bArrayOutput)
   stTrain = stTrain{1};
end

% --- END of STInstantiate.m ---
