module FIFO #(
    parameter DEPTH_FIFO = 4,
    parameter ADDR_WIDTH = 2,
    parameter DATA_WIDTH = 8
)(
    input wr_clk,
    input rd_clk,
    input a_reset_n,

    input [DATA_WIDTH - 1 : 0] din,
    input wr_en,
    output reg full,

    output reg [DATA_WIDTH - 1 : 0] dout,
    output reg empty,
    input rd_en
);

//функция для преобразования в код Грея
function [ADDR_WIDTH:0] bin_to_gray;
    input [ADDR_WIDTH:0] bin;
    bin_to_gray = (bin >> 1) ^ bin;
endfunction

//объявляем память для хранения данных
reg [DATA_WIDTH - 1 : 0] mem_data [DEPTH_FIFO - 1 : 0];
integer i;

//указатели для чтения и преобразования в код Грея
reg [ADDR_WIDTH : 0] read_ptr_bin = 0;
wire [ADDR_WIDTH : 0] read_ptr_gray;
reg [ADDR_WIDTH : 0] read_ptr_gray_sync_1 = 0;
reg [ADDR_WIDTH : 0] read_ptr_gray_sync_2 = 0;

//указатели для чтения на один меньше для NEXT_FULL 
wire [ADDR_WIDTH : 0] read_ptr_prev_gray;
reg [ADDR_WIDTH : 0] read_ptr_prev_gray_sync_1 = 0;
reg [ADDR_WIDTH : 0] read_ptr_prev_gray_sync_2 = 0;

//указатели для записи и преобразования в код Грея
reg [ADDR_WIDTH : 0] write_ptr_bin = 0;
wire [ADDR_WIDTH : 0] write_ptr_gray;
reg [ADDR_WIDTH : 0] write_ptr_gray_sync_1 = 0;
reg [ADDR_WIDTH : 0] write_ptr_gray_sync_2 = 0;

//указатели для записи на один меньше для NEXT_EMPTY 
wire [ADDR_WIDTH : 0] write_ptr_prev_gray;
reg [ADDR_WIDTH : 0] write_ptr_prev_gray_sync_1 = 0;
reg [ADDR_WIDTH : 0] write_ptr_prev_gray_sync_2 = 0;

//это длинные условия которые лень каждый раз записывать
wire FIFO_FULL;
wire FIFO_NEXT_FULL;
wire FIFO_EMPTY;
wire FIFO_NEXT_EMPTY;

