//+------------------------------------------------------------------+
//|                                                  FiboChannel.mq4 |
//|                      Copyright © 2010, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Soja & mr_orange "
#property link      "http://www.argoden.com"

  extern int    Quant_Bars    = 25;                 
  extern int    MinChSize     = 10; 
  extern int    LabelFontSize = 9;
  extern double Risk          = 0.1;


  extern double buyTakeProfitCoef = 0.764;
  extern double buyStopLossCoef   = 0.01; 
  extern double buyOpenCoef       = 0.51;


  extern double sellTakeProfitCoef = 0.382;
  extern double sellStopLossCoef   = 0.99;
  extern double sellOpenCoef       = 0.764;

  extern int MaxAllowedPos = 1;

  extern color LineColorTrue  =C'0x44,0xB9,0xE6';
  extern color LineColorFalse =C'0x00, 0x00, 0x00';

  int posCount;
  int ticket;

  int maxInd; 
  int minInd;                

  double Minimum;
  double Maximum;


  double oldMax;
  double oldMin;

  string Symb;                      
  
  string labelArray[4];
  string labelArrayRes[4];
  string errorCodeDesc[148];

  string validOrderTypes[6];
   
  double Min_Ch_Width;
           
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
  Alert("got INIT"); 
  
  Symb = Symbol();  
  

  
  validOrderTypes[0] = "OP_BUY";
  validOrderTypes[1] = "OP_SELL";
  validOrderTypes[2] = "OP_BUYLIMIT";
  
  validOrderTypes[3] = "OP_SELLLIMIT";
  validOrderTypes[4] = "OP_BUYSTOP";
  validOrderTypes[5] = "OP_SELLSTOP";
  
  
  
  
  
   

//==============================================================  
  
  labelArray[0] = "Channel ";  
  labelArray[1] = "Max Index ";
  labelArray[2] = "Min Index ";
  labelArray[3] = "Direction ";
  labelArray[4] = "Total Open ";

