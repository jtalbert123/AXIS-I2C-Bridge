
`timescale 1 ns / 1 ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: James Talbert <jtalbert123@gmail.com> 
// 
// Create Date: 02/13/2020 02:59:03 PM
// Design Name: AXIS I2C Master
// Module Name: AXIS_I2C_Master
// Project Name: 
// Target Devices: 
// Tool Versions: Developed with Vivado 2019.2
// Description: Receives AXIS data beats, and inteprets them as I2C transactions. Responses are provided on another AXI Stream.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: 
// 
//////////////////////////////////////////////////////////////////////////////////

	module AXIS_I2C_Master_v1_0
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line
		input wire  clk,
		input wire  aresetn,

        // Ports of Axi Slave Bus Interface S_AXIS_REQ
		
		output wire  s_axis_req_tready,
		input wire [7 : 0] s_axis_req_tdata,
		input wire  s_axis_req_tlast,
		input wire  s_axis_req_tvalid,

		// Ports of Axi Master Bus Interface M_AXIS_RESP
		output reg  m_axis_resp_tvalid,
		output reg [7 : 0] m_axis_resp_tdata,
		output reg  m_axis_resp_tlast,
		input wire  m_axis_resp_tready,
		
		// I2C port
		output reg  SDA_o,
		output wire SDA_t,
		input  wire SDA_i,
		output reg  SCL_o,
		output wire SCL_t,
		input  wire SCL_i,
		
		input wire [31:0] period_1,
		input wire [31:0] period_2,
		input wire [31:0] period_3,
		input wire [31:0] period_4,
		input wire [31:0] period_start_1,
		input wire [31:0] period_start_2,
		input wire [31:0] period_start_3,
		input wire [31:0] period_stop_1,
		input wire [31:0] period_stop_2,
		input wire [31:0] period_stop_3,
		
		output wire [4:0] state_o,
		output wire [1:0] bit_state_o
	);

	
	// High-level states.
	// Many states use the bt_state signal as a counter for the timing of the bit.
	// DATA states us ethe bit_counter to track the position in a byte.
	//
	// In general, each 'bit' on the I2C bus, takes 4 ticks:
	// SDA:    X===================================X
	// SCL:    _________/-----------------\_________
	// STATE:  |   S1   |   S2   |   S3   |   S4   |
	//
	// Receivied data is sampled on the transition from S2 to S3.
	//
	// START:
	// SDA:    ---------\__________________
	// SCL:    ------------------\_________
	// STATE:  |   S1   |   S2   |   S3   |
	//
	// STOP:
	// SDA:    __________________/---------
	// SCL:    ________/-------------------
	// STATE:  |   S1   |   S2   |   S3   |
	//
	// Drain is a state used to empty the bus after a failed transaction (NACK on a write).
	localparam [4:0]    IDLE    = 0,
	                    START   = 1,
	                    ADDR    = 2,
	                    ADDRACK = 3,
	                    RXACK   = 4,
	                    TXACK   = 5,
	                    TXDATA  = 7,
	                    RXDATA  = 8,
	                    STOP    = 9,
	                    DRAIN   = 10;
	// See the usage of the bit_state register above.
    localparam [1:0]    S1 = 0,
                        S2 = 1,
                        S3 = 2,
                        S4 = 3;
	
	// The current bit being sent/received within the current byte, not used for ACK, STOP, START bits.
    reg[2:0] bit_counter;
    // Reset to 7 at the next fsm_sample cycle.
	reg bit_counter_clr;
	// Decrement by one at the next fsm_sample cycle.
    reg bit_counter_dec;
	
	// high-level protocol FSM state.
	reg[4:0] curr_state;
	reg[4:0] next_state;
	
	// Inner state of the bus bits.
	reg[1:0] bit_state;
	reg[1:0] bit_state_next;
	
	// Reset for the quantagen. The tick output should be asserted one full period after reset is cleared.
	// When active, the period is loaded by the quentagen.
    reg quantagen_clr;
	// Preiodic output for bus timing.
    wire quantagen_tick;
	// Sgnal controlling when to sample the FSM. Defaults to quantagen_tick
    reg fsm_sample;
    
	// Indicates if the last recieved ACK bit was a 1, updated on the fsm_sample cycle between S2 and S3 of a received ACK.
    reg received_nack;
	// Set immediately when recieving the first byte (the address +R/~W) on the AXI stream. Set before the START condition is sent on the bus (on the transition to START). 
    reg is_read_req;
	
	// Set during the last byte of a transaction. Determined from the tlast signal of a write request, or from a counter starting at the second byte of a read transaction on the AXI Stream request interface.
    reg last_byte;
	
	// The byte being received, bits are updated as they appear on the bus (sampled in the middle of the high-pulse of SCL, between S2 and S3). Indexed by bit_counter.
    reg[7:0] rx_byte;
	
	// True if this byte is the first byte of a transaction, cleared during the ACK state of a read transaction.
    reg first_read_byte;
    
	// The number of bytes to read. Max allowed is 255 per transaction.
    reg[7:0] num_bytes_to_read;
    
    // The number of bytes written
    reg[7:0] num_bytes_written;
    
    // qantagen period
    reg [31:0] period;
    
	// Generate the 'tick' pulse for the I2C timing. In general, the FSM is sampled on this tick.
	// The generator is suspended by the quantagen_clr signal, which resets it to the start of a period.
	//   This is used when receiving a bit to enable clock stretching. The tick is reset when the SCL line is held low
	//   This ensures that the high state will persist for a full two tick times after being brought high.
	//   This also ensures that S2 persists for a full tick, giving time for SDA to settle if it is lagging before sampling.
    QuantaGenerator quantagen(
        .i_clk(clk),
        .i_aresetn(aresetn),
        .i_reset(quantagen_clr),
        .o_en(quantagen_tick),
        .i_period(period)
    );
    
	// tready on the request AXI Stream interface, generated when done using a byte from the interface.
	// tready will trigger the reception of the byte, clearing it from the bus.
	// The I2C Address is transfered at the end of the ADDR state.
	// Write data bytes are transfered at the end of the TXDATA state.
	// The read count is transferred at the end of the RXDATA state of the first byte.
	// When in the drain state (after a NACK on write) tready is active until tlast is seen (at which point the state goes to idle).
    assign s_axis_req_tready = ((curr_state == ADDR || curr_state == TXDATA || (curr_state == RXDATA && first_read_byte))
                                         && (S4 == bit_state) && (bit_counter == 0) && (quantagen_tick == 1))
                            || (curr_state == DRAIN);
							
	// Set to input mode when outputting a 1. Output mode when outputting a 0.
    assign SDA_t = SDA_o;
	// Set to input mode when outputting a 1. Output mode when outputting a 0.
    assign SCL_t = SCL_o;
	
	// The user can connect the input of the tri-state driver (the desired output when in output mode) to 0, and only connect the _t signal if desired.
	// Alternatively, use either _o or _t conected to an open collector output,ignoring the other.
    
    
	// Next State logic. Also assgns control bits for the registers/counters.
	// Clock stretching is handled, allowing for slave devices to slow the bus.
	// The TXACK and RXACK states delay the leading edge of the clock while awaiting the AXIS bus the clear/fill, respectively.
    always @(*) begin
        next_state <= curr_state;
        quantagen_clr <= 0;
        bit_counter_dec <= 0;
        bit_counter_clr <= 0;
        bit_state_next <= bit_state;
        fsm_sample <= quantagen_tick;
        
        SDA_o <= 1;
        SCL_o <= 1;
        period <= period_1;
        
        case (curr_state)
            IDLE:
            begin
                SDA_o <= 1;
                SCL_o <= 1;
                quantagen_clr <= 1;
                period <= period_start_1;
                if (s_axis_req_tvalid == 1) begin
                    next_state <= START;
                    bit_counter_clr <= 1;
                    quantagen_clr <= 0;
                    bit_state_next <= S1;
                    period <= period_1;
					fsm_sample <= 1;
                end
            end
            
            START:
            begin
                case (bit_state)
                    S1: begin
                        SDA_o <= 1;
                        SCL_o <= 1;
                        bit_state_next <= S2;
                        period <= period_start_2;
                    end
                    S2: begin
                        SDA_o <= 0;
                        SCL_o <= 1;
                        bit_state_next <= S3;
                        period <= period_start_3;
                    end
                    S3: begin
                        SDA_o <= 0;
                        SCL_o <= 0;
                        bit_state_next <= S1;
                        period <= period_1;
                        next_state <= ADDR;
                    end
                endcase
            end
            
            ADDR:
            begin
                SDA_o <= s_axis_req_tdata[bit_counter];
                
                case (bit_state)
                    S1: begin
                        SCL_o <= 0;
                        bit_state_next <= S2;
                        period <= period_2;
                    end
                    S2: begin
                        SCL_o <= 1;
						quantagen_clr <= ~SCL_i;
                        bit_state_next <= S3;
                        period <= period_3;
                    end
                    S3: begin
                        SCL_o <= 1;
                        bit_state_next <= S4;
                        period <= period_4;
                    end
                    S4: begin
                        SCL_o <= 0;
                        bit_state_next <= S1;
                        period <= period_1;
                        bit_counter_dec <= 1;
                    end
                endcase
                if ((bit_counter == 0) && (bit_state == S4)) begin
                    bit_counter_dec <= 0;
                    next_state <= ADDRACK;
                    bit_state_next <= S1; 
                    period <= period_1;
                end
            end
            
            ADDRACK:
            begin
                bit_counter_clr <= 1;
                SDA_o <= 1; 
                case (bit_state)
                    S1: begin
                        SCL_o <= 0;
                        bit_state_next <= S2;
                        period <= period_2;
                    end
                    S2: begin
                        SCL_o <= 1;
                        quantagen_clr <= ~SCL_i;
                        bit_state_next <= S3;
                        period <= period_3;
                    end
                    S3: begin
                        SCL_o <= 1;
                        bit_state_next <= S4;
                        period <= period_4;
                    end
                    S4: begin
                        SCL_o <= 0;
                        bit_state_next <= S1;
                        period <= period_1;
                        
                        if (last_byte || received_nack) begin
                            next_state <= STOP;
                            period <= period_stop_1;
                        end else begin
                            bit_counter_clr <= 1;
                            if (is_read_req) begin
                                next_state <= RXDATA;
                            end else begin
                                next_state <= TXDATA;
                            end
                        end                     
                    end
                endcase
            end
            
			// Clock stretching while awaiting new data on the AXI Stream request interface.
            RXACK:
            begin
                SDA_o <= 1; 
                case (bit_state)
                    S1: begin
                        SCL_o <= 0;
                        bit_state_next <= S2;
                        period <= period_2;
                    end
                    S2: begin
                        SCL_o <= s_axis_req_tvalid || last_byte;
                        quantagen_clr <= ~SCL_i;
                        bit_state_next <= S3;
                        period <= period_3;
                    end
                    S3: begin
                        SCL_o <= 1;
                        bit_state_next <= S4;
                        period <= period_4;
                    end
                    S4: begin
                        SCL_o <= 0;
                        bit_state_next <= S1;
                        period <= period_1;
                        if (last_byte) begin
                            quantagen_clr <= m_axis_resp_tvalid;
                            next_state <= STOP;
                            period <= period_stop_1;
                        end else begin
                            next_state <= TXDATA;
                            bit_counter_clr <= 1;
                        end
                    end
                endcase
            end
            
            TXDATA:
            begin
                SDA_o <= s_axis_req_tdata[bit_counter];
                
                case (bit_state)
                    S1: begin
                        SCL_o <= 0;
                        bit_state_next <= S2;
                        period <= period_2;
                    end
                    S2: begin
                        SCL_o <= 1;
                        quantagen_clr <= ~SCL_i;
                        bit_state_next <= S3;
                        period <= period_3;
                    end
                    S3: begin
                        SCL_o <= 1;
                        bit_state_next <= S4;
                        period <= period_4;
                    end
                    S4: begin
                        SCL_o <= 0;
                        bit_state_next <= S1;
                        period <= period_1;
                        bit_counter_dec <= 1;
                    end
                endcase
                if ((bit_counter == 0) && (bit_state == S4)) begin
                    bit_counter_dec <= 0;
                    next_state <= RXACK;
                    bit_state_next <= S1;
                    period <= period_1;
                end
            end
            
            RXDATA:
            begin
                SDA_o <= 1;
                case (bit_state)
                    S1: begin
                        SCL_o <= 0;
                        bit_state_next <= S2;
                        period <= period_2;
                    end
                    S2: begin
                        SCL_o <= 1;
                        quantagen_clr <= ~SCL_i;
                        bit_state_next <= S3;
                        period <= period_3;
                    end
                    S3: begin
                        SCL_o <= 1;
                        bit_state_next <= S4;
                        period <= period_4;
                    end
                    S4: begin
                        SCL_o <= 0;
                        bit_state_next <= S1;
                        period <= period_1;
                        bit_counter_dec <= 1;
                    end
                endcase
                if ((bit_counter == 0) && (bit_state == S4)) begin
                    bit_counter_dec <= 0;
                    next_state <= TXACK;
                    bit_state_next <= S1;
                    period <= period_1;
                end
            end
            
			// Delays rising edge of SCL if a AXIS slave has not taken the data from the last I2C byte, unless there are no more bytes to be read.
            TXACK:
            begin
                SDA_o <= last_byte;
                case (bit_state)
                    S1: begin
                        SCL_o <= 0;
                        bit_state_next <= S2;
                        period <= period_2;
                    end
                    S2: begin
                        SCL_o <= ~m_axis_resp_tvalid || last_byte;
                        quantagen_clr <= ~SCL_i;
                        bit_state_next <= S3;
                        period <= period_3;
                        period <= period_3;
					end
                    S3: begin
                        SCL_o <= 1;
                        bit_state_next <= S4;
                        period <= period_4;
                    end
                    S4: begin
                        SCL_o <= 0;
                        bit_state_next <= S1;
                        period <= period_1;
                        if (last_byte) begin
                            next_state <= STOP;
                            period <= period_stop_1;
                        end else begin
                            next_state <= RXDATA;
                            bit_counter_clr <= 1;
                        end
                    end
                endcase
            end
            
            STOP:
            begin
                case (bit_state)
                    S1: begin
                        SDA_o <= 0;
                        SCL_o <= 0;
                        bit_state_next <= S2;
                        period <= period_2;
                        period <= period_stop_2;
                    end
                    S2: begin
                        SDA_o <= 0;
                        SCL_o <= 1;
                        bit_state_next <= S3;
                        period <= period_3;
                        period <= period_stop_1;
                    end
                    S3: begin
                        SDA_o <= 1;
                        SCL_o <= 1;
                        bit_state_next <= S4;
                        period <= period_4;
                        if (received_nack && !last_byte) begin
                            next_state <= DRAIN;
                        end else begin
                            next_state <= IDLE;
                            period <= period_start_1;
                        end
                    end
                endcase
            end
            
            DRAIN:
            begin
                fsm_sample <= 1;
                if (s_axis_req_tlast && s_axis_req_tvalid) begin
                    next_state <= IDLE;
                    period <= period_start_1;
                end
            end
            default: next_state <= curr_state; 
        endcase
    end
    
	// Manages the last_byte register
	// Cleared whenever in IDLE (no transaction/between transactions).
	// Set dependant on the read/write state.
	// Generally, set during the entirety of the last byte of the I2C transaction.
    always @(posedge clk) begin
        if (curr_state == IDLE) begin
            last_byte <= 0;
        end else begin
            if (!is_read_req) begin
                if (((curr_state == ADDR) || (curr_state == TXDATA)) && (bit_counter == 7)) begin
                    last_byte <= s_axis_req_tlast;
                end 
            end else begin
                if ((curr_state == ADDRACK) && (bit_state == S4)) begin
                    last_byte <= num_bytes_to_read == 0;
                end else if ((curr_state == RXDATA) && (bit_counter == 7)) begin
                    last_byte <= num_bytes_to_read == 1;
                end
            end
        end
    end
    
	// Manages the bit state, and the protocol state registers.
    always @(negedge aresetn, posedge clk) begin
        if (aresetn == 0) begin
            curr_state <= IDLE;
            bit_state <= S1;
        end else if (clk == 1) begin
            if (fsm_sample == 1) begin
                curr_state <= next_state;
                bit_state <= bit_state_next;
            end
        end
    end
	
	// Manages control bit registers (single-bit states).
	// Also manages the response AXI Stream bus.
    always @(negedge aresetn, posedge clk) begin
        if (aresetn == 0) begin
            bit_counter <= 7;
            is_read_req <= 0;
            received_nack <= 0;
            num_bytes_to_read <= 0;
            first_read_byte <= 0;
            num_bytes_written <= 0;
            rx_byte <= 0;
        end else if (clk == 1) begin
            // Initialize stuff for the next request
            if (curr_state == IDLE) begin
                first_read_byte <= 1;
                num_bytes_written <= 0;
            end
            // Most registers only change at the same time as the state machine
            //   take the bit counter, the FSM couputes increment based on state, and we apply it once per transition
            if (fsm_sample == 1) begin
                // bit counter management, the FSM outputs determine when to change this.
                if (bit_counter_clr == 1)
                    bit_counter <= 7;
                else if (bit_counter_dec == 1)
                    bit_counter <= bit_counter - 1;
                else
                    bit_counter <= bit_counter;
                
                // Samples the ACK value. Sampled between S2 and S3 of an ADDRACK or RXACK state (in the middle of the SCL high pulse).
                if ((curr_state == RXACK && bit_state == S2 && bit_state_next == S3) || (curr_state == ADDRACK && bit_state == S2 && bit_state_next == S3)) begin
                    // Sample the ACK value
                    received_nack <= SDA_i;
                end
                
                // Sample RX bit, same logic as the ACK, but only in RXDATA
                if (curr_state == RXDATA && bit_state == S2 && bit_state_next == S3) begin
                    // Sample the ACK value
                    rx_byte[bit_counter] <= SDA_i;
                end
                // Initialize the RX count after finishing the address. By S3 of the ADDRACK, the new byte is available.
                // S3 is used because we want the value available in S4 for the trnasition to STOP or *XDATA.
                if (curr_state == ADDRACK && is_read_req && bit_state == S3) begin
                    num_bytes_to_read <= s_axis_req_tdata;
                end
                // Decrement the RX counter when we finish a byte.
                if (curr_state == RXDATA && bit_counter == 0 && bit_state == S4) begin
                    num_bytes_to_read <= num_bytes_to_read - 1; 
                end
                // Clear the byte after the first byte of a read transaction
                if (curr_state == RXDATA && next_state != RXDATA) begin
                    first_read_byte <= 0;
                end
                // After receiving a byte, increment the number of bytes written
                if (curr_state == RXACK && bit_state == S1 && !is_read_req) begin
                    num_bytes_written <= num_bytes_written + 1;
                end
            end
            // When starting a transaction, sample if it is a read or write as soon as we see it on the request bus.
            if (curr_state == IDLE && s_axis_req_tvalid) begin
                is_read_req <= s_axis_req_tdata[0];
            end
        end
    end
    
	// Manage the response AXI Stream bus.
    always @(negedge aresetn, posedge clk) begin
        if (aresetn == 0) begin
            m_axis_resp_tvalid <= 0;
            m_axis_resp_tlast <= 0;
            m_axis_resp_tdata <= 0;
        end else if (clk == 1) begin
            // Most registers only change at the same time as the state machine
            //   take the bit counter, the FSM couputes increment based on state, and we apply it once per transition
            // Data is placed on the bus on an FSM transition out of an ACK state
            // Data is cleared when the AXIS slave asserts tready
            if (fsm_sample == 1) begin
                // 
                if ((curr_state == ADDRACK) && (bit_state == S4)) begin
                    m_axis_resp_tvalid <= 1;
                    m_axis_resp_tdata <= {7'd0, received_nack};
                    m_axis_resp_tlast <= received_nack && is_read_req;
                end else if ((curr_state == TXACK) && (bit_state == S4)) begin
                    m_axis_resp_tvalid <= 1;
                    m_axis_resp_tdata <= rx_byte;
                    m_axis_resp_tlast <= last_byte;
                end else if (curr_state == RXACK && next_state == STOP) begin
                    m_axis_resp_tvalid <= 1;
                    m_axis_resp_tdata <= num_bytes_written;
                    m_axis_resp_tlast <= 1;
                end
            end
            if (m_axis_resp_tvalid && m_axis_resp_tready) begin
                m_axis_resp_tvalid <= 0;
            end
        end
    end
    assign bit_state_o = bit_state;
    assign state_o = curr_state;
	// User logic ends

	endmodule
