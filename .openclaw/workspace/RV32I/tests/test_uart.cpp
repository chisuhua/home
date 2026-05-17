#include <iostream>
#include <cassert>
#include <cstdint>
#include <cstring>
#include "../include/uart/uart16550.h"

using namespace rv32i::uart;

// Test result tracking
static int tests_passed = 0;
static int tests_failed = 0;

#define TEST(name) void name()
#define RUN_TEST(name) do { \
    std::cout << "Running " << #name << "... "; \
    try { \
        name(); \
        std::cout << "✓ PASS" << std::endl; \
        tests_passed++; \
    } catch (const std::exception& e) { \
        std::cout << "✗ FAIL: " << e.what() << std::endl; \
        tests_failed++; \
    } catch (...) { \
        std::cout << "✗ FAIL: Unknown exception" << std::endl; \
        tests_failed++; \
    } \
} while(0)

#define ASSERT_EQ(a, b, msg) do { \
    if ((a) != (b)) { \
        throw std::runtime_error(std::string(msg) + " - Expected " + std::to_string(b) + ", got " + std::to_string(a)); \
    } \
} while(0)

#define ASSERT_TRUE(cond, msg) do { \
    if (!(cond)) { \
        throw std::runtime_error(msg); \
    } \
} while(0)

// ============================================================================
// Test Cases
// ============================================================================

TEST(test_uart_reset) {
    UART16550 uart;
    uart.reset();
    
    // After reset, THR and TEMT should be set (transmitter empty)
    ASSERT_EQ(uart.get_regs().lsr & (LSR_THRE | LSR_TEMT), LSR_THRE | LSR_TEMT, 
              "After reset, THR and TEMT should be set");
    
    // Data Ready should be clear
    ASSERT_EQ(uart.get_regs().lsr & LSR_DR, 0, 
              "After reset, DR should be clear");
}

TEST(test_uart_baud_rate) {
    UART16550 uart;
    
    // Default baud rate
    ASSERT_EQ(uart.get_baud_rate(), UART_DEFAULT_BAUD, 
              "Default baud rate should be 115200");
    
    // Set custom baud rate
    uart.set_baud_rate(9600);
    ASSERT_EQ(uart.get_baud_rate(), 9600, 
              "Baud rate should be 9600 after setting");
}

TEST(test_uart_write_thr) {
    UART16550 uart;
    uart.reset();
    
    // Write to THR (offset 0x00)
    uart.axi_write(UART_THR_OFFSET, 'A');
    
    // THR should no longer be empty
    ASSERT_TRUE(!(uart.get_regs().lsr & LSR_THRE) || uart.get_tx_count() > 0, 
                "After writing to THR, FIFO should have data");
}

TEST(test_uart_read_rbr_empty) {
    UART16550 uart;
    uart.reset();
    
    // Read from RBR when empty should return 0
    uint32_t data = uart.axi_read(UART_RBR_OFFSET);
    ASSERT_EQ(data, 0, "Reading from empty RBR should return 0");
}

TEST(test_uart_receive_char) {
    UART16550 uart;
    uart.reset();
    
    // Receive a character
    bool result = uart.receive_char('X');
    ASSERT_TRUE(result, "receive_char should succeed when FIFO is not full");
    
    // LSR.DR should be set
    ASSERT_TRUE(uart.get_regs().lsr & LSR_DR, 
                "After receiving char, LSR.DR should be set");
    
    // Read the character
    uint32_t data = uart.axi_read(UART_RBR_OFFSET);
    ASSERT_EQ(data, 'X', "Should read back the received character");
    
    // LSR.DR should be clear after reading
    ASSERT_TRUE(!(uart.get_regs().lsr & LSR_DR), 
                "After reading, LSR.DR should be clear");
}