//==============================================================
   
  errorCodeDesc[0]   = "No error returned";
  errorCodeDesc[1]   = "No error returned, but the result is unknown";
  errorCodeDesc[2]   = "Common error";
  errorCodeDesc[3]   = "Invalid trade parameters.";
  errorCodeDesc[4]   = "Trade server is busy";
  errorCodeDesc[5]   = "Old version of the client terminal";
  errorCodeDesc[6]   = "No connection with trade server";
  errorCodeDesc[7]   = "Not enough rights";
  errorCodeDesc[8]   = "Too frequent requests";
  errorCodeDesc[9]   = "Malfunctional trade operation";

  errorCodeDesc[64]  = "Account disabled";
  errorCodeDesc[65]  = "Invalid account";

  errorCodeDesc[128] = "Trade timeout";
  errorCodeDesc[129] = "Invalid price";
  errorCodeDesc[130] = "Invalid stops";

  errorCodeDesc[131] = "Invalid trade volume";
  errorCodeDesc[132] = "Market is closed";
  errorCodeDesc[133] = "Trade is disabled";
  errorCodeDesc[134] = "Not enough money";
  errorCodeDesc[135] = "Price changed";
  errorCodeDesc[136] = "Off quotes";
  errorCodeDesc[137] = "Broker is busy";
  errorCodeDesc[138] = "Requote";
  errorCodeDesc[139] = "Order is locked";  
  
  errorCodeDesc[140] = "Long positions only allowed"; 
  errorCodeDesc[141] = "Too many requests";
 
  errorCodeDesc[145] = "Modification denied because an order is too close to market";
  errorCodeDesc[146] = "Trade context is busy"; 
  errorCodeDesc[147] = "Expirations are denied by broker";
  errorCodeDesc[148] = "The amount of opened and pending orders has reached the limit set by a broker";
  
  return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
  Alert("DEINIT");
  makeChInactive();
  return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {           
  maxInd =ArrayMaximum(High,Quant_Bars,0);// Bar index of max. price 
  minInd =ArrayMinimum(Low, Quant_Bars,0);// Bar index of min. price                
  
  Minimum = Low[minInd];                             
  Maximum = High[maxInd];          

  double twentyTree = (Maximum - Minimum) * 0.236;
         twentyTree = NormalizeDouble(twentyTree, 2);

  double twentyTreePrice = Minimum + twentyTree;
         twentyTreePrice = NormalizeDouble(twentyTreePrice, 2);

  double thirtyEight   =  (Maximum - Minimum) * 0.382;
         thirtyEight   = NormalizeDouble(thirtyEight, 2);

  double thirtyEightPrice = Minimum + thirtyEight;
         thirtyEightPrice = NormalizeDouble(thirtyEightPrice, 2);
         
  double HALF      = (Maximum - Minimum) * 0.5;
  double HalfPrice = Minimum + HALF; 
         HalfPrice = NormalizeDouble(HalfPrice, 2);

  double sixtyOne  = (Maximum - Minimum) * 0.618;
         sixtyOne  = NormalizeDouble(sixtyOne, 2);
         
  double sixtyOnePrice = Minimum + sixtyOne;
         sixtyOnePrice = NormalizeDouble(sixtyOnePrice, 2);


  double seventySix  = (Maximum - Minimum) * 0.764;
         seventySix  = NormalizeDouble(seventySix, 2);
         
  double seventySixPrice = Minimum + seventySix;    
         seventySixPrice = NormalizeDouble(seventySixPrice, 2);         


// =========== Levels =====================================

  double buyTakeProfit = genLevelVal(buyTakeProfitCoef);     
//  Print ("buyTakeProfit " + buyTakeProfit);       


  double buyStopLoss   = genLevelVal(buyStopLossCoef);        
//  Print ("buyStopLoss " + buyStopLoss);

  double buyOpen       = genLevelVal(buyOpenCoef);
//  Print ("buyOpen " + buyOpen);
     
  double sellTakeProfit = genLevelVal(sellTakeProfitCoef);
//  Print ("sellTakeProfit " + sellTakeProfit);              
  
  double sellStopLoss   = genLevelVal(sellStopLossCoef);
//  Print ("sellStopLoss " + sellStopLoss):  

  double sellOpen       = genLevelVal(sellOpenCoef);
//  Print ("sellOpen " + sellOpen);
  
// ========================================================

   
//  Print ("twentyTreePrice " + twentyTreePrice); 
//  Print ("thirtyEightPrice " + thirtyEightPrice);
//  Print ("HalfPrice " + HalfPrice);
//  Print ("sixtyOnePrice " + sixtyOnePrice);
//  Print ("seventySixPrice " + seventySixPrice);    
  
  double chWidth = Maximum - Minimum;
         chWidth = chWidth * 100;
       
                  
  int Ch_Line_Prop = STYLE_SOLID;                 

  string chWidthDSP = DoubleToStr(chWidth, 2);                            

//==============================================================
//==============================================================  
   
   labelArrayRes[0] = chWidthDSP;
   labelArrayRes[1] = maxInd;
   labelArrayRes[2] = minInd;
   labelArrayRes[3] = "SIDE";
   
   posCount =  OrdersTotal();
   labelArrayRes[4] = posCount;

  if (chWidth < MinChSize)
      {
      clearBothChannels();
      labelArrayRes[3] = "N/A";
      makeChInactive();
      }
  else
      { 
       if (maxInd < minInd)
           {
           clearBothChannels();
           genChannelUp();          
           labelArrayRes[3] = "UP";
//           openPosition();
           }
        else if (maxInd > minInd)
           {
           clearBothChannels();
           genChannelDown();
           labelArrayRes[3] = "DOWN";           
//           openPosition();
           }
        else
           {           
           makeChInactive();
           deleteDisplay();
           }
       } 

  int tmp = 0;
      
  if (Maximum != oldMax) 
      {
      oldMax = Maximum;
      Print ("New Max");
      tmp =1;
      }
      
  if (Minimum != oldMin)
      {
      oldMin = Minimum;
      Print ("New Min");
      tmp = 1;
      }      
      
      
  if ((posCount < MaxAllowedPos) && (tmp != 1))
      {
      if ((labelArrayRes[3] == "UP") && (Ask > buyOpen ))
          { 
          openPosition (OP_BUYLIMIT, buyOpen, buyTakeProfit, buyStopLoss);
          }         
      else if ((labelArrayRes[3] == "DOWN") && (Bid < sellOpen ))
          {          
          openPosition(OP_SELLLIMIT, sellOpen, sellTakeProfit, sellStopLoss);
          }
      else
          {
//          Print ("Can Not Open Position " + Ask +" | "+ Bid  + " > " + HalfPrice );
          }    
      }
  else 
      {
//      Print ("Too Many Positions ");
      }    
            
 
  if (tmp ==1)
      {
      closePending();
      tmp = 0;
      }
 
// Alert("tmp " + tmp);
 
      
  genDisplay();
  return(0);
  }

