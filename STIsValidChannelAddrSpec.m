function [bValid] = STIsValidChannelAddrSpec(stasChannelSpec)

% STIsValidChannelAddrSpec - FUNCTION Checks an address specification for use with channel IDs
% $Id: STIsValidChannelAddrSpec.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [bValid] = STIsValidChannelAddrSpec(stasChannelSpec)
%
% This function verifies that an addresssing specification is valid to be used
% to specify the monitor channel ID address.  The specification must contain
% two fields only, the first ignore and the second not ignored.  The second
% field will specify the bits interpreted as the monitor channel ID.  The
% descriptions are ignored.
%
% See 'STAddrSpecChannel' for help in creating a valid channel addressing
% specification.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 18th July, 2004

% -- Check arguments

if (nargin > 1)
   disp('--- STIsValidChannelAddrSpec: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STIsValidChannelAddrSpec: Incorrect usage');
   return;
end


% -- Check the specification

bValid = false;

% - Is it even a valid specification?
if (~STIsValidAddrSpec(stasChannelSpec))
   disp('--- STIsValidChannelAddrSpec: An invalid addressing specification was supplied');
   return;
end

% - Check for a valid channel addressing specification
if ((length(stasChannelSpec) ~= 2) | ~stasChannelSpec(1).bIgnore | stasChannelSpec(2).bIgnore)
   % - There should be two fields only, the first ignored and the second
   % not ignored
   disp('--- STIsValidChannelAddrSpec: The addressing specification supplied for the monitor');
   disp('       channel ID does not meet the requirements for that use.  Please use');
   disp('       ''STAddrSpecChannel'' to create a conforming specification.');
   return;
end


% -- Passed the tests

bValid = true;

% --- END of STIsValidChannelAddrSpec.m ---

% $Log: STIsValidChannelAddrSpec.m,v $
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