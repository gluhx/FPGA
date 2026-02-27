module skid_buff(
    input clk,
    input reset_n,

    input [7:0] s_data,
    input s_valid,
    input s_last,
    output reg s_ready,

    output reg [7:0] m_data,
    output reg m_valid,
    output reg m_last,
    input m_ready
);

//объявляем возможные состояния
//(0 - обычная работа, 1 - работа в режиме буферизации)
reg STATE = 1'b0;

//объявляем память для хранения данных
reg [7:0] mem_data1 = 8'b0;
reg [7:0] nen_data2 = 8'b0;
reg mem_last = 1'b0;

always @(posedge clk or negedge reset_n) begin 
    
    //Проверяем reset
    if(~reset_n) begin
        mem_data <= 8'b0;
        mem_last <= 1'b0;
        s_ready <= 1'b0;
        m_data <= 8'b0;
        m_valid <= 1'b0;
        m_last <= 1'b0;
        STATE <= 1'b0;
    end else begin
        
        //проверяем состояние текущее
        if (STATE == 1'b0) begin
            
            //проверяем ситуацию, где мы должны переключиться в другой режим
            if ((s_ready == 1'b1) && (m_ready == 1'b0)) begin
                //запоминаем данные
                mem_data <= m_data;
                mem_last <= m_last;

                //выставляем сигналы
                s_ready <= 1'b0;
                m_valid <= 1'b1;
                m_data <= 8'b0;
                m_last <= 1'b0;

                //меняем состояние
                STATE <= 1'b1;
            end else begin
                
                //нормальный режим работы
                m_data <= s_data;
                m_last <= s_last;
                m_valid <= s_valid;
                s_ready <= m_ready;
            end
        end else begin 
            
            //если ready у Slave установлен в 1, то выводим данные, а если нет,
            //то просто молчим, ожидая готовности
            if (m_ready == 1'b1) begin
                
                //выдаём данные на выход
                m_data <= mem_data;
                m_last <= mem_last;

                //обновляем состояние
                STATE <= 1'b0;
            end
        end
    end
end

endmodule // skid_buff
