
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


module SARA #(parameter size=32,group_size=4) 
  (output [size:1] sum,output cout,input [size:1] a,b,input cin,input   	 [size/group_size:1] select);
  
  wire [size:0] p;
  wire [size:0] g;
  wire [size:0] gen;
  wire [size/group_size:0] genexact;
 
  assign p[0]=0;
  assign gen[0]=cin;
  assign genexact[0]=cin;
  
  genvar i,j,k;
  generate
    for(i=0;i<=size;i=i+1)
      begin
        BIT_PROPAGATE g1(p[i],a[i],b[i]);
        BIT_GENERATE g2(g[i],a[i],b[i]);
      end
    for(j=1;j<=size/group_size;j=j+1)
      begin 
        GC #(size+1) g3(genexact[j],{g[((j)*group_size):((j-		 1)*group_size)+1],genexact[j-1]},p[((j)*group_size):((j-1)*group_size)+1]); 
      end
    
    for(i=1;i<=size/group_size;i=i+1)
      begin
        assign gen[i*group_size]=(select[i])?genexact[i]:g[i*group_size];
        for(j=1;j<group_size;j=i+1)  //Group generate of each bit
           begin
             GC #(2) g4(gen[j+((i-1)*group_size)],
                        {g[j+((i-1)*group_size)],
                   gen[j-1+((i- 1)*group_size)]},p[j+((i-1)*group_size)]);
           end
        
        for(k=2;k<=group_size;k=k+1)
          begin
            xor(sum[k+((i-1)*group_size)],p[k+((i-1)*group_size)],
                gen[k-1+((i-1)*group_size)]);
          end
        
        xor(sum[((i-1)*group_size)+1],p[1+((i-1)*group_size)],
            genexact[i-1]);
           
      end
    
endgenerate
endmodule