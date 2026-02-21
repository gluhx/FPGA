module skid_buff(
    input clk,
    input reset,

    input [7:0] m_data,
    input m_valid,
    input m_last,
    output reg m_ready,

    output reg [7:0] s_data,
    output reg s_valid,
    output reg s_last,
    input s_ready
);

//объявляем возможные состояния
//(0 - обычная работа, 1 - работа в режиме буферизации)
reg STATE = 1'b0;

//объявляем память для хранения данных
reg [7:0] mem_data = 8'b0;
reg mem_last = 1'b0;

always @(posedge clk or negedge reset) begin 
    
    //Проверяем reset
    if(!reset) begin
        mem_data <= 8'b0;
        mem_last <= 1'b0;
        m_ready <= 1'b0;
        s_data <= 8'b0;
        s_valid <= 1'b0;
        s_last <= 1'b0;
        STATE <= 1'b0;
    end else begin
        
        //проверяем состояние текущее
        if (STATE == 1'b0) begin
            
            //проверяем ситуацию, где мы должны переключиться в другой режим
            if ((m_ready == 1'b1) && (s_ready == 1'b0)) begin
                //запоминаем данные
                mem_data <= m_data;
                mem_last <= m_last;

                //выставляем сигналы
                m_ready <= 1'b0;
                s_valid <= 1'b1;
                s_data <= 8'b0;
                s_last <= 1'b0;

                //меняем состояние
                STATE <= 1'b1;
            end else begin
                
                //нормальный режим работы
                s_data <= m_data;
                s_last <= m_last;
                s_valid <= m_valid;
                m_ready <= s_ready;
            end
        end else begin 
            
            //если ready у Slave установлен в 1, то выводим данные, а если нет,
            //то просто молчим, ожидая готовности
            if (s_ready == 1'b1) begin
                
                //выдаём данные на выход
                s_data <= mem_data;
                s_last <= mem_last;

                //обновляем состояние
                STATE <= 1'b0;
            end
        end
    end
end

endmodule // skid_buff
