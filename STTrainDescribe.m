function STTrainDescribe(stTrain)

% STTrainDescribe - FUNCTION Print a description of a spike train
% $Id: STTrainDescribe.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: STTrainDescribe(stTrain)
%
% STDescribe will print as much information as is available about 'stTrain'.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 18th july, 2004

% -- Get options

stOptions = STOptions;


% -- Check arguments

if (nargin > 1)
   disp('--- STTrainDescribe: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STTrainDescribe: Incorrect number of arguments');
   help STDescribe;
   return;
end


% -- Describe spike train

SameLinePrintf('This is ');

if (isfield(stTrain, 'mapping'))
   if (isfield(stTrain.mapping, 'addrSynapse'))
      SameLinePrintf('a mapped spike train:\n');
      SameLinePrintf('   Addressing format: ');
      STAddrSpecDescribe(stTrain.mapping.stasSpecification);
      SameLinePrintf('   Address indices: ');
      SameLinePrintf('[%d] ', stTrain.mapping.addrFields{:});
      SameLinePrintf('(Logical address [%.4f])\n', stTrain.mapping.addrSynapse);
      
   else     % must be a multiplexed spike train
      SameLinePrintf('a multiplexed mapped spike train:\n');
      SameLinePrintf('   Addressing format: ');
      STAddrSpecDescribe(stTrain.mapping.stasSpecification);      
   end
                  
   PrintChunkedMode(stTrain.mapping);  
   PrintDuration(stTrain);
   PrintDefinition(stTrain);

elseif (isfield(stTrain, 'instance'))
   SameLinePrintf('an instantiated spike train:\n')
   PrintChunkedMode(stTrain.instance);
   PrintDuration(stTrain);
   PrintDefinition(stTrain);

elseif (isfield(stTrain, 'definition'))
   SameLinePrintf('a simple spike train definition:\n');
   PrintDefinition(stTrain);
   
else
   SameLinePrintf('not a spike train!\n');
end

SameLinePrintf('\n');

return;


% --- FUNCTION PrintChunkedMode
function PrintChunkedMode(stNode)
if (stNode.bChunkedMode)
   SameLinePrintf('   Using chunked mode encoding\n');
end

return;



% --- FUNCTION PrintDuration
function PrintDuration(stTrain)
if (isfield(stTrain, 'instance'))
   tDuration = stTrain.instance.tDuration;
else
   tDuration = stTrain.mapping.tDuration;
end

SameLinePrintf('   Duration [%.2f] seconds\n', tDuration);

return;


% --- FUNCTION PrintDefintion
function PrintDefinition(stTrain)
if (isfield(stTrain, 'definition'))
   SameLinePrintf('   This train contains a definition:\n');
   
   switch (stTrain.definition.strType)
      case {'constant'}
         SameLinePrintf('      Constant frequency spike train\n');
         SameLinePrintf('      Frequency [%.2f] Hz\n', stTrain.definition.fFreq);
         
      case {'linear'}
         SameLinePrintf('      Linear frequency change spike train\n');
         SameLinePrintf('      Start freq [%.2f] Hz ==> End freq [%.2f] Hz\n', ...
                        stTrain.definition.fStartFreq, stTrain.definition.fEndFreq);
         
      case {'sinusoid'}
         SameLinePrintf('      Sinusoidal frequency change spike train\n');
         SameLinePrintf('      Min freq [%.2f] Hz | Max freq [%.2f] Hz\n', ...
                        stTrain.definition.fMinFreq, stTrain.definition.fMaxFreq);
         SameLinePrintf('      Sinusoid period [%.2f] seconds\n', stTrain.definition.tPeriod);
         
      otherwise
         SameLinePrintf('      (Unknown definition type)\n');
   end
end

return;

% --- END of STTrainDescribe.m ---

% $Log: STTrainDescribe.m,v $
% Revision 2.2  2004/09/16 11:45:23  dylan
% Updated help text layout for all functions
%
% Revision 2.1  2004/07/19 16:21:03  dylan
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