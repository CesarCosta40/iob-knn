//START_TABLE sw_reg
`SWREG_W(DATA_1, DATA_W, 0)//Data input register
`SWREG_W(DATA_2, DATA_W, 0)//Data input register
`SWREG_R(DATA_OUT, DATA_W/4, 0)
`SWREG_W(KNN_RESET, 1, 0)
`SWREG_W(DONE, 1, 0)
`SWREG_W(SEL, 4, 0)
