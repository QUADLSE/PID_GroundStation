function recibirPID(block)
% Level-2 MATLAB file S-Function for unit delay demo.
%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ 
global qConeccionIN;
global ConnState;
  setup(block);
tic;  
%endfunction

function setup(block)
  
  block.NumDialogPrms  = 2;
  
  %% Register number of input and output ports
  block.NumInputPorts  = 0;
  block.NumOutputPorts = 6;

%   
%    block.InputPort(1).Dimensions        = 1;
%    block.InputPort(1).DirectFeedthrough = false;
%   
  for k=1:block.NumOutputPorts
    block.OutputPort(k).Dimensions       = 1;
    block.OutputPort(k).SamplingMode = 'sample';
  end
  
  %% Set block sample time
  block.SampleTimes = [0 1];
  
  %% Set the block simStateCompliance to default (i.e., same as a built-in block)
  block.SimStateCompliance = 'DefaultSimState';

  %% Register methods
  block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
  block.RegBlockMethod('InitializeConditions',    @InitConditions);  
  block.RegBlockMethod('Outputs',                 @Output);  
  block.RegBlockMethod('Update',                  @Update);  
  block.RegBlockMethod('Terminate',               @Terminate);  
  
%endfunction

% function SetInputPortSamplingMode(block, idx, fd)
% 
% for k=1:block.NumOutputPorts
%     block.OutputPort(k).SamplingMode = idx;
% end
% 
% %endfunction

function DoPostPropSetup(block)

  %% Setup Dwork
  block.NumDworks = 1;
  block.Dwork(1).Name = 'x0'; 
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;
  block.Dwork(1).Complexity      = 'Real';
  block.Dwork(1).UsedAsDiscState = true;

%endfunction

function InitConditions(block)

  %% Initialize Dwork
  global qConeccionIN;
  global ConnState; 
  
  if (block.DialogPrm(1).Data~=1)
      host = block.DialogPrm(1).Data;
      puerto = block.DialogPrm(2).Data;
      %qConeccionIN=tcpip(host, puerto, 'NetworkRole', 'Client');
      qConeccionIN=tcpip(host, puerto);
      set(qConeccionIN, 'InputBufferSize', 16*1024);
      set(qConeccionIN, 'ByteOrder', 'littleEndian');
      set(qConeccionIN, 'ReadAsyncMode', 'Continuous');
      
      %qConeccionIN.ReadAsyncMode='manual';
      try
        fopen(qConeccionIN);
      catch me
        warndlg(me.message, 'Warning');
      end
      ConnState = 'REGISTERING';
      %fprintf(qConeccionIN,['TELEMETRY' 10])
  end
  
  
%endfunction

function Output(block)

  global qConeccionIN;
  global ConnState;
  
  if strcmp(qConeccionIN.Status,'open')      
      if strcmp(ConnState, 'REGISTERING')
          disp('Registrando');
          fwrite(qConeccionIN,['TELEMETRY' 13 10])
          ConnState = 'STREAMING';
          readasync(qConeccionIN);
      else
          %disp('Streaming!');
          dataDisponible=false;
          if (qConeccionIN.BytesAvailable>=26)
              [dataDisponible, valor]=qFormatearPID_IN(qConeccionIN);
          end
          if dataDisponible
              %disp(valor);
              for k=1:block.NumOutputPorts                 %block.NumOutputPorts      
                block.OutputPort(k).Data = valor(k);
              end
         end
      end
      %{
      [dataDisponible, valor]=qFormatearPID_IN(qConeccionIN);
      valor
      if dataDisponible
          for k=1:5                 %block.NumOutputPorts      
            block.OutputPort(k).Data = valor(k);
          end
          block.OutputPort(6).Data = toc;
      end
      %}
  end   
%endfunction

function Update(block)


  %x=block.InputPort(1).Data;
  
%endfunction

function Terminate(block)
global qConeccionIN;
fclose(qConeccionIN);
