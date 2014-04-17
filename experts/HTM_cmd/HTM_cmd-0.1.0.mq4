//+------------------------------------------------------------------+
//|                                                      HTM_cmd.mq4 |
//|                        Copyright 2012, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"


extern string cmd_file="htm_cmd.csv";
extern string out_file="htm_out.csv";
extern double lotSize=0.01;

          int cmd_handle;
          int out_handle;
          
       string orderType[6]; 
  
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
  orderType[0] = "OP_BUY";
  orderType[1] = "OP_SELL";
  
  orderType[2] = "OP_BUYLIMIT";
  orderType[3] = "OP_SELLLIMIT";
  
  orderType[4] = "OP_BUYSTOP";
  orderType[5] = "OP_SELLSTOP"; 
   
  return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {  
  string msg [10];
  string out;
  string tst; 
  
  scan_dir(msg);
  
  if (ArraySize(msg) < 1) 
      {return (0);}       
  
  if ((msg[0] == "OP_BUY") || 
      (msg[0] == "OP_SELL"))
     {
     open_pos(msg);
     //out = "got OPEN msg type"; 
     }
  else if ((msg[0] == "OP_BUYLIMIT") || 
          (msg[0] == "OP_BUYSTOP")   || 
          (msg[0] == "OP_SELLLIMIT") || 
          (msg[0] == "OP_SELLSTOP"))
     {
     proccess_pending_order(msg);
     //out = "got PENDING message type"; 
     }
  else if (msg[0] == "MODIFY")
     {
     modify_order(msg);
     //out ="got MODIFY message";
     }
  else if (msg[0] == "CLOSE")
     {
     close_order(msg);
     //out ="got CLOSE message";
     }
  else if (msg[0] == "DELETE")
     {
     delete_pending(msg); 
     //out ="got DELETE message"; 
     } 
  else if (msg[0] == "GET_STATUS")
     {
     //out ="got POS STATUS message"; 
     get_status(msg);
     }
  else if (msg[0] == "ACC_STATUS")
     {
     //out ="got ACC_STATUS message"; 
     acc_status(msg);
     }
  else
     {
     out = ("POS_ID="+msg[1]+"|STATUS=ERROR|POS_TYPE="+msg[0]+"|POS_OPEN=0.00|ERROR_CODE=6002|POS_TICKET=0;");
     }    
  
  log_msg(out);  
  ArrayResize(msg, 0);

  return(0);
  }
//+------------------------------------------------------------------+
//| Custom Functions
//+------------------------------------------------------------------+
 int scan_dir(string &msg[]) {
 
 string error;
 
 cmd_handle=FileOpen(cmd_file,FILE_CSV|FILE_READ,";");
    
 if(cmd_handle<0)                        
    {
    if(GetLastError()!=4103)
        {          
        // If any other error occurs..
        error =("error| can not open cmd file | error_code = " + GetLastError());//..this message
        log_msg(error);
        }
    return;                         
    }
 
 parse_cmd_file(msg);
 FileClose(cmd_handle);
 FileDelete(cmd_file);
 }
//+------------------------------------------------------------------+
 int log_msg(string error) {

 if(StringLen(error) < 1)
      {
      return;
      }

 out_handle=FileOpen(out_file,FILE_READ|FILE_WRITE,";");
 
 if(out_handle<0) 
     {
     Print(out_file," OPEN Error: ",GetLastError());
     return(0);
     }
 else 
     {
     FileSeek(out_handle,0,SEEK_END);
     int out_line = FileWrite(out_handle,error);//Writing to the file
     
     if(out_handle==-1)                      // File opening fails
        {
        Alert("log_msg: An error while opening the file. ",// Error message
              "May be the file is busy by the other applictiom");
        PlaySound("Bzrrr.wav");          // Sound accompaniment
        return(0);                          // Exir start()      
        }
     else if(out_line < 0)                 // If failed
        {
        Alert("log msg: Error writing to the file",GetLastError());// Message
        PlaySound("Bzrrr.wav");       // Sound accompaniment
        return(0);                       // Exit start()      
        }
     }
     
 FileClose(out_handle);         // File closing
 }
