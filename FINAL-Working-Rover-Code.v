`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module FreqCounter(

//////////////////////////////////////////////////////////////////////////////////
//INPUTS AND OUTPUTS, INTANTIATING VARIABLES
//////////////////////////////////////////////////////////////////////////////////	 
	 //Clock input from basys
	 input clock,
	 //IPS inputs
	 input IPS_left,
     input IPS_mid,
     input IPS_right,
	 //PT inputs
	 input signalleftred,
	 input signalleftblue,
	 input signalrightred,
	 input signalrightblue,	 
	 //servo outputs	 
	 output right_red,
	 output left_red,
	 //rover chasis outputs		 
	 output left_forward,
     output left_backward,
     output right_forward,
     output right_backward,
	 // sseg outputs
	 output a, b, c, d, e, f, g, //the individual LED output for the seven segment
     output [3:0]an
    );

//////////////////////////////////////////////////////////////////////////////////
    //REGISTERS, INITIAL TEMP VALUES TO BE ALTERED IN CODE
//////////////////////////////////////////////////////////////////////////////////
parameter countToR = 55000000; //50,000,000 is about 1 sec
parameter countToL = 55000000; //50,000,000 is about 1 sec
parameter Delay = 200000000;

//Set up registers
// These registers are used to set temp values, count, avg, and tie the frequency to the output
reg [15:0] right_red_freq_count;
reg [15:0] left_red_freq_count;
reg [15:0] right_blue_freq_count;
reg [15:0] left_blue_freq_count;
reg [15:0] freq_outR;
reg [15:0] freqHold0R;
reg [15:0] freqHold1R;
reg [15:0] freqHold2R;
reg [15:0] freqHold3R;
reg [15:0] freqHold4R;
reg [15:0] freqHold5R;
reg [15:0] freqHold6R;
reg [15:0] freqHold7R;
reg [15:0] freqHold8R;
reg [15:0] freqHold9R;
reg [15:0] freqHold10R;
reg [15:0] freqHold11R;
reg [15:0] freqHold12R;
reg [15:0] freqHold13R;
reg [15:0] freqHold14R;
reg [15:0] freqHold15R;

reg [15:0] freq_outL;
reg [15:0] freqHold0L;
reg [15:0] freqHold1L;
reg [15:0] freqHold2L;
reg [15:0] freqHold3L;
reg [15:0] freqHold4L;
reg [15:0] freqHold5L;
reg [15:0] freqHold6L;
reg [15:0] freqHold7L;
reg [15:0] freqHold8L;
reg [15:0] freqHold9L;
reg [15:0] freqHold10L;
reg [15:0] freqHold11L;
reg [15:0] freqHold12L;
reg [15:0] freqHold13L;
reg [15:0] freqHold14L;
reg [15:0] freqHold15L;

reg temp_right_red;
reg temp_left_red;

// counters for frequency and servos
reg [25:0] fcountR;
reg [25:0] fcountL;

reg [20:0] scounterR;
reg [20:0] scounterL;

reg [20:0] dcounter;

//servo pule widths
reg [20:0] swidthR;
reg [20:0] swidthL;

//This register is used for comparison of the signal from cycle to cycle
reg old_sig1;
reg old_sig2;
reg old_sig3;
reg old_sig4;

//this register used to debounce the incoming signal
reg [4:0] debounce_sig1;
reg [4:0] debounce_sig2;
reg [4:0] debounce_sig3;
reg [4:0] debounce_sig4;


//this register is used to keep track of different readings over time
reg [2:0] avClkR;
reg [2:0] avClkL;


reg [18:0] freqTempR;
reg [18:0] freqTempL;

// 7 segment display temp values
reg [3:0]temp_an;
reg [6:0]temp_sseg;

reg [19:0] mcounter;  
reg [19:0] mwidth;    

reg temp_left_forward;      // temporary outputs
reg temp_left_backward;      
reg temp_right_forward;
reg temp_right_backward;

reg [2:0] state;
reg [27:0] servodelaycount;
reg incflag;


/////////////////////////////////////////////////////////////////////////
    //Initializing regs to 0 to prevent float error
/////////////////////////////////////////////////////////////////////////
initial begin
	fcountR = 26'b0;
	fcountL = 26'b0;
	scounterR = 21'b0;
	scounterL = 21'b0;
	dcounter = 21'b0;
	swidthR = 21'd225000;
	swidthL = 21'd60000;
	old_sig1 = 1'b0;
	old_sig2 = 1'b0;
	old_sig3 = 1'b0;
	old_sig4 = 1'b0;
	freq_outR = 16'b0;
	freq_outL = 16'b0;
	right_red_freq_count = 16'b0;
	left_red_freq_count = 16'b0;
	right_blue_freq_count = 16'b0;
	left_blue_freq_count = 16'b0;
	avClkR = 3'b0;
	freqTempR = 19'b0;	
	freqHold0R = 16'b0;
	freqHold1R = 16'b0;
	freqHold2R = 16'b0;
	freqHold3R = 16'b0;
	freqHold4R = 16'b0;
	freqHold5R = 16'b0;
	freqHold6R = 16'b0;
	freqHold7R = 16'b0;
	freqHold8R = 16'b0;
	freqHold9R = 16'b0;
	freqHold10R = 16'b0;
	freqHold11R = 16'b0;
	freqHold12R = 16'b0;
	freqHold13R = 16'b0;
	freqHold14R = 16'b0;
	freqHold15R = 16'b0;
    avClkL = 3'b0;
    freqTempL = 19'b0;
    freqHold0L = 16'b0;
    freqHold1L = 16'b0;
    freqHold2L = 16'b0;
    freqHold3L = 16'b0;
    freqHold4L = 16'b0;
    freqHold5L = 16'b0;
    freqHold6L = 16'b0;
    freqHold7L = 16'b0;
    freqHold8L = 16'b0;
    freqHold9L = 16'b0;
    freqHold10L = 16'b0;
    freqHold11L = 16'b0;
    freqHold12L = 16'b0;
    freqHold13L = 16'b0;
    freqHold14L = 16'b0;
    freqHold15L = 16'b0;
	temp_an = 4'b0;
	debounce_sig1 = 5'b0;
	debounce_sig2 = 5'b0;
	debounce_sig3 = 5'b0;
	debounce_sig4 = 5'b0;
	temp_sseg = 0;
	mcounter = 0;
    mwidth = 0;
    temp_left_forward = 0;
    temp_left_backward = 0;
    temp_right_forward = 0;
    temp_right_backward = 0;
    state = 3'b0;
    servodelaycount = 28'b0;
    incflag = 1'b0;
end

//////////////////////////////////////////////////////////////////////////////////
    //FREQUENCY DETECTION AND AVERAGING
//////////////////////////////////////////////////////////////////////////////////
always @(posedge clock) begin
	//Increment count once per up clock edge
	fcountR = fcountR + 1;
	fcountL = fcountL + 1;
	scounterR = scounterR + 1;
	scounterL = scounterL + 1;
	dcounter = dcounter + 1;

	//shift the signal into debounce_sig up to 8 bits
	debounce_sig1[0] = signalleftred;
	debounce_sig2[0] = signalleftblue;
	debounce_sig3[0] = signalrightred;
	debounce_sig4[0] = signalrightblue;
	debounce_sig1 = debounce_sig1 << 1;
	debounce_sig2 = debounce_sig2 << 1;
	debounce_sig3 = debounce_sig3 << 1;
	debounce_sig4 = debounce_sig4 << 1;


	//If debounce_sig is filled with ones or zeros
	if ((&debounce_sig1) | (~&debounce_sig1))begin
		if ((signalleftred != old_sig1)) begin
			left_red_freq_count = left_red_freq_count +1;
		end
	end
	if ((&debounce_sig2) | (~&debounce_sig2))begin
        if ((signalleftblue != old_sig2)) begin
            left_blue_freq_count = left_blue_freq_count +1;
        end
    end	
	if ((&debounce_sig3) | (~&debounce_sig3))begin
        if ((signalrightred != old_sig3)) begin
            right_red_freq_count = right_red_freq_count +1;
        end
    end
	if ((&debounce_sig4) | (~&debounce_sig4))begin
        if ((signalrightblue != old_sig4)) begin
            right_blue_freq_count = right_blue_freq_count +1;
        end
    end        

	//When the count is at approximately 1 sec (as close as the clock will get)
	// output the shifted count and reset values counts to 0
	if (fcountR >= (countToR >> 4)) begin
		freq_outR = right_red_freq_count << 3;// >> 1;			
		freq_outR = right_blue_freq_count << 3;// >> 1;			
		fcountR = 0;
		right_red_freq_count = 0;		
		right_blue_freq_count = 0;
		avClkR = avClkR + 1;
	end
	
	case (avClkR)
            0 : freqHold0R = freq_outR;
            1 : freqHold1R = freq_outR;
            2 : freqHold2R = freq_outR;
            3 : freqHold3R = freq_outR;
            4 : freqHold4R = freq_outR;
            5 : freqHold5R = freq_outR;
            6 : freqHold6R = freq_outR;
            7 : begin
                    freqHold7R = freq_outR;
                    //Adding all frequency readings
                    freqTempR = freqHold0R + freqHold1R + freqHold2R + freqHold3R +freqHold4R + freqHold5R + freqHold6R + freqHold7R+freqHold8R + freqHold9R + freqHold10R + freqHold11R +freqHold12R + freqHold13R + freqHold14R + freqHold15R;
                 end
    
          default :;
      endcase
		
	if (fcountL >= (countToL >> 4)) begin		
		freq_outL = left_red_freq_count << 3;// >> 1;				
		freq_outL = left_blue_freq_count << 3;// >> 1;		
		fcountL = 0;		
		left_red_freq_count = 0;		
		left_blue_freq_count = 0;
		avClkL = avClkL + 1;
	end
	
    case (avClkL)
		0 : freqHold0L = freq_outL;
		1 : freqHold1L = freq_outL;
		2 : freqHold2L = freq_outL;
		3 : freqHold3L = freq_outL;
		4 : freqHold4L = freq_outL;
		5 : freqHold5L = freq_outL;
		6 : freqHold6L = freq_outL;
		7 : begin
				freqHold7L = freq_outL;
				//Adding all frequency readings
				freqTempL = freqHold0L + freqHold1L + freqHold2L + freqHold3L +freqHold4L + freqHold5L + freqHold6L + freqHold7L + freqHold8L + freqHold9L + freqHold10L + freqHold11L +freqHold12L + freqHold13L + freqHold14L + freqHold15L;
			 end

		default :;
	endcase


	//Setting up old signal for next clock pulse comparison
	old_sig1 = signalleftred;
	old_sig2 = signalleftblue;
	old_sig3 = signalrightred;
	old_sig4 = signalrightblue;



	//Holding old readings to mix with new
	freqHold8R = freqHold0R;
	freqHold9R = freqHold1R;
	freqHold10R = freqHold2R;
	freqHold11R = freqHold3R;
	freqHold12R = freqHold4R;
	freqHold13R = freqHold5R;
	freqHold14R = freqHold6R;
	freqHold15R = freqHold7R;

    freqHold8L = freqHold0L;
    freqHold9L = freqHold1L;
    freqHold10L = freqHold2L;
    freqHold11L = freqHold3L;
    freqHold12L = freqHold4L;
    freqHold13L = freqHold5L;
    freqHold14L = freqHold6L;
    freqHold15L = freqHold7L;

//////////////////////////////////////////////////////////////////////////////////
    //SHOOTING CONDITIONALS BASED ON FREQUENCY
//////////////////////////////////////////////////////////////////////////////////
    if (scounterR < swidthR) begin        
        temp_right_red <= 1;
    end
    else begin
        temp_right_red <= 0;
    end

    if (scounterL < swidthL) begin        
        temp_left_red <= 1;
    end
    else begin
        temp_left_red <= 0;
    end
// end of posedge clock begin    
end

//////////////////////////////////////////////////////////////////////////////////
    //MOVEMENT CONDITIONALS FROM IPS INPUTS
//////////////////////////////////////////////////////////////////////////////////    
    always @ (posedge clock) begin

        mcounter = mcounter + 1;  //increment counter every clock cycle

        if (IPS_left == 1 && IPS_mid == 1 && IPS_right == 0) begin              

            temp_left_backward <= 0;
            temp_right_forward <= 0;            

            if (mcounter < mwidth) begin
                temp_left_forward <= 1;
                temp_right_backward <= 1;
              end 

            else begin
                temp_left_forward <= 0;
                temp_right_backward <= 0;
              end            
        end


        if (IPS_left == 1 && IPS_mid == 0 && IPS_right == 1) begin              

            temp_left_backward <= 0;
            temp_right_backward <= 0;            

            if (mcounter < mwidth) begin
                temp_left_forward <= 1;
                temp_right_forward <= 1;
              end 

            else begin
                temp_left_forward <= 0;
                temp_right_forward <= 0;
              end            
        end

        if (IPS_left == 1 && IPS_mid == 0 && IPS_right == 0) begin              

            temp_left_backward <= 0;
            temp_right_forward <= 0;            
            temp_right_backward <= 0;

            if (mcounter < mwidth) begin
                temp_left_forward <= 1;                
              end 

            else begin
                temp_left_forward <= 0;                
              end            
        end 

        if (IPS_left == 0 && IPS_mid == 1 && IPS_right == 1) begin              

            temp_left_forward <= 0;
            temp_right_backward <= 0;            

            if (mcounter < mwidth) begin
                temp_left_backward <= 1;
                temp_right_forward <= 1;
              end 

            else begin
                temp_left_backward <= 0;
                temp_right_forward <= 0;
              end            
        end          


        if (IPS_left == 0 && IPS_mid == 0 && IPS_right == 1) begin              

            temp_left_forward <= 0;
            temp_left_backward <= 0;                        
            temp_right_backward <= 0;

            if (mcounter < mwidth) begin
                temp_right_forward <= 1;                
              end 

            else begin
                temp_right_forward <= 0;                
              end            
        end 

    //end of IPS test
    end

//////////////////////////////////////////////////////////////////////////////////
    //SETTING PULSE WIDTH FOR MOVEMENT AND SERVO
//////////////////////////////////////////////////////////////////////////////////    
    always @ (*) begin

         if (IPS_left == 0 || IPS_mid == 0 || IPS_right == 0) begin   
             //width = 20'd524075;     // 50% duty cycle
             mwidth = 20'd1048575;
              //width = 5'd15;  
         end
         else begin               
             mwidth = 20'd0;     // 0% duty cycle
         end
 
       end
       
//////////////////////////////////////////////////////////////////////////////////
     //STATE MACHINE FOR SHOOTER PINS
////////////////////////////////////////////////////////////////////////////////// 
       
       always @(posedge clock) begin
            servodelaycount = servodelaycount + 1;
            case(state)
                3'b000: begin
                    incflag = 0;
                    if (((freqTempR >> 4) >= 250)) begin
                        state = 3'b100;
                    end
                    if (((freqTempL >> 4) >= 250)) begin
                        state = 3'b101;
                    end
                end    
                3'b001: begin 
                    
                    if (incflag == 0) begin
                        swidthR = swidthR - 21'd55000;
                        incflag = 1;
                    end
                    if (servodelaycount>=Delay)begin
                        swidthL = swidthL + 21'd55000;
                        state = 3'b011;
                    end
                end
                3'b010: begin
                    
                    if (incflag == 0) begin
                        swidthL = swidthL + 21'd55000;
                        incflag = 1;
                    end
                    if (servodelaycount>=Delay)begin
                        swidthR = swidthR - 21'd55000;
                        state = 3'b011;
                    end
                end
                3'b011: begin
                    servodelaycount = 0;
                    state = 3'b000;
                end 
                3'b100: begin
                    servodelaycount = 0;
                    state = 3'b001;
                end  
                3'b101: begin
                    servodelaycount = 0;
                    state = 3'b010;
                end           
           
           
           endcase
       end
                                       
//////////////////////////////////////////////////////////////////////////////////
    //SEVEN SEGMENT DISPLAY MULTIPLEXING
//////////////////////////////////////////////////////////////////////////////////                          
always @ (*) begin      

     case(dcounter[20:19])               
               2'b00 :  //When the 2 MSB's are 00 enable the fourth display
                begin                 
                 temp_an = 4'b1110;
                  if (((freqTempR >> 4) >= 250) || ((freqTempL >> 4) >= 250)) begin
                    temp_sseg = 7'b1000110;  // displays "C"
                  end
                  else begin
                    temp_sseg = 7'b1111111;  //displays "-"
                  end
                end

              2'b01:  //When the 2 MSB's are 01 enable the third display
                begin
                temp_an = 4'b1101;
                    if ((((freqTempR >> 4) < 250) &&  ((freqTempR >> 4) > 25)) || (((freqTempL >> 4) < 250) && ((freqTempL >> 4) > 25))) begin
                        temp_sseg = 7'b0001110; // displays "F"
                    end 
                    else begin
                        temp_sseg = 7'b1111111; // displays "-"
                    end
                end 
                              
               2'b10:  //When the 2 MSB's are 10 enable the second display
                begin
                 temp_an = 4'b1011;
                 temp_sseg = 7'b1111111;   //turns off diaplay
                end

               2'b11:  //When the 2 MSB's are 11 enable the first display
                begin
                 temp_an = 4'b0111;                 
                 temp_sseg = 7'b1111111;  //turns off display
                end
    endcase

end

//////////////////////////////////////////////////////////////////////////////////
     //ASSIGNING FINAL TEMP VARIABLES
//////////////////////////////////////////////////////////////////////////////////	

  assign right_red = temp_right_red;
  assign left_red = temp_left_red;
  assign an = temp_an;
  assign {g, f, e, d, c, b, a} = temp_sseg;
  assign left_forward = temp_left_forward;
  assign left_backward = temp_left_backward;
  assign right_forward = temp_right_forward;        
  assign right_backward = temp_right_backward;

// END OF PROGRAM			
endmodule
