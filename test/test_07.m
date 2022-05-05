clear;
clc;
% topic_func_dict
topic_func_dict = containers.Map;
topic_func_dict('motion') = @motion_received;
topic_func_dict('field') = @field_received;

data_dict = containers.Map;

info = '{"currentTimestep": 15}';

func = topic_func_dict('field');
func(data_dict,info);

data_dict("currentTimestep")

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
