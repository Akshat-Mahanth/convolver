module sample_selector (
    input [3:0] fr_lconvo,
    input clk,
    output reg [2:0] line_a,
    output reg [2:0] line_b,
    output cmp_booth,
    output reg WE_ARE_DONE
);
parameter  RELOAD=3'b000,SAMPLE_SELECT=3'b001,REG_LATCH=3'b010,PADDING_STATE=3'b011,LATCH_REVERSE_PAIR=3'b100,DONE=3'b101;
reg [2:0]STATE=RELOAD;
reg [2:0]a_sel;
reg [2:0]b_sel;
reg r_cmp_booth;
reg r_cmp_controller;


always @(posedge clk) begin
    case(STATE)
    RELOAD:begin
         assign WE_ARE_DONE = 1'b0;
         a_sel<=3'b000;
         b_sel<=3'b000;
         if (fr_lconvo>7)
            begin
                a_sel<=7;
                b_sel<=fr_lconvo-7;
            end
        else 
            begin
                a_sel<=3'b000;
                b_sel<=fr_lconvo;
            end
        
         STATE=REG_LATCH;
    end

    SAMPLE_SELECT:begin
         a_sel<=a_sel+1;
         b_sel<=b_sel-1;
         STATE = REG_LATCH;
          end 
    
    REG_LATCH:begin
        line_a<=a_sel;
        line_b<=b_sel;
        if (fr_lconvo%2==0)
            begin
                if (a_sel==b_sel)
                    begin
                        STATE=DONE;
                    end
                else 
                    STATE=LATCH_REVERSE_PAIR;
            end
        else STATE=PADDING_STATE;
    end

    PADDING_STATE:begin
        STATE=LATCH_REVERSE_PAIR;
    end

    LATCH_REVERSE_PAIR:begin
        line_a<=b_sel;
        line_b<=a_sel;
        if (a_sel==fr_lconvo/2)
            begin
               STATE=DONE;
            end
        else STATE=SAMPLE_SELECT;
    end

    
    DONE:begin
        r_cmp_controller<=1'b1;
        assign WE_ARE_DONE = 1'b1;

    end



endcase;
end

assign cmp_booth=r_cmp_booth;
assign cmp_controller=r_cmp_controller;


endmodule