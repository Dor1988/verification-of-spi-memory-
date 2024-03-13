`include "uvm_macros.svh"
 import uvm_pkg::*;
 
 
////////////////////////////////////////////////////////////
 
interface spi_i;
 
    logic clk, rst, cs, miso; // notice that miso it is the line that the data goes from the driver into the memory
    logic ready, mosi, op_done; // notice that mosi it is the line that the data goes from the memory outside of it 
      
endinterface 
 
 
 
////////////////////////////////////////////////////////////////////////////////////
class spi_config extends uvm_object; /////configuration of env
  `uvm_object_utils(spi_config)
  
  function new(string name = "spi_config");
    super.new(name);
  endfunction
  
  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
endclass
 
//////////////////////////////////////////////////////////
 
typedef enum bit [1:0]   {readd = 0, writed = 1, rstdut = 2} oper_mode; // for verify the memory we considring only 3 operations write,read,rst 
 
 
class transaction extends uvm_sequence_item;
    randc logic [7:0] addr;// not exist at the dut, just for work convenience with transactions
    rand logic [7:0] din;// not exist at the dut, just for work convenience with transactions
         logic [7:0] dout;// not exist at the dut, just for work convenience with transactions
    rand oper_mode   op;
         logic rst;
    rand logic miso;
         logic cs;     
         logic done;
         logic err;
         logic ready;
         logic mosi;
         
  constraint addr_c { addr <= 10;}
 
        `uvm_object_utils_begin(transaction)
        `uvm_field_int (addr,UVM_ALL_ON)
        `uvm_field_int (din,UVM_ALL_ON)
        `uvm_field_int (dout,UVM_ALL_ON)
        `uvm_field_int (ready,UVM_ALL_ON)
        `uvm_field_int (rst,UVM_ALL_ON)
        `uvm_field_int (done,UVM_ALL_ON)
        `uvm_field_int (miso,UVM_ALL_ON)
        `uvm_field_int (mosi,UVM_ALL_ON)
        `uvm_field_int (cs,UVM_ALL_ON)
        `uvm_field_int (err,UVM_ALL_ON)
        `uvm_field_enum(oper_mode, op, UVM_DEFAULT)
        `uvm_object_utils_end
  
 
  function new(string name = "transaction");
    super.new(name);
  endfunction
 
endclass : transaction
 
 
///////////////////////////////////////////////////////////////////////
 
 
///////////////////write seq- sequence for writing a data
class write_data extends uvm_sequence#(transaction);
  `uvm_object_utils(write_data)
  
  transaction tr;
 
  function new(string name = "write_data");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(15)
      begin
        tr = transaction::type_id::create("tr");
        tr.addr_c.constraint_mode(1);
        start_item(tr);
        assert(tr.randomize);
        tr.op = writed;
        finish_item(tr);
      end
  endtask
  
 
endclass
//////////////////////////////////////////////////////////
 
 // sequence for reading a data
class read_data extends uvm_sequence#(transaction);
  `uvm_object_utils(read_data)
  
  transaction tr;
 
  function new(string name = "read_data");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(15)
      begin
        tr = transaction::type_id::create("tr");
        tr.addr_c.constraint_mode(1);
        start_item(tr);
        assert(tr.randomize);
        tr.op = readd;
        finish_item(tr);
      end
  endtask
  
 
endclass
/////////////////////////////////////////////////////////////////////
 //sequence for perform reset of the dut
class reset_dut extends uvm_sequence#(transaction);
  `uvm_object_utils(reset_dut)
  
  transaction tr;
 
  function new(string name = "reset_dut");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(15)
      begin
        tr = transaction::type_id::create("tr");
        tr.addr_c.constraint_mode(1);
        start_item(tr);
        assert(tr.randomize);
        tr.op = rstdut;
        finish_item(tr);
      end
  endtask
  
 
endclass
////////////////////////////////////////////////////////////
 
 
 
