
interface synch_fifo(); //interface of synchronous fifo
  logic clk,rst,wr_en,rd_en,empty,full;
  logic [7:0] wr_data;
  logic [7:0] rd_data;
  
  modport rtl(input clk,rst,wr_en,rd_en,wr_data, output rd_data,full,empty);
  modport tb(output clk,rst,wr_en,rd_en,wr_data, input rd_data,full,empty);
endinterface

module fifo(synch_fifo.rtl inf); // design block
  
  bit [3:0] wr_ptr,rd_ptr,cnt;
  bit [7:0] fifo_mem [15:0];
  
  always@(posedge inf.clk)
    begin
      if(inf.rst== 1'b1)       // reset condition
         begin
           cnt <= 0;
           wr_ptr <= 0;
           rd_ptr <= 0;
         end
      
      //when write enabe and memory does not full
      else if(inf.wr_en && !inf.full)   
          begin
            if(cnt < 15) begin
              fifo_mem[wr_ptr] <= inf.wr_data;
            wr_ptr <= wr_ptr + 1;
            cnt <= cnt + 1;
            end
          end
      
      // when read enable and memory does not empty
      else if (inf.rd_en && !inf.empty) 
        begin
          if(cnt > 0) begin
            inf.rd_data <= fifo_mem[rd_ptr];
          rd_ptr <= rd_ptr + 1;
          cnt <= cnt - 1;
          end
        end 
      // when write pointer reach to last memory location
      if(wr_ptr == 15)
         wr_ptr <= 0;
      // when read pointer reach to last memory location
      if(rd_ptr == 15)
         rd_ptr <= 0;
    end
  
  // condition of empty and full memory
  assign inf.empty = (cnt == 0) ? 1'b1 : 1'b0;
  assign inf.full = (cnt == 15) ? 1'b1 : 1'b0;
  
endmodule