//+------------------------------------------------------------------+ 
 int parse_cmd_file(string &msg[]) {
 
 string cmd = FileReadString(cmd_handle);

 //code 44 = ","
 //code 124 = "|" 

 int char[],pos;
 for(int i=0;i<StringLen(cmd);i++)
   {
   // Print ("#" + StringGetChar(cmd,i));
   if(StringGetChar(cmd,i)==124)
      {
      pos++;
      ArrayResize(char,pos);
      char[pos-1]=i;
      //Print (i);
      }
   }
 
 ArrayResize(msg,10);
 
 for(i=0;i<=pos;i++)
   {
   if(i==0)msg[0]=StringSubstr(cmd,0,char[i]);
   else if(i==pos)msg[i]=StringSubstr(cmd,char[i-1]+1);
   else msg[i]=StringSubstr(cmd,char[i-1]+1,char[i]-char[i-1]-1);
   //Print("i - ",i," str - ",stri[i]);
   }
 
 
 return(0);
 }
//+------------------------------------------------------------------+
 int display_msg (string &msg[]) {
  
 for(int i=0; i< ArraySize(msg); i++)
    {
    //Print ("|#", msg[i]);// some calculations.
    } 
 }
//+------------------------------------------------------------------+
 int checkOrderType (string cmd) {
 
 //Alert(ArraySize(orderType));

 for (int i =0; i < ArraySize(orderType); i++)
     {
     if (orderType[i] == cmd)
         {
         return(i);
         }
     }

 return (-1);
 }
//+------------------------------------------------------------------+
 void proccess_pending_order(string &msg[]) {
 
 string out;
 
 int slippage     = 3;
 double volume    = 0.1;

 string order_cmd = msg[0]; 
 int    magic     = StrToInteger(msg[1]);     
 double pos_open  = StrToDouble(msg[2]);
 double pos_tp    = StrToDouble(msg[3]);
 double pos_sl    = StrToDouble(msg[4]);
 string comment   = msg[1] +" "+ msg[5];
      
 int order_type = checkOrderType(order_cmd);
 
 if (order_type < 0)
     {
     out = ("POS_ID="+ magic +"|STATUS=ERROR|POS_TYPE="+ order_cmd +"|POS_OPEN="+pos_open+"|ERROR_CODE=6000|POS_TICKET=0;");
     msg[6] = "ERROR";           // status
     msg[7] = "6000"; // error_code
     msg[8] = "0";   // ticket
     msg[9] = "0";  // pos_pl 
     out = gen_out_msg(msg);     
     log_msg(out);
     return;
     }

 int ticket = OrderSend(Symbol(), order_type, volume, pos_open, slippage, pos_sl, pos_tp, comment, magic);
     
 if(ticket < 0)
     {
     //out = ("error="+ magic +"|msg="+ msg[0] +"|type="+ order_cmd +"|error=" + GetLastError()) + ";";
     //out = ("POS_ID="+ magic +"|STATUS=ERROR|POS_TYPE="+ order_cmd +"|POS_OPEN="+pos_open+"|ERROR_CODE=" + GetLastError()) + "|POS_TICKET=0;";
     msg[6] = "ERROR";           // status
     msg[7] = GetLastError(); // error_code
     msg[8] = 0;   // ticket
     msg[9] = 0;  // pos_pl 
     out = gen_out_msg(msg);
     }
 else
     {
     //out = "ok="+ magic +"|msg="+ msg[0]+"|type="+ order_cmd +"|comment="+ OrderComment() +"|ticket=" + ticket +";"; 
     //out = ("POS_ID="+ magic +"|STATUS=OK|POS_TYPE="+ order_cmd +"|POS_OPEN="+pos_open+"|ERROR_CODE=" + GetLastError()) + "|POS_TICKET=" + OrderTicket() +";";
     msg[6] = "OK";           // status
     msg[7] = GetLastError(); // error_code
     msg[8] = ticket;         // ticket
     msg[9] = 0;  // pos_pl
     out = gen_out_msg(msg); 
     }  
     
 //out = gen_out_msg(msg);     
 log_msg(out); 
 }
