function STAddrDescribe(varargin)

% STAddrDescribe - FUNCTION Print information about an address
% $Id: STAddrDescribe.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: STAddrDescribe(nAddr1, nAddr2, ...)
%        STAddrDescribe(stasSpecification, nAddr1, nAddr2, ...)
%
% This function will display information about a spike toolbox address.  The
% addressing fields should be sent as function arguments.  If an addressing
% specification is not included in the argument list, the default output
% addressing specification will be taken from the toolbox options.
%
% Note: STAddrDescribe is NOT vectorised.  That wouldn't be very useful
% anyway.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 19th July, 2004 

% -- Check arguments

if (nargin < 1)
   disp('*** STAddrDescribe: Incorrect usage');
   help STAddrDescribe;
   return;
end


% -- Extract the address

[stasSpecification, varargin] = STAddrFilterArgs(varargin{:});

% - Check that we were supplied with a valid specification
if (~STIsValidAddrSpec(stasSpecification))
   disp('--- STIsValidAddress: An invalid addressing specification was supplied');
   return;
end

% - Fill out the empty fields in the specificaiton
stasSpecification = STAddrSpecFill(stasSpecification);

% - Is the address valid?
if (~STIsValidAddress(stasSpecification, varargin{:}))
   disp('*** STAddrDescribe: Invalid address');
   return;
end


% -- Display the address

% - Print the fields
disp('Address fields:');

nFieldIndex = 1;
for (nEntryIndex = 1:length(stasSpecification))
   if (~stasSpecification(nEntryIndex).bIgnore)
      fprintf(1, '   [%s]: [%d]\n', stasSpecification(nEntryIndex).Description, varargin{nFieldIndex});
      nFieldIndex = nFieldIndex + 1;
   end
end

fprintf('\n');

% - Print the specification
disp('Addressing specification:');
fprintf(1, '   ');
STAddrSpecDescribe(stasSpecification);
fprintf(1, '\n');

% - Print the logical and physical addresses
fprintf(1, 'Logical address: [%.4f]\n', STAddrLogicalConstruct(stasSpecification, varargin{:}));
fprintf(1, 'Physical address: [%x] hex\n', STAddrPhysicalConstruct(stasSpecification, varargin{:}));
fprintf(1, '\n');

% --- END of STAddrDescribe.m ---

% $Log: STAddrDescribe.m,v $
% Revision 2.3  2004/09/16 11:45:22  dylan
% Updated help text layout for all functions
%
% Revision 2.2  2004/07/30 10:18:17  dylan
% * Added a new field to addressing specifications: bIgnore will cause a field
% in a hardware address to be binary-inverted when converting to and from
% hardware addresses.
%
% Revision 2.1  2004/07/19 16:21:00  dylan
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