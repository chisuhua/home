#ifndef UART16550_H
#define UART16550_H

#include <cstdint>
#include <cstring>

namespace rv32i {
namespace uart {

// ============================================================================
// UART16550 Register Offsets (AXI4-Lite interface)
// ============================================================================
constexpr uint32_t UART_RBR_OFFSET = 0x00;  // Receiver Buffer Register (read)
constexpr uint32_t UART_THR_OFFSET = 0x00;  // Transmitter Holding Register (write)
constexpr uint32_t UART_IER_OFFSET = 0x04;  // Interrupt Enable Register
constexpr uint32_t UART_FCR_OFFSET = 0x08;  // FIFO Control Register
constexpr uint32_t UART_LCR_OFFSET = 0x0C;  // Line Control Register
constexpr uint32_t UART_MCR_OFFSET = 0x10;  // Modem Control Register
constexpr uint32_t UART_LSR_OFFSET = 0x14;  // Line Status Register

// ============================================================================
// Interrupt Enable Register (IER) bits
// ============================================================================
constexpr uint8_t IER_RDA_IE   = (1 << 0);  // Received Data Available Interrupt
constexpr uint8_t IER_THRE_IE  = (1 << 1);  // THR Empty Interrupt
constexpr uint8_t IER_RLS_IE   = (1 << 2);  // Receiver Line Status Interrupt
constexpr uint8_t IER_MS_IE    = (1 << 3);  // Modem Status Interrupt

// ============================================================================
// FIFO Control Register (FCR) bits
// ============================================================================
constexpr uint8_t FCR_FIFO_EN   = (1 << 0);  // FIFO Enable
constexpr uint8_t FCR_RX_FIFO_CLR = (1 << 1);  // Clear Receive FIFO
constexpr uint8_t FCR_TX_FIFO_CLR = (1 << 2);  // Clear Transmit FIFO
constexpr uint8_t FCR_DMA_MODE    = (1 << 3);  // DMA Mode Select
// FIFO Trigger Level (bits 6:7)
constexpr uint8_t FCR_TRIGGER_1   = (0 << 6);  // 1 byte
constexpr uint8_t FCR_TRIGGER_4   = (1 << 6);  // 4 bytes
constexpr uint8_t FCR_TRIGGER_8   = (2 << 6);  // 8 bytes
constexpr uint8_t FCR_TRIGGER_14  = (3 << 6);  // 14 bytes

// ============================================================================
// Line Control Register (LCR) bits
// ============================================================================
constexpr uint8_t LCR_WLS_5    = (0 << 0);  // Word Length Select: 5 bits
constexpr uint8_t LCR_WLS_6    = (1 << 0);  // Word Length Select: 6 bits
constexpr uint8_t LCR_WLS_7    = (2 << 0);  // Word Length Select: 7 bits
constexpr uint8_t LCR_WLS_8    = (3 << 0);  // Word Length Select: 8 bits
constexpr uint8_t LCR_STOP     = (1 << 2);  // Stop Bits (0=1, 1=2)
constexpr uint8_t LCR_PARITY_EN = (1 << 3); // Parity Enable
constexpr uint8_t LCR_PARITY_ODD = (1 << 4); // Parity Select (0=even, 1=odd)
constexpr uint8_t LCR_BREAK    = (1 << 6);  // Set Break
constexpr uint8_t LCR_DLAB     = (1 << 7);  // Divisor Latch Access Bit

// ============================================================================
// Modem Control Register (MCR) bits
// ============================================================================
constexpr uint8_t MCR_DTR = (1 << 0);  // Data Terminal Ready
constexpr uint8_t MCR_RTS = (1 << 1);  // Request To Send
constexpr uint8_t MCR_OUT1 = (1 << 2); // Output 1
constexpr uint8_t MCR_OUT2 = (1 << 3); // Output 2 (interrupt enable)
constexpr uint8_t MCR_LOOP = (1 << 4); // Loopback Mode

// ============================================================================
// Line Status Register (LSR) bits
// ============================================================================
constexpr uint8_t LSR_DR    = (1 << 0);  // Data Ready (receive buffer has data)
constexpr uint8_t LSR_OE    = (1 << 1);  // Overrun Error
constexpr uint8_t LSR_PE    = (1 << 2);  // Parity Error
constexpr uint8_t LSR_FE    = (1 << 3);  // Framing Error
constexpr uint8_t LSR_BI    = (1 << 4);  // Break Interrupt
constexpr uint8_t LSR_THRE  = (1 << 5);  // THR Empty
constexpr uint8_t LSR_TEMT  = (1 << 6);  // Transmitter Empty
constexpr uint8_t LSR_FIFO_ERR = (1 << 7); // FIFO Error

// ============================================================================
// UART Configuration
// ============================================================================
constexpr uint32_t UART_DEFAULT_BAUD = 115200;
constexpr uint32_t UART_DEFAULT_CLOCK = 1843200;  // 1.8432 MHz typical clock
constexpr size_t UART_FIFO_SIZE = 16;

// ============================================================================
// UART16550 Controller Class
// ============================================================================
class UART16550 {
public:
    // Register map structure (AXI4-Lite slave interface)
    struct Registers {
        uint32_t rbr_thr;  // 0x00: RBR (read) / THR (write)
        uint32_t ier;      // 0x04: Interrupt Enable Register
        uint32_t fcr;      // 0x08: FIFO Control Register
        uint32_t lcr;      // 0x0C: Line Control Register
        uint32_t mcr;      // 0x10: Modem Control Register
        uint32_t lsr;      // 0x14: Line Status Register
    };

private:
    Registers regs_;
    uint8_t rx_fifo_[UART_FIFO_SIZE];  // Receive FIFO buffer
    uint8_t tx_fifo_[UART_FIFO_SIZE];  // Transmit FIFO buffer
    size_t rx_head_ = 0;
    size_t rx_tail_ = 0;
    size_t rx_count_ = 0;  // Track count separately to handle full FIFO
    size_t tx_head_ = 0;
    size_t tx_tail_ = 0;
    size_t tx_count_ = 0;  // Track count separately to handle full FIFO
    uint32_t baud_rate_ = UART_DEFAULT_BAUD;
    uint32_t clock_freq_ = UART_DEFAULT_CLOCK;