//+------------------------------------------------------------------+
 void delete_pending (string &msg[]) {
 
 string order_cmd = msg[0];
 int    magic     = StrToInteger(msg[1]);     
 double pos_open  = StrToDouble(msg[2]);
 double pos_tp    = StrToDouble(msg[3]);
 double pos_sl    = StrToDouble(msg[4]);
 string comment   = msg[1] +" "+ msg[5];

 string out;
 
 for(int pos = OrdersTotal() - 1; pos >= 0 ; pos --)  
   {
   if(! OrderSelect(pos, SELECT_BY_POS, MODE_TRADES)) continue;   
       {
       if(OrderMagicNumber() == magic)  
           {
           if (OrderDelete(OrderTicket())== true)
               {
               //out = "ok=" + magic_numb + "|msg=" + msg[0] +"|type="+ orderType[OrderType()] +"|comment="+ OrderComment() +"|ticket=" + OrderTicket() +";";
               //out = ("POS_ID="+ magic +"|STATUS=OK|POS_TYPE="+ order_cmd +"|POS_OPEN="+pos_open+"|ERROR_CODE=" + GetLastError()) + "|POS_TICKET=" + OrderTicket() +";"; 
               msg[6] = "OK";           // status
               msg[7] = GetLastError(); // error_code
               msg[8] = OrderTicket();   // ticket
               msg[9] = OrderProfit();  // pos_pl 
               out = gen_out_msg(msg);
               }
           else
               {
               //out = "error="+ magic_numb + "|msg=" + msg[0] +"|type="+ orderType[OrderType()] +"|comment="+ OrderComment() +"|ticket=" + OrderTicket() +";";
               //out = ("POS_ID="+ magic +"|STATUS=ERROR|POS_TYPE="+ order_cmd +"|POS_OPEN="+pos_open+"|ERROR_CODE=" + GetLastError()) + "|POS_TICKET=0;";
               msg[6] = "ERROR";           // status
               msg[7] = GetLastError(); // error_code
               msg[8] = "0";   // ticket
               msg[9] = OrderProfit();  // pos_pl 
               out = gen_out_msg(msg);
               }             
           }
  
        }
    }
  
  
   if(StringLen(out) < 1)
     {
     //out ="error=" + magic + "|msg="+ msg[0] +"|order not found;";
     //out = ("POS_ID="+ magic +"|STATUS=ERROR|POS_TYPE="+ order_cmd +"|POS_OPEN="+pos_open+"|ERROR_CODE=6000|POS_TICKET=0;");
     msg[6] = "ERROR";           // status
     msg[7] = "6000"; // error_code
     msg[8] = "0";   // ticket
     msg[9] = "0"; // pos_pl 
     out = gen_out_msg(msg);
     }     
    
 //out = gen_out_msg(msg);
 log_msg(out);
 return(0);
 }
//+------------------------------------------------------------------+

 int modify_order (string &msg[]) {

 string order_cmd = msg[0];
 int    magic     = StrToInteger(msg[1]);     
 double pos_open  = StrToDouble(msg[2]);
 double pos_tp    = StrToDouble(msg[3]);
 double pos_sl    = StrToDouble(msg[4]);
 string comment   = msg[1] +" "+ msg[5];
 string out;

 for(int pos =  OrdersTotal() - 1; pos >= 0 ; pos --)  
   {
   if(! OrderSelect(pos, SELECT_BY_POS, MODE_TRADES)) continue;   
       {
       if(OrderMagicNumber() == magic)  
           {
           if (OrderModify(OrderTicket(),OrderOpenPrice(),pos_sl,pos_tp,0) == true)
               { 
               //out ="ok=" + magic_numb + "|msg=" + msg[0] + "|tp=" + tp + "|sl=" + sl +"|comment="+ OrderComment() +"|ticket=" + OrderTicket() + ";"; 
               //out = ("POS_ID="+ magic +"|STATUS=OK|POS_TYPE="+ order_cmd +"|POS_OPEN="+pos_open+"|ERROR_CODE=" + GetLastError() + "|POS_TICKET=" + OrderTicket() +";");
               msg[6] = "OK";           // status
               msg[7] = GetLastError(); // error_code
               msg[8] = OrderTicket();   // ticket
               msg[9] = OrderProfit();  // pos_pl 
               out = gen_out_msg(msg);
               }
           else
               {
               //out ="error=" + magic_numb + "|msg=" + msg[0]+ "|comment="+ OrderComment()+"|ticket=" + OrderTicket() + ";";
               //out = ("POS_ID="+ magic +"|STATUS=ERROR|POS_TYPE="+ order_cmd +"|POS_OPEN="+pos_open+"|ERROR_CODE=" + GetLastError() + "|POS_TICKET=0;");
               msg[6] = "ERROR";           // status
               msg[7] = GetLastError(); // error_code
               msg[8] = "0";   // ticket
               msg[9] = OrderProfit();  // pos_pl 
               out = gen_out_msg(msg);
               }    
           }
           
       }
    }

 if(StringLen(out) < 1)
     {
     //out ="error=" + magic + "|msg="+ msg[0] +"|order not found;";
     //out = ("POS_ID="+ magic +"|STATUS=ERROR|POS_TYPE="+ order_cmd +"|POS_OPEN="+pos_open+"|ERROR_CODE=6000|POS_TICKET=0;");
     msg[6] = "ERROR";           // status
     msg[7] = "6000"; // error_code
     msg[8] = "0";   // ticket
     msg[9] = OrderProfit();  // pos_pl 
     out = gen_out_msg(msg);
     }
     
 log_msg(out);
 return(0);
 }