TEST(test_uart_fifo_fill) {
    UART16550 uart;
    uart.reset();
    
    // Fill the receive FIFO
    for (size_t i = 0; i < UART_FIFO_SIZE; i++) {
        bool result = uart.receive_char(static_cast<uint8_t>('A' + i));
        ASSERT_TRUE(result, "FIFO should accept 16 characters");
    }
    
    // FIFO should be full now
    ASSERT_TRUE(uart.has_data(), "FIFO should have data");
    
    // Read all characters back
    for (size_t i = 0; i < UART_FIFO_SIZE; i++) {
        uint32_t data = uart.axi_read(UART_RBR_OFFSET);
        ASSERT_EQ(data, 'A' + i, "Should read back characters in order");
    }
}

TEST(test_uart_fifo_overrun) {
    UART16550 uart;
    uart.reset();
    
    // Fill the FIFO
    for (size_t i = 0; i < UART_FIFO_SIZE; i++) {
        uart.receive_char('A');
    }
    
    // Try to receive one more - should fail and set overrun error
    bool result = uart.receive_char('B');
    ASSERT_TRUE(!result, "receive_char should fail when FIFO is full");
    
    // Overrun error should be set
    ASSERT_TRUE(uart.get_regs().lsr & LSR_OE, 
                "Overrun error should be set when FIFO overflows");
}

TEST(test_uart_transmit_fifo) {
    UART16550 uart;
    uart.reset();
    
    // Write multiple characters to THR
    const char* test_str = "Hello";
    for (size_t i = 0; i < strlen(test_str); i++) {
        uart.axi_write(UART_THR_OFFSET, test_str[i]);
    }
    
    // Read characters back via transmit_char
    for (size_t i = 0; i < strlen(test_str); i++) {
        uint8_t c;
        bool result = uart.transmit_char(&c);
        ASSERT_TRUE(result, "Should be able to transmit character");
        ASSERT_EQ(c, test_str[i], "Transmitted character should match");
    }
    
    // Transmitter should be empty now
    ASSERT_TRUE(uart.is_transmitter_empty(), 
                "Transmitter should be empty after sending all chars");
}

TEST(test_uart_ier) {
    UART16550 uart;
    uart.reset();
    
    // Write to IER
    uart.axi_write(UART_IER_OFFSET, IER_RDA_IE | IER_THRE_IE);
    
    // Read back
    uint32_t ier = uart.axi_read(UART_IER_OFFSET);
    ASSERT_EQ(ier, IER_RDA_IE | IER_THRE_IE, 
              "IER should retain written value");
}

TEST(test_uart_fcr) {
    UART16550 uart;
    uart.reset();
    
    // Enable FIFO and set trigger level
    uart.axi_write(UART_FCR_OFFSET, FCR_FIFO_EN | FCR_TRIGGER_8);
    
    // Read back
    uint32_t fcr = uart.axi_read(UART_FCR_OFFSET);
    ASSERT_TRUE(fcr & FCR_FIFO_EN, "FCR should have FIFO enabled");
}

TEST(test_uart_lcr_8n1) {
    UART16550 uart;
    uart.reset();
    
    // Configure for 8N1: 8 data bits, no parity, 1 stop bit
    uint8_t lcr = LCR_WLS_8;  // 8 data bits, no parity, 1 stop bit
    uart.axi_write(UART_LCR_OFFSET, lcr);
    
    // Read back
    uint32_t read_lcr = uart.axi_read(UART_LCR_OFFSET);
    ASSERT_EQ(read_lcr & 0x07, LCR_WLS_8, "LCR should be configured for 8N1");
}

TEST(test_uart_mcr) {
    UART16550 uart;
    uart.reset();
    
    // Set DTR and RTS
    uart.axi_write(UART_MCR_OFFSET, MCR_DTR | MCR_RTS);
    
    // Read back
    uint32_t mcr = uart.axi_read(UART_MCR_OFFSET);
    ASSERT_EQ(mcr, MCR_DTR | MCR_RTS, 
              "MCR should retain DTR and RTS settings");
}

