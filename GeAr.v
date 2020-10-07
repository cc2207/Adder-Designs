module BIT_GENERATE(output g, input a,b);
  and (g,a,b);
endmodule
  
module BIT_PROPAGATE(output p, input a,b);
  xor (p,a,b);
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

module BC #(parameter valency=4)(output GG,GP, input [valency-1 : 0] g, input [valency-1 : 1] p);
  wire [valency-1 : 0] wr, gg,gp;
    assign gp[0]=p[0];
    assign gg[0]=g[0];
	genvar k;
	generate
	for(k=0; k<valency-1; k=k+1)
		begin
		and (wr[k], p[k+1], gg[k]);
		or (gg[k+1], wr[k], g[k+1]);   
        and(gp[k+1],p[k+1],gp[k]);
		end
	endgenerate	
	assign GG=gg[valency-1];   
    endmodule

module GeAr #(parameter size=12,p=4,r=2) (output cout,output [size:1] sum,input [size:1] a,b,input cin);

parameter l=p+r;
parameter k=(size-l)/r;
wire [size:0] prop,g;
wire [size:0] gen;
assign prop[0]=0;
assign g[0]=cin;
assign gen[0]=cin;
genvar i,j;
generate
for(i=1;i<=size;i=i+1)
begin
BIT_PROPAGATE G1(prop[i],a[i],b[i]);
BIT_GENERATE G2(g[i],a[i],b[i]);
end

for(i=1;i<l;i=i+1)  //group generate for first sub-adder
begin
GC #(2) G3(gen[i],{g[i],gen[i-1]},prop[i]);
end

for(i=1;i<=k;i=i+1)
begin		  //carry prediction for each sub-adder
GC #(p) G4(gen[((i-1)*r)+l],g[((i-1)*r)+l:((i-1)*r)+l-p+1],prop[((i-1)*r)+l:((i-1)*r)+l-p+2]);
for(j=1;j<r;j=j+1)
begin		//groupgen for remaining bits of suadder
GC #(2) G5(gen[((i-1)*r)+l+j],{g[((i-1)*r)+l+j],gen[((i-1)*r)+l+j-1]},prop[((i-1)*r)+l+j]);
end
end
for(i=1;i<=size;i=i+1) //sum 
xor(sum[i],prop[i],gen[i-1]);
endgenerate
GC #(2) G6(gen[size],{g[size],gen[size-1]},prop[size]);
assign cout=gen[size];

endmodule


