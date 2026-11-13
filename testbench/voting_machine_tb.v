
module voting_machine_tb;

reg clk;
reg reset;

reg vote_A, vote_B, vote_C, vote_D;

wire [7:0] count_A, count_B, count_C, count_D;
wire [2:0] winner;
wire tie;

// Connecting main voting machine
voting_machine uut (
    .clk(clk),
    .reset(reset),

    .vote_A(vote_A),
    .vote_B(vote_B),
    .vote_C(vote_C),
    .vote_D(vote_D),

    .count_A(count_A),
    .count_B(count_B),
    .count_C(count_C),
    .count_D(count_D),

    .winner(winner),
    .tie(tie)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Test voting machine
initial begin

    $dumpfile("simulation/voting_machine.vcd");
    $dumpvars(0, voting_machine_tb);

    reset = 1;
    vote_A = 0;
    vote_B = 0;
    vote_C = 0;
    vote_D = 0;

    #20;
    reset = 0;

    // Candidate A votes
    vote_A = 1;
    #20;
    vote_A = 0;
    #10;

    // Candidate B votes
    vote_B = 1;
    #20;
    vote_B = 0;
    #10;

    // Candidate A votes again
    vote_A = 1;
    #20;
    vote_A = 0;
    #10;

    // Candidate C votes
    vote_C = 1;
    #20;
    vote_C = 0;
    #10;

    // Candidate D votes
    vote_D = 1;
    #20;
    vote_D = 0;
    #10;

    // Display results
    $display("\n------------------------------");
    $display("       VOTING RESULTS");
    $display("------------------------------");

    $display("Candidate A: %d", count_A);
    $display("Candidate B: %d", count_B);
    $display("Candidate C: %d", count_C);
    $display("Candidate D: %d", count_D);

    if (tie)
        $display("RESULT: TIE DETECTED");
    else if (winner == 3'b001)
        $display("WINNER: Candidate A");
    else if (winner == 3'b010)
        $display("WINNER: Candidate B");
    else if (winner == 3'b011)
        $display("WINNER: Candidate C");
    else if (winner == 3'b100)
        $display("WINNER: Candidate D");
    else
        $display("RESULT: No votes yet");

    $display("------------------------------");

    // Reset test
    reset = 1;
    #10;
    reset = 0;
    #10;

    $display("After reset: A=%d B=%d C=%d D=%d",
             count_A, count_B, count_C, count_D);

    $finish;
end

endmodule
