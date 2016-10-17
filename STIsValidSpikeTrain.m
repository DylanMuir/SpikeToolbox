function [bValid] = STIsValidSpikeTrain(stTrain)

% STIsValidSpikeTrain - FUNCTION Test for a valid spike train
% $Id: STIsValidSpikeTrain.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [bValid] = STIsValidSpikeTrain(stTrain)
%
% STIsValidSpikeTrain will test whether an object is a valid spike toolbox
% spike train.  'bValid' will indicate the result of this test.
%
% 'bValid' will be true for zero-duration spike trains.  See STIsZeroDuration
% to test for this condition.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 18th July, 2004

% -- Check arguments

if (nargin > 1)
   disp('--- STIsValidSpikeTrain: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STIsValidSpikeTrain: Incorrect number of arguments');
   help STIsValidSpikeTrain;
   return
end


% -- Test the spike train

bValid = false;

% - Does any spike train level structure exist?
if (~FieldExists(stTrain, 'mapping') & ...
    ~FieldExists(stTrain, 'instance') & ...
    ~FieldExists(stTrain, 'definition'))
   disp('--- STIsValidSpikeTrain: No spike train level exists');
   return;
end

if (FieldExists(stTrain, 'mapping'))
   mapping = stTrain.mapping;
   if (~FieldExists(mapping, 'tDuration') | ...
       ~FieldExists(mapping, 'fTemporalResolution') | ...
       ~FieldExists(mapping, 'bChunkedMode') | ...
       ~isfield(mapping, 'spikeList'))
      disp('--- STIsValidSpikeTrain: Invalid spike train mapping structure');
      return;
   end
end

if (FieldExists(stTrain, 'instance'))
   instance = stTrain.instance;
   if (~FieldExists(instance, 'fTemporalResolution') | ...
       ~FieldExists(instance, 'tDuration') | ...
       ~FieldExists(instance, 'bChunkedMode') | ...
       ~isfield(instance, 'spikeList'))
      disp('--- STIsValidSpikeTrain: Invalid spiketrain instance structure');
      return;
   end
end

if (FieldExists(stTrain, 'definition'))
   definition = stTrain.definition;
   if (~FieldExists(definition, 'strType'))
      disp('--- STIsValidSpikeTrain: Invalid spike train definition');
      return;
   end
end


% -- The tests were passed

bValid = true;

% --- END of STIsValidSpikeTrain.m ---

% $Log: STIsValidSpikeTrain.m,v $
% Revision 2.4  2005/02/22 14:27:54  chiara
% *** empty log message ***
%
% Revision 2.3  2004/09/16 11:45:23  dylan
% Updated help text layout for all functions
%
% Revision 2.2  2004/09/02 08:23:18  dylan
% * Added a function STIsZeroDuration to test for zero duration spike trains.
%
% * Modified all functions to use this test rather than custom tests.
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