//+------------------------------------------------------------------+
 int close_order (string &msg[]) {

 double Slippage  = 3;

 int    magic     = StrToInteger(msg[1]);     
 string order_cmd = msg[2];
 double pos_open  = StrToDouble(msg[3]);
 double pos_tp    = StrToDouble(msg[4]);
 double pos_sl    = StrToDouble(msg[5]);
 string comment   = msg[1] +" "+ msg[6];
 string out;
 
 for(int pos = OrdersTotal()- 1; pos >= 0 ; pos --)  //  <-- for loop to loop through all Orders . .   COUNT DOWN TO ZERO !
   {
   if( ! OrderSelect(pos, SELECT_BY_POS, MODE_TRADES) ) continue;   // <-- if the OrderSelect fails advance the loop to the next PositionIndex
     {
     if( OrderMagicNumber() == magic       // <-- does the Order's Magic Number match our EA's magic number ? 
        && OrderSymbol() == Symbol()         // <-- does the Order's Symbol match the Symbol our EA is working on ? 
        && ( OrderType() == OP_BUY           // <-- is the Order a Buy Order ? 
        ||   OrderType() == OP_SELL ) )      // <-- or is it a Sell Order ?
        {
        if (OrderClose( OrderTicket(), OrderLots(), OrderClosePrice(), Slippage)== true ) 
            {             
            msg[6] = "OK";           // status
            msg[7] = GetLastError(); // error_code
            msg[8] = OrderTicket();   // ticket
            msg[9] = OrderProfit();  // pos_pl 
            out = gen_out_msg(msg);
            }
        else
            {
            msg[6] = "ERROR";        // status
            msg[7] = GetLastError(); // error_code
            msg[8] = OrderTicket();  // ticket
            msg[9] = OrderProfit();  // pos_pl             
            out = gen_out_msg(msg);
            }     
        }  
     }
    
   }
    
 if(StringLen(out) < 1)
   {
   msg[6] = "ERROR";        // status
   msg[7] = "6000";         // error_code
   msg[8] = "0";            // ticket
   msg[9] = OrderProfit();  // pos_pl                
   out = gen_out_msg(msg);        
   }
   
log_msg(out);
return(0);
}
//+------------------------------------------------------------------+
int open_pos (string &msg[]) {

 string out;
 int slippage     = 3;

 string order_cmd = msg[0]; 
 int    magic     = StrToInteger(msg[1]);     
 double pos_open  = StrToDouble(msg[2]);
 double pos_tp    = StrToDouble(msg[3]);
 double pos_sl    = StrToDouble(msg[4]);
 string comment   = msg[1] + " " +msg[5];

 //Alert(order_cmd);  
      
 int order_type = checkOrderType(order_cmd);
     
 if (order_type == 0)
     {
     pos_open = Ask; 
     }       
 else if (order_type == 1)
     {
     pos_open = Bid;
     }
 else
     {
     msg[6] = "ERROR";      // status
     msg[7] = "6000";       // error_code
     msg[8] = "0";          // ticket
     msg[9] = "0";          // pos_pl

     out = gen_out_msg(msg);
     log_msg(out);
     return;
     }     

 int ticket = OrderSend(Symbol(), order_type, lotSize, pos_open, slippage, pos_sl, pos_tp, comment, magic);
     
 if(ticket < 0)
     {
     msg[6] = "ERROR";           // status
     msg[7] = GetLastError(); // error_code
     msg[8] = ticket;         // ticket
     msg[9] = OrderProfit();  // pos_pl
     out = gen_out_msg(msg);
     }
 else
     {
     msg[6] = "OK";           // status
     msg[7] = GetLastError(); // error_code
     msg[8] = ticket;         // ticket
     msg[9] = OrderProfit();  // pos_pl
     out = gen_out_msg(msg);
     }  
     
 log_msg(out); 
}
//+------------------------------------------------------------------+
 int get_status (string &msg[]) {
 
 // message format
 // cmd|magic_numb
 // POS_STATUS|722
 
 //ArrayResize(msg, 10);
 
 string order_cmd = msg[0]; 
 int    magic     = StrToInteger(msg[1]);     
 double pos_open  = StrToDouble(msg[2]);
 double pos_tp    = StrToDouble(msg[3]);
 double pos_sl    = StrToDouble(msg[4]);
 string comment   = msg[1] + " " +msg[5];
 string status;
 
 string out;
   
 int i,hstTotal  = OrdersHistoryTotal();
 for(i=0;i<hstTotal;i++)
    {
    if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
       {
       //out = "error|Access to history failed with error (" + GetLastError()+");";
       //out = ("POS_ID="+ magic +"|STATUS=ERROR|ERROR_CODE=6001|POS_TICKET=0;");
       msg[6] = "ERROR";           // status
       msg[7] = "6001"; // error_code
       msg[8] = "0";         // ticket
       msg[9] = "0";  // pos_pl
       out = gen_out_msg(msg);         
       break;
       }
     
    if(OrderMagicNumber() == magic)  
        {
        // out = ("POS_ID="+ magic +"|STATUS=HISTORY|POS_TYPE="+ OrderType() +"|POS_OPEN="+OrderProfit()+"|ERROR_CODE=" + GetLastError()) + "|POS_TICKET=" + OrderTicket() +";";        
        msg[6] = "HISTORY";      // status
        msg[2] = OrderOpenPrice();
        msg[3] = OrderTakeProfit();
        msg[4] = OrderStopLoss();
        msg[5] = OrderComment();
        msg[7] = 0; // error_code
        msg[8] = OrderTicket();  // ticket
        msg[9] = OrderProfit();  // pos_pl                              
        out = gen_out_msg(msg);         
        log_msg(out);
        return;
        }  
    } 
    
 if(StringLen(out) < 1)
   {
   for(int pos =  OrdersTotal() - 1; pos >= 0 ; pos --)  
       {
       if(! OrderSelect(pos, SELECT_BY_POS, MODE_TRADES)) continue;   
           {
           if(OrderMagicNumber() == magic)  
               {
               //Alert("orderType " + OrderType());
               
               if (OrderType() < 1 )
                   {
                   msg[6] = "LIVE"; 
                   } 
               else
                   {
                   msg[6] = "PENDING";  
                   }
               //out = ("POS_ID="+ magic +"|STATUS=LIVE|CMD="+ order_cmd +"|POS_OPEN="+OrderProfit()+"|ERROR_CODE=" + GetLastError()) + "|POS_TICKET=" + OrderTicket() +";";
               //msg[6] = "LIVE";      // status
               msg[2] = OrderOpenPrice();
               msg[3] = OrderTakeProfit();
               msg[4] = OrderStopLoss();
               msg[5] = orderType[OrderType()] +" "+ OrderComment();
               msg[7] = 0; // error_code
               msg[8] = OrderTicket();  // ticket
               msg[9] = OrderProfit();  // pos_pl                              
               out = gen_out_msg(msg);         
               log_msg(out);
               return;
               }
           }
        }
    }
    
 if(StringLen(out) < 1)
     {
     // out ="error=" + magic_numb + "|msg="+ msg[0] +"|order not found;";
     //out = ("POS_ID="+ magic +"|STATUS=ERROR|POS_TYPE="+ order_cmd +"|POS_OPEN="+pos_open+"|ERROR_CODE=6000|POS_TICKET=0;");
     msg[6] = "ERROR";     // status
     msg[2] = 0;
     msg[3] = 0;
     msg[4] = 0;
     msg[7] = "6000";      // error_code
     msg[8] = "0";         // ticket
     msg[9] = "0";         // pos_pl
     out = gen_out_msg(msg);
     }   
    
 log_msg(out);      
 }

