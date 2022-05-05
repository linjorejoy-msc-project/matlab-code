clear;
clc;
server_conn = tcpclient('131.231.139.66',1236);

%resp = read(server_conn, server_conn.BytesAvailable);
%native2unicode(resp)

msg = recv_msg(server_conn)

function msg = recv_msg(server_connection)
    % server_connection     : tcpclient
    
    %try
        while true
           resp = read(server_connection, server_connection.BytesAvailable);
           msg_str = native2unicode(resp);
           if msg_str
               msg = msg_str(6:end);
               break;
           end
        end
    %catch
        %warning('Error occured while reading message');
        %msg = NaN;
   % end
end