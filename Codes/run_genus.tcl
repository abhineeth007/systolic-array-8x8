set_db init_lib_search_path [list /home/install/FOUNDRY/digital/90nm/dig/lib/]
read_libs slow.lib

set TOP Conv2Ch2x2_SystolicArray_Top
set RTL_FILES [list \
    Processing_Element.v \
    S2P_Skew_OneShot.v \
    Deskew_8x8.v \
    Systolic_Array_8x8.v \
    im2col_addr_gen.v \
    Conv2Ch2x2_SystolicArray_Top.v \
]

read_hdl $RTL_FILES

elaborate $TOP
check_design -unresolved

read_sdc systolic_constraints.sdc

set_db syn_generic_effort medium
set_db syn_map_effort medium
set_db syn_opt_effort medium

syn_generic
syn_map
syn_opt

file mkdir reports
report_timing > reports/${TOP}_timing.rep
report_area   > reports/${TOP}_area.rep
report_power  > reports/${TOP}_pwr.rep

file mkdir outputs
write_hdl > outputs/${TOP}_net.v
write_sdc > outputs/${TOP}_block.sdc

gui_show