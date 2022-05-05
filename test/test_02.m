format compact
HEADERSIZE = 5;
server_conn = tcpclient('131.231.139.66',1236);
server_conn

while true
    break
    pause(1);
    current_time = datetime('now');
    data_to_send = format_with_header(sprintf('MATLAB says time is %s', current_time));
    write(server_conn, unicode2native(data_to_send));
    resp = read(server_conn, server_conn.BytesAvailable);
    msg = native2unicode(resp)
end

function str = format_with_header(data)
    len = strlength(data);
    str = sprintf('%-5d%s',len, data);
end