//привязываем преобразование Грея в комбинационнуб логику
assign read_ptr_gray = bin_to_gray(read_ptr_bin);
assign read_ptr_prev_gray = bin_to_gray(read_ptr_bin == 0 ? {(ADDR_WIDTH + 1){1'b1}} : read_ptr_bin - 1);

assign write_ptr_gray = bin_to_gray(write_ptr_bin);
assign write_ptr_prev_gray = bin_to_gray(write_ptr_bin == 0 ? {(ADDR_WIDTH + 1){1'b1}} : write_ptr_bin - 1);

//привязываем состояния
assign FIFO_EMPTY = (read_ptr_gray == write_ptr_gray_sync_2);
assign FIFO_NEXT_EMPTY = (read_ptr_gray == write_ptr_prev_gray_sync_2);
assign FIFO_FULL = (write_ptr_gray[ADDR_WIDTH : ADDR_WIDTH - 1] == ~read_ptr_gray_sync_2[ADDR_WIDTH : ADDR_WIDTH - 1]) 
    && (write_ptr_gray[ADDR_WIDTH - 2:0] == read_ptr_gray_sync_2[ADDR_WIDTH - 2:0]);
assign FIFO_NEXT_FULL = (write_ptr_gray[ADDR_WIDTH : ADDR_WIDTH - 1] == ~read_ptr_prev_gray_sync_2[ADDR_WIDTH : ADDR_WIDTH - 1]) 
    && (write_ptr_gray[ADDR_WIDTH - 2:0] == read_ptr_prev_gray_sync_2[ADDR_WIDTH - 2:0]);

//---------------------------------
//-         Домен чтения          -
//---------------------------------

//логика изменения указателя чтения
always @(posedge rd_clk or negedge a_reset_n) begin
    if (~a_reset_n) begin
        read_ptr_bin <= 0;
        read_ptr_gray_sync_1 <= 0;
        read_ptr_gray_sync_2 <= 0;
        read_ptr_prev_gray_sync_1 <= {(ADDR_WIDTH + 1){1'b1}};
        read_ptr_prev_gray_sync_2 <= {(ADDR_WIDTH + 1){1'b1}};
    end else begin
        //увеличиваем указатель чтения, если прочитали
        if (rd_en && ~empty)
            read_ptr_bin <= (read_ptr_bin == {(ADDR_WIDTH + 1){1'b1}} ? 0 : read_ptr_bin + 1);

        //синхронизуем указатели чтения
        read_ptr_gray_sync_1 <= read_ptr_gray;
        read_ptr_gray_sync_2 <= read_ptr_gray_sync_1;

        //синхронезируем указатель чтения на один меньше
        read_ptr_prev_gray_sync_1 <= read_ptr_prev_gray;
        read_ptr_prev_gray_sync_2 <= read_ptr_prev_gray_sync_1;
    end
end

//логика empty
always @(posedge rd_clk or negedge a_reset_n) begin
    if (~a_reset_n)
        empty <= 1'b1;
    else
        if (FIFO_EMPTY)
            empty <= 1'b1;
        else
            empty <= 1'b0;
end

//логика чтения
always @(posedge rd_clk or negedge a_reset_n) begin
    if (~a_reset_n)
        dout <= 0;
    else 
        if (rd_en && ~empty)
            dout <= mem_data[read_ptr_bin[ADDR_WIDTH - 1 : 0]];
end


//---------------------------------
//-         Домен записи          -
//---------------------------------

//логика изменения указателя записи
always @(posedge wr_clk or negedge a_reset_n) begin
    if (~a_reset_n) begin
        write_ptr_bin <= 0;
        write_ptr_gray_sync_1 <= 0;
        write_ptr_gray_sync_2 <= 0;
        write_ptr_prev_gray_sync_1 <= {(ADDR_WIDTH + 1){1'b1}};
        write_ptr_prev_gray_sync_2 <= {(ADDR_WIDTH + 1){1'b1}};
    end else begin
        //увеличиваем указатель записи, если прочитали
        if (wr_en && ~full)
            write_ptr_bin <= (write_ptr_bin == {(ADDR_WIDTH + 1){1'b1}} ? 0 : write_ptr_bin + 1);

        //синхронизуем указатели записи
        write_ptr_gray_sync_1 <= write_ptr_gray;
        write_ptr_gray_sync_2 <= write_ptr_gray_sync_1;

        //синхронизуем указатели записи
        write_ptr_prev_gray_sync_1 <= write_ptr_prev_gray;
        write_ptr_prev_gray_sync_2 <= write_ptr_prev_gray_sync_1;
    end
end

//логика full
always @(posedge wr_clk or negedge a_reset_n) begin
    if (~a_reset_n)
        full <= 1'b0;
    else
        if (FIFO_NEXT_FULL && wr_en)
            full <= 1'b1;
        else if (FIFO_FULL)
            full <= 1'b1;
        else
            full <= 1'b0;
end

//логика записи
always @(posedge wr_clk or negedge a_reset_n) begin
    if (~a_reset_n)
        for(i = 0; i < DEPTH_FIFO; i = i + 1)
            mem_data[i] <= 1'b0;
    else 
        if (wr_en && ~full)
            mem_data[write_ptr_bin[ADDR_WIDTH - 1 : 0]] <= din;
end

endmodule
