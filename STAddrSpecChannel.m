function [stasSpecification] = STAddrSpecChannel(nIgnoreBits, nChannelBits, bInvert)

% STAddrSpecChannel - FUNCTION Address specification utility function
% $Id: STAddrSpecChannel.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [stasSpecification] = STAddrSpecChannel(nIgnoreBits, nChannelBits)
%        [stasSpecification] = STAddrSpecChannel(nIgnoreBits, nChannelBits, bInvert)
%
% This function returns an address specification structure for use with the
% Spike Toolbox.  This specification will contain a single ignored address
% field and a single channel address field, with user-specified widths.  The
% channel address field is most significant.
%
% The user can optionally supply an argument 'bInvert'.  If this boolean value
% is true, the channel ID address field will have its bits inverted.  If not
% supplied, this argument defaults to false.
%
% This function is used to help identify the bits used for channel ID
% filtering for monitored spike trains.
%
% Type 'help STAddrSpecInfo' for information about specifying address formats.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 14th July, 2004 

% -- Check arguments

if (nargin > 3)
   disp('--- STAddrSpecChannel: Extra arguments ignored');
end

if (nargin < 2)
   disp('*** STAddrSpecChannel: Incorrect usage');
   help STAddrSpecChannel;
   return;
end

if (nargin < 3)
   bInvert = false;
end


% -- Make the address specification structure

% - 'Ignore' address field
field.Description = '(Ignored)';
field.nWidth = nIgnoreBits;
field.bReverse = false;
field.bInvert = false;
field.bMajorField = false;
field.bRangeCheck = false;
field.bIgnore = true;
stasSpecification(1) = field;

% - Channel ID address field
clear field;
field.Description = 'Channel ID';
field.nWidth = nChannelBits;
field.bReverse = false;
field.bInvert = bInvert;
field.bMajorField = false;
field.bRangeCheck = false;
field.bIgnore = false;
stasSpecification(2) = field;


% - Check to make sure it's a valid spec
if (~STIsValidAddrSpec(stasSpecification))
   disp('*** STAddrSpecChannel: Invalid specification supplied');
   clear stasSpecification;
   return;
end

% --- END of STAddrSpecChannel.m ---

% $Log: STAddrSpecChannel.m,v $
% Revision 2.4  2004/09/16 11:45:22  dylan
% Updated help text layout for all functions
%
% Revision 2.3  2004/07/30 10:18:17  dylan
% * Added a new field to addressing specifications: bIgnore will cause a field
% in a hardware address to be binary-inverted when converting to and from
% hardware addresses.
%
% Revision 2.2  2004/07/30 09:00:36  dylan
% Fixed a bug in STAddrSpecIgnoreSYnapseNeuron.m (nonote)
%
% Revision 2.1  2004/07/19 16:21:01  dylan
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