`ifndef _SPI_SCB
`define _SPI_SCB

`include "spi_scoreboard.sv"

class spi_scoreboard;
    //Mailboxes for master & slave
    mailbox scb_mbx, drv_scb_mbx;
    mailbox drv_scb_mbx_s; 
    //Declare 3 transaction items - one for the master driver and master monitor & 1 fore the slave driver
    spi_trans_item drv_item, scb_item;
    spi_slave_trans_item s_drv_item;
    //Queue init w/ depth 2- this is used for verification
    bit[7:0] mosi_queue[$:2];
    //Variables used in data validation
    bit[7:0] temp_addr;
    bit wr_data = 1'b0;
    //Class Variables
    string TAG = "Scoreboard";
    int success = 0, fail = 0, num_writes = 0;       
    
    task main();
        //Init instance of the transaction Items
        scb_item = new;
        drv_item = new;
        s_drv_item = new;
        
        $display("[%s] Starting...", TAG);
        
        //Fetch data from the slave driver mailbox first & block at this point until data is ready. 
        //This will ensure the register file is initialized before proceeding
        drv_scb_mbx_s.get(s_drv_item);
        s_drv_item.print(TAG);
        
        forever begin
            //Fetch data from the driver mailbox - this will hold the data to send on the MOSI line
            drv_scb_mbx.get(drv_item);     
            //Fetch data from monitor mailbox - this will hold the data recieved on the MISO line
            scb_mbx.get(scb_item);
            $display("[%s] Transaction Complete", TAG);
            drv_item.print(TAG);               
            scb_item.print_miso(TAG);                             
            //validate the data
            write_reg_file(drv_item, scb_item, s_drv_item);
        end
        
    endtask: main
    
    function void validate_items(spi_trans_item mosi_data, spi_trans_item miso_data, spi_slave_trans_item reg_file);
        //Push the mosi data into the queue
        mosi_queue.push_front(mosi_data.mosi_dout);       
        
        //Check if the queue has 2 pieces of data - if so, this indicates that there has been two transactions
        //& we can begin comparing the data
        if(mosi_queue.size() == 2) begin
            if(reg_file.slave_reg_file[mosi_queue[1][3:0]] == miso_data.miso_din) begin
                $display("[%s] Data Match!", TAG);
                success += 1;
            end
            else begin
                $display("[%s] Data Mismatch!", TAG);
                fail += 1;
            end
            //Remove the old value form the back
            mosi_queue.pop_back();
        end
        
        if((mosi_queue[0][7] == 1) || (wr_data == 1'b1))
            mosi_queue.delete(0);        
        
    endfunction : validate_items 
    
    //This is the function that is called for validation. It is responsible for keeping track of the flow of data
    function void write_reg_file(spi_trans_item mosi_data, spi_trans_item miso_data, spi_slave_trans_item reg_file);
        //Begin by validating the MOSI data 
       validate_items(mosi_data, miso_data, reg_file);
       
       //If the wr data flag is set, change the register file stored in the transaction item - this is used to continously cross
       //check the data being read out of the actual reg file wihtout having to monitor the spi slave
        if(wr_data == 1'b1) begin
            reg_file.slave_reg_file[temp_addr[3:0]] = mosi_data.mosi_dout;
            $display("[%s] New Value: %0h Written into addr: %0h", TAG, mosi_data.mosi_dout, temp_addr[3:0]);
            wr_data = 1'b0;
            num_writes++;
        end
        else if(mosi_data.mosi_dout[7]) begin
            temp_addr = {1'b0, mosi_data.mosi_dout[6:0]};
            wr_data = 1'b1;
        end
        
    endfunction : write_reg_file
    
    //This is called from the test class at teh completion of the test
    function void display_score();
        $display("*********************************");
        $display("[%s] Final Scoreboard:", TAG);
        $display("Succesful SPI Reads: %0d, Failed SPI Reads: %0d", success, fail);
        $display("Number of Writes: %0d", num_writes);
    endfunction: display_score   

endclass : spi_scoreboard

`endif  //_SPI_SCB
