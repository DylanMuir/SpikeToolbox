function [stNormTrain] = STNormalise(stTrain)

% STNormalise - FUNCTION Shift a spike train to time zero and fix its duration
% $Id: STNormalise.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [stNormTrain] = STNormalise(stTrain)
%
% This function will shift the first spike in a spike train to time zero, and
% correct the duration fields of the spike train object to reflect the true
% duration of the train.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Date: 14th May, 2004

% -- Check arguments

if (nargin > 1)
   disp('--- STNormalise: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STNormalise: Incorrect usage');
   help STNormalise;
   return;
end


% -- Normalise spike levels

if (isfield(stTrain, 'mapping'))
   stNormTrain.mapping = STNormaliseNode(stTrain.mapping);
   stNormTrain.mapping.tDuration = stNormTrain.mapping.tDuration * stNormTrain.mapping.fTemporalResolution;
end

if (isfield(stTrain, 'instance'))
   stNormTrain.mapping = STNormaliseNode(stTrain.instance);
end

if (isfield(stTrain, 'definition'))
   disp('--- STNormalise: Warning: Spike train definitions are stripped from normalised spike trains');
end


% --- FUNCTION STNormaliseNode

function [nodeNorm] = STNormaliseNode(node)

nodeNorm = node;

% - Extract spike list
if (nodeNorm.bChunkedMode)
   spikeList = node.spikeList;
   nNumChunks = node.nNumChunks;
else
   spikeList = {node.spikeList};
end

tOldFirstSpikeTime = spikeList{1}(1, 1);

% - Normalise chunks
for (nChunkIndex = 1:length(spikeList))
   spikeList{nChunkIndex}(:, 1) = spikeList{nChunkIndex}(:, 1) - tOldFirstSpikeTime;
end

% - Correct duration
nodeNorm.tDuration = max(spikeList{nNumChunks}(:, 1));

% - Reassign spike list
if (nodeNorm.bChunkedMode)
   nodeNorm.spikeList = spikeList;
else
   nodeNorm.spikeList = spikeList{1};
end

% --- END of STNormalise.m ---

% $Log: STNormalise.m,v $
% Revision 2.2  2004/09/16 11:45:23  dylan
% Updated help text layout for all functions
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
% Revision 1.1  2004/06/04 09:35:48  dylan
% Reimported (nonote)
%
% Revision 1.1  2004/05/14 15:37:19  dylan
% * Created utilities/CellFlatten.m -- CellFlatten coverts a list of items
% into a cell array containing a single cell for each item.  CellFlatten will
% also flatten the heirarchy of a nested cell array, returning all cell
% elements on a single dimension
% * Created utiltites/CellForEach.m -- CellForEach executes a specified
% function for each top-level element of a cell array, and returns a matrix of
% the results.
% * Converted spike_tb/STFindMatchingLevel to natively process cell arrays of trains
% * Converted spike_tb/STMultiplex to natively process cell arrays of trains
% * Created spike_tb/STCrop.m -- STCrop will crop a spike train to a specified
% time extent
% * Created spike_tb/STNormalise.m -- STNormalise will shift a spike train to
% begin at zero (first spike is at zero) and correct the duration
%