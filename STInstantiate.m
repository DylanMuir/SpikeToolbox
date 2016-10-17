function [stTrain] = STInstantiate(stOldTrain, strTemporalType, tDuration)

% STInstantiate - FUNCTION Convert spike train definitions into concrete trains
% $Id: STInstantiate.m 124 2005-02-22 16:34:38Z dylan $
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

% -- Get options

stOptions = STOptions;
InstanceTemporalResolution = stOptions.InstanceTemporalResolution;
SpikeChunkLength = stOptions.SpikeChunkLength;


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
   disp('*** STInstantiate: Cannot instantiate a zero-duration spiketrain');
   return;
end

stTrain = stOldTrain;

% -- Handle a cell array of spike trains

if (iscell(stTrain))
   for (nCellIndex = 1:prod(size(stTrain)))
      % - Send each cell individually to STInstantiate
      fprintf(1, 'Instantiating: Spike train [%02d/%02d]\n', nCellIndex, prod(size(stTrain)));
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
instance.fTemporalResolution = InstanceTemporalResolution;
instance.tDuration = tDuration;

% - Check if we need to use chunked mode
bChunkedMode = (tDuration / InstanceTemporalResolution) > SpikeChunkLength;
instance.bChunkedMode = bChunkedMode;

nNumChunks = 1;

if (bChunkedMode)
   % - Determine how many chunks are required
   nNumChunks = ceil((tDuration / InstanceTemporalResolution) / SpikeChunkLength);
   instance.nNumChunks = nNumChunks;
   instance.spikeList = cell(1, nNumChunks);
   
   fprintf(1, 'Instantiating: Chunk [%02d/%02d]', 0, nNumChunks);
end

for (nChunkIndex = 1:nNumChunks)
   % - Get start and end times for the current chunk
   tTimeStart = (nChunkIndex-1) * InstanceTemporalResolution * SpikeChunkLength;
   if (nChunkIndex == nNumChunks)
      tTimeEnd = tDuration;
   else
      tTimeEnd = (nChunkIndex) * InstanceTemporalResolution * (SpikeChunkLength-1);
   end
   
   tTimeCurr = tTimeStart:InstanceTemporalResolution:tTimeEnd;
   fInstFreq = feval(stTrain.definition.fhInstFreq, stTrain.definition, tTimeCurr);
    
   if ((max(fInstFreq) * InstanceTemporalResolution) > 1.0)
      disp('--- STInstantiateRegular: Spike frequency is greater than the temporal resolution.');
      disp(sprintf('      Frequency [%.2f]MHz is clipped to [%.2f]MHz', ...
                   max(fInstFreq) / 1e3, (1/InstanceTemporalResolution) / 1e3));
   end

   % - Find indices of tTimeCurr that correspond to a spike
   nSpikeIndices = feval(fhDoSpike, tTimeCurr, fInstFreq);
   spikeList = tTimeCurr(nSpikeIndices);

   if (bChunkedMode)
      % - Assign the chunk to the spike list
      instance.spikeList{nChunkIndex} = spikeList';
      fprintf(1, '\b\b\b\b\b\b%02d/%02d]', nChunkIndex, nNumChunks);
      
      % - Print a line feed if we're displaying staus
      if (nChunkIndex == nNumChunks)
         fprintf(1, '\n');
      end
      
   else
      % - Just assign the spike list (non-chunked)
      instance.spikeList = spikeList';
   end
end

% - Assign instance to spike train
stTrain.instance = instance;


% --- END of STInstantiate.m ---

% $Log: STInstantiate.m,v $
% Revision 2.5  2004/09/16 11:45:23  dylan
% Updated help text layout for all functions
%
% Revision 2.4  2004/09/02 08:23:18  dylan
% * Added a function STIsZeroDuration to test for zero duration spike trains.
%
% * Modified all functions to use this test rather than custom tests.
%
% Revision 2.3  2004/08/28 11:10:25  dylan
% STInstantiate now has prettier status output (nonote)
%
% Revision 2.2  2004/08/27 12:49:15  dylan
% Added more descriptive progress indicators to STMap and STInstantiate (nonote)
%
% Revision 2.1  2004/07/19 16:21:02  dylan
% * Major update of the spike toolbox (moving to v0.02)
%
% * Modified the procedure for retrieving and setting toolbox options.  The new
% suite of functions comprises of STOptions, STOptionsLoad, STOptionsSave,
% STOptionsDescribe, STCreateGlobals and STIsValidOptionsStruct.  Spike Toolbox
% 'factory default' options are defined in STToolboxDefaults.  Options can be
% saved as user defaults using STOptionsSave, and will be loaded automatically
% for each session.
%
% * Removed STAccessDefaults and STCreateDefaults.
%
% * Renamed STLogicalAddressConstruct, STLogicalAddressExtract,
% STPhysicalAddressContstruct and STPhysicalAddressExtract to
% STAddr<type><verb>
%
% * Drastically modified the way synapse addresses are specified for the
% toolbox.  A more generic approach is now taken, where addressing modes are
% defined by structures that outline the meaning of each bit-field in a
% physical address.  Fields can have their bits reversed, can be ignored, can
% have a description attached, and can be marked as major or minor fields.
% Any type of neuron/synapse topology can be addressed in this way, including
% 2D neuron arrays and chips with no separate synapse addresses.
%
% The following functions were created to handle this new addressing mode:
% STAddrDescribe, STAddrFilterArgs, STAddrSpecChannel, STAddrSpecCompare,
% STAddrSpecDescribe, STAddrSpecFill, STAddrSpecIgnoreSynapseNeuron,
% STAddrSpecInfo, STAddrSpecSynapse2DNeuron, STIsValidAddress, STIsValidAddrSpec,
% STIsValidChannelAddrSpec and STIsValidMonitorChannelsSpecification.
%
% This modification required changes to STAddrLogicalConstruct and Extract,
% STAddrPhysicalConstruct and Extract, STCreate, STExport, STImport,
% STStimulate, STMap, STCrop, STConcat and STMultiplex.
%
% * Removed the channel filter functions.
%
% * Modified STDescribe to handle the majority of toolbox variable types.
% This function will now describe spike trains, addressing specifications and
% spike toolbox options.  Added STAddrDescribe, STOptionsDescribe and
% STTrainDescribe.
%
% * Added an STIsValidSpikeTrain function to test the validity of a spike
% train structure.  Modified many spike train manipulation functions to use
% this feature.
%
% * Added features to Todo.txt, updated Readme.txt
%
% * Added an info.xml file, added a welcome HTML file (spike_tb_welcome.html)
% and associated images (an_spike-big.jpg, an_spike.gif)
%
% Revision 2.0  2004/07/13 12:56:32  dylan
% Moving to version 0.02 (nonote)
%
% Revision 1.2  2004/07/13 12:55:19  dylan
% (nonote)
%
% Revision 1.1  2004/06/04 09:35:47  dylan
% Reimported (nonote)
%
% Revision 1.9  2004/05/05 16:15:17  dylan
% Added handling for zero-length spike trains to various toolbox functions
%
% Revision 1.8  2004/05/04 09:40:07  dylan
% Added ID tags and logs to all version managed files
%