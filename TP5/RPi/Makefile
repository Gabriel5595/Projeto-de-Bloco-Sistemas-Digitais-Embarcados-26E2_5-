AS      = as
AR      = ar
LD      = ld
OBJDUMP = objdump
GDB     = gdb

TARGET  = main

OBJS_TOP = main.o fsm_principal.o

OBJS_ARITMETICA = converte_temp.o converte_luz.o converte_umidade_ar.o converte_umidade_solo.o \
                coeficientes_calibracao.o calcula_info.o

OBJS_IO = gpio.o estabelece_conexao.o atuadores.o usa_lcd.o apresenta_info_em_tela.o

OBJS_PARSING = recebe_info.o tabelas_amostras.o

OBJS_UTILIDADES = eh_dia.o

LIB_ARITMETICA = libaritmetica.a
LIB_IO = libio.a
LIB_PARSING = libparsing.a
LIB_UTILIDADES = libutilidades.a

LIBS = $(LIB_ARITMETICA) $(LIB_IO) $(LIB_PARSING) $(LIB_UTILIDADES)

all: $(TARGET)

$(TARGET): $(OBJS_TOP) $(LIBS)
	$(LD) -o $(TARGET) $(OBJS_TOP) --start-group $(LIBS) --end-group

$(LIB_ARITMETICA): $(OBJS_ARITMETICA)
	$(AR) rcs $(LIB_ARITMETICA) $(OBJS_ARITMETICA)

$(LIB_IO): $(OBJS_IO)
	$(AR) rcs $(LIB_IO) $(OBJS_IO)

$(LIB_PARSING): $(OBJS_PARSING)
	$(AR) rcs $(LIB_PARSING) $(OBJS_PARSING)

$(LIB_UTILIDADES): $(OBJS_UTILIDADES)
	$(AR) rcs $(LIB_UTILIDADES) $(OBJS_UTILIDADES)

main.o: main.s
	$(AS) -g -o main.o main.s

fsm_principal.o: fsm_principal.s
	$(AS) -g -o fsm_principal.o fsm_principal.s

converte_temp.o: converte_temp.s
	$(AS) -g -o converte_temp.o converte_temp.s

converte_luz.o: converte_luz.s
	$(AS) -g -o converte_luz.o converte_luz.s

converte_umidade_ar.o: converte_umidade_ar.s
	$(AS) -g -o converte_umidade_ar.o converte_umidade_ar.s

converte_umidade_solo.o: converte_umidade_solo.s
	$(AS) -g -o converte_umidade_solo.o converte_umidade_solo.s

coeficientes_calibracao.o: coeficientes_calibracao.s
	$(AS) -g -o coeficientes_calibracao.o coeficientes_calibracao.s

calcula_info.o: calcula_info.s
	$(AS) -g -o calcula_info.o calcula_info.s

gpio.o: gpio.s
	$(AS) -g -o gpio.o gpio.s

estabelece_conexao.o: estabelece_conexao.s
	$(AS) -g -o estabelece_conexao.o estabelece_conexao.s

atuadores.o: atuadores.s
	$(AS) -g -o atuadores.o atuadores.s

usa_lcd.o: usa_lcd.s
	$(AS) -g -o usa_lcd.o usa_lcd.s

apresenta_info_em_tela.o: apresenta_info_em_tela.s
	$(AS) -g -o apresenta_info_em_tela.o apresenta_info_em_tela.s

recebe_info.o: recebe_info.s
	$(AS) -g -o recebe_info.o recebe_info.s

tabelas_amostras.o: tabelas_amostras.s
	$(AS) -g -o tabelas_amostras.o tabelas_amostras.s

eh_dia.o: eh_dia.s
	$(AS) -g -o eh_dia.o eh_dia.s

run: $(TARGET)
	sudo ./$(TARGET)

debug: $(TARGET)
	sudo $(GDB) ./$(TARGET)

disasm: $(TARGET)
	$(OBJDUMP) -d $(TARGET)

clean:
	rm -f *.o *.a $(TARGET)
