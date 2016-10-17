function [varargout] = STAddrPhysicalExtract(addrPhys, stasSpecification)

% STAddrPhysicalExtract - FUNCTION Extract the neuron and synapse IDs from a physical address
% $Id: STAddrPhysicalExtract.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [nAddr1, nAddr2, ...] = STAddrPhysicalExtract(addrPhys)
%        [nAddr1, nAddr2, ...] = STAddrPhysicalExtract(addrPhys, stasSpecification)
%
% 'addrPhys' should be a physcial address as constructed by
% STAddrPhysicalConsstruct.  STAddrPhysicalExtract will extract the
% indices for each addressing field, as defined by the addressing
% specification.  If this specification is not supplied in the argument
% list, the default output addressing specification will be taken from
% the toolbox options.  The field indices will be returned in the variable
% length argument list.
%
% STAddrPhysicalExtract will respect the 'bReverse' field in the addressing
% specification, and reverse the bits in the respective fields in the supplied
% address.  STAddrPhysicalExtract will also respect the 'bInvert' field in the
% specification, and invert the bits in an addressing field.
%
% STAddrPhysicalExtract is vectorised.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 9th May, 2004 

% -- Get options

stOptions = STOptions;


% -- Check arguments

if (nargin > 2)
   disp('--- STAddrPhysicalExtract: Extra arguments ignored');
end

if (nargin < 2)
   stasSpecification = stOptions.stasDefaultOutputSpecification;
end

if (nargin < 1)
   disp('*** STAddrPhysicalExtract: Incorrect number of arguments');
   help STAddrPhysicalExtract;
   return;
end

% - Check for a valid address specification
if (~STIsValidAddrSpec(stasSpecification))
   disp('*** STAddrPhysicalExtract: Invalid addressing specification supplied');
   return;
end

% - Check for the correct number of output arguments
nRequiredFields = sum(~[stasSpecification.bIgnore]);

if (nargout ~= nRequiredFields)
   disp('--- STAddrPhysicalExtract: Outputting a different number of addressing fields');
   disp('        than you''ve provided');
end


% -- Extract the indices

nField = 1;
for (nEntryIndex = 1:length(stasSpecification))
   if (~stasSpecification(nEntryIndex).bIgnore)
      nFieldWidth = stasSpecification(nEntryIndex).nWidth;
      
      % - Mask off the current address field
      varargout{nField} = bitshift(addrPhys, 0, nFieldWidth);
              
      % - Shift the rest of the field, truncate the decimal portion
      addrPhys = fix(addrPhys .* 2^(-nFieldWidth));
      
      % - Reverse the bits in the field if required
      if (FieldExists(stasSpecification(nEntryIndex), 'bReverse') && stasSpecification(nEntryIndex).bReverse)
         varargout{nField} = BitReverse(varargout{nField}, nFieldWidth);
      end
      
      % - Invert the bits in the field if required
      if (FieldExists(stasSpecification(nEntryIndex), 'bInvert') && stasSpecification(nEntryIndex).bInvert)
         varargout{nField} = (2^nFieldWidth - 1) - varargout{nField};
      end
      
      nField = nField + 1;
   end
end

return;

% --- END of STAddrPhysicalExtract.m ---

% $Log: STAddrPhysicalExtract.m,v $
% Revision 2.6  2004/09/16 11:45:22  dylan
% Updated help text layout for all functions
%
% Revision 2.5  2004/08/28 10:46:33  dylan
% * Extracted BitReverse from STAddrPhysical* and put it in the utilities
% directory. STAddPhysical* now rely on this function.
%
% * STAddrPhysicalExtract now correctly reverses bit fields instead of ignoring
% the 'bReverse' flag in the addressing specification.  Nasty.
%
% Revision 2.4  2004/08/02 14:40:49  chiara
% cvs comment:
% Added files:
% STplot2DRaster.m: raster plot for a 2D array, with different colors
% for different rows of the array
% STPlot2DMeanFreq.m: imagesc plot of the mean frequency of each pixel
% in a 2D array
% Modified files:
% STAddrPhysicalExtract.m: fixed a bug for the inversion of the
% addresses in negative logic
% STImport.m: modified the acquisition of he spike train to cut off the
% initial part of spontaneous activity: the monitored spike train starts with the
% beginning of the stimulation
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
% Revision 2.0  2004/07/13 12:56:31  dylan
% Moving to version 0.02 (nonote)
%
% Revision 1.2  2004/07/13 12:55:19  dylan
% (nonote)
%
% Revision 1.1  2004/06/04 09:35:47  dylan
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