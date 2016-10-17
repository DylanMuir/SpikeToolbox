function [stTrain] = STCreate(strType, varargin)

% STCreate - FUNCTION Create a spike train
% $Id: STCreate.m 8347 2008-02-04 17:48:50Z dylan $
%
% Usage: [stTrain] = STCreate(<train definition type>,
%                             <definition arguments>,
%                             <instantiation arguments>,
%                             <mapping arguments>)
%
% Usage: [stTrain] = STCreate('constant', fFreq, ...)
%        [stTrain] = STCreate('linear', fStartFreq, fEndFreq, ...)
%        [stTrain] = STCreate('sinusoid', fMinFreq, fMaxFreq, tPeriod, ...)
%        [stTrain] = STCreate(..., strTemporalType, tDuration <, nAddr1, nAddr2, ...>)
%        [stTrain] = STCreate(..., strTemporalType, tDuration <, stasSpecification, nAddr1, nAddr2, ...>)
%
% STCreate will create a spike train definition of various types.  The first
% argument specifies the type of spike train, and must be one of {'constant',
% 'linear', 'sinusoid'}.
%
% The second set of parameters is passed to the definition creation
% function (See STCreateConstant, STCreateLinear and STCreateSinusoid for details of the parameters relating to the spike train
% types).  When called with only the train definition parameters, 'stTrain'
% will comprise of a single field 'defintion' containing the spike train
% definition.
%
% STCreate can also be used to instantiate and map the resulting spike train.
% By providing the instantiation arguments, the train will be instantiated
% and 'stTrain' will contain a field 'instance' containing the spike train
% instance.  See STInstantiate for details of these parameters.
%
% By providing the mapping arguments, the train will be mapped and
% 'stTrain' will contain a field 'mapping' containing the mapped spike
% train.  See STMap for details of these arguments.
%
% Arrays can be supplied for one or more arguments, according to the
% calling syntax for the separate utility functions (ie STCreate...,
% STInstantiate and STMap).  In this case, 'stTrain' will be a cell array
% of spike trains.  Note that the train(s) will be created in order: all
% definitions will be created, then all instances, then all mappings.  The
% train will be a 'scalar' train until a step is encountered that specifies
% an array of arguments.  This means that if an array is passed to the
% mapping arguments but not the instantiation arguments, all mapped spike
% trains will have been created from a SINGLE spike train instance, and
% will have identical spike timing for all spikes.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 26th March, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

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
         addrMapping = varargin(4:end);
         bMapTrain = true;
      end

      stTrain = STCreateConstant(varargin{1});
        
      
   % - Linearly increasing freqiency profile
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
         addrMapping = varargin(5:end);
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
         addrMapping = varargin(6:end);
         bMapTrain = true;
      end

      stTrain = STCreateSinusoid(varargin{1}, varargin{2}, varargin{3});


   % - Unknown train type
   otherwise
      disp('*** STCreate: Unknown spike train type.');
      disp('       Should be one of {''constant'', ''linear'', ''sinusoid''}');
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


% --- END of STCreate.m ---
