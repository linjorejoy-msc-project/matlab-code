format compact
text = '1234567890';
text2 = '123456789';

if strcmp(text, text2)
    a = 'yes'
else
    a = 'no'
end

size = 3;
text(size+2:end)


CONFIG_DATA_STR = '{"id":"CLIENT_6","name":"atmosphere","subscribed_topics":["motion","field"],"published_topics":["atmosphere"],"constants_required":["timestepSize","totalTimesteps"],"variables_subscribed":[]}';
CONFIG_DATA = jsondecode(CONFIG_DATA_STR);

jsonencode(CONFIG_DATA);