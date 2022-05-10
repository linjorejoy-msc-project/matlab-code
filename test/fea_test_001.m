%% CFDTool Version 1.8.3, Build 22.04.109, Model M-Script file.
%% Created on 06-May-2022 14:57:59 with MATLAB 9.10.0.1602886 (R2021a) PCWIN64.


%% Starting new model.
fea.sdim = { 'x', 'y' };
fea.geom = struct;
fea = addphys( fea, @navierstokes, { 'u', 'v', 'p' } );

%% Geometry operations.
gobj = gobj_rectangle( 0.2, 0.9, 0.3, 0.6, 'R1');
fea = geom_add_gobj( fea, gobj );
gobj = gobj_rectangle( [0], [2.2], [0], [0.41], 'R1' );
fea.geom.objects{1} = gobj;
gobj = gobj_ellipse( [ 1.21381 0.2 ], 0.062079, 0.056733, 'E1');
fea = geom_add_gobj( fea, gobj );
gobj = gobj_ellipse( [0.2 0.2], [0.5], [0.5], 'E1' );
fea.geom.objects{2} = gobj;
gobj = gobj_ellipse( [0.2 0.2], [0.05], [0.05], 'E1' );
fea.geom.objects{2} = gobj;
fea.geom = geom_apply_formula( fea.geom, 'R1-E1' );

%% Grid operations.
fea.grid = gridgen( fea, 'gridgen', 'default', 'hmax', 0.13, 'grading', 0.3 );
fea.grid = gridgen( fea, 'gridgen', 'default', 'hmax', 0.02, 'grading', 0.3 );

%% Equation settings.
fea.phys.ht.dvar = { 'T' };
fea.phys.ht.sfun = { 'sflag1' };
fea.phys.ht.eqn.coef = { 'rho_ht', 'rho', 'Density', { 1 };
                         'cp_ht', 'C_p', 'Heat capacity', { 1 };
                         'k_ht', 'k', 'Thermal conductivity', { 1 };
                         'u_ht', 'u', 'Convection velocity in x-direction', { 0 };
                         'v_ht', 'v', 'Convection velocity in y-direction', { 0 };
                         'q_ht', 'Q', 'Heat source', { 0 };
                         'T0_ht', 'T_0', 'Initial condition for T', { 0 } };
fea.phys.ht.eqn.seqn = 'rho_ht*cp_ht*T'' - k_ht*(Tx_x + Ty_y) + rho_ht*cp_ht*(u_ht*Tx_t + v_ht*Ty_t) = q_ht';
fea.phys.ht.eqn.sdiff = ' - k_ht*(Tx_x + Ty_y)';
fea.phys.ht.eqn.sconv = 'rho_ht*cp_ht*(u_ht*Tx_t + v_ht*Ty_t)';
fea.phys.ht.eqn.vars = { 'Temperature, T', 'T';
                         'Temperature gradient, T', { 'Tx', 'Ty' } };
fea.phys.ht.prop.isaxi = 0;
fea.phys.ht.prop.artstab.id = 0;
fea.phys.ht.prop.artstab.id_coef = 0.5;
fea.phys.ht.prop.artstab.sd = 0;
fea.phys.ht.prop.artstab.sd_coef = 0.25;
fea.phys.ht.prop.artstab.iupw = 0;
fea.phys.ht.prop.active = 0;
fea.phys.ht.prop.intb = 0;
fea.phys.ns.dvar = { 'u', 'v', 'p' };
fea.phys.ns.sfun = { 'sflag1', 'sflag1', 'sflag1' };
fea.phys.ns.eqn.coef = { 'rho_ns', 'rho', 'Density', { '1' };
                         'miu_ns', 'mu', 'Viscosity', { '0.001' };
                         'Fx_ns', 'F_x', 'Volume force in x-direction', { '0' };
                         'Fy_ns', 'F_y', 'Volume force in y-direction', { '0' };
                         'u0_ns', 'u_0', 'Initial condition for u', { 0 };
                         'v0_ns', 'v_0', 'Initial condition for v', { 0 };
                         'p0_ns', 'p_0', 'Initial condition for p', { 0 };
                         'miuT_ns', [], 'Turbulent viscosity', { 0 } };
