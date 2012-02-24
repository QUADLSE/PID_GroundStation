function qMandarPID(block)
% Level-2 MATLAB file S-Function for unit delay demo.
%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ 
global qConeccionOUT;

  setup(block);

%endfunction

function setup(block)
  
  block.NumDialogPrms  = 2;
  
  %% Register number of input and output ports
  block.NumInputPorts  = 4;
  block.NumOutputPorts = 0;

  %% Setup functional port properties to dynamically
  %% inherited.
  block.SetPreCompInpPortInfoToDynamic;
  block.SetPreCompOutPortInfoToDynamic;
 
  block.InputPort(1).Dimensions        = 1;
  block.InputPort(1).DirectFeedthrough = false;
  
  %block.OutputPort(1).Dimensions       = 1;
  
  %% Set block sample time
  block.SampleTimes = [-1 0];
  
  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';

  %% Register methods
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('InitializeConditions',    @InitConditions);  
  block.RegBlockMethod('Outputs',                 @Output);  
  block.RegBlockMethod('Update',                  @Update);  
  
%endfunction

function DoPostPropSetup(block)

  %% Setup Dwork
  block.NumDworks = 1;
  block.Dwork(1).Name = 'x0'; 
  block.Dwork(1).Dimensions      = 6;
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 'Real';
  block.Dwork(1).UsedAsDiscState = true;

%endfunction

function InitConditions(block)

  %% Initialize Dwork
  global qConeccionOUT;
  if (block.DialogPrm(1).Data~=1)
      host = block.DialogPrm(1).Data;
      puerto = block.DialogPrm(2).Data;
      qConeccionOUT=tcpip(host, puerto);
      try
        fopen(qConeccionOUT);
      catch me
        warndlg(me.message, 'Warning');
      end
  end
  
  
%endfunction

function Output(block)

  %block.OutputPort(1).Data = block.Dwork(1).Data;
  global qConeccionOUT;
  
  mandar    = block.Dwork(1).Data(6);
  
  if mandar
      
      Kp        = block.Dwork(1).Data(1);
      Ki        = block.Dwork(1).Data(2);
      Kd        = block.Dwork(1).Data(3);
      SetPoint  = block.Dwork(1).Data(4);
      Bias      = block.Dwork(1).Data(5);


      mensaje=qFormatearPID_OUT(Kp, Ki, Kd, SetPoint, Bias);
      fprintf(qConeccionOUT, mensaje);
  end
  
%endfunction

function Update(block)
    
  mandar = false;
  for k=1:5         %5 valores estamos mandando
      dataOld       = block.Dwork(1).Data(k);
      dataNew       = block.InputPort(k).Data;
        if (dataOld~=dataNew)
            block.Dwork(1).Data(k) = dataNew;
            mandar = true;
        end
  end
  
  block.Dwork(1).Data(6) = mandar;


  
%endfunction