TEST(test_uart_interrupt_status) {
    UART16550 uart;
    uart.reset();
    
    // Enable receive interrupt
    uart.axi_write(UART_IER_OFFSET, IER_RDA_IE);
    
    // No data yet - no interrupt
    uint8_t status = uart.get_interrupt_status();
    ASSERT_EQ(status, 0, "No interrupt when no data");
    
    // Receive data
    uart.receive_char('A');
    
    // Now interrupt should be pending
    status = uart.get_interrupt_status();
    ASSERT_TRUE(status & IER_RDA_IE, 
                "RDA interrupt should be pending when data received");
}

TEST(test_uart_axi_address_masking) {
    UART16550 uart;
    uart.reset();
    
    // Write to THR with various address offsets that map to same register
    uart.axi_write(0x00, 'A');
    uart.axi_write(0x20, 'B');  // Should also map to offset 0x00
    uart.axi_write(0x40, 'C');  // Should also map to offset 0x00
    
    // Should have 3 characters in FIFO
    ASSERT_EQ(uart.get_tx_count(), 3, "Address masking should work correctly");
}

TEST(test_uart_loopback_mode) {
    UART16550 uart;
    uart.reset();
    
    // Enable loopback mode
    uart.axi_write(UART_MCR_OFFSET, MCR_LOOP);
    
    // Verify MCR has loopback set
    uint32_t mcr = uart.axi_read(UART_MCR_OFFSET);
    ASSERT_TRUE(mcr & MCR_LOOP, "MCR should have loopback enabled");
}

TEST(test_uart_fifo_clear) {
    UART16550 uart;
    uart.reset();
    
    // Fill both FIFOs
    for (int i = 0; i < 8; i++) {
        uart.receive_char('R');
        uart.axi_write(UART_THR_OFFSET, 'T');
    }
    
    // Clear FIFOs via FCR
    uart.axi_write(UART_FCR_OFFSET, FCR_RX_FIFO_CLR | FCR_TX_FIFO_CLR);
    
    // Both FIFOs should be empty
    ASSERT_EQ(uart.get_rx_count(), 0, "RX FIFO should be cleared");
    ASSERT_EQ(uart.get_tx_count(), 0, "TX FIFO should be cleared");
}

TEST(test_uart_register_map_size) {
    // Verify the register map structure size matches expected layout
    // 6 registers * 4 bytes = 24 bytes minimum
    UART16550::Registers regs;
    ASSERT_TRUE(sizeof(regs) >= 24, 
                "Register map should be at least 24 bytes");
}

// ============================================================================
// Main
// ============================================================================

int main() {
    std::cout << "========================================" << std::endl;
    std::cout << "  UART16550 Controller Test Suite" << std::endl;
    std::cout << "========================================" << std::endl;
    std::cout << std::endl;
    
    // Run all tests
    RUN_TEST(test_uart_reset);
    RUN_TEST(test_uart_baud_rate);
    RUN_TEST(test_uart_write_thr);
    RUN_TEST(test_uart_read_rbr_empty);
    RUN_TEST(test_uart_receive_char);
    RUN_TEST(test_uart_fifo_fill);
    RUN_TEST(test_uart_fifo_overrun);
    RUN_TEST(test_uart_transmit_fifo);
    RUN_TEST(test_uart_ier);
    RUN_TEST(test_uart_fcr);
    RUN_TEST(test_uart_lcr_8n1);
    RUN_TEST(test_uart_mcr);
    RUN_TEST(test_uart_interrupt_status);
    RUN_TEST(test_uart_axi_address_masking);
    RUN_TEST(test_uart_loopback_mode);
    RUN_TEST(test_uart_fifo_clear);
    RUN_TEST(test_uart_register_map_size);
    
    // Summary
    std::cout << std::endl;
    std::cout << "========================================" << std::endl;
    std::cout << "  Test Summary" << std::endl;
    std::cout << "========================================" << std::endl;
    std::cout << "Passed: " << tests_passed << std::endl;
    std::cout << "Failed: " << tests_failed << std::endl;
    std::cout << "Total:  " << (tests_passed + tests_failed) << std::endl;
    std::cout << "========================================" << std::endl;
    
    return (tests_failed == 0) ? 0 : 1;
}
