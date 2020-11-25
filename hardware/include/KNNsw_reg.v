//START_TABLE sw_reg
`SWREG_W(KNN_RESET,          1, 0) //Timer soft reset
`SWREG_W(KNN_ENABLE,         1, 0) //Timer enable
`SWREG_W(DATA_1, DATA_W, 0)//Data input register
`SWREG_W(DATA_2, DATA_W, 0)
`SWREG_R(DATA_OUT, DATA_W, 0)
