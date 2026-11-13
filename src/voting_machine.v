
module voting_machine (
    input clk,
    input reset,

    input vote_A,
    input vote_B,
    input vote_C,
    input vote_D,

    output reg [7:0] count_A,
    output reg [7:0] count_B,
    output reg [7:0] count_C,
    output reg [7:0] count_D,

    output reg [2:0] winner,
    output reg tie
);

reg prev_A, prev_B, prev_C, prev_D;

// Vote counting
always @(posedge clk) begin

    if (reset) begin
        count_A <= 0;
        count_B <= 0;
        count_C <= 0;
        count_D <= 0;

        prev_A <= 0;
        prev_B <= 0;
        prev_C <= 0;
        prev_D <= 0;
    end

    else begin

        if (vote_A && !prev_A &&
            !vote_B && !vote_C && !vote_D)
            count_A <= count_A + 1;

        else if (vote_B && !prev_B &&
                 !vote_A && !vote_C && !vote_D)
            count_B <= count_B + 1;

        else if (vote_C && !prev_C &&
                 !vote_A && !vote_B && !vote_D)
            count_C <= count_C + 1;

        else if (vote_D && !prev_D &&
                 !vote_A && !vote_B && !vote_C)
            count_D <= count_D + 1;

        prev_A <= vote_A;
        prev_B <= vote_B;
        prev_C <= vote_C;
        prev_D <= vote_D;

    end
end

// Winner and tie detection
always @(*) begin

    winner = 3'b000;
    tie = 0;

    if (count_A == 0 && count_B == 0 &&
        count_C == 0 && count_D == 0) begin
        winner = 3'b000;
        tie = 0;
    end

    else if (count_A > count_B &&
             count_A > count_C &&
             count_A > count_D)
        winner = 3'b001;

    else if (count_B > count_A &&
             count_B > count_C &&
             count_B > count_D)
        winner = 3'b010;

    else if (count_C > count_A &&
             count_C > count_B &&
             count_C > count_D)
        winner = 3'b011;

    else if (count_D > count_A &&
             count_D > count_B &&
             count_D > count_C)
        winner = 3'b100;

    else begin
        winner = 3'b000;
        tie = 1;
    end

end

endmodule
