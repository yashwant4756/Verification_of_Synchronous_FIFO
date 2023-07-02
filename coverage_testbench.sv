module testbench(synch_fifo.tb inf); // testbench of synchronous fifo
  initial begin
   inf.clk = 0;
   inf.wr_en = 0;
   inf.rd_en = 0;
   inf.rst = 0;
   inf.wr_data = 0;
  end
  
  always #5 inf.clk = ~inf.clk;
 
  covergroup c @(posedge inf.clk);  
  option.per_instance = 1; // give detailed informaiton of each bin
                           // coverpoints of coverage
   coverpoint inf.empty {
     bins empty_l = {0};
     bins empty_h = {1};
   }
   
      coverpoint inf.full {
     bins full_l = {0};
     bins full_h = {1};
   }
  
     coverpoint inf.rst {
     bins rst_l = {0};
     bins rst_h = {1};
   }
  
      coverpoint inf.wr_en {
     bins wr_l = {0};
     bins wr_h = {1};
   }
  
  
     coverpoint inf.rd_en {
     bins rd_l = {0};
     bins rd_h = {1};
   }
  
    coverpoint inf.wr_data
   {
     option.auto_bin_max=256;
     bins lower= {[0:84]};
     bins mid = {[85:169]};
     bins high= {[170:255]};
     
   }
   
     coverpoint inf.rd_data
   {
     option.auto_bin_max=256;
     bins lower = {[0:84]};
     bins mid = {[85:169]};
     bins high = {[170:255]};
   }
  // cross coverage
  cross_wr_enXwr_data: cross inf.wr_en,inf.wr_data;
  cross_rd_enXrd_data: cross inf.rd_en,inf.rd_data;
  
 endgroup
  
  c ci;  // instantiation of covergroup 
  
  task write();
    for(int i = 0; i < 20; i++) begin
      @(posedge inf.clk);   
    inf.wr_en = 1'b1;
    inf.rd_en = 1'b0;
      inf.wr_data = $urandom();   // unsigned randomisation of wr_data
        $display("--------------------------------------------------");
      $display("The value of write data is %0d when wr_en=%0d and rd_en=%0d",inf.wr_data,inf.wr_en,inf.rd_en);
        //$display("--------------------------------------------------");
   end  
  endtask
  
    task read();
      for(int i = 0; i < 20; i++) begin
        @(posedge inf.clk);   
    inf.wr_en = 1'b0;
    inf.rd_en = 1'b1;
    inf.wr_data = 0;
        #20;
          $display("--------------------------------------------------");
        $display("The value of read data is %0d when wr_en=%0d and rd_en=%0d",inf.rd_data,inf.wr_en,inf.rd_en);
         // $display("--------------------------------------------------");
   end  
  endtask
  
  
  initial begin
  inf.rst = 1'b1;
    #50;
  inf.rst = 0;
  inf.wr_en = 0;
  inf.rd_en= 0;
  #20;
    write(); 
   #30;
    read(); 
   #30; 
  end
  
  initial begin
    ci = new(); 
    $display("--------------------------------------------------");
    $display("Coverage of Synchronous fifo is %0f",ci.get_coverage());
    $display("--------------------------------------------------");
    $dumpfile("dump.vcd");
    $dumpvars;
    #1000;
    $finish();
  end
endmodule

module top_module();  // top level module
  synch_fifo utt();
  fifo dut(utt);
  testbench test(utt);
endmodule
