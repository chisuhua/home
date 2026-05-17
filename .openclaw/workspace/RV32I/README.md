# RV32I - Phase 3D: UART16550 Controller

## Overview

UART16550 controller implementation for RV32I CPU project (Phase 3D: Peripheral Integration).

## Specifications

- **Baud Rate**: 115200 (configurable)
- **Data Bits**: 8
- **Stop Bits**: 1
- **Parity**: None
- **FIFO**: 16 bytes (RX and TX)
- **Interface**: AXI4-Lite Slave

## Register Map

| Offset | Register | Access | Description |
|--------|----------|--------|-------------|
| 0x00   | RBR/THR  | R/W    | Receiver Buffer / Transmitter Holding |
| 0x04   | IER      | W      | Interrupt Enable Register |
| 0x08   | FCR      | W      | FIFO Control Register |
| 0x0C   | LCR      | W      | Line Control Register |
| 0x10   | MCR      | W      | Modem Control Register |
| 0x14   | LSR      | R      | Line Status Register |

## Build & Test

```bash
# Build and run tests
make test

# Debug build with sanitizers
make debug
./build/test_uart

# Clean
make clean
```

## Test Coverage

- ✓ Reset behavior
- ✓ Baud rate configuration
- ✓ THR write / RBR read
- ✓ FIFO fill and drain
- ✓ FIFO overrun detection
- ✓ Interrupt enable/status
- ✓ Register access (IER, FCR, LCR, MCR, LSR)
- ✓ AXI address masking
- ✓ Loopback mode
- ✓ FIFO clear

## Files

```
RV32I/
├── include/uart/uart16550.h   # UART controller header
├── tests/test_uart.cpp        # Test suite (17 tests)
├── Makefile                   # Build system
└── README.md                  # This file
```

## Status

✅ **Phase 3D Round 1 Complete** - UART16550 Controller
- All 17 tests passing
- Zero compiler warnings (-Wall -Wextra -Werror)
- Clean AddressSanitizer/UBSan run

## Next

Waiting for Round 2 instructions (Timer/定时器 implementation)