//==============================================================
int genDisplay ()
{
  string LableName = "LabelName_";
  int labelPos_Y;
  int labelPos_X;
  int i;    
      
  for (i =0; i<5; i++)
      {
      labelPos_Y = 20 + (i * 2 * LabelFontSize);
      ObjectCreate(LableName +i, OBJ_LABEL, 0, 0, 0);
      ObjectSet(LableName +i, OBJPROP_COLOR, LineColorTrue);
      ObjectSet(LableName +i, OBJPROP_BACK, 1);
      ObjectSet(LableName +i, OBJPROP_CORNER, 1);
      ObjectSet(LableName +i, OBJPROP_XDISTANCE, 10);
      ObjectSet(LableName +i, OBJPROP_YDISTANCE, labelPos_Y);
      ObjectSet(LableName +i, OBJPROP_FONTSIZE, LabelFontSize);        
      ObjectSetText(LableName +i, labelArray[i] + labelArrayRes[i]);
      }
}  
//==============================================================
int deleteDisplay ()
{
  string LableName = "LabelName_";
  string itemName;   
  int i;   
     
  for (i =0; i<5; i++)
      {
      itemName =  LableName + i;
      ObjectDelete(itemName);
      }
return;
}
//==============================================================
int makeChActive ()
{
genVLine();
genMaxLine();
genMinLine();

ObjectSet("MaxLine", OBJPROP_COLOR, LineColorTrue);
ObjectSet("MinLine", OBJPROP_COLOR, LineColorTrue);
ObjectSet("StartLine", OBJPROP_COLOR, LineColorTrue);
}
//==============================================================
int makeChInactive ()
{
genVLine();
genMaxLine();
genMinLine();

ObjectSet("MaxLine", OBJPROP_COLOR, LineColorFalse);
ObjectSet("MinLine", OBJPROP_COLOR, LineColorFalse);
ObjectSet("StartLine", OBJPROP_COLOR, LineColorFalse);

deleteFiboDown();
deleteFiboUp();

deleteDisplay ();

}
//==============================================================
int genChannelUp ()
{
genFiboUp();
genVLine();
genMaxLine();
genMinLine();
}
//==============================================================
int genChannelDown ()
{
genFiboDown();
genVLine();
genMaxLine();
genMinLine();
}
//==============================================================
int clearChannelUp ()
{
deleteFiboUp();
deleteVLine();
deleteMaxLine();
deleteMinLine();
}
//==============================================================
int clearChannelDown ()
{
deleteFiboDown();
deleteVLine();
deleteMaxLine();
deleteMinLine();
}
//==============================================================
int clearBothChannels ()
{
clearChannelUp();
clearChannelDown();
}
//==============================================================
int genFiboUp () 
{
   ObjectCreate("FiboUp", OBJ_FIBO, 0, 0, 0, 0);
    
   ObjectSet("FiboUp", OBJPROP_TIME1, Time[maxInd]);
   ObjectSet("FiboUp", OBJPROP_TIME2, Time[minInd]);
   
   ObjectSet("FiboUp", OBJPROP_PRICE1, Maximum);   
   ObjectSet("FiboUp", OBJPROP_PRICE2, Minimum);

   ObjectSet("FiboUp", OBJPROP_LEVELCOLOR, LineColorTrue);
  
   ObjectSet("FiboUp", OBJPROP_LEVELSTYLE, STYLE_DOT);
   ObjectSet("FiboUp", OBJPROP_BACK, 1); 

   // FIBO LEVELS   
   ObjectSet("FiboUp",OBJPROP_FIBOLEVELS, 9);

   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+0,0.0); 
   ObjectSetFiboDescription("FiboUp",0,"0.0");

   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+1,0.236); 
   ObjectSetFiboDescription("FiboUp",1,"23.6");

   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+2,0.382); 
   ObjectSetFiboDescription("FiboUp",2,"38.2");
 
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+3,0.500); 
   ObjectSetFiboDescription("FiboUp",3,"50.0");

   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+4,0.618); 
   ObjectSetFiboDescription("FiboUp",4,"61.8");

   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+5,0.764); 
   ObjectSetFiboDescription("FiboUp",5,"76.4");

   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+6,1.000); 
   ObjectSetFiboDescription("FiboUp", 6, "100.0");

   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+7,1.382); 
   ObjectSetFiboDescription("FiboUp", 7, "138.2");

   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+8,1.618); 
   ObjectSetFiboDescription("FiboUp", 8, "161.8");

