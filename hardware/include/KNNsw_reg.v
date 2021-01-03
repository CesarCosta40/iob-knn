//START_TABLE sw_reg
`SWREG_W(DATA_1, DATA_W, 0)//Test point input register
`SWREG_W(DATA_2, DATA_W, 0)//Dataset point input register
`SWREG_R(DATA_OUT, 16, 0)//Index output register
`SWREG_W(DONE, 1, 1)//Signal if all dataset points have been sent
`SWREG_W(SOLVER_SEL, 16, 0)//Solver module select
`SWREG_W(SEL, 16, 0)//Neighbor select
`SWREG_W(SERIES_ENABLE, 2, 0)//LSB is whether a module is working in paralell or in series with the one before in order to solve bigger problems. MSB is enable
`SWREG_W(KNN_RESET, 1, 0)//Soft reset
