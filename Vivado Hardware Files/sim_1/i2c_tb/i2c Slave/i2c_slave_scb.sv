`ifndef _I2C_SCB_S
`define _I2C_SCB_S

class i2c_slave_scb;
    //Mailbox declarations
    mailbox scb_mbx, scb_drv_mbx;
    
    logic [7:0] SLAVE_ADDR = 7'b0001000;
    bit addr_set = 1'b0, i2c_rd = 1'b0, i2c_wr = 1'b0;
    bit stop_cond, init = 1'b1;
    bit [3:0] addr_ptr = 4'b0;   
    int rd_succ = 0, rd_fail = 0; 
    string TAG = "Scoreboard";

    function new(mailbox _mbx, mailbox _drv_mbx);
        scb_mbx = _mbx;
        scb_drv_mbx = _drv_mbx;
    endfunction : new
    
    task main();
        i2c_slave_item scb_item, reg_file_item;
        $display("[%s] Starting...", TAG);
        
        //Fetch data from the driver to get the contents of the generated register file
        scb_drv_mbx.get(reg_file_item);
    
        forever begin
            //Fetch read data from the monitor 
            scb_mbx.get(scb_item);
            validate_data(scb_item, reg_file_item);
        end
    endtask : main
    
    //This task is used to validate the data read from the monitor. This is done by doing 2 things:
    // 1) When the sda line data displays we are writing, this task will make the changes that are expected
    //    to the generated register file. 
    // 2) When the sda line data displays we are reading, this task will cross-reference the data read from the 
    //    actual file with the data from the generated file to ensure it is correct
    task validate_data(input i2c_slave_item item, input i2c_slave_item item2);
         
         stop_cond = item.stop_condition;
         $display("[%s] Data rec: %0h & stop condition: %0b", TAG, item.d_in, item.stop_condition);
         
        //First monitor if the data address matches the slave address after a stop condition has been generated
        if((item.d_in[7:1] == SLAVE_ADDR) && (stop_cond || init)) begin
            $display("[%s] Stop condition followed by a slave address.", TAG);
            stop_cond = 0;
            init = 0;
            //if the sda line data displays a read set the read flags
            if(item.d_in[0]) begin
                addr_set = 0;
                i2c_rd = 1'b1;
                i2c_wr = 1'b0;
            //if the sda line displays a write, set the write flag
            end else begin
                i2c_wr = 1'b1;
                i2c_rd = 1'b0;
            end
        end        
        //If the i2c command is to read, then we need to check if the actual data read from the sda line
        //matches the data read from the generated i2c register file
        else if(i2c_rd) begin
            if(item.d_in == item2.reg_file[addr_ptr]) begin
                $display("[%s] Read Data Match! Actual: %0h Expected: %0h", TAG, item.d_in, item2.reg_file[addr_ptr]);
                rd_succ++;
            end else begin
                $fatal("[%s] Read Data MisMatch! Actual: %0h Expected: %0h", TAG, item.d_in, item2.reg_file[addr_ptr]);
                rd_fail++;
            end
            //Auto-increment the addr_ptr
            addr_ptr++;
        end        
        //If the i2c command is to write, then write the desired value into the specified register file address in the
        //generated reg_file.
        else if(i2c_wr) begin
            //if the address has been set, write the data into the data ptr
            if(addr_set) begin
                item2.reg_file[addr_ptr] = item.d_in;
                $display("[%s] Data %0h written to addr %0h", TAG, item.d_in, addr_ptr);
                addr_set = 1'b0;
            //if the address pointer has not been set, write the value into the addr variable
            end else begin
                addr_ptr = item.d_in[3:0];
                addr_set = 1'b1;
            end
        end
        
        
           
    endtask : validate_data
    
    function display_final();
        $display("**************************************");
        $display("Test Complete. Final Scoreboard: ");
        $display("Succesful Reads: %0d", rd_succ);
        $display("Failed Reads: %0d", rd_fail);
    endfunction : display_final

endclass : i2c_slave_scb

`endif //_I2C_SCB_S