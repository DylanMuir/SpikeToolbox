function [stTrain] = STCreate(strType, varargin)

% STCreate - FUNCTION Create a spike train
% $Id: STCreate.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [stTrain] = STCreate('constant', fFreq, ...)
%        [stTrain] = STCreate('linear', fStartFreq, fEndFreq, ...)
%        [stTrain] = STCreate('sinusoid', fMinFreq, fMaxFreq, tPeriod, ...)
%        [stTrain] = STCreate(..., strTemporalType, tDuration)
%        [stTrain] = STCreate(..., strTemporalType, tDuration, nAddr1, nAddr2, ...)
%        [stTrain] = STCreate(..., strTemporalType, tDuration, stasSpecification, nAddr1, nAddr2, ...)
%
% STCreate will create a spike train definition of various types.  The first
% argument specifies the type of spike train, and must be one of {'constant',
% 'linear', 'sinusoid'}.  (See STCreateConstant, STCreateLinear and
% STCreateSinusoid for details of the parameters relating to the spike train
% types).  When called with only the train definition parameters, 'stTrain'
% will comprise of a single field 'defintion' containing the spike train
% definition.
%
% STCreate can also be used to instantiate and map the resulting spike train.
% By providing the parameters 'strTemporalType' (one of {'regular',
% 'poisson'}) and 'tDuration', the train will be instantiated and 'stTrain'
% will contain a field 'instance' containing the spike train instance.  See
% STInstaniate for details of these parameters.
%
% By providing the paramters 'nAddr1', 'nAddr2', 'stasSpecification', etc., the
% train will be mapped and 'stTrain' will contain a field 'mapping' containing
% the mapped spike train.  See STMap for details of these parameters.
%
% Note that when using the full syntax for STCreate to result in a mapped
% spike train, only a single instance has been produced.  This means that for
% a poissonian spike train, each mapped train will contain the IDENTICAL
% sequence of spikes.  To create spike trains with the same statistics but
% different spike sequences, STInstantiate must be called in a loop.  STCreate
% does not provide that functionality.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004

% -- Basic argument checking

if (nargin < 2)
    disp('*** STCreate: incorrect usage');
    help STCreate;
    return;
end


% -- Pull apart the command line

% - Default is not to instantiate the train, or map it to a synapse
bInstantiateTrain = false;
bMapTrain = false;

switch lower(strType)
   % - Constant frequency spike train
   case {'constant', 'c'}
      if (nargin < 2)
         disp('*** STCreate: Incorrect number of arguments for constant train');
         help STCreate;
         return;
      end

      if (nargin > 2)
         if (nargin < 4)
            disp('*** STCreate: Not enough arguments to instantiate the constant train');
            help STCreate;
            return;
         end   
         bInstantiateTrain = true;
         strTemporalType = varargin{2};
         tDuration = varargin{3};
      end
        
      if (nargin > 4)
         addrMapping = varargin(4:length(varargin));
         bMapTrain = true;
      end

      stTrain = STCreateConstant(varargin{1});
        
      
   % - Increasing spike train
   case {'linear', 'l'}
      if (nargin < 3)
           disp('*** STCreate: Incorrect number of arguments for linear train');
           help STCreate;
           return;
      end
        
      if (nargin > 3)
         if (nargin < 5)
            disp('*** STCreate: Not enough arguments to instantiate the linear train');
            help STCreate;
            return;
         end
         bInstantiateTrain = true;
         strTemporalType = varargin{3};
         tDuration = varargin{4};
        end
        
      if (nargin > 5)
         addrMapping = varargin(5:length(varargin));
         bMapTrain = true;
      end

      stTrain = STCreateLinear(varargin{1}, varargin{2});
        
        
   % - Sinusoidal spike train
   case {'sinusoid', 's'}
      if (nargin < 4)
         disp('*** STCreate: Incorrect number of arguments for sinusoidal train');
         help STCreate;
         return;
      end
        
      if (nargin > 4)
         if (nargin < 6)
            disp('*** STCreate: Not enough arguments to instantiate the sinusoidal train');
            help STCreate;
            return;
         end
         bInstantiateTrain = true;
         strTemporalType = varargin{4};
         tDuration = varargin{5};
      end
        
      if (nargin > 6)
         addrMapping = varargin(6:length(varargin));
         bMapTrain = true;
      end

      stTrain = STCreateSinusoid(varargin{1}, varargin{2}, varargin{3});
        
   % - Unknown train type
   otherwise
      disp('*** STCreate: Unknown spike train type.');
      disp('       Should be one of {constant, linear, sinusoid}');
      help STCreate;
      return;
end


% -- Instantiate train, if required

if (bInstantiateTrain)
    stTrain = STInstantiate(stTrain, strTemporalType, tDuration);
end


% -- Map train, if required

if (bMapTrain)
   % - Is it a valid address?
   if (~STIsValidAddress(addrMapping{:}))
      disp('*** STCreated: Invalid address supplied for mapping');
      return;
   end
   
   stTrain = STMap(stTrain, addrMapping{:})';
end


% --- END of STCReate.m ---

% $Log: STCreate.m,v $
% Revision 2.5  2005/02/10 09:32:13  dylan
% * STCreate now returns a cell array of spike trains as a column array, instead
% of a row array.  Now they can be plotted nicely without requiring a transpose.
%
% Revision 2.4  2004/09/16 11:45:22  dylan
% Updated help text layout for all functions
%
% Revision 2.3  2004/09/16 10:15:09  dylan
% STCreate now has more verbose help text.
%
% Revision 2.2  2004/07/29 15:44:36  chiara
% fixed a bug in STCreate
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
% Revision 1.7  2004/05/04 09:40:06  dylan
% Added ID tags and logs to all version managed files
%
