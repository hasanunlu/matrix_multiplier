module top (
  input  pin_clk,

  inout  pin_usbp,
  inout  pin_usbn,
  output pin_pu,

  output pin_led
);

  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  ////////
  //////// generate 48 mhz clock
  ////////
  ////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////
  wire clk_48mhz;

  SB_PLL40_CORE #(
    .DIVR(4'b0000),
    .DIVF(7'b0101111),
    .DIVQ(3'b100),
    .FILTER_RANGE(3'b001),
    .FEEDBACK_PATH("SIMPLE"),
    .DELAY_ADJUSTMENT_MODE_FEEDBACK("FIXED"),
    .FDA_FEEDBACK(4'b0000),
    .DELAY_ADJUSTMENT_MODE_RELATIVE("FIXED"),
    .FDA_RELATIVE(4'b0000),
    .SHIFTREG_DIV_MODE(2'b00),
    .PLLOUT_SELECT("GENCLK"),
    .ENABLE_ICEGATE(1'b0)
  ) usb_pll_inst (
    .REFERENCECLK(pin_clk),
    .PLLOUTCORE(clk_48mhz),
    .RESETB(1'b1),
    .BYPASS(1'b0)
  );

  reg led = 0;
  assign pin_led = led;

  reg signed [7:0] uart_do;
  reg [7:0] uart_di;

  reg uart_re = 0;
  reg uart_we = 0;
  wire uart_wait, uart_ready;

  reg [4:0] state = 0;

  // Generate reset signal
  reg [5:0] reset_cnt = 0;
  wire resetn = &reset_cnt;
  always @(posedge clk_48mhz) reset_cnt <= reset_cnt + !resetn;

  // Generate another reset signal
  reg [10:0] reset_cnt_2 = 0;
  wire resetn_2 = &reset_cnt_2;
  always @(posedge pin_clk) reset_cnt_2 <= reset_cnt_2 + !resetn_2;

  localparam N_ROW_CACHED = 15;
  localparam ROW_SIZE = 1024;

  reg [11:0] N = 0;
  reg [11:0] M = 0;
  reg [11:0] data_cnt = 0;
  reg [11:0] data_cnt_column = 0;

  reg signed [36:0] quantized = 0;
  reg signed [27:0] acc[0:(N_ROW_CACHED - 1)];

  reg signed [8:0] scale = 1;
  reg [7:0] shift = 0;

  reg [7:0] mem[0:(ROW_SIZE - 1)];
  reg [7:0] mem2[0:(ROW_SIZE - 1)];
  reg [7:0] mem3[0:(ROW_SIZE - 1)];
  reg [7:0] mem4[0:(ROW_SIZE - 1)];
  reg [7:0] mem5[0:(ROW_SIZE - 1)];
  reg [7:0] mem6[0:(ROW_SIZE - 1)];
  reg [7:0] mem7[0:(ROW_SIZE - 1)];
  reg [7:0] mem8[0:(ROW_SIZE - 1)];
  reg [7:0] mem9[0:(ROW_SIZE - 1)];
  reg [7:0] mem10[0:(ROW_SIZE - 1)];
  reg [7:0] mem11[0:(ROW_SIZE - 1)];
  reg [7:0] mem12[0:(ROW_SIZE - 1)];
  reg [7:0] mem13[0:(ROW_SIZE - 1)];
  reg [7:0] mem14[0:(ROW_SIZE - 1)];
  reg [7:0] mem15[0:(ROW_SIZE - 1)];
  reg [7:0] mem16[0:(ROW_SIZE - 1)];
  
  reg signed [7:0] output_buffer[0:(N_ROW_CACHED - 1)];

  reg we = 0;
  reg re = 0;

  // Multiplier for data in & cache
  wire signed [15:0] mul;
  reg signed [15:0] mul_reg;
  wire signed [27:0] mul_sign_extend;
  reg signed [7:0] mult_operand;
  assign mul = uart_do * mult_operand;
  assign mul_sign_extend = mul_reg[15] ? {12'b111111111111, mul_reg} :
                                         {12'b000000000000, mul_reg};

  wire signed [15:0] mul2;
  reg signed [15:0] mul_reg2;
  wire signed [27:0] mul_sign_extend2;
  reg signed [7:0] mult_operand2;
  assign mul2 = uart_do * mult_operand2;
  assign mul_sign_extend2 = mul_reg2[15] ? {12'b111111111111, mul_reg2} :
                                         {12'b000000000000, mul_reg2};


  // Scale multiplier extender
  reg signed [36:0] acc_signed_ext_operand;
  wire signed [36:0] mul_sign_extend_scaled;
  assign mul_sign_extend_scaled = scale * acc_signed_ext_operand;

  localparam [3:0] BANK_COUNT = N_ROW_CACHED - 1;
  reg [3:0] bank_select = 0;

  always@(posedge clk_48mhz) begin
    if(re) begin
      output_buffer[0] <= mem[data_cnt];
      output_buffer[1] <= mem2[data_cnt];
      output_buffer[2] <= mem3[data_cnt];
      output_buffer[3] <= mem4[data_cnt];
      output_buffer[4] <= mem5[data_cnt];
      output_buffer[5] <= mem6[data_cnt];
      output_buffer[6] <= mem7[data_cnt];
      output_buffer[7] <= mem8[data_cnt];
      output_buffer[8] <= mem9[data_cnt];
      output_buffer[9] <= mem10[data_cnt];
      output_buffer[10] <= mem11[data_cnt];
      output_buffer[11] <= mem12[data_cnt];
      output_buffer[12] <= mem13[data_cnt];
      output_buffer[13] <= mem14[data_cnt];
      output_buffer[14] <= mem15[data_cnt];
      output_buffer[15] <= mem16[data_cnt];
    end
  end	

  always@(posedge clk_48mhz) begin
    if(we) begin
      case (bank_select)
        0: mem[data_cnt] <= uart_do;
        1: mem2[data_cnt] <= uart_do;
        2: mem3[data_cnt] <= uart_do;
        3: mem4[data_cnt] <= uart_do;
        4: mem5[data_cnt] <= uart_do;
        5: mem6[data_cnt] <= uart_do;
        6: mem7[data_cnt] <= uart_do;
        7: mem8[data_cnt] <= uart_do;
        8: mem9[data_cnt] <= uart_do;
        9: mem10[data_cnt] <= uart_do;
        10: mem11[data_cnt] <= uart_do;
        11: mem12[data_cnt] <= uart_do;
        12: mem13[data_cnt] <= uart_do;
        13: mem14[data_cnt] <= uart_do;
        14: mem15[data_cnt] <= uart_do;
        15: mem16[data_cnt] <= uart_do;
      endcase
    end
  end

  integer  i;

  always @(posedge clk_48mhz) begin
    case (state)
    0: begin // Reset state
      if (resetn_2) begin
        data_cnt <= 0;
        bank_select <= 0;
        data_cnt_column <= 0;
        for (i = 0; i < N_ROW_CACHED; i++) begin
          acc[i] <= 0;
        end
        state <= 1;
      end
    end
    1: begin // Reading data size
      uart_re <= 1;
      if (uart_ready) begin
	      led <= 0;
        uart_re <= 0;
	      data_cnt <= data_cnt + 1;
	      if (data_cnt == 0) begin
	        N[11:8] <= uart_do[3:0];
        end
	      if (data_cnt == 1) begin
	        N[7:0] <= uart_do;
        end
	      if (data_cnt == 2) begin
	        M[11:8] <= uart_do[3:0];
        end
	      if (data_cnt == 3) begin
	        M[7:0] <= uart_do;
        end
	      if (data_cnt == 4) begin
	        scale[7:0] <= uart_do;
        end
	      if (data_cnt == 5) begin
	        shift <= uart_do;
          /////////////////////
	        data_cnt <= 0;
          we <= 1;
          state <= 2;
        end
      end
    end
    2: begin // Reading row to cache
      uart_re <= 1;
      if (uart_ready) begin
        uart_re <= 0;
	      data_cnt <= data_cnt + 1;
	      if (data_cnt == N) begin
          data_cnt <= 0;
          if (bank_select == BANK_COUNT) begin
            bank_select <= 0;
            we <= 0;
            re <= 1;
            state <= 3;
          end else begin
            bank_select <= bank_select + 1;
          end
        end
      end
    end
    3: begin // Reading column data and computing
      uart_re <= 1;
      if (uart_ready) begin
        uart_re <= 0;
        mult_operand <= output_buffer[0];
        mult_operand2 <= output_buffer[1];
        state <= 10;
      end
    end
    // Multiplication pipelining
    10: begin
      mul_reg <= mul;
      mul_reg2 <= mul2;
      mult_operand <= output_buffer[2];
      mult_operand2 <= output_buffer[3];
      state <= 11;
    end
    11: begin
      acc[0] <= acc[0] + mul_sign_extend;
      acc[1] <= acc[1] + mul_sign_extend2;
      mul_reg <= mul;
      mul_reg2 <= mul2;
      mult_operand <= output_buffer[4];
      mult_operand2 <= output_buffer[5];
      state <= 12;
    end
    12: begin
      acc[2] <= acc[2] + mul_sign_extend;
      acc[3] <= acc[3] + mul_sign_extend2;
      mul_reg <= mul;
      mul_reg2 <= mul2;
      mult_operand <= output_buffer[6];
      mult_operand2 <= output_buffer[7];
      state <= 13;
    end
    13: begin
      acc[4] <= acc[4] + mul_sign_extend;
      acc[5] <= acc[5] + mul_sign_extend2;
      mul_reg <= mul;
      mul_reg2 <= mul2;
      mult_operand <= output_buffer[8];
      mult_operand2 <= output_buffer[9];
      state <= 14;
    end
    14: begin
      acc[6] <= acc[6] + mul_sign_extend;
      acc[7] <= acc[7] + mul_sign_extend2;
      mul_reg <= mul;
      mul_reg2 <= mul2;
      mult_operand <= output_buffer[10];
      mult_operand2 <= output_buffer[11];
      state <= 15;
    end
    15: begin
      acc[8] <= acc[8] + mul_sign_extend;
      acc[9] <= acc[9] + mul_sign_extend2;
      mul_reg <= mul;
      mul_reg2 <= mul2;
      mult_operand <= output_buffer[12];
      mult_operand2 <= output_buffer[13];
      state <= 16;
    end
    16: begin
      acc[10] <= acc[10] + mul_sign_extend;
      acc[11] <= acc[11] + mul_sign_extend2;
      mul_reg <= mul;
      mul_reg2 <= mul2;
      mult_operand <= output_buffer[14];
      mult_operand2 <= output_buffer[15];
      state <= 17;
    end
    17: begin
      acc[12] <= acc[12] + mul_sign_extend;
      acc[13] <= acc[13] + mul_sign_extend2;
      mul_reg <= mul;
      mul_reg2 <= mul2;
      state <= 18;
    end
    18: begin
      acc[14] <= acc[14] + mul_sign_extend;
      acc[15] <= acc[15] + mul_sign_extend2;

      data_cnt <= data_cnt + 1;
      if (data_cnt == N) begin
	        data_cnt <= 0;
          bank_select <= 0;
	        state <= 4;
      end else begin
        state <= 3;
      end
    end
    4: begin // sign extention
      if (acc[bank_select][27] == 1) begin
          acc_signed_ext_operand <= {9'b111111111, acc[bank_select]}; 
      end else begin
          acc_signed_ext_operand <= {9'b000000000, acc[bank_select]}; 
      end
      acc[bank_select] <= 0;
      state <= 5;
    end
    5: begin // normalize it
      quantized <= mul_sign_extend_scaled >>> shift;
      uart_we <= 0;
      state <= 6;
    end
    6: begin
      uart_we <= 1;
      if (quantized < -37'sd128) begin
        uart_di <= -8'sd128;
      end else if (quantized > 37'sd127) begin
        uart_di <= 8'sd127;
      end else begin
        uart_di <= quantized[7:0];
      end
      state <= 7;
    end
    7: begin
      if (uart_wait) begin // Necessary for tracking uart transmit
        state <= 8;
      end
    end
    8: begin // Writing
      if (!uart_wait) begin
        uart_we <= 0;
        if (bank_select == BANK_COUNT) begin
          bank_select <= 0;
          data_cnt_column <= data_cnt_column + 1;
          if (data_cnt_column == M) begin
            data_cnt_column <= 0;
            re <= 0;
            led <= 1;
            state <= 1;
          end else begin
            state <= 3;
          end
        end else begin
          bank_select <= bank_select + 1;
          state <= 4;
        end
      end
    end
    endcase
  end

  // usb uart
  usb_uart uart (
    .clk_48mhz  (clk_48mhz),
    .resetn     (resetn),

    .usb_p_tx(usb_p_tx),
    .usb_n_tx(usb_n_tx),
    .usb_p_rx(usb_p_rx),
    .usb_n_rx(usb_n_rx),
    .usb_tx_en(usb_tx_en),

    .uart_we  (uart_we),
    .uart_re  (uart_re),
    .uart_di  (uart_di),
    .uart_do  (uart_do),
    .uart_wait(uart_wait),
    .uart_ready(uart_ready)
  );

  wire usb_p_tx;
  wire usb_n_tx;
  wire usb_p_rx;
  wire usb_n_rx;
  wire usb_tx_en;
  wire usb_p_in;
  wire usb_n_in;

  assign pin_pu = 1'b1;

  assign usb_p_rx = usb_tx_en ? 1'b1 : usb_p_in;
  assign usb_n_rx = usb_tx_en ? 1'b0 : usb_n_in;

  SB_IO #(
    .PIN_TYPE(6'b 1010_01), // PIN_OUTPUT_TRISTATE - PIN_INPUT
    .PULLUP(1'b 0)
  ) 
  iobuf_usbp 
  (
    .PACKAGE_PIN(pin_usbp),
    .OUTPUT_ENABLE(usb_tx_en),
    .D_OUT_0(usb_p_tx),
    .D_IN_0(usb_p_in)
  );

  SB_IO #(
    .PIN_TYPE(6'b 1010_01), // PIN_OUTPUT_TRISTATE - PIN_INPUT
    .PULLUP(1'b 0)
  ) 
  iobuf_usbn 
  (
    .PACKAGE_PIN(pin_usbn),
    .OUTPUT_ENABLE(usb_tx_en),
    .D_OUT_0(usb_n_tx),
    .D_IN_0(usb_n_in)
  );

endmodule
