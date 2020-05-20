input double   Lots                    =     0.01;
input int      FastMA_Period           =     7;
input int      SlowMA_Period           =     14;
input int      Shift1                  =     0;
extern bool    UseAutoMagic            =     true;
extern int     ManualMagic             =     10000001;
extern bool    TrailAfterBreakEvenOnly =     true;

void OnTick()
  {
    string signal     = "";
    string BuyOrder   = 100;
    string SellOrder  = 200;
    int    ticket     = 0;
    
    double SlowMovingAverage      =  iMA(NULL,0,SlowMA_Period,Shift1,MODE_SMA,PRICE_CLOSE,0); //yellow
    double LastSlowMovingAverage  =  iMA(NULL,0,SlowMA_Period,Shift1,MODE_SMA,PRICE_CLOSE,1); //yellow
    double FastMovingAverage      =  iMA(NULL,0,FastMA_Period,Shift1,MODE_SMA,PRICE_CLOSE,0); //blue
    double LastFastMovingAverage  =  iMA(NULL,0,FastMA_Period,Shift1,MODE_SMA,PRICE_CLOSE,1); //blue
  
    
    if ((LastFastMovingAverage < LastSlowMovingAverage) && (FastMovingAverage > SlowMovingAverage))
      {
        signal = "Buy";
      }
          
    if ((LastFastMovingAverage > LastSlowMovingAverage) && (FastMovingAverage < SlowMovingAverage))
      {
        signal = "Sell";
      }
        
    //Open Buy Orders
    if (signal == "Buy")
      {
        // Sell the previous sell order to make orders_total = 0
        CloseSellOrder();
        Comment(signal);
      }
        
    if (signal == "Buy" && OrdersTotal() == 0)
      {
        ticket = OrderSend(Symbol(),OP_BUY,Lots,Ask,3,0,0, NULL,0,0,Green); 
      }
        
    //Close Buy Orders
    if (signal == "Sell")
      {
        // Sell the previous buy order to make orders_total = 0
        CloseBuyOrder();  
        Comment(signal);
      }
    if (signal == "Sell" && OrdersTotal() == 0) 
      {
        ticket = OrderSend(Symbol(),OP_SELL,Lots,Bid,3,0,0, NULL,0,0,Red);
      }
  
  }

//find open buy orders      
double CloseSellOrder()
  {
    int closeTicket = 0;
    for (int x = OrdersTotal(); x >= 0; x--)
      {
        //select a trade
        if (OrderSelect(x,SELECT_BY_POS) == true)
          {
            //check if trade belongs to current chart
            if (OrderSymbol() == Symbol ())
              {
                //Close the current trade order
                closeTicket = OrderClose ( OrderTicket(), OrderLots (), MarketInfo(OrderSymbol(), MODE_ASK),5, Green );
              }
          }
      }
  }

//find close orders
double CloseBuyOrder()
  {
    int closeTicket = 0;
    // go through open orders
    for (int i = OrdersTotal(); i >= 0; i--)
      {
        if (OrderSelect(i,SELECT_BY_POS) == true)
          {
            if (OrderSymbol() == Symbol ()) 
              {
                closeTicket = OrderClose ( OrderTicket(), OrderLots (), MarketInfo(OrderSymbol(), MODE_BID),5, Green );
              }
          }
      }
  }