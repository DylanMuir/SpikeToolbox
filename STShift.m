function [stShiftedTrain] = STShift(stTrain, tOffset)

% STShift - FUNCTION Offset a spike train in time
% $Id: STShift.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [stShiftedTrain] = STShift(stTrain, tOffset)
%
% 'stTrain' is an either instantiated or mapped spike train.  'tOffset' is a
% time in seconds to offset the spike train by.  'stShiftedTrain' will have an
% instance or mapping or both, depending on the input in 'stTrain'.
%
% Note that shifting a spike train with a definition will strip the definition
% from the train.  Shifting a spike train with only a definition will erase
% the train and STShift will return an empty matrix.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 3rd May, 2004

% -- Check arguments

if (nargin > 2)
   disp('--- STShift: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** STShift: Incorrect usage');
   help STShift;
   return;
end

% - Test for zero-duration spike trains
if (STIsZeroDuration(stTrain))
   stShiftedTrain = stTrain;
   return;
end


% -- Shift train

if (FieldExists(stTrain, 'instance'))
   stShiftedTrain.instance = STShiftNode(stTrain.instance, tOffset);
   stShiftedTrain.instance.tDuration = stShiftedTrain.instance.tDuration + tOffset;
end

if (FieldExists(stTrain, 'mapping'))
	% - How many time bins should we shift?
	nBinOffset = round(tOffset / stTrain.mapping.fTemporalResolution);
	
	% - Are we shifting at all?
	if (nBinOffset < 1)
		disp('--- STShift: The time offset was negligible for shifting the mapped train');
		stShiftedTrain.mapping = stTrain.mapping;
	else
		stShiftedTrain.mapping = STShiftNode(stTrain.mapping, nBinOffset);
   end
   
   % - Shift duration
   stShiftedTrain.mapping.tDuration = stShiftedTrain.mapping.tDuration + tOffset;
end

if (isfield(stTrain, 'definition'))
   disp('--- STShift: Warning: A spike train definition was stripped from the shifted train');
end

if (~exist('stShiftedTrain', 'var'))
   disp('--- STShift: There''s nothing left!');
   stShiftedTrain = [];
end

% --- FUNCTION STShiftNode

function [nodeShifted] = STShiftNode(node, tOffset)

nodeShifted = node;

% - Extract the spike train

if (node.bChunkedMode)
   spikeList = node.spikeList;
else
   spikeList = {node.spikeList};
end

% - Shift the spike train

for (nChunkIndex = 1:length(spikeList))
   spikeList{nChunkIndex}(:, 1) = spikeList{nChunkIndex}(:, 1) + tOffset;
end

% - Reassign the shifted spike list

if (node.bChunkedMode)
   nodeShifted.spikeList = spikeList;
else
   nodeShifted.spikeList = spikeList{1};
end

% --- END of STShift.m ---

% $Log: STShift.m,v $
% Revision 2.10  2004/11/29 18:46:29  dylan
% Whoops again! (nonote)
%
% Revision 2.9  2004/11/29 18:45:49  dylan
% Whoops! (nonote)
%
% Revision 2.8  2004/11/29 18:45:20  dylan
% Fixed a bug in STShift; mapped spike trains would have an incorrect shift applied to their duration
%
% Revision 2.7  2004/09/16 11:45:23  dylan
% Updated help text layout for all functions
%
% Revision 2.6  2004/09/02 08:23:18  dylan
% * Added a function STIsZeroDuration to test for zero duration spike trains.
%
% * Modified all functions to use this test rather than custom tests.
%
% Revision 2.5  2004/08/30 12:47:18  dylan
% Fiexed a bug in STShift where the spike train duration would not be correctly
% changed.  STShift now adds the offset to the original duration.
%
% Revision 2.4  2004/08/26 16:19:30  dylan
% * Fixed a bug in STShift when shifting mapped spiketrains.  Sometimes the
%   shifting offset would result in a non-integer number of mapping spike bins.
%   This would cause invalid spiketrain timestamps to be generated.
%
% * STShift now warns the user if a time shift will result in a negligible
%   shift in a mapped spiketrain, ie the shifted train will be identical to the
%   original. (nonote)
%
% Revision 2.3  2004/08/26 09:04:16  dylan
% Updated help text for STShift (nonote)
%
% Revision 2.2  2004/08/26 09:02:34  dylan
% STShift now prints a message if it can't shift the train without erasing it.
%
% Revision 2.1  2004/07/19 16:21:03  dylan
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
% Revision 1.3  2004/05/05 16:15:17  dylan
% Added handling for zero-length spike trains to various toolbox functions
%
% Revision 1.2  2004/05/04 09:40:07  dylan
% Added ID tags and logs to all version managed files
%
