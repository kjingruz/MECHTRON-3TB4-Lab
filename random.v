module random (
    input clk, reset_n, resume_n,
    output reg [13:0] random,
    output reg rnd_ready
);
    // For 14 bits Linear Feedback Shift Register,
    // the Taps that need to be XNORed are: 14, 5, 3, 1
    wire xnor_taps, and_allbits, feedback;
    reg [13:0] reg_values;
    reg enable = 1;

    always @(posedge clk or negedge reset_n or negedge resume_n) begin
        if (!reset_n) begin
            // Initialize LFSR with a non-zero value
            reg_values <= 14'b11111111111111;
            enable <= 1;
            rnd_ready <= 0;
        end else if (!resume_n) begin
            // Resume functionality, potentially resetting rnd_ready
            enable <= 1;
            rnd_ready <= 0;
            // Maintain current state of reg_values
        end else if (enable) begin
            // Shift and feedback logic
            reg_values[13] <= reg_values[0];
            reg_values[12:5] <= reg_values[13:6];
            reg_values[4] <= reg_values[0] ^ reg_values[5]; // Feedback from tap 5
            reg_values[3] <= reg_values[4];
            reg_values[2] <= reg_values[0] ^ reg_values[3]; // Feedback from tap 3
            reg_values[1] <= reg_values[2];
            reg_values[0] <= reg_values[0] ^ reg_values[1]; // Feedback from tap 1

            // Check if reg_values is within the desired range
            if (reg_values >= 1000 && reg_values <= 5000) begin
                enable <= 1'b1; // Stop updating once in range
                rnd_ready <= 1'b1; // Indicate ready status
                random <= reg_values; // Output the random value
            end
        end
    end
endmodule