fea.phys.ns.eqn.sdiff = { ' - (miu_ns+miuT_ns)*(2*ux_x + uy_y + vx_y)', ' - (miu_ns+miuT_ns)*(vx_x + uy_x + 2*vy_y)', [] };
fea.phys.ns.eqn.sconv = { 'rho_ns*(u*ux_t + v*uy_t)', 'rho_ns*(u*vx_t + v*vy_t)', [] };
fea.phys.ns.eqn.seqn = { 'rho_ns*u'' - (miu_ns+miuT_ns)*(2*ux_x + uy_y + vx_y) + rho_ns*(u*ux_t + v*uy_t) + p_x = Fx_ns', 'rho_ns*v'' - (miu_ns+miuT_ns)*(vx_x + uy_x + 2*vy_y) + rho_ns*(u*vx_t + v*vy_t) + p_y = Fy_ns', 'ux_t + vy_t = 0' };
fea.phys.ns.eqn.vars = { 'Velocity field', 'sqrt(u^2+v^2)';
                         'x-velocity', 'u';
                         'y-velocity', 'v';
                         'Pressure', 'p';
                         'Vorticity', 'vx-uy';
                         'Velocity field', { 'u', 'v' } };
fea.phys.ns.prop.isaxi = 0;
fea.phys.ns.prop.artstab.id = 0;
fea.phys.ns.prop.artstab.id_coef = 0.5;
fea.phys.ns.prop.artstab.sd = 0;
fea.phys.ns.prop.artstab.sd_coef = 0.25;
fea.phys.ns.prop.artstab.ps = 1;
fea.phys.ns.prop.artstab.ps_coef = 1;
fea.phys.ns.prop.artstab.iupw = 0;
fea.phys.ns.prop.turb.model = 'laminar';
fea.phys.ns.prop.turb.wallf = 1;
fea.phys.ns.prop.turb.inlet = [];
fea.phys.ns.prop.active = [ 1;
                            1;
                            1 ];
fea.phys.ns.prop.intb = 0;

%% Boundary settings.
fea.phys.ns.bdr.sel = [ 1, 4, 1, 2, 1, 1, 1, 1 ];
fea.phys.ns.bdr.coef = { 'bw_ns', 'Zero velocity, u = v = 0', 'Wall/no-slip', [], { 1, 1, 1, 1, 1, 1, 1, 1;
                         1, 1, 1, 1, 1, 1, 1, 1;
                         0, 0, 0, 0, 0, 0, 0, 0 }, [], { 0, 0, 0, 0, 0, 0, 0, 0;
                         0, 0, 0, 0, 0, 0, 0, 0;
                         0, 0, 0, 0, 0, 0, 0, 0 };
                         'bv_ns', 'Prescribed velocity, u = u_0', 'Inlet/velocity', { 'u_0';
                         'v_0';
                         [] }, { 1, 1, 1, 1, 1, 1, 1, 1;
                         1, 1, 1, 1, 1, 1, 1, 1;
                         0, 0, 0, 0, 0, 0, 0, 0 }, [], { 0, 0, 0, '4*0.3*(y*(0.41-y))/0.41^2', 0, 0, 0, 0;
                         0, 0, 0, '0', 0, 0, 0, 0;
                         0, 0, 0, 0, 0, 0, 0, 0 };
                         'bn_ns', 'Zero stress boundary', 'Neutral outflow/stress boundary', [], { 0, 0, 0, 0, 0, 0, 0, 0;
                         0, 0, 0, 0, 0, 0, 0, 0;
                         0, 0, 0, 0, 0, 0, 0, 0 }, [], { 0, 0, 0, 0, 0, 0, 0, 0;
                         0, 0, 0, 0, 0, 0, 0, 0;
                         0, 0, 0, 0, 0, 0, 0, 0 };
                         'bp_ns', 'Prescribed pressure, p = p_0', 'Outflow/pressure', { [];
                         [];
                         'p_0' }, { 0, 0, 0, 0, 0, 0, 0, 0;
                         0, 0, 0, 0, 0, 0, 0, 0;
                         1, 1, 1, 1, 1, 1, 1, 1 }, { { '-p*nx';
                         '-p*ny';
                         '0' };
                         [] }, { 0, 0, 0, 0, 0, 0, 0, 0;
                         0, 0, 0, 0, 0, 0, 0, 0;
                         0, '0', 0, 0, 0, 0, 0, 0 };
                         'bs_ns', 'Zero normal velocity, n&.u = 0', 'Symmetry/slip', [], { 0, 0, 0, 0, 0, 0, 0, 0;
                         0, 0, 0, 0, 0, 0, 0, 0;
                         0, 0, 0, 0, 0, 0, 0, 0 }, [], { 'solve_hook_bdrslip', 'solve_hook_bdrslip', 'solve_hook_bdrslip', 'solve_hook_bdrslip', 'solve_hook_bdrslip', 'solve_hook_bdrslip', 'solve_hook_bdrslip', 'solve_hook_bdrslip';
                         0, 0, 0, 0, 0, 0, 0, 0;
                         0, 0, 0, 0, 0, 0, 0, 0 } };
