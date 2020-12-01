`timescale 1ns / 1ps
// Project Name:   Reconfigurable Approximate Carry Look-ahead Adder (RAPCLA)
// Description:  SIZE: size of complete adder, groupsize: size of each RAPCLA module, window: approximation carry generation window, ApproxRCON: 1=approximate 0=exact
//////////////////////////////////////////////////////////////////////////////////

module BIT_P(output BP, input A, B);

   xor (BP, A, B);

endmodule

module GC #(parameter valency=4)(output GG, input [valency-1 : 0] g, input [valency-1 : 1] p);

	wire [valency-1 : 0] wr, gg;

	assign gg[0]=g[0];
	

	genvar k;
	generate
	for(k=0; k<valency-1; k=k+1)
		begin
			and (wr[k], p[k+1], gg[k]);
			or (gg[k+1], wr[k], g[k+1]);                        
		end
	endgenerate	
	assign GG=gg[valency-1];
       
endmodule


module BC #(parameter valency=4)(output GG, GP, input [valency-1 : 0] g, input [valency-1 : 0] p);

	wire [valency-1 : 0]  gp;

	wire [valency-1 : 0] wr, gg;

	assign gg[0]=g[0];
	assign gp[0]=p[0];

	genvar k;
	generate
	for(k=0; k<valency-1; k=k+1)
		begin
			and (wr[k], p[k+1], gg[k]);
			or (gg[k+1], wr[k], g[k+1]); 
                        and (gp[k+1], p[k+1], gp[k]);
		end
	endgenerate	
	assign GG=gg[valency-1];
        assign GP=gp[valency-1];
endmodule




module mux_2_input (
	output OP, 
	input  A, B, sel);	 

        assign OP= (sel)? A : B;     

		
endmodule






module RAPCLA_p_16 #(parameter SIZE=16, groupsize=4, window=2)(
	output [SIZE:1] SUM,
	output COUT,
	input [SIZE:1] A, B,
	input CIN,
        input [SIZE/groupsize:1] ApproxRCON );

	wire [SIZE:0] gen;       
        wire [SIZE:0] p;
	wire [SIZE:0] g;
     	wire [SIZE/groupsize:0] genexact;
	wire [2*SIZE/groupsize:1] groupgen1,groupprop1;

        assign gen[0]=CIN;
	assign p[0]=0;

	genvar i, j, k;


		generate 

//BIT GENERATE and BIT PROPAGATE signals
			for (i=1; i<=SIZE; i=i+1)
				begin:BIT_GENERATE_PROPAGATE
					and BITGEN(g[i],  A[i], B[i]);
					BIT_P BITPROP(p[i],  A[i], B[i]);
				end
// Black Cells for all subgroups (in every group, there is lower black cell of valency (groupsize-window) and upper black cell of valency (window))

			for (i=1; i<=SIZE/groupsize; i=i+1)
				begin:BLACK_CELLS_GROUP
					BC #(groupsize-window) BLACKCELLL(groupgen1[i*2-1], groupprop1[i*2-1], g[groupsize*i-window:groupsize*(i-1)+1], p[groupsize*i-window:groupsize*(i-1)+1]); 
					BC #(window) BLACKCELLU(groupgen1[i*2], groupprop1[i*2], g[groupsize*i:groupsize*i-window+1], p[groupsize*i:groupsize*i-window+1]); 
				end

// Group generate signal at every bit position

			for (i=1; i<=SIZE/groupsize; i=i+1)
				begin:SUBGROUP_END_GG
					GC #(2) GRAYCELL_LOW_GROUP(gen[i*groupsize-window], {groupgen1[i*2-1], gen[(i-1)*groupsize]}, groupprop1[i*2-1]); //For lower subgroup in each group
					GC #(2) GRAYCELL_HIGH_GROUP(genexact[i], {groupgen1[i*2], gen[i*groupsize-window]}, groupprop1[i*2]); //For upper subgroup in each group
					mux_2_input RECON(gen[i*groupsize], groupgen1[i*2], genexact[i], ApproxRCON[i]); // Selection between exact and approximate carry ApproxRCON[i]					
					for (j=1; j<groupsize-window; j=j+1)   //Group generate at every bit position in lower subgroup of a group
						begin:GROUP_GENERATE_WITHIN_LOSUBGROUP
							GC #(2) GRAYCELLLO(gen[(i-1)*groupsize+j], {g[(i-1)*groupsize+j], gen[(i-1)*groupsize+j-1]}, p[groupsize*(i-1)+j]); 
						end
					for (j=1; j<window; j=j+1)  //Group generate at every bit position in upper subgroup of a group
						begin:GROUP_GENERATE_WITHIN_HIGHSUBGROUP
							GC #(2) GRAYCELLHIGH(gen[i*groupsize-window+j], {g[i*groupsize-window+j], gen[i*groupsize-window+j-1]}, p[i*groupsize-window+j]); 
						end
				end	
// Generations of sum bits at every bit position	
			for(k=0; k<SIZE; k=k+1)	
				begin:CLA_SUM
					xor g1(SUM[k+1], p[k+1], gen[k]);    //SUM[i]=p[i] XOR G[i-1:0]
				end	
		endgenerate
      	assign COUT=gen[SIZE];  //Final carry output		
endmodule
