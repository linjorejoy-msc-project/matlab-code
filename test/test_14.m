info = '{"currentTimestep": 1}';
info_struct = jsondecode(info);
info_obj = containers.Map(fieldnames(info_struct), struct2cell(info_struct));
fprintf('info_obj("currentTimestep"): %s\n', info_obj("currentTimestep"));
info_obj("currentTimestep")
class(info_obj("currentTimestep"))