function [stasSpecificationFilled] = STAddrSpecFill(stasSpecification)

% STAddrSpecFill - FUNCTION Fill empty fields in a address specification
% $Id: STAddrSpecFill.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [stasSpecificationFilled] = STAddrSpecFill(stasSpecification)
%
% This function will take a valid (but minimal) addressing specification given
% in 'stasSpecification' and fill any fields which have been left empty with
% their defaults.  This function will never change the functional aspects of
% an address specification.  Type 'help STAddrSpecInfo' for help on creating
% address specifications.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 14th July, 2004 

% -- Check arguments

if (nargin > 1)
   disp('--- STAddrSpecFill: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STAddrSpecFill: Incorrect usage');
   help STAddrSpecFill;
   return;
end


% -- Check for a valid specification

if (~STIsValidAddrSpec(stasSpecification))
   disp('*** STAddrSpecFill: Invalid address spefication supplied');
   return;
end


% -- Fill the address fields

for (nFieldIndex = 1:length(stasSpecification))
   if (~FieldExists(stasSpecification(nFieldIndex), 'Description'))
      if (FieldExists(stasSpecification(nFieldIndex), 'bIgnored') & stasSpecification(nFieldIndex).bIgnored)
         stasSpecification(nFieldIndex).Description = '(Ignored)';
      else
         stasSpecification(nFieldIndex).Description = sprintf('Field%d', nFieldIndex-1);
      end
   end
   
   if (~FieldExists(stasSpecification(nFieldIndex), 'bReverse'))
      stasSpecification(nFieldIndex).bReverse = false;
   end
   
   if (~FieldExists(stasSpecification(nFieldIndex), 'bInvert'))
      stasSpecification(nFieldIndex).bInvert = false;
   end
   
   if (~FieldExists(stasSpecification(nFieldIndex), 'bMajorField'))
      stasSpecification(nFieldIndex).bMajorField = false;
   end
   
   if (~FieldExists(stasSpecification(nFieldIndex), 'bRangeCheck'))
      stasSpecification(nFieldIndex).bRangeCheck = false;
   end
   
   if (~FieldExists(stasSpecification(nFieldIndex), 'bIgnore'))
      stasSpecification(nFieldIndex).bIgnore = false;
   end   
end

stasSpecificationFilled = stasSpecification;

% --- END of STAddrSpecFill.m ---

% $Log: STAddrSpecFill.m,v $
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