//+------------------------------------------------------------------+
//|                                                tst_toms_junk.mq4 |
//|                         Thomas Peterson Copyright 2009 Cygni LLC |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Thomas Peterson Copyright 2009 Cygni LLC"
#property link      "http://www.metaquotes.net"

//int      Tick = 5238355;
int      Tick = 5381500;

string   QUOTE_OUTFILE = "quote_output.dat";
string   BAR_OUTFILE   = "bar_output.dat";
int      fd;
int      fd2;
datetime last_time;
bool     New_Bar = false;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
    int ind;
    string tstr;

Alert ("Funct. init() triggered at start");  // Alert

fd  = FileOpen(QUOTE_OUTFILE, FILE_WRITE," ");

fd2 = FileOpen(BAR_OUTFILE,   FILE_WRITE," ");



return;
}


//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
    double Price = Bid;
    string   tstr = TimeToStr(TimeCurrent(),
                              TIME_DATE|TIME_MINUTES|TIME_SECONDS);

Tick++;                                     // Ticks counter
//Alert ("Tick ",Tick," bid=",Bid," ask=", Ask );  // Alert
FileWrite(fd,
          "tick=",Tick,";",
          "datetime=",tstr,";",
          "bid="     ,Bid,";",
          "ask="     ,Ask,";",
          "digits="  ,Digits,";"
          );
FileFlush(fd);

Fun_New_Bar();
if (New_Bar == false)
    return;

tstr = TimeToStr(Time[1], TIME_DATE|TIME_MINUTES|TIME_SECONDS);
FileWrite(fd2,
        "time=",   tstr,     ";",
        "open=",   Open[1],  ";",
        "close=",  Close[1], ";",
        "high=",   High[1],  ";",
        "low=",    Low[1],   ";",
        "Volume=", Volume[1],";"
         );
FileFlush(fd2);

return;
}



void Fun_New_Bar()
{
    static datetime New_Time=0;

New_Bar = false;
if (New_Time != Time[0])
    {
    New_Time = Time[0];
    New_Bar  = true;
    }
}




//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
  Alert ("Funct. deinit() triggered at exit"); // Exit deinit()
  FileClose(fd);
  return;
  }



