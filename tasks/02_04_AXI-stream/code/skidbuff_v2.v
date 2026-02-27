module skid_buff(
    input clk,
    input reset_n,

    input [7:0] s_data,
    input s_valid,
    input s_last,
    output reg s_ready,

    output reg [7:0] m_data,
    output m_valid,
    output reg m_last,
    input m_ready
);

//объявляем возможные состояния
//(0 - обычная работа, 1 - работа в режиме буферизации, отправка второго байта)
reg [1:0] STATE = 2'b0;

//объявляем память для хранения данных
reg [7:0] mem_data1 = 8'b0;
reg [7:0] mem_data2 = 8'b0;
reg mem_last1 = 1'b0;
reg mem_last2 = 1'b0;
reg flag_2b = 1'b0;

//флаг наличия рукопожатия
wire flag_m_handshake;

//завязываем рукопожатие на значение сигналов
assign flag_m_handshake = m_ready & m_valid;

//завязываем valid на запись и счётчик
assign m_valid = s_valid | STATE;

always @(posedge clk or negedge reset_n) begin 
    if(~reset_n) begin 
        m_data <= 8'b0;
        m_last <= 1'b0;
    end else 
        if(flag_m_handshake)
            if(STATE == 0) begin
                m_data <= s_data;
                m_last <= s_last;
                s_ready <= m_ready;
            end else if(STATE == 1) begin 
                m_data <= mem_data1;
                m_last <= mem_last1;
                STATE <= 2'b10;
            end else begin 
                m_data <= mem_data2;
                m_last <= mem_last2;
                STATE <= 2'b0;
                flag_2b <= 1'b0;
            end
        else begin 
            m_last <= 1'b0;
            m_data <= 8'b0;
        end
end


always @(posedge clk or negedge reset_n) begin 
    if(reset_n) begin
        if (s_ready & ~m_ready) begin
            STATE <= 1'b1;
            mem_data1 <= s_data;
            mem_last1 <= s_last;
            s_ready <= 1'b0;
        end else begin
            if((STATE == 1) & ~flag_2b) begin 
                mem_data2 <= s_data;
                mem_last2 <= s_last;
                flag_2b <= 1'b1;
            end
            s_ready <= m_ready;
        end
    end 
end

endmodule // skid_buff
