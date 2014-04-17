//+------------------------------------------------------------------+
//|                                        quoteCollector-0.1.4.mq4  |
//|                                    Aleksander Rezen argoden 2014 |
//|                                        http://www.argoden.com    |
//+------------------------------------------------------------------+
#property copyright "Aleksander Rezen"
#property link      "http://www.argoden.com"

int    Tick = 0;
int    fileHandle;
string fyleNameExt = ".quote";

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{

    string fyleName; 

fyleName   = getFileName();
fileHandle = FileOpen(fyleName, FILE_CSV|FILE_READ|FILE_WRITE," ");
Tick       = getLastTick();
Print ("Logging start @ Tick=",Tick);  

return(0);
}


string getFileName() 
{
  return (StringConcatenate(Symbol(),fyleNameExt));
}


int getLastTick()
{
    string tok;
    string tmp;
    string fyleName; 
    int    rfd;
    int    fsize;
    int    pos;

fyleName = getFileName();
rfd  = FileOpen(fyleName, FILE_CSV|FILE_READ," ");
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
  if (FileIsEnding(rfd) == true)
    break;
  
  tok = FileReadString(rfd);

  if (tok == "tick=")
    {
    tmp  = FileReadString(rfd);
    Print("start Tick=",Tick);
    FileClose(rfd);
    return(StrToInteger(tmp));
    }
  }

}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{

Tick++;             
FileSeek(fileHandle,0,SEEK_END);
FileWrite(fileHandle,
          "tick=",Tick,";",
          "mdx=",GetTickCount(),";", 
          "bid="     ,Bid,";",
          "ask="     ,Ask,";",
          "datetime=",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES|TIME_SECONDS),";",
          "symbol=",Symbol(),";"
          );
FileFlush(fileHandle);
return(0);
}


//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
  Print ("Funct. deinit() triggered at exit"); 
  FileClose(fileHandle);
  return(0);
}