    // Helper: get FIFO count (now trivial with separate counter)
    size_t rx_count() const {
        return rx_count_;
    }
    
    size_t tx_count() const {
        return tx_count_;
    }

    // Helper: update LSR based on FIFO state
    void update_lsr() {
        regs_.lsr &= ~(LSR_DR | LSR_THRE | LSR_TEMT);
        
        if (rx_count() > 0) {
            regs_.lsr |= LSR_DR;
        }
        
        if (tx_count() == 0) {
            regs_.lsr |= LSR_THRE | LSR_TEMT;
        } else if (tx_count() < UART_FIFO_SIZE) {
            regs_.lsr |= LSR_THRE;
        }
    }

public:
    UART16550() {
        reset();
    }

    // Reset the UART controller
    void reset() {
        std::memset(&regs_, 0, sizeof(Registers));
        std::memset(rx_fifo_, 0, sizeof(rx_fifo_));
        std::memset(tx_fifo_, 0, sizeof(tx_fifo_));
        rx_head_ = rx_tail_ = rx_count_ = 0;
        tx_head_ = tx_tail_ = tx_count_ = 0;
        baud_rate_ = UART_DEFAULT_BAUD;
        // After reset: LSR indicates THR and TEMT are empty
        regs_.lsr = LSR_THRE | LSR_TEMT;
    }

    // Configure baud rate
    void set_baud_rate(uint32_t baud) {
        baud_rate_ = baud;
    }

    uint32_t get_baud_rate() const {
        return baud_rate_;
    }

    // AXI4-Lite Read (word-aligned access)
    uint32_t axi_read(uint32_t addr) {
        uint32_t offset = addr & 0x1F;  // Only care about lower 5 bits
        
        switch (offset) {
            case UART_RBR_OFFSET:
                // Read from RBR (only valid when LSR.DR is set)
                if (regs_.lsr & LSR_DR) {
                    uint8_t data = rx_fifo_[rx_tail_];
                    rx_tail_ = (rx_tail_ + 1) % UART_FIFO_SIZE;
                    rx_count_--;
                    update_lsr();
                    return data;
                }
                return 0;
                
            case UART_IER_OFFSET:
                return regs_.ier;
                
            case UART_FCR_OFFSET:
                return regs_.fcr;
                
            case UART_LCR_OFFSET:
                return regs_.lcr;
                
            case UART_MCR_OFFSET:
                return regs_.mcr;
                
            case UART_LSR_OFFSET:
                return regs_.lsr;
                
            default:
                return 0;
        }
    }

