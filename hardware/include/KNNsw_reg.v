//START_TABLE sw_reg
`SWREG_W(KNN_RESET,          1, 0) //Timer soft reset
`SWREG_W(KNN_ENABLE,         1, 0) //Timer enable
`SWREG_W(DATA_X1, DATA_W, 0)//Data input register
`SWREG_W(DATA_X2, DATA_W, 0)
`SWREG_W(DATA_Y1, DATA_W, 0)
`SWREG_W(DATA_Y2, DATA_W, 0)
`SWREG_R(DATA_OUT, DATA_W, 0)
