clear;
clc;
format compact

HEADERSIZE = 5;

CONFIG_DATA_STR = '{"id":"CLIENT_4","name":"aerodynamics","subscribed_topics":["motion", "atmosphere", "field"],"published_topics":["drag", "field_update"],"constants_required":["dragCoefficient","rocketFrontalArea", "timestepSize","totalTimesteps"],"variables_subscribed":[]}';
global CONFIG_DATA;
CONFIG_DATA = jsondecode(CONFIG_DATA_STR);

server_conn = tcpclient('192.168.150.160',1234);


global CONSTANTS;
CONSTANTS = containers.Map;

% Topic Data
global topic_data;
topic_data = containers.Map;
topic_data('drag') = 0.0;
fprintf("Topic_data after initiation : %s\n", jsonencode(topic_data))


% cycle flags
global cycle_flags;
cycle_flags = containers.Map;
cycle_flags('motion') = false;
cycle_flags('atmosphere') = false;
cycle_flags('field') = false;

% topic_func_dict
global topic_func_dict;
topic_func_dict = containers.Map;
topic_func_dict('motion') = @motion_received;
topic_func_dict('atmosphere') = @atmosphere_received;
topic_func_dict('field') = @field_received;



global data_dict;
data_dict = containers.Map;


main(server_conn);


% -------------------------------------------
% |         ANALYSIS FUNCTIONS              |
% -------------------------------------------
function run_one_cycle(server_connection)
    % server_connection         :tcpclient
    
    global topic_data;
    global data_dict;
    global CONSTANTS;
    
    fprintf('Timestep: %d running\n', data_dict('currentTimestep'));
    topic_data('drag') = (CONSTANTS('dragCoefficient')*data_dict('density')*data_dict('currentVelocity')*data_dict('currentVelocity')*CONSTANTS('rocketFrontalArea'))/2;
    send_topic_data(server_connection, 'drag', jsonencode(topic_data));
    timestep_str = sprintf('{"currentTimestep":%d}',data_dict('currentTimestep')+1);
    send_topic_data(server_connection, 'field_update', timestep_str);
end


function run_cycle(server_connection)
    % server_connection         :tcpclient
    
    global cycle_flags;
    while true
       if check_to_run_cycle()
           make_all_cycle_flags_default();
           run_one_cycle(server_connection);
       else
           listen_analysis(server_connection);
       end
       
    end
end

function start_initiation(server_connection)
    % server_connection         :tcpclient
    
    global topic_data;
    fprintf('Starting Initiation.....\n');
    fprintf('Sending %s\n', jsonencode(topic_data));
    send_topic_data(server_connection, 'drag', jsonencode(topic_data));
    run_cycle(server_connection);
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
            fprintf('%s is not subscribed to %s\n', CONFIG_DATA('name'), topic);
        end
        break;
    end
end


function listening_function(server_connection)
    % server_connection     : tcpclient
    
    fprintf('Inside Listening Function\n');
    global CONSTANTS;
    global CONFIG_DATA
    while true
        msg = recv_msg2(server_connection);
        fprintf('Received: %s\n', msg);
        if strcmp(msg, 'CONFIG')
            fprintf('Config Requested\n');
            send_config(server_connection, CONFIG_DATA);
            CONSTANTS = request_constants(server_connection);
        elseif strcmp(msg, 'START')
            fprintf('Start request received\n');
            break
        end
    end
    fprintf('Exit initial while loop\n');
    
    % Runing 2 threads for 2 operations
    global topic_data;
    fprintf('Topic Data in Listening Function :%s\n', jsonencode(topic_data));
    fprintf('run_cycle started\n');
    start_initiation(server_connection);
    
end


function main(server_conn)
    % server_conn           : tcpclient
    
    fprintf('Main Function Started\n');
    listening_function(server_conn);
end


% -------------------------------------------
% |         HELPER FUNCTIONS                |
% -------------------------------------------
function canRun = check_to_run_cycle()
    % cycle_flags           : Map
    global cycle_flags;
    flag = true;
    for key = keys(cycle_flags)
       if ~cycle_flags(key{1})
           flag = false;
           break;
       end
    end
    canRun = flag;
end

function make_all_cycle_flags_default()
    % cycle_flags           : Map
    
    global cycle_flags;
    for key = keys(cycle_flags)
       cycle_flags(key{1}) = false;
    end
end


function constants_dict = request_constants(server_connection)
    % server_connection     : tcpclient
    
    write(server_connection, format_msg_with_header('CONSTANTS'));
    constants_str = recv_msg2(server_connection);
    fprintf('Received Constants str: %s\n', constants_str);
    constants_struct = jsondecode(constants_str);
    constants_dict = containers.Map(fieldnames(constants_struct), struct2cell(constants_struct));
end



function send_config(server_connection, config)
    % server_connection     : tcpclient
    % config                : Map
    
    data_to_send = format_msg_with_header(jsonencode(config));
    fprintf('Sending Config: %s\n',data_to_send);
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

function atmosphere_received(data_dict, info)
    % data_dict             : Map
    % info                  : string
    
    info_struct = jsondecode(info);
    info_obj = containers.Map(fieldnames(info_struct), struct2cell(info_struct));
    data_dict("pressure") = info_obj("pressure");
    data_dict("temperature") = info_obj("temperature");
    data_dict("density") = info_obj("density");
end

function field_received(data_dict, info)
    % data_dict             : Map
    % info                  : string
    
    info_struct = jsondecode(info);
    info_obj = containers.Map(fieldnames(info_struct), struct2cell(info_struct));
    data_dict("currentTimestep") = info_obj("currentTimestep");
end


function msg = recv_msg2(server_connection)
    % server_connection     : tcpclient
    % varargin              : 1 parameter as msg length
    
    while true
            while true
                header = read(server_connection, 5);
                if ~isnan(header)
                    break
                end
            end
            msg_len = str2double(native2unicode(header));
            resp = read(server_connection, msg_len);
        msg_str = native2unicode(resp);
        if msg_str
           msg = msg_str;
           break;
        end
    end
end

function msg = recv_msg(server_connection, varargin)
    % server_connection     : tcpclient
    % varargin              : 1 parameter as msg length
    
    try
        while true
            if nargin == 0
                resp = read(server_connection, server_connection.BytesAvailable);
            else
                % sometimes only n number of input is required, so to
                % prevent NaN from being encountered, we use this
                received_count = 0;
                resp = "";
                while true
                    if received_count >= varargin{1}
                        break
                    end
                    next_data = read(server_connection, 1);
                    if ~isnan(next_data)
                        resp = append(resp, next_data);
                        received_count = received_count + 1;
                    end
                end
                resp = read(server_connection, varargin{1});
            end
            % resp = read(server_connection, server_connection.BytesAvailable);
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

    data = recv_msg2(server_connection);
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