    // AXI4-Lite Write (word-aligned access)
    void axi_write(uint32_t addr, uint32_t data) {
        uint32_t offset = addr & 0x1F;
        
        switch (offset) {
            case UART_THR_OFFSET:
                // Write to THR (only valid when LSR.THRE is set)
                if (regs_.lsr & LSR_THRE) {
                    if (tx_count_ < UART_FIFO_SIZE) {
                        tx_fifo_[tx_head_] = static_cast<uint8_t>(data & 0xFF);
                        tx_head_ = (tx_head_ + 1) % UART_FIFO_SIZE;
                        tx_count_++;
                        update_lsr();
                    }
                }
                break;
                
            case UART_IER_OFFSET:
                regs_.ier = data & 0x0F;  // Only lower 4 bits are valid
                break;
                
            case UART_FCR_OFFSET:
                regs_.fcr = data & 0xBF;  // Bits 6-7 are trigger level, bit 7 is reserved
                if (data & FCR_RX_FIFO_CLR) {
                    rx_head_ = rx_tail_ = rx_count_ = 0;
                }
                if (data & FCR_TX_FIFO_CLR) {
                    tx_head_ = tx_tail_ = tx_count_ = 0;
                }
                update_lsr();
                break;
                
            case UART_LCR_OFFSET:
                regs_.lcr = data & 0xFF;
                break;
                
            case UART_MCR_OFFSET:
                regs_.mcr = data & 0x1F;  // Only lower 5 bits are valid
                break;
                
            case UART_LSR_OFFSET:
                // LSR is read-only, writes are ignored
                break;
                
            default:
                break;
        }
    }

    // Simulate receiving a character (called by external environment)
    bool receive_char(uint8_t c) {
        if (rx_count_ >= UART_FIFO_SIZE) {
            regs_.lsr |= LSR_OE;  // Overrun error
            return false;
        }
        rx_fifo_[rx_head_] = c;
        rx_head_ = (rx_head_ + 1) % UART_FIFO_SIZE;
        rx_count_++;
        update_lsr();
        return true;
    }

    // Simulate transmitting a character (returns true if FIFO was empty)
    bool transmit_char(uint8_t* c) {
        if (tx_count_ == 0) {
            return false;  // No data to transmit
        }
        *c = tx_fifo_[tx_tail_];
        tx_tail_ = (tx_tail_ + 1) % UART_FIFO_SIZE;
        tx_count_--;
        update_lsr();
        return true;
    }

    // Check if transmitter is completely empty
    bool is_transmitter_empty() const {
        return (regs_.lsr & LSR_TEMT) != 0;
    }

    // Check if receiver has data
    bool has_data() const {
        return (regs_.lsr & LSR_DR) != 0;
    }

    // Get interrupt status (for interrupt controller integration)
    uint8_t get_interrupt_status() const {
        uint8_t status = 0;
        
        // Check if interrupts are enabled and conditions are met
        if ((regs_.ier & IER_RDA_IE) && (regs_.lsr & LSR_DR)) {
            status |= IER_RDA_IE;
        }
        if ((regs_.ier & IER_THRE_IE) && (regs_.lsr & LSR_THRE)) {
            status |= IER_THRE_IE;
        }
        
        return status;
    }

    // Direct register access for testing
    const Registers& get_regs() const { return regs_; }
    
    // Public FIFO count accessors for testing
    size_t get_rx_count() const { return rx_count(); }
    size_t get_tx_count() const { return tx_count(); }
    
    // Get register by offset
    uint32_t read_register(uint32_t offset) const {
        switch (offset) {
            case UART_RBR_OFFSET: return regs_.rbr_thr;
            case UART_IER_OFFSET: return regs_.ier;
            case UART_FCR_OFFSET: return regs_.fcr;
            case UART_LCR_OFFSET: return regs_.lcr;
            case UART_MCR_OFFSET: return regs_.mcr;
            case UART_LSR_OFFSET: return regs_.lsr;
            default: return 0;
        }
    }
};

} // namespace uart
} // namespace rv32i

#endif // UART16550_H