fea.phys.ns.bdr.coefi = { 'bcic_ns', 'Flow continuity', 'Continuity', [], { 0, 0, 0, 0, 0, 0, 0, 0;
                          0, 0, 0, 0, 0, 0, 0, 0;
                          0, 0, 0, 0, 0, 0, 0, 0 }, [], { 0, 0, 0, 0, 0, 0, 0, 0;
                          0, 0, 0, 0, 0, 0, 0, 0;
                          0, 0, 0, 0, 0, 0, 0, 0 };
                          'bcij_ns', 'Prescribed velocity, u = u_0', 'Prescribed velocity', { 'u_0';
                          'v_0';
                          [] }, { 1, 1, 1, 1, 1, 1, 1, 1;
                          1, 1, 1, 1, 1, 1, 1, 1;
                          0, 0, 0, 0, 0, 0, 0, 0 }, [], { 0, 0, 0, 0, 0, 0, 0, 0;
                          0, 0, 0, 0, 0, 0, 0, 0;
                          0, 0, 0, 0, 0, 0, 0, 0 };
                          'bcir_ns', 'Prescribed pressure, p = p_0', 'Prescribed pressure', { [];
                          [];
                          'p_0' }, { 0, 0, 0, 0, 0, 0, 0, 0;
                          0, 0, 0, 0, 0, 0, 0, 0;
                          1, 1, 1, 1, 1, 1, 1, 1 }, [], { 0, 0, 0, 0, 0, 0, 0, 0;
                          0, 0, 0, 0, 0, 0, 0, 0;
                          0, 0, 0, 0, 0, 0, 0, 0 } };
fea.phys.ns.bdr.vars = { 'Viscous force, x-component', '(miu_ns+miuT_ns)*(2*nx*ux+ny*(uy+vx))';
                         'Viscous force, y-component', '(miu_ns+miuT_ns)*(nx*(vx+uy)+2*ny*vy)';
                         'Total force, x-component', '-nx*p+(miu_ns+miuT_ns)*(2*nx*ux+ny*(uy+vx))';
                         'Total force, y-component', '-ny*p+(miu_ns+miuT_ns)*(nx*(vx+uy)+2*ny*vy)' };
fea.phys.ns.prop.intb = 0;

%% Solver call.
fea = parsephys( fea );
fea = parseprob( fea );

fea.sol.u = solvestat( fea, ...
                       'iupw', [ 0, 0, 0 ], ...
                       'linsolv', 'backslash', ...
                       'icub', 'auto', ...
                       'nlrlx', 1, ...
                       'toldef', 1e-06, ...
                       'tolchg', 1e-06, ...
                       'reldef', 0, ...
                       'relchg', 1, ...
                       'maxnit', 20, ...
                       'hook', [], ...
                       'nproc', 2, ...
                       'init', { 'u0_ns', 'v0_ns', 'p0_ns' }, ...
                       'solcomp', [ 1; 1; 1 ] );

%% Postprocessing.
postplot( fea, ...
          'surfexpr', 'sqrt(u^2+v^2)', ...
          'title', 'surface: Velocity field', ...
          'solnum', 1 );

