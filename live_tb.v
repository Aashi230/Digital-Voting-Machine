
module live_tb;

    reg clk, reset;
    reg vote_A, vote_B, vote_C, vote_D;

    wire [7:0] count_A, count_B, count_C, count_D;
    wire [2:0] winner;
    wire tie;

    integer command;
    integer status;

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

    // Continuous clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Initialize circuit and waveform
    initial begin

        $dumpfile("simulation/live.vcd");
        $dumpvars(0, live_tb);

        reset = 1;

        vote_A = 0;
        vote_B = 0;
        vote_C = 0;
        vote_D = 0;

        #12;
        reset = 0;

        $display("LIVE_SIMULATION_READY");
        $fflush();

        // Wait for commands from Flask
        forever begin

            command = -1;

            status = $fscanf(32'h80000000, "%d", command);

            if (status == 1) begin

                if (command == 0) begin
                    // Reset election
                    @(negedge clk);
                    reset = 1;

                    @(negedge clk);
                    reset = 0;
                end

                else begin

                    // Apply one vote
                    @(negedge clk);

                    case (command)

                        1: vote_A = 1;
                        2: vote_B = 1;
                        3: vote_C = 1;
                        4: vote_D = 1;

                        default: begin
                            $display("INVALID_COMMAND");
                        end

                    endcase

                    // Allow circuit to count the vote
                    @(negedge clk);

                    vote_A = 0;
                    vote_B = 0;
                    vote_C = 0;
                    vote_D = 0;

                end

                // Wait for updated outputs
                @(posedge clk);
                #1;

                $display(
                    "RESULT:%0d,%0d,%0d,%0d,%0d,%0d",
                    count_A, count_B, count_C, count_D,
                    winner, tie
                );
$dumpflush;
                $fflush();

            end
            else begin
                $display("INPUT_CLOSED");
                $finish;
            end

        end

    end

endmodule
