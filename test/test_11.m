clear
clc
% Topic Data
global topic_data;
topic_data = containers.Map;
topic_data('drag') = 0;

jsonencode(topic_data)

main2()

function main2()
    
    global topic_data;
    jsonencode(topic_data)

end