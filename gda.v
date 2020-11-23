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
module BC #(parameter valency=4)(output GG,GP, input [valency-1 : 0] g, input [valency-1 : 0] p);
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
	assign GP=gp[valency-1];
    endmodule

module gda #(parameter size=16,subsize=4)(output cout,output [size:1] sum,input [size:1] a,b,input cin,input [(size/subsize)-1:1] control);
wire [size:0] carry;
assign carry[0]=cin;
wire [size:0] g,p;
assign g[0]=cin;
assign p[0]=0;
wire [size/subsize-1:1] capprox,cexact;
genvar i,j;
generate
	for(i=1;i<=size;i=i+1)
	begin
		BIT_GENERATE G0(g[i],a[i],b[i]);
		BIT_PROPAGATE G1(p[i],a[i],b[i]);
	end
	for(i=subsize;i<size;i=i+subsize)
	begin
		GC #(subsize) g2(capprox[i/subsize],g[i:i-subsize+1],p[i:i-subsize+2]);
		GC #(2) g3(cexact[i/subsize],{g[i],carry[i-1]},p[i]);
	assign carry[i]=(control[i/subsize])?cexact[i/subsize]:capprox[i/subsize];
	end
for(i=0;i<size;i=i+subsize)
begin
for(j=1;j<subsize;j=j+1)
GC #(2) g3(carry[i+j],{g[i+j],carry[i+j-1]},p[i+j]);
end
GC #(2) g3(carry[size],{g[size],carry[size-1]},p[size]);

for(i=1;i<=size;i=i+1)
xor g1(sum[i],p[i],carry[i-1]);
endgenerate
assign cout=carry[size];
endmodule