return (0);
}

//==============================================================
int genFiboDown ()
{
   ObjectCreate("FiboDown", OBJ_FIBO, 0, 0, 0, 0);

   ObjectSet("FiboDown", OBJPROP_TIME1, Time[minInd]); 
   ObjectSet("FiboDown", OBJPROP_TIME2, Time[maxInd]);
   
   ObjectSet("FiboDown", OBJPROP_PRICE1, Minimum);   
   ObjectSet("FiboDown", OBJPROP_PRICE2, Maximum);

   ObjectSet("FiboDown", OBJPROP_LEVELCOLOR, LineColorTrue);
  
   ObjectSet("FiboDown", OBJPROP_LEVELSTYLE, STYLE_DOT);
   ObjectSet("FiboDown", OBJPROP_BACK, 1); 

   // FIBO LEVELS   
   ObjectSet("FiboDown",OBJPROP_FIBOLEVELS, 9);

   ObjectSet("FiboDown",OBJPROP_FIRSTLEVEL+0,0.0); 
   ObjectSetFiboDescription("FiboDown",0,"0.0");

   ObjectSet("FiboDown",OBJPROP_FIRSTLEVEL+1,0.236); 
   ObjectSetFiboDescription("FiboDown",1,"23.6");

   ObjectSet("FiboDown",OBJPROP_FIRSTLEVEL+2,0.382); 
   ObjectSetFiboDescription("FiboDown",2,"38.2");
 
   ObjectSet("FiboDown",OBJPROP_FIRSTLEVEL+3,0.500); 
   ObjectSetFiboDescription("FiboDown",3,"50.0");

   ObjectSet("FiboDown",OBJPROP_FIRSTLEVEL+4,0.618); 
   ObjectSetFiboDescription("FiboDown",4,"61.8");

   ObjectSet("FiboDown",OBJPROP_FIRSTLEVEL+5,0.764); 
   ObjectSetFiboDescription("FiboDown",5,"76.4");

   ObjectSet("FiboDown",OBJPROP_FIRSTLEVEL+6,1.000); 
   ObjectSetFiboDescription("FiboDown", 6, "100.0");

   ObjectSet("FiboDown",OBJPROP_FIRSTLEVEL+7,1.382); 
   ObjectSetFiboDescription("FiboDown", 7, "138.2");

   ObjectSet("FiboDown",OBJPROP_FIRSTLEVEL+8,1.618); 
   ObjectSetFiboDescription("FiboDown", 8, "161.8");


return (0);
}
//==============================================================

int deleteFiboUp ()
{
ObjectDelete("FiboUp");
return (0);
}

