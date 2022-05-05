cl = tcpclient('131.231.139.66',1236);
% write(cl,unicode2native('hello'));
% pause(5); % increase wait time as appropriate.
resp = read(cl, cl.BytesAvailable);
msg = native2unicode(resp);