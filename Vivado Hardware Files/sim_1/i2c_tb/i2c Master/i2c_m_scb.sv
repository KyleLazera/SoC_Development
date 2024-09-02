`ifndef _I2C_SCB
`define _I2C_SCB

/*
 * This class is used to produce a final "score" for the simulation. It will provide self-checking 
 * and allow the simulation to run a large number of tests only providing how many of those tests failed
 * & how many succeeded without having to analyze waveforms.
*/

class i2c_m_scb;
    //mailboxes 
    mailbox scb_mbx;        //interface with monitor
    mailbox gen_scb_mbx;    //interface with generator
    //class variables
    string TAG = "Scoreboard";
    int succ = 0, fail = 0;
    
    function new(mailbox _mbx);
        scb_mbx = _mbx;
    endfunction : new
    
    task main();
        $display("[%s] Starting...", TAG);
        
        forever begin
            //Init a transaction item
            i2c_item_m mon_item, gen_item;
            //Fetch from generator then monitor mailbox
            gen_scb_mbx.get(gen_item);
            scb_mbx.get(mon_item);
            validate_data(mon_item, gen_item);
            mon_item.print(TAG);
        end        
    endtask : main
    
    //This function cross-checks the data and is used to generate the final scoreboard.
    //Because the i2c master module always smaples the sda line (irrespective of whether it is 
    //writing or reading), the most recent data on the sda line can be accessed by reading from the
    //regiter.
    function validate_data(i2c_item_m monitor_item, i2c_item_m gen_item);
        if(monitor_item.master_out == gen_item.master_out) begin
            succ++;
            $display("[%s] Data Match!", TAG);
        end
        else begin
            fail++;
            $display("[%s] Data Mismatch!", TAG);
        end
    endfunction : validate_data
    
    function final_score();
        $display("***********************");
        $display("Testbench simulation complete.");
        $display("Succesful Transmissions: %0d", succ);
        $display("Failed Transmissions: %0d", fail);
    endfunction : final_score

endclass : i2c_m_scb


`endif //_I2C_SCB