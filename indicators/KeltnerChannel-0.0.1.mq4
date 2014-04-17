//+------------------------------------------------------------------+
//|                                           Keltner ATR Bands .mq4 |
//|                                     This is not Keltner Channels |
//|                                                                  |
//|                                        Converted by : Dr. Gaines |
//|                                      dr_richard_gaines@yahoo.com |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright " Copyright © 2005, MetaQuotes Software Corp."
#property link      " http://www.metaquotes.net/"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Aquamarine
#property indicator_color2 Aquamarine
#include <stdlib.mqh>
//+------------------------------------------------------------------+
//| Common External variables                                        |
//+------------------------------------------------------------------+
extern double MAPeriod=50;
extern double ATRMult=1.9;
//+------------------------------------------------------------------+
//| Special Convertion Functions                                     |
//+------------------------------------------------------------------+
int LastTradeTime;
double ExtHistoBuffer[];
double ExtHistoBuffer2[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetLoopCount(int loops)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetIndexValue(int shift, double value)
  {
   ExtHistoBuffer[shift]=value;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetIndexValue2(int shift, double value)
  {
   ExtHistoBuffer2[shift]=value;
  }
//+------------------------------------------------------------------+
//| End                                                              |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(0, ExtHistoBuffer);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(1, ExtHistoBuffer2);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
//+------------------------------------------------------------------+
//| Local variables                                                  |
//+------------------------------------------------------------------+
   int shift=0;
   double ma=0;
   double atr=0;
   double KU=0;
   double KL=0;
/*[[
    Name := Keltner ATR Bands
    Author := Copyright © 2005, MetaQuotes Software Corp.
    Link := http://www.metaquotes.net/
    Separate Window := No
    First Color := White
    First Draw Type := Line
    First Symbol := 217
    Use Second Data := Yes
    Second Color := White
    Second Draw Type := Line
    Second Symbol := 218
]]*/
   SetLoopCount(0);
   // loop from first bar to current bar (with shift=0)
     for(shift=Bars-1;shift>=0 ;shift--){
      ma=iMA(NULL, 0, MAPeriod, 0,  MODE_SMA, PRICE_CLOSE,  shift);
      atr=iATR(NULL, 0, MAPeriod, shift);
      KU=ma + ATRMult*atr;
      KL=ma - ATRMult*atr;
      SetIndexValue(shift, KU);
      SetIndexValue2(shift, KL);
     }
   return(0);
  }
//+------------------------------------------------------------------+