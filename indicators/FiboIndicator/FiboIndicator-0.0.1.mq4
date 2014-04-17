//--------------------------------------------------------------------
//  
// 
//--------------------------------------------------------------------
#property indicator_chart_window                 
#property indicator_buffers 1       
#property indicator_color1 C'0x44,0xB9,0xE6'   

extern int History        = 125;  
extern color FiboColor    = C'0x44,0xB9,0xE6';    
extern color WarningColor = Black;
extern bool AllowChange   = true;
double Buf_0[];

double fiboLevel[9];

//--------------------------------------------------------------------
int init()
{
    fiboLevel[0] = 0;
    fiboLevel[1] = 0.236;
    fiboLevel[2] = 0.382;
    fiboLevel[3] = 0.500;
    fiboLevel[4] = 0.618;
    fiboLevel[5] = 0.764;
    fiboLevel[6] = 1.000;
    fiboLevel[7] = 1.382;
    fiboLevel[8] = 1.618;
//    fiboLevel[9] = 2.000;

    SetIndexBuffer(0,Buf_0);  
    ObjectCreate("StartLine", OBJ_VLINE, 0, 0, 0);
    ObjectSet("StartLine", OBJPROP_STYLE, STYLE_DOT);

    ObjectCreate("MaxLine",OBJ_HLINE,0,0,0);
  
    ObjectCreate("MinLine",OBJ_HLINE,0,0, 0);

    ObjectCreate("Fibo", OBJ_FIBO, 0, 0, 0, 0);
    ObjectSet("Fibo", OBJPROP_BACK, 1); 
    ObjectSet("Fibo", OBJPROP_LEVELSTYLE, STYLE_DOT);

    int count=ArraySize(fiboLevel);
    ObjectSet("Fibo",OBJPROP_FIBOLEVELS, count);

    for(int i=0; i<count; i++)
        {
        ObjectSet("Fibo",OBJPROP_FIRSTLEVEL+i,fiboLevel[i]);
        string lbl=DoubleToStr((fiboLevel[i] * 100), 1);
        ObjectSetFiboDescription("Fibo",i,lbl);
        } 
  
    return(0);                       
}
//--------------------------------------------------------------------
int deinit()
{
    ObjectDelete("Fibo");
    ObjectDelete("MaxLine");
    ObjectDelete("MinLine"); 
    ObjectDelete("StartLine");

    return(0);    
}
//--------------------------------------------------------------------
int start() 
{ 
    int Counted_bars;
    Counted_bars=IndicatorCounted();  
 
    int maxBar, minBar;                
    double minPrice, maxPrice;

    maxBar =ArrayMaximum(High,History,0);  // Bar index of max. price 
    minBar =ArrayMinimum(Low, History,0);  // Bar index of min. price                   
  
    minPrice = Low[minBar];                             
    maxPrice = High[maxBar];  
    
    if (Counted_bars > 0) 
        {
        moveStartLine();
        moveHorizontalChannel(minPrice, maxPrice);    
        moveFiboChanel(minBar, maxBar, minPrice, maxPrice);
           
        if ((minBar == 0) || (minBar == 0 )) 
            {
            if (AllowChange == true) 
                {
                ObjectSet("Fibo", OBJPROP_LEVELCOLOR,  WarningColor);
                ObjectSet("MaxLine", OBJPROP_COLOR,  WarningColor);
                ObjectSet("MinLine", OBJPROP_COLOR,  WarningColor); 
                ObjectSet("StartLine", OBJPROP_COLOR, WarningColor);
                }
            } 
        else 
            {
            ObjectSet("Fibo", OBJPROP_LEVELCOLOR, FiboColor);
            ObjectSet("MaxLine", OBJPROP_COLOR, FiboColor);
            ObjectSet("MinLine", OBJPROP_COLOR, FiboColor);
            ObjectSet("StartLine", OBJPROP_COLOR, FiboColor); 
            } 
        
        WindowRedraw(); 
        }

    return(0);    
}
//--------------------------------------------------------------------
//--------------------------------------------------------------------
int moveFiboChanel (int minBar, int maxBar, double minPrice, double maxPrice) 
{
    if (minBar > maxBar) 
        {   
        ObjectSet("Fibo", OBJPROP_PRICE1, maxPrice);   
        ObjectSet("Fibo", OBJPROP_PRICE2, minPrice);
        ObjectSet("Fibo", OBJPROP_TIME1, Time[maxBar]);
        ObjectSet("Fibo", OBJPROP_TIME2, Time[minBar]);
        } 
    else 
        {
        ObjectSet("Fibo", OBJPROP_PRICE1, minPrice);   
        ObjectSet("Fibo", OBJPROP_PRICE2, maxPrice);       
        ObjectSet("Fibo", OBJPROP_TIME1, Time[minBar]);
        ObjectSet("Fibo", OBJPROP_TIME2, Time[maxBar]);
        } 

    return(0);    
}
//--------------------------------------------------------------------
int moveStartLine ()
{
    ObjectMove("StartLine", 0, Time[History], 0); 

    return(0);    
}
//--------------------------------------------------------------------
int moveHorizontalChannel (double minPrice, double maxPrice )
{
    ObjectSet("MinLine", OBJPROP_PRICE1, minPrice);
    ObjectSet("MaxLine", OBJPROP_PRICE1, maxPrice);
    
    return(0);    
}
//--------------------------------------------------------------------
// end
