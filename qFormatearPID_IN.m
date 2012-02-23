function [dataDisponible, valor]=qFormatearPID_IN(qConeccionIN)


%% lectura del de qMandarPID
%       %raro pero el primer byte se pierde... por eso mando x!!
%       formato=['xKp=%f;Ki=%f;Kd=%f;Bias=%f;t=%f;'];
% 
%       lectura=fscanf(qConeccionIN);
%       valor=sscanf(lectura, formato, 5);
% 
%       disp(lectura);
%       disp(valor);

%% lectura de formato alan

try
    %[A, count] = fread(qConeccionIN, 6, 'float', 'l');
    
    % Leo los datos reales
    [A, count,msg] = fread(qConeccionIN, 6, 'float');
    
    % Descarto el \r\n \10\13
    fread(qConeccionIN, 2, 'uint8');
    dataDisponible=(count==6);
    valor=A;
catch me
    %disp(msg);
    %disp(me.message);
    dataDisponible=false;
    valor=[];
    %warndlg(me.message, 'Warning');
end
          
end