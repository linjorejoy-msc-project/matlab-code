format compact
keySet = {'Jan','Feb','Mar','Apr'};
valueSet = [327.2 368.2 197.6 178.4];
M = containers.Map(keySet,valueSet);
M('May') = 500;
M('Jan');
M('May');
N = containers.Map(keySet,valueSet);



CONFIG_DATA_STR = '{"id":"CLIENT_6","name":"atmosphere","subscribed_topics":["motion","field"],"published_topics":["atmosphere"],"constants_required":["timestepSize","totalTimesteps"],"variables_subscribed":[]}';
CONFIG_DATA = jsondecode(CONFIG_DATA_STR);


data_dict = containers.Map;
data_dict
info = '{"currentTimestep": 12}';
field_received(data_dict, info);

data_dict("currentTimestep")

clear

function field_received(data_dict, info)
    info_struct = jsondecode(info);
    info_map = containers.Map(fieldnames(info_struct), struct2cell(info_struct));
    data_dict("currentTimestep") = info_map("currentTimestep");
end