# Plant Life Support — Projeto de Bloco: Sistemas Digitais Embarcados

Sistema embarcado de monitoramento e controle ambiental para o cultivo de um pé de manjericão, desenvolvido para a disciplina de Projeto de Bloco: Sistemas Digitais Embarcados do curso de Engenharia da Computação do Instituto INFNET, sob orientação do professor Dácio Moreira de Souza.

## Visão geral

O sistema é dividido em duas unidades de processamento com responsabilidades bem separadas:

- **Tang Nano 9K (FPGA, Verilog)** — aquisição paralela dos sensores. Nunca interpreta nem decide nada, apenas lê os valores brutos e os transmite.
- **Raspberry Pi Zero 2W (Assembly ARM64)** — recepção dos dados, conversão para unidades reais, lógica de decisão, acionamento dos atuadores e exibição no display.

A comunicação entre as duas placas é feita por SPI bit-banged (o Raspberry Pi como mestre), com handshaking por comando (`0xA5`), byte de status e checksum para detecção de erro na transmissão.

### Sensores
- **BME280** — temperatura, umidade do ar e pressão atmosférica (I2C).
- **BH1750** — luminosidade (I2C).
- **Sensor capacitivo de umidade do solo** — lido via conversor analógico-digital MCP3008 (SPI).

### Atuadores
- Bomba peristáltica (irrigação).
- Fita de luz de crescimento vermelha e azul.

### Interface
- Display de cristal líquido 16x2, protocolo HD44780, conectado via I2C através de um expansor PCF8574T.

## Estrutura do repositório

O repositório está organizado por entrega, seguindo o cronograma da disciplina (cinco Testes de Performance mais a entrega final):

```
TP1/  TP2/  TP3/   -> Assembly/  Verilog/
TP4/  TP5/  AT/     -> RPi/      FPGA/
```

- `TP1` a `TP3` usam as pastas `Assembly/` e `Verilog/`.
- `TP4`, `TP5` e `AT` (a entrega final) usam `RPi/` e `FPGA/`, refletindo a divisão de hardware real do sistema a partir da integração completa.
- `AT/` contém a versão final do projeto, evoluída a partir do TP5.

Cada pasta de TP corresponde a um relatório próprio (Parte 1: relatório narrativo; Parte 2: apêndice técnico com código e evidências), entregues separadamente no Moodle.

## Hardware principal

| Componente | Função |
|---|---|
| Raspberry Pi Zero 2W | Unidade de controle e decisão (Assembly ARM64) |
| Tang Nano 9K | FPGA de aquisição dedicada (Verilog) |
| BME280 | Temperatura, umidade do ar, pressão (I2C) |
| BH1750 | Luminosidade (I2C) |
| Sensor capacitivo de umidade do solo + MCP3008 | Umidade do solo (SPI) |
| LCD 16x2 + PCF8574T | Exibição em tempo real (I2C) |
| Bomba peristáltica | Irrigação |
| Fita de luz de crescimento | Compensação de luminosidade |

## Organização do código (AT/RPi)

O código Assembly é modular, organizado em bibliotecas estáticas por tema:

- `libaritmetica.a`
- `libio.a`
- `libparsing.a`
- `libutilidades.a`

O `Makefile` compila os módulos individuais e os agrupa nessas bibliotecas antes de linkar o executável final (`main`).

## Toolchain

**Raspberry Pi (Assembly ARM64):**
- `aarch64-linux-gnu-as`, `aarch64-linux-gnu-ld`, `aarch64-linux-gnu-objdump`
- GDB para depuração
- `make`

**FPGA (Verilog):**
- Gowin IDE Education Edition (síntese, FloorPlanner, Programmer)
- Icarus Verilog + GTKWave (simulação)
- `openFPGALoader` como alternativa em Linux

## Como compilar e rodar

**Raspberry Pi:**
```bash
cd AT/RPi
make
./main
```

**FPGA — simulação dos testbenches:**
```bash
cd AT/FPGA
iverilog -o sim_umiSolo fsm_umiSolo.v fsm_umiSolo_tb.v
vvp sim_umiSolo
gtkwave fsm_umiSolo_tb.vcd fsm_umiSolo_tb.gtkw

iverilog -o sim_spi spi_transmite_dados.v spi_transmite_dados_tb.v
vvp sim_spi
gtkwave spi_transmite_dados_tb.vcd spi_transmite_dados_tb.gtkw
```

Os arquivos `.gtkw` já trazem os sinais relevantes de cada testbench pré-selecionados.

## Tags

O histórico de commits está marcado com uma tag por entrega: `TP1`, `TP2`, `TP3`, `TP4`, `TP5` e `FINAL` (esta última na entrega definitiva do AT).

## Evidências

Fotos e vídeos de funcionamento do protótipo físico não ficam versionados neste repositório — eles são referenciados por link (OneDrive) diretamente no relatório final em PDF entregue no Moodle.

## Autor

Gabriel Carvalho — Engenharia da Computação, Instituto INFNET.
