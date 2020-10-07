module SARA_tb #(parameter size=16, group_size=4);
  reg [size:1] a,b;
	reg cin;
  reg [size/group_size:1] select;
  wire [size:1] sum;
	wire cout;
	
  SARA #(size, group_size) INST1(
    .sum(sum),
    .cout(cout),
    .a(a),
    .b(b),
    .cin(cin),
    .select(select));

	initial 
		begin
		#150 $finish;
		end

	initial
		begin
		a=16'b0000000000000000; b=16'b0000000000000000; cin=1'b0; select=4'b00;
		#20 a=16'b0000000111101000; b=16'b0000000100011111; cin=1'b1; select=4'b00;
		#40 a=16'b0000000111101000; b=16'b0000000100011111; cin=1'b1; select=4'b00;
		#60 a=16'b1111000111100000; b=16'b1111000000000000; cin=1'b1; select=4'b00;
		end
        
endmodule

