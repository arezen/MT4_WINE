//--------------------------------------------------------------------
// 
//
//--------------------------------------------------------------------
#property indicator_chart_window                 
#property indicator_buffers 1 

extern int   Len_Cn=70;            
extern color Col_Cn=Orange;        

double Buf_0[];

//--------------------------------------------------------------- 1 --
int init()                          
  {
   SetIndexBuffer(0,Buf_0);  
   Create();                        
   return;                          
  }
//--------------------------------------------------------------- 2 --
int start()                       
  {
   datetime T2;                      
   int Error;                        
//--------------------------------------------------------------- 3 --   
   T2=ObjectGet("Obj_Reg_Ch",OBJPROP_TIME2);
   Error=GetLastError();              
   if (Error==4202)                   
     {
      Alert("Object can not be created");
      Create();                       
      T2=Time[0];                      
     }
//--------------------------------------------------------------- 4 --
   if (T2!=Time[0])               
     {
      ObjectMove("Obj_Reg_Ch", 0, Time[Len_Cn-1],0); 
      ObjectMove("Obj_Reg_Ch", 1, Time[0],       0); 
      WindowRedraw();               
     }
   return;                          
  }
//--------------------------------------------------------------- 5 --
int deinit()                       
  {
   ObjectDelete("Obj_Reg_Ch");      
   return;                          
  }
//--------------------------------------------------------------- 6 --
int Create()                         
  {
   datetime T1=Time[Len_Cn-1];                                    
   datetime T2=Time[0];             
   ObjectCreate("Obj_Reg_Ch",OBJ_REGRESSION,0,T1,0,T2,0);
   ObjectSet(   "Obj_Reg_Ch", OBJPROP_COLOR, Col_Cn);    
   ObjectSet(   "Obj_Reg_Ch", OBJPROP_RAY,   false);     
   ObjectSet(   "Obj_Reg_Ch", OBJPROP_STYLE, STYLE_DASH);
   ObjectSetText("Obj_Reg_Ch","Whooo -- haaa ",10);
   WindowRedraw();                    
  }
//--------------------------------------------------------------- 7 --
