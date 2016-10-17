function [addrLog] = STAddrLogicalConstruct(varargin)

% STAddrLogicalConstruct - FUNCTION Build a logical address from a neuron and synapse ID
% $Id: STAddrLogicalConstruct.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [addrLog] = STAddrLogicalConstruct(nAddr1, nAddr2, ...)
%        [addrLog] = STAddrLogicalConstruct(stasSpecification, nAddr1, nAddr2, ...)
%
% STAddrLogicalConstruct will return the logical address corresponding to a
% synapse address provided by the addressing fields.  The returned address will
% take the form defined by the addressing specification.  If a specification
% is not supplied in the argument list, the default output address
% specification will be taken from the toolbox options.
%
% Address fields marked as 'major' fields in the specification will be to the
% left of the decimal point.  Fields marked as 'minor' fields will be to the
% right of the decimal point.  Fields will be taken from the command line in
% least to most significant order.  The most significant 'minor' field will be
% closest to the decimal point.
%
% Note that logical addresses are intended to be in semi-human readable form,
% and therefore addressing fields marked for reversal will not be reversed.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 9th May, 2004

% -- Check arguments

if (nargin < 1)
   disp('*** STAddrLogicalConstruct: Incorrect number of arguments');
   help STAddrLogicalConstruct;
   return;
end

% - Check for a valid address
if (~STIsValidAddress(varargin{:}))
   disp('*** STAddrLogicalConstruct: An invalid address was supplied for the given');
   disp('       addressing specification');
   return;
end


% -- Extract the addressing arguments

[stasSpecification, varargin] = STAddrFilterArgs(varargin{:});

% - Fill empty fields in the specification
stasSpecification = STAddrSpecFill(stasSpecification);

% -- Construct the address

nFieldIndex = 1;
nIntegerBitsUsed = 0;
nFractionalComponent = 0;
nIntegerComponent = 0;
for (nEntryIndex = 1:length(stasSpecification))
   if (~stasSpecification(nEntryIndex).bIgnore)
      % - Constrain to the width of the field
      nComponent = bitshift(varargin{nFieldIndex}, 0, stasSpecification(nEntryIndex).nWidth);

      if (stasSpecification(nEntryIndex).bMajorField)
         % - Use as a integer component
         % - Shift the field left
         nComponent = nComponent .* 2^(nIntegerBitsUsed);
         nIntegerComponent = nIntegerComponent + nComponent;
         nIntegerBitsUsed = nIntegerBitsUsed + stasSpecification(nEntryIndex).nWidth;
      else
         % - Use as a fractional component
         % - Shift the existing stuff right
         nFractionalComponent = nFractionalComponent .* 2^(-stasSpecification(nEntryIndex).nWidth);
         nFractionalComponent = nFractionalComponent + nComponent .* 2^(-stasSpecification(nEntryIndex).nWidth);
      end
      
      nFieldIndex = nFieldIndex + 1;
   end
end

addrLog = nIntegerComponent + nFractionalComponent;

% --- END of STAddrLogicalConstruct.m ---

% $Log: STAddrLogicalConstruct.m,v $
% Revision 2.2  2004/09/16 11:45:22  dylan
% Updated help text layout for all functions
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
% Revision 2.0  2004/07/13 12:56:31  dylan
% Moving to version 0.02 (nonote)
%
% Revision 1.2  2004/07/13 12:55:19  dylan
% (nonote)
%
% Revision 1.1  2004/06/04 09:35:46  dylan
% Reimported (nonote)
%
% Revision 1.1  2004/05/09 17:55:15  dylan
% * Created STFlatten function to convert a spike train mapping back into an
% instance.
% * Created STExtract function to extract a train(s) from a multiplexed
% mapped spike train
% * Renamed STConstructAddress to STConstructPhysicalAddress
% * Modified the address format for spike train mappings such that the
% integer component of an address specifies the neuron.  This makes raster
% plots much easier to read.  The format is now
% |STDEF_NEURON_BITS|.|STDEF_SYNAPSE_BITS|  This is now referred to as a logical
% address.  The format required by the PCIAER board is referred to as a
% physical address.
% * Created STConstructLogicalAddress and STExtractLogicalAddress to
% convert neuron and synapse IDs to and from logical addresses
% * Created STExtractPhysicalAddress to convert a physical address back to
% neuron and synapse IDs
% * Modified STConstructPhysicalAddress so that it accepts vectorised input
% * Modified STConcat so that it accepts cell arrays of spike trains to
% concatenate
% * Modified STExport, STImport so that they handle logical / physical
% addresses
% * Fixed a bug in STMultiplex and STConcat where spike event addresses were
% modified when temporal resolutions were different across spike trains
% * Modified STFormats to reflect addresss format changes
%