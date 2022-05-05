clear;
clc;
format compact

HEADERSIZE = 5;

CONFIG_DATA_STR = '{"id":"CLIENT_6","name":"atmosphere","subscribed_topics":["motion","field"],"published_topics":["atmosphere"],"constants_required":["timestepSize","totalTimesteps"],"variables_subscribed":[]}';
global CONFIG_DATA;
CONFIG_DATA = jsondecode(CONFIG_DATA_STR);

server_conn = tcpclient('131.231.139.66',1234);


global CONSTANTS;
CONSTANTS = containers.Map;

% Topic Data
global topic_data;
topic_data = containers.Map;
topic_data('pressure') = 0;
topic_data('temperature') = 0;
topic_data('density') = 0;

% cycle flags
global cycle_flags;
cycle_flags = containers.Map;
cycle_flags('motion') = false;
cycle_flags('field') = false;

% topic_func_dict
global topic_func_dict;
topic_func_dict = containers.Map;
topic_func_dict('motion') = @motion_received;
topic_func_dict('field') = @field_received;



global data_dict;
data_dict = containers.Map;


main(server_conn);


% -------------------------------------------
% |         ANALYSIS FUNCTIONS              |
% -------------------------------------------

function [pressure, temperature] = external_pressure_temperature(altitude)
    % altitude              : int
    
    if altitude < 11000
        temperature = 15.04 - 0.00649 * altitude;
        pressure = 101.29 * ((T + 273.1) / 288.08) ^ 5.256;
    elseif altitude >= 11000 && altitude < 25000
        temperature = -56.46;
        pressure = 22.65 * math.exp(1.73 - 0.000157 * altitude);
    else
        temperature = -131.21 + 0.00299 * altitude;
        pressure = 2.488 * ((T + 273.1) / 216.6) ^ -11.388;
    end
end

function density = get_air_density(pressure, temperature)
    % altitude              : int
    
    density = pressure / (0.2869 * (temperature + 273.1));
end

function run_one_cycle(server_connection)
    % server_connection         :tcpclient
    
    global topic_data;
    global data_dict
    
    [P, T] = external_pressure_temperature(data_dict("currentAltitude"));
    topic_data('pressure') = P;
    topic_data('temperature') = T;
    topic_data('density') = get_air_density(P,T);
    send_topic_data(server_connection, 'atmosphere', jsonencode(topic_data));
end


function run_cycle(server_connection)
    % server_connection         :tcpclient
    global cycle_flags;
    while true
       if check_to_run_cycle(cycle_flags)
          make_all_cycle_flags_default(cycle_flags);
          run_one_cycle(server_connection);
       end
    end
end


function listen_analysis(server_connection)
    % server_connection     : tcpclient
    
    global data_dict;
    global cycle_flags;
    global topic_func_dict;
    while true
        [topic, info] = recv_topic_data(server_connection);
        if isKey(cycle_flags, topic)
            cycle_flags(topic) = true;
            func = topic_func_dict(topic);
            func(data_dict, info);
        else
            fprintf('%s is not subscribed to %s', CONFIG_DATA('name'), topic);
        end
    end
end


function listening_function(server_connection)
    % server_connection     : tcpclient
    
    global CONSTANTS;
    global CONFIG_DATA
    while true
        msg = recv_msg(server_connection);
        if strcmp(msg, 'CONFIG')
            send_config(server_connection, CONFIG_DATA);
            CONSTANTS = request_constants(server_connection);
        elseif strcmp(msg, 'START')
            break
        end
    end
    
    % Runing 2 threads for 2 operations
    parfor n = 1:2
       if n == 1
           fprintf('Listen Analysis started\n');
           listen_analysis(server_connection);
       elseif n == 2
           fprintf('run_cycle started\n');
           run_cycle(server_connection);
       end
    end
end


function main(server_conn)
    listening_function(server_conn);
end


% -------------------------------------------
% |         HELPER FUNCTIONS                |
% -------------------------------------------
function canRun = check_to_run_cycle(cycle_flags)
    % cycle_flags           : Map

    flag = true;
    for key = keys(cycle_flags)
       if ~cycle_flags(key)
           flag = false;
           break;
       end
    end
    canRun = flag;
end

function make_all_cycle_flags_default(cycle_flags)
    % cycle_flags           : Map

    for key = keys(cycle_flags)
       cycle_flags(key) = false;
    end
end


function constants_dict = request_constants(server_connection)
    % server_connection     : tcpclient
    
    write(server_connection, format_msg_with_header('CONSTANTS'));
    constants_str = recv_msg(server_connection);
    constants_struct = jsondecode(constants_str);
    constants_dict = containers.Map(fieldnames(constants_struct), struct2cell(constants_struct));
end



function send_config(server_connection, config)
    % server_connection     : tcpclient
    % config                : Map
    
    data_to_send = format_msg_with_header(jsonencode(config));
    write(server_connection, data_to_send);
end



function motion_received(data_dict, info)
    % data_dict             : Map
    % info                  : string
    
    info_struct = jsondecode(info);
    info_obj = containers.Map(fieldnames(info_struct), struct2cell(info_struct));
    data_dict("netThrust") = info_obj("netThrust");
    data_dict("currentAcceleration") = info_obj("currentAcceleration");
    data_dict("currentVelocityDelta") = info_obj("currentVelocityDelta");
    data_dict("currentVelocity") = info_obj("currentVelocity");
    data_dict("currentAltitudeDelta") = info_obj("currentAltitudeDelta");
    data_dict("currentAltitude") = info_obj("currentAltitude");
    data_dict("requiredThrustChange") = info_obj("requiredThrustChange");
end

function field_received(data_dict, info)
    % data_dict             : Map
    % info                  : string
    
    info_struct = jsondecode(info);
    info_obj = containers.Map(fieldnames(info_struct), struct2cell(info_struct));
    data_dict("currentTimestep") = info_obj("currentTimestep");
end

function msg = recv_msg(server_connection)
    % server_connection     : tcpclient
    
    try
        while true
           resp = read(server_connection, server_connection.BytesAvailable);
           msg_str = native2unicode(resp);
           if msg_str
               msg = msg_str(6:end);
               break;
           end
        end
    catch
        warning('Error occured while reading message');
        msg = NaN;
    end
end

function [topic, msg] = recv_topic_data(server_connection)
    % server_connection     : tcpclient

    data = recv_msg(server_connection);
    topic = strip(data(1:25));
    fprintf('Received data of topic: "%s" as "%s"\n',topic, data);
    msg = data(26:end);
end

function send_topic_data(server_connection, topic, data)
    % server_connection     : tcpclient
    % topic                 : str
    % data                  : str
    
    data_to_send = format_msg_with_header(sprintf('%-25s%s', topic, data));
    fprintf('Sending %s\n', data_to_send);
    write(server_connection, data_to_send);
end

function output = format_msg_with_header(msg)
    % msg                   : string
    
    len = strlength(msg);
    output = unicode2native(sprintf('%-5d%s',len, msg));
end
