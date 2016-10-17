function [varargout] = STAddrLogicalExtract(addrLog, stasSpecification)

% STAddrLogicalExtract - FUNCTION Extract the neuron and synapse IDs from a logical address
% $Id: STAddrLogicalExtract.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [nAddr1, nAddr2, ...] = STAddrLogicalExtract(addrLog)
%        [nAddr1, nAddr2, ...] = STAddrLogicalExtract(addrLog, stasSpecification)
%
% 'addrLog' should be a logical address as constructed by
% STAddrLogicalConstruct.  STAddrLogicalExtract will extract the
% indices for each addressing field, as defined by the addressing
% specification.  If this specification is not supplied in the argument
% list, the default output addressing specification will be taken from
% the toolbox options.  The field indices will be returned in the variable
% length argument list.  STAddrLogicalExtract is vectorised.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 9th May, 2004

% -- Get options

stOptions = STOptions;


% -- Check arguments

if (nargin > 2)
   disp('--- STAddrLogicalExtract: Extra arguments ignored');
end

if (nargin < 2)
   stasSpecification = stOptions.stasDefaultOutputSpecification;
end

if (nargin < 1)
   disp('*** STAddrLogicalExtract: Incorrect usage');
   help STAddrLogicalExtract;
   return;
end

% - Check for a valid address specification
if (~STIsValidAddrSpec(stasSpecification))
   disp('*** STAddrLogicalExtract: Invalid addressing specification supplied');
   return;
end

% - Check for the correct number of output arguments
nRequiredFields = sum(~[stasSpecification.bIgnore]);

if (nargout ~= nRequiredFields)
   disp('--- STAddrLogicalExtract: Outputting a different number of addressing fields');
   disp('       than you''ve provided');
end


% -- Extract the indices

% - Which field are major?
vbMajorField = [stasSpecification.bMajorField];
vbMinorField = ~vbMajorField;

% - Count bits for the minor fields
if (any(vbMinorField))
   nMinorBits = sum(stasSpecification(find(~vbMajorField)).nWidth);
else
   nMinorBits = 0;
end

% - Separate the major and minor fields
nMajorAddress = fix(addrLog);
nMinorAddress = (addrLog - fix(addrLog)) .* 2^nMinorBits;

nField = 1;
for (nEntryIndex = 1:length(stasSpecification))
   if (~stasSpecification(nEntryIndex).bIgnore)
      if (vbMajorField(nEntryIndex))
         % - Mask off the current address field
         varargout{nField} = bitshift(nMajorAddress, 0, stasSpecification(nEntryIndex).nWidth);
         
         % - Shift the rest of the field, truncate the decimal portion
         nMajorAddress = fix(nMajorAddress .* 2^(-stasSpecification(nEntryIndex).nWidth));
      else
         % - Mask off the current address field
         varargout{nField} = bitshift(nMinorAddress, 0, stasSpecification(nEntryIndex).nWidth);
         
         % - Shift the rest of the field
         nMinorAddress = fix(nMinorAddress .* 2^(-stasSpecification(nEntryIndex).nWidth));
      end
      
      nField = nField + 1;
   end
end


% --- END of STAddrLogicalExtract.m ---

% $Log: STAddrLogicalExtract.m,v $
% Revision 2.4  2004/09/16 11:45:22  dylan
% Updated help text layout for all functions
%
% Revision 2.3  2004/09/01 12:15:28  dylan
% Updated several functions to use if (any(... instead of if (max(...
%
% Revision 2.2  2004/07/29 14:04:28  dylan
% * Fixed a bug in STAddrLogicalExtract where it would incorrectly handle
% addressing specifications with no minor address fields.
%
% * Updated the help for STOptions, making it more verbose.
%
% * Modified the help for STAddrSpecInfo: Added a reference to STDescribe.
%
% * Modifed readme.txt to point to the welcome HTML file.
%
% * Modified the spike_tb_welcome.html file: Added a reference to STDescribe.
%
% * Modified STAddrSpecSynapse2DNeuron: This function now accepts an argument
% 'bXSecond' which can swap the order of the two neuron address fields.
%
% * Added a more explicit description of 'strPlotOptions' to STPlotRaster.
%
% * Updated STFormats to bring it up to date with the new toolbox variable
% formats.
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
% Revision 1.1  2004/06/04 09:35:47  dylan
% Reimported (nonote)
%
% Revision 1.2  2004/05/10 08:26:44  dylan
% Bug fixes
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
% |NEURON_BITS|.|SYNAPSE_BITS|  This is now referred to as a logical
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