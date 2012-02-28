function qMandarPID(block)
% Level-2 MATLAB file S-Function for unit delay demo.
%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ 


  setup(block);

%endfunction

function setup(block)
  
  block.NumDialogPrms  = 2;
  
  %% Register number of input and output ports
  block.NumInputPorts  = 5;
  block.NumOutputPorts = 1;

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
  block.RegBlockMethod('Terminate',               @Terminate);  
  
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
  global ConnState;
  
  if (block.DialogPrm(1).Data~=1)
      host = block.DialogPrm(1).Data;
      puerto = block.DialogPrm(2).Data;
      qConeccionOUT=tcpip(host, puerto);
      try
        fopen(qConeccionOUT);
        set(qConeccionOUT, 'ByteOrder', 'littleEndian');
      catch me
        warndlg(me.message, 'Warning');
      end
      
      ConnState = 'REGISTERING';
      
  end
  
  
%endfunction

function Output(block)

  
  global qConeccionOUT;
  global ConnState;
  
  
  if strcmp(qConeccionOUT.Status,'open')  
      
       
          mandar    = block.Dwork(1).Data(6);

          if mandar

              Kp        = block.Dwork(1).Data(1);
              Ki        = block.Dwork(1).Data(2);
              Kd        = block.Dwork(1).Data(3);
              SetPoint  = block.Dwork(1).Data(4);
              Bias      = block.Dwork(1).Data(5);


              mensaje=qFormatearPID_OUT(Kp, Ki, Kd, Bias);
              fwrite(qConeccionOUT, mensaje, 'float32');
              fwrite(qConeccionOUT, [13 10]);
              
          end
      
  end
   block.OutputPort(1).Data=block.Dwork(1).Data(6);
  
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

function Terminate(block) %#ok<INUSD>

global qConeccionOUT
fclose (qConeccionOUT);