//==============================================================
int deleteFiboDown ()
{
ObjectDelete("FiboDown");
return (0);
}
//==============================================================
int genMaxLine ()
{
ObjectCreate("MaxLine",OBJ_HLINE,0,0, Maximum);
ObjectSet("MaxLine", OBJPROP_COLOR, LineColorTrue);
return (0);
}
//==============================================================
int genMinLine()
{
ObjectCreate("MinLine",OBJ_HLINE,0,0, Minimum);
ObjectSet("MinLine", OBJPROP_COLOR, LineColorTrue);
return (0);
}
//==============================================================
int deleteMaxLine ()
{
ObjectDelete("MaxLine");
return (0);
}
//==============================================================
int deleteMinLine ()
{
ObjectDelete("MinLine");
return (0);
}
//==============================================================
int genVLine()
{
ObjectCreate("StartLine", OBJ_VLINE, 0, Time[Quant_Bars], 0);
ObjectSet("StartLine", OBJPROP_COLOR, LineColorTrue);
ObjectSet("StartLine", OBJPROP_STYLE, STYLE_DOT);
return (0);
}
//==============================================================
int deleteVLine ()
{
ObjectDelete("StartLine");
return (0);
}
//==============================================================
int openPosition (int orderTypeIndex, double openPrice, double TP, double SL)
{        
  
//--------------------------------------------------------- 2 --                            
     
   double Min_Dist = MarketInfo(Symb,MODE_STOPLEVEL);
   double Min_Lot  = MarketInfo(Symb,MODE_MINLOT);
   double Step     = MarketInfo(Symb,MODE_LOTSTEP);
   double Free     = AccountFreeMargin();      
   double One_Lot  = MarketInfo(Symb,MODE_MARGINREQUIRED);      
   double Lot      = MathFloor(Free*Risk/One_Lot/Step)*Step;      

   Min_Dist = Min_Dist/1000;      
      
//---------------------------------------------------------- 3 --
      
  if (Lot<Min_Lot)                          
     {
      Print (" Not enough money for ", Min_Lot," lots");
      return;                               
      }
        
  if (orderTypeIndex < 3) // BUY   
      {
       if (Ask < openPrice +  Min_Dist )
          {
          openPrice = openPrice +  Min_Dist; 
          }
      }
  else                    // SELL
      {
      if ( Bid > openPrice - Min_Dist)
         {
         openPrice =  openPrice - Min_Dist;
         }        
      }                   
      
//--------------------------------------------------------- 4 --
//      if (Dist_SL<Min_Dist)                    
//        {
//         Dist_SL = Min_Dist*2;                     
//         Alert(" Increased the distance of SL = ",Dist_SL," pt");
//        }
      
//--------------------------------------------------------- 5 --
//      if (Dist_TP<Min_Dist)                    
//        {
//         Dist_TP = Min_Dist*2;                    
//         Alert(" Increased the distance of TP = ",Dist_TP," pt");
//        }
        
//      if (orderTypeIndex < 3)
//          {        
//          TP = Bid + Dist_TP*Point;   
//          }
//      else
//          {
//          TP = Ask + Dist_TP*Point;     
 //         }
      
              
//------------------------------------------------------ 6 --

  Print ("The request was sent to the server. Waiting for reply..."); 
  ticket = OrderSend(Symb, orderTypeIndex, Lot, openPrice, 5, SL, TP); 

//------------------------------------------------------ 7 --
      if (ticket>0)                         
        {  
         posCount++;
         labelArrayRes[4] = posCount;        
         return;                            
        }
//----------------------------------------------------- 8 --
      int Error=GetLastError();
      if ((Error > 0) && (Error != 146 ))
          {
          Print (errorCodeDesc[Error]);  
          Sleep(1000); 
          return;                                       
          }
return (ticket);                                      
}

//==============================================================
int getPosIndex(string posKind)
{
 int retVal;

 for (int i=0; i<6; i++) 
        {
        if ( posKind == validOrderTypes[i])
            {
//            Alert("## got Correct Type " + validOrderTypes[i]);
            retVal = i;
            }    
        } 

return (retVal);
}

//==============================================================
int closePending ()
{
 for(int i=1; i<=OrdersTotal(); i++)            // Order searching cycle     
   {      
   if (OrderSelect(i-1,SELECT_BY_POS)==true)   // If the next is available        
       {                                       // Order analysis:         
       if (OrderSymbol()!= Symb) 
       continue;                              // Symbol is not ours         
              
       int Tip=OrderType();                   // Order type                 
       if (Tip>1)                             // Pending order          
          { 
          double Price   = OrderOpenPrice();  // Order price        
          int Real_Order = Tip;               // Market order available           
          int Ticket     = OrderTicket();     // Order ticket           
          double Lot     = OrderLots();       // Amount of lots                     
          }
       }                                   
    }                                         

while(true)                                  
    {      
    if (Real_Order==-1)                     
        {         
        Alert("For ",Symb," no market orders available");         
        break;                                   
        }      

    switch(Real_Order)                          
        {         
        case 0: double Price_Cls=Bid;                       
        string Text="Buy ";                          
        break; 
                                     
        case 1: Price_Cls=Ask;                          
        Text="Sell ";                           
        }
     
     if (Ticket > 0)
          {          
          bool Ans= OrderDelete(Ticket);             
          Sleep(2000);
          }

     if (Ans==true)                              
         {         
         Alert ("Closed order ",Text," ",Ticket);    
         ticket = 0;    
         break;                    
         }      
              
     int Error=GetLastError();                
     if ((Error > 0) && (Error != 146))
         {
         Alert(errorCodeDesc[Error]);  
         break; 
         }
     }
return;
}
//==============================================================
double genLevelVal (double Coef)
{
  if (Coef > 0.99)
      {
      Coef = 0.99;
      } 
  else if (Coef < 0.01)
      {
      Coef = 0.01;
      }

  double diff   = Maximum - Minimum;
    
  double retVal = diff * Coef;  
         retVal = NormalizeDouble(retVal, 2);
         retVal = retVal + Minimum;

  
//  Print ("######################################");
//  Print ("Coef " + Coef);
//  Print ("diff " + diff);
//  Print ("retVal " + retVal);
//  Print ("######################################");


return (retVal);
}

//==============================================================
//==============================================================