//+------------------------------------------------------------------+
 int acc_status(string &msg[]){

 string out;
 
 out ="account_number="+ AccountNumber() +"|isDemo="+ IsDemo()+"|balance=" +AccountBalance()+ "|equaty="+AccountEquity()+"|umargin="+AccountMargin()+";";

 log_msg(out);

 return(0); 
 }
//+------------------------------------------------------------------+
 string gen_out_msg (string &msg[]){ 
 string out;
 
 string cmd        = msg[0];
 string pos_id     = msg[1];
 string pos_open   = msg[2]; 
 string pos_tp     = msg[3];
 string pos_sl     = msg[4];
 string comment    = msg[5];
 string status     = msg[6]; 
 string error_code = msg[7];
 string ticket     = msg[8];
 string pos_pl     = msg[9];
 
 out = "POS_ID="+pos_id+"|";
 out = out + "STATUS="+status+"|";
 out = out + "CMD="+cmd+"|";
 out = out + "POS_OPEN="+pos_open+"|";
 out = out + "POS_TP="+pos_tp+"|";
 out = out + "POS_SL="+pos_sl+"|";
 out = out + "POS_PL="+pos_pl+"|";
 out = out + "ERROR_CODE="+error_code+"|";
 out = out + "POS_TICKET="+ticket+"|";
 out = out + "POS_COMM="+comment+"|";  
 
 return (out);
 }
//+------------------------------------------------------------------+