class writeb_readb extends uvm_sequence#(transaction);
  `uvm_object_utils(writeb_readb)
  
  transaction tr;
 
  function new(string name = "writeb_readb");
    super.new(name);
  endfunction
  
  virtual task body();
     
    repeat(10)
      begin
        tr = transaction::type_id::create("tr");
        tr.addr_c.constraint_mode(1);
        start_item(tr);
        assert(tr.randomize);
        tr.op = writed;
        finish_item(tr);  
      end
        
    repeat(10)
      begin
        tr = transaction::type_id::create("tr");
        tr.addr_c.constraint_mode(1);
        start_item(tr);
        assert(tr.randomize);
        tr.op = readd;
        finish_item(tr);
      end   
    
  endtask
  
 
endclass
 
 
 
////////////////////////////////////////////////////////////
class driver extends uvm_driver #(transaction);
  `uvm_component_utils(driver)
  
  virtual spi_i vif;
  transaction tr;
  logic [15:0] data; ////<- din , addr ->
  logic [7:0] datard;
  
  
  function new(input string path = "drv", uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
 virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     tr = transaction::type_id::create("tr");
      
      if(!uvm_config_db#(virtual spi_i)::get(this,"","vif",vif))//uvm_test_top.env.agent.drv.aif
      `uvm_error("drv","Unable to access Interface");
  endfunction
  
  
  
  ////////////////////reset task
  task reset_dut(); 
    begin
    vif.rst      <= 1'b1;  ///active high reset
    vif.miso     <= 1'b0; // default value
    vif.cs       <= 1'b1; // default value
   `uvm_info("DRV", "System Reset", UVM_MEDIUM);
    @(posedge vif.clk);
    end
  endtask
  
  ///////////////////////write 
  
  task write_d();
  vif.rst  <= 1'b0;
  vif.cs   <= 1'b1;
  vif.miso <= 1'b0;
  @(posedge vif.clk);
  ////start of transaction
  vif.rst  <= 1'b0;
  vif.cs   <= 1'b0;//start of transaction making cs=0
  vif.miso <= 1'b0;
  data     = {tr.din, tr.addr};
  `uvm_info("DRV", $sformatf("DATA WRITE addr : %0d din : %0d",tr.addr, tr.din), UVM_MEDIUM); 
  @(posedge vif.clk);
  vif.miso <= 1'b1;  ///write operation
  @(posedge vif.clk);
  
  for(int i = 0; i < 16 ; i++)
   begin
   vif.miso <= data[i];
   @(posedge vif.clk);
   end
  
  @(posedge vif.op_done);
  
  endtask 
  
 //////////////////read operation 
  task read_d();
  
  vif.rst  <= 1'b0;
  vif.cs   <= 1'b1;
  vif.miso <= 1'b0;
  @(posedge vif.clk);
  ////start of transaction
  vif.rst  <= 1'b0;
  vif.cs   <= 1'b0;
  vif.miso <= 1'b0;
  data     = {8'h00, tr.addr};
  @(posedge vif.clk);
  vif.miso <= 1'b0;  ///read operation
  @(posedge vif.clk);
  
  ////send addr
  for(int i = 0; i < 8 ; i++)
   begin
   vif.miso <= data[i];
   @(posedge vif.clk);
   end
   
   ///wait for data ready
  @(posedge vif.ready);
  
  ///sample output data
   for(int i = 0; i < 8 ; i++)
   begin
   @(posedge vif.clk);
   datard[i] = vif.mosi;
   end
   `uvm_info("DRV", $sformatf("DATA READ addr : %0d dout : %0d",tr.addr,datard), UVM_MEDIUM);  // so we will compare the collected data by the monitor
  @(posedge vif.op_done);
  //vif.cs   <= 1'b1; // the end  of transaction
  
  endtask 
  
  //////////////////////////
 
  
 
  virtual task run_phase(uvm_phase phase);
  //  vif.rst      <= 1'b1;  ///active high reset
 //   #100ns;
    forever begin
     
         seq_item_port.get_next_item(tr);
     
     
                   if(tr.op ==  rstdut)
                          begin
                          reset_dut();
                          end
 
                  else if(tr.op == writed)
                          begin
                          write_d();
                          end
                else if(tr.op ==  readd)
                          begin
					      read_d();
                          end
                          
       seq_item_port.item_done();
     
   end
  endtask
 
  
endclass
 
//////////////////////////////////////////////////////////////////////////////////////////////
 
class mon extends uvm_monitor;
`uvm_component_utils(mon)
 
uvm_analysis_port#(transaction) send;
transaction tr;
virtual spi_i vif;
logic [15:0] din;
logic [7:0] dout;
 
    function new(input string inst = "mon", uvm_component parent = null);
    super.new(inst,parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr = transaction::type_id::create("tr");
    send = new("send", this);
      if(!uvm_config_db#(virtual spi_i)::get(this,"","vif",vif))//uvm_test_top.env.agent.drv.aif
        `uvm_error("MON","Unable to access Interface");
    endfunction
    
    
    virtual task run_phase(uvm_phase phase);
    forever begin
      //@(posedge vif.clk);
      @(posedge vif.clk);
      if(vif.rst)
        begin
        tr.op      = rstdut; 
        `uvm_info("MON", "SYSTEM RESET DETECTED", UVM_NONE);
        send.write(tr);
        end
        
        
      else begin
        @(posedge vif.clk);
        @(posedge vif.clk);
             if(vif.miso && !vif.cs)	// that's indicate the write transaction
               begin
                       tr.op = writed;
                      @(posedge vif.clk);
              
                      for(int i = 0; i < 16 ; i++)
                       begin
                       din[i]  <= vif.miso; 
                       @(posedge vif.clk);
                       end
                       
                       tr.addr = din[7:0];
                       tr.din  = din[15:8];
                       
                      @(posedge vif.op_done);
                     `uvm_info("MON", $sformatf("DATA WRITE addr:%0d data:%0d",din[7:0],din[15:8]), UVM_NONE); 
                      send.write(tr);
              end
            else if (!vif.miso && !vif.cs) // that's indicate the read transaction
              begin
                             tr.op = readd; 
                             @(posedge vif.clk);
                             
                               for(int i = 0; i < 8 ; i++)
                               begin
                               din[i]  <= vif.miso;  
                               @(posedge vif.clk);
                               end
                               tr.addr = din[7:0];
                               
                              @(posedge vif.ready);
                              // after ready rising to 1, we are start the collecting of data sended from the memory
                              for(int i = 0; i < 8 ; i++)
                              begin
                              @(posedge vif.clk);
                              dout[i] = vif.mosi;
                              end
                               @(posedge vif.op_done);
                              tr.dout = dout;  
                             `uvm_info("MON", $sformatf("DATA READ addr:%0d data:%0d ",tr.addr,tr.dout), UVM_NONE); 
                             send.write(tr);
           end      
    end
end
   endtask 
 
endclass
//////////////////////////////////////////////////////////////////////////////////////////////////
 
class sco extends uvm_scoreboard;
`uvm_component_utils(sco)
 
  uvm_analysis_imp#(transaction,sco) recv;
  bit [31:0] arr[32] = '{default:0}; //array storing 32 elements each one 32 bits
  bit [31:0] addr    = 0;
  bit [31:0] data_rd = 0;
 
 
 
    function new(input string inst = "sco", uvm_component parent = null);
    super.new(inst,parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv = new("recv", this);
    endfunction
    
    
  virtual function void write(transaction tr);
    if(tr.op == rstdut)
              begin
                `uvm_info("SCO", "SYSTEM RESET DETECTED", UVM_NONE);
              end  
    else if (tr.op == writed)
      begin
          arr[tr.addr] = tr.din;
          `uvm_info("SCO", $sformatf("DATA WRITE OP  addr:%0d, wdata:%0d arr_wr:%0d",tr.addr,tr.din,  arr[tr.addr]), UVM_NONE);
      end
 
    else if (tr.op == readd)
                begin
                  data_rd = arr[tr.addr]; // data_rd is the data from the array in the scorboard, tr.dout it is the actual data that dut send in respone to the read operation
                  if (data_rd == tr.dout)
                    `uvm_info("SCO", $sformatf("DATA MATCHED : addr:%0d, rdata:%0d",tr.addr,tr.dout), UVM_NONE)
                         else
                     `uvm_info("SCO",$sformatf("TEST FAILED : addr:%0d, rdata:%0d data_rd_arr:%0d",tr.addr,tr.dout,data_rd), UVM_NONE) 
                end
     
  
    $display("----------------------------------------------------------------");
    endfunction
 
endclass
 
 
//////////////////////////////////////////////////////////////////////////////////////////////
                  
                  
class agent extends uvm_agent;
`uvm_component_utils(agent)
  
  spi_config cfg;
 
function new(input string inst = "agent", uvm_component parent = null);
super.new(inst,parent);
endfunction
 
 driver d;
 uvm_sequencer#(transaction) seqr;
 mon m;
 
 
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
   cfg =  spi_config::type_id::create("cfg"); 
   m = mon::type_id::create("m",this);
  
  if(cfg.is_active == UVM_ACTIVE)
   begin   
   d = driver::type_id::create("d",this);
   seqr = uvm_sequencer#(transaction)::type_id::create("seqr", this);
   end
  
  
endfunction
 
virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
  if(cfg.is_active == UVM_ACTIVE) begin  
    d.seq_item_port.connect(seqr.seq_item_export);
  end
endfunction
 
endclass
 
//////////////////////////////////////////////////////////////////////////////////
 
class env extends uvm_env;
`uvm_component_utils(env)
 
function new(input string inst = "env", uvm_component c);
super.new(inst,c);
endfunction
 
agent a;
sco s;
 
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
  a = agent::type_id::create("a",this);
  s = sco::type_id::create("s", this);
endfunction
 
virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
 a.m.send.connect(s.recv);
endfunction
 
endclass
 
//////////////////////////////////////////////////////////////////////////
 
class test extends uvm_test;
`uvm_component_utils(test)
virtual spi_i vif;
function new(input string inst = "test", uvm_component c);
super.new(inst,c);
endfunction
 
env e;
write_data wdata;
read_data rdata;
writeb_readb wrrdb;
reset_dut rstdut;  
 
  
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
   e      = env::type_id::create("env",this);
   wdata  = write_data::type_id::create("wdata");
   rdata  = read_data::type_id::create("rdata");
   wrrdb  = writeb_readb::type_id::create("wrrdb");
   rstdut = reset_dut::type_id::create("rstdut");
   
   // Retrieve virtual interface handle from the configuration database
    if (!uvm_config_db#(virtual spi_i)::get(this, "*", "vif", vif))
    `uvm_fatal("NO_VIF", "Virtual interface not found in the configuration database")
endfunction
 
virtual task run_phase(uvm_phase phase);
phase.raise_objection(this);
`uvm_info("test", ("Starting test..."), UVM_NONE)
@(negedge(vif.rst));
`uvm_info("test", ("rst falling to 0..."), UVM_NONE)
wrrdb.start(e.a.seqr);
 
phase.drop_objection(this);
endtask
endclass
 
//////////////////////////////////////////////////////////////////////
module tb;
  // Define interface signals including reset
  logic reset;
  
  // Instantiate interface
  spi_i vif();
  
  // Connect reset signal in the testbench to vif.rst
  assign vif.rst = reset;
  
  // Instantiate DUT
  spi_mem dut (.clk(vif.clk), .rst(vif.rst), .cs(vif.cs), .miso(vif.miso), .ready(vif.ready), .mosi(vif.mosi), .op_done(vif.op_done));
  
  // Implement reset generation logic
  initial begin
    vif.clk <= 0;
    
    // Assert reset
    reset <= 1'b1;
    #100ns; // Hold reset for 100 ns
    // Deassert reset
    reset <= 1'b0;
  end
  
  // Toggle clock
  always #10 vif.clk <= ~vif.clk;
 
  // Configure virtual interface and run test
  initial begin
    // Set virtual interface in the configuration database
    uvm_config_db#(virtual spi_i)::set(null, "*", "vif", vif);
    
    // Run the test
    run_test("test");
  end
endmodule
