info = '{"currentTimestep": 1}';
info_struct = jsondecode(info);
info_obj = containers.Map(fieldnames(info_struct), struct2cell(info_struct));
info_obj("currentTimestep")