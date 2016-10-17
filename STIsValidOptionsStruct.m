function [bValid] = STIsValidOptionsStruct(stOptions)

% STIsValidOptionsStruct - FUNCTION Tests for a valid Spike Toolbox options structure
% $Id: STIsValidOptionsStruct.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [bValid] = STIsValidOptionsStruct(stOptions)
%
% 'stOptions' is a matlab variable.  If 'stOptions' is a valid options
% structure, 'bValid' will be true.  Otherwise 'bValid' will be false.  Type
% 'help STOptions' for help on retrieving a valid Spike Toolbox options
% structure.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 13th July, 2004

% -- Declare globals
global ST_OPTIONS_STRUCTURE_SIGNATURE;
STCreateGlobals;

% -- Check arguments

if (nargin < 1)
   disp('*** STIsValidOptionsStruct: Incorrect usage');
   help STIsValidOptionsStruct;
   return;
end

bValid = false;

% - Check for the signature field
if (~isfield(stOptions, 'Signature'))
   return;
end

% - Check for a valid signature
if (~strcmp(stOptions.Signature, ST_OPTIONS_STRUCTURE_SIGNATURE))
   disp('--- STIsValidOptionsStruct: Invalid options signature field.  This options');
   disp('       structure may be from a previous revision of the toolbox');
   return;
end

% - Check for a valid output addressing specification
if (~STIsValidAddrSpec(stOptions.stasDefaultOutputSpecification))
   disp('--- STIsValidOptionsStruct: An invalid output addressing specification was');
   disp('       supplied in the options structure');
   return;
end

% - Check for valid monitor channel addressing specifications
if (FieldExists(stOptions, 'MonitorChannelsAddressing'))
   if (~STIsValidMonitorChannelsSpecification(stOptions.MonitorChannelsAddressing))
      % - The spec is invalid
      return;
   end
else
   % - The field doesn't even exist!
   disp('--- STIsValidOptionsStruct: No addressing specifications were supplied for');
   disp('       the monitor channels in the options structure');
end



if (FieldExists(stOptions, 'stasMonitorChannelID'))
   if (~STIsValidChannelAddrSpec(stOptions.stasMonitorChannelID))
      % - The spec is invalid
      return;
   end
else
   % - The spec doesn't even exist!
   disp('--- STIsValidOptionsStruct: No addressing specifcation was supplied for the');
   disp('       monitor channel ID in the options structure');
   return;
end


% -- Passed the tests

bValid = true;

% --- END of STIsValidOptionsStruct ---

% $Log: STIsValidOptionsStruct.m,v $
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