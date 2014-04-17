
//+------------------------------------------------------------------+
//|                                                tst_toms_junk.mq4 |
//|                         Thomas Peterson Copyright 2009 Cygni LLC |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Thomas Peterson Copyright 2009 Cygni LLC"
#property link      "http://www.metaquotes.net"

//int      Tick = 10512806;
//int      Tick = 10597198;
int      Tick = 0;

extern string   QUOTE_OUTFILE = "/ea_quote_out/quote_output.dat";
int      fd;


//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{

fd  = FileOpen(QUOTE_OUTFILE, FILE_CSV|FILE_READ|FILE_WRITE," ");
last_tick();

Alert ("Funct. init() triggered at start Tick=",Tick);  // Alert
return;
}


int last_tick()
{
    string tok;
    string tmp;
    int    rfd;
    int    fsize;
    int    pos;

rfd  = FileOpen(QUOTE_OUTFILE, FILE_CSV|FILE_READ," ");
fsize = FileSize(rfd);

if (fsize > 1024)
    {
    pos = fsize - 512;
    }
else
    {
    pos = 0;
    }

FileSeek(rfd, pos, SEEK_SET);

while (FileIsEnding(rfd) == false)
    {
    tok = FileReadString(rfd);
    
    if (tok == "tick=")
        {
        tmp  = FileReadString(rfd);
        Tick = StrToInteger(tmp);
        //Alert("Tick=",Tick);
        }


    if (FileIsEnding(rfd) == true)
        break;
    }

Alert("cur Tick=",Tick);
FileClose(rfd);
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
FileSeek(fd,0,SEEK_END);
FileWrite(fd, 
          "tick=",Tick,";",
          "datetime=",tstr,";",
          "bid="     ,Bid,";", 
          "ask="     ,Ask,";",
          "digits="  ,Digits,";"
          );
FileFlush(fd);

return;
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



