function [addrPhys] = STAddrPhysicalConstruct(varargin)

% STAddrPhysicalConstruct - FUNCTION Determine a synapse physical address
% $Id: STAddrPhysicalConstruct.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [addrPhys] = STAddrPhysicalConstruct(nAddr1, nAddr2, ...)
%        [addrPhys] = STAddrPhysicalConstruct(stasSpecification, nAddr1, nAddr2, ...)
%
% STAddrLogicalConstruct will return the logical address corresponding to a
% synapse address provided by the addressing fields.  The returned address will
% take the form defined by the addressing specification.  If a specification
% is not supplied in the argument list, the default output address
% specification will be taken from the toolbox options.
%
% Fields will be taken from the command line in least to most significant order.
% STAddrPhysicalConstruct uses the floor of all addressing fields.
% STAddrPhysicalConstruct is also vectorised.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 1st April, 2004 (no, really)

% -- Get options

stOptions = STOptions;


% -- Check arguments

if (nargin < 1)
   disp('*** STAddrPhysicalConstruct: Incorrect number of arguments');
   help STAddrPhysicalConstruct;
   return;
end

% - Check for a valid address
if (~STIsValidAddress(varargin{:}))
   disp('*** STAddrPhysicalConstruct: An invalid address was supplied for the given');
   disp('       addressing specification');
   return;
end


% -- Extract the addressing arguments

[stasSpecification, varargin] = STAddrFilterArgs(varargin{:});

% - Fill empty fields in the specification
stasSpecification = STAddrSpecFill(stasSpecification);


% -- Construct the address

nFieldIndex = 1;
nBitsUsed = 0;
addrPhys = 0;
for (nEntryIndex = 1:length(stasSpecification))
   nFieldWidth = stasSpecification(nEntryIndex).nWidth;
   if (~stasSpecification(nEntryIndex).bIgnore)
      % - Constrain supplied index to the width of the field
      nComponent = bitshift(varargin{nFieldIndex}, 0, nFieldWidth);
      
      % - Reverse the bits in the field if required
      if (FieldExists(stasSpecification(nEntryIndex), 'bReverse') && stasSpecification(nEntryIndex).bReverse)
         nComponent = BitReverse(nComponent, nFieldWidth);
      end
      
      % - Invert the bits in the field if required
      if (FieldExists(stasSpecification(nEntryIndex), 'bInvert') && stasSpecification(nEntryIndex).bInvert)
         nComponent = (2^nFieldWidth - 1) - nComponent;
      end

      % - Shift the field left
      nComponent = nComponent .* 2^(nBitsUsed);
      
      addrPhys = addrPhys + nComponent;
     
      nFieldIndex = nFieldIndex + 1;
   end
   nBitsUsed = nBitsUsed + nFieldWidth;
end

return;

% --- END of STAddrPhysicalConstruct.m ---
 
% $Log: STAddrPhysicalConstruct.m,v $
% Revision 2.8  2004/09/16 11:45:22  dylan
% Updated help text layout for all functions
%
% Revision 2.7  2004/08/28 10:46:33  dylan
% * Extracted BitReverse from STAddrPhysical* and put it in the utilities
% directory. STAddPhysical* now rely on this function.
%
% * STAddrPhysicalExtract now correctly reverses bit fields instead of ignoring
% the 'bReverse' flag in the addressing specification.  Nasty.
%
% Revision 2.6  2004/08/25 12:49:22  dylan
% * Fixed a bug in STMultiplex, where spike trains with different levels
% could not be multiplexed, even if they shared a common level.
% STMultiplex now requires CellForEachCell, in the utilities repository.
%
% * Added a feature request to Todo.txt
%
% Revision 2.5  2004/08/24 10:00:27  dylan
% Fixed a bug in STAddrPhysicalConstruct -- the function did not handle ignored
% fields correctly, resulting in incorrect and possibly invalid physcial
% addresses.
%
% Revision 2.4  2004/08/24 09:59:28  dylan
% "`cat commitlog`"
%
% Revision 2.3  2004/07/30 10:18:17  dylan
% * Added a new field to addressing specifications: bInvert will cause a field
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
% Revision 2.0  2004/07/13 12:56:31  dylan
% Moving to version 0.02 (nonote)
%
% Revision 1.2  2004/07/13 12:55:19  dylan
% (nonote)
%
% Revision 1.1  2004/06/04 09:35:46  dylan
% Reimported (nonote)
%
% Revision 1.2  2004/05/25 10:51:05  dylan
% Bug fixes (nonote)
%
% Revision 1.1  2004/05/09 17:55:15  dylan
% * Created STFlatten function to convert a spike train mapping back into an
% instance.
% * Created STExtract function to extract a train(s) from a multiplexed
% mapped spike train
% * Renamed STConstructAddress to STAddrPhysicalConstruct
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