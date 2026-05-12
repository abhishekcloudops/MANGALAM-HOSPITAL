#property copyright "BSDK BOT"
#property link      "https://example.com"
#property version   "1.00"
#property description "Swing trading EA with trend filter and fixed TP/SL"
#property icon      "BSDK_BOT.ico"
#property tester_indicator
#property tester_file
#property tester_library
#property script_show_inputs

#include <Trade\Trade.mqh>

///////////////////////
// INPUT PARAMETERS
///////////////////////
input int      InpMagicNumber      = 123456;          // Magic number
input string   InpComment          = "AI_Bot";        // Order comment
input int      InpSlippage         = 3;               // Slippage in points
input double   InpRiskPerTrade     = 2.0;             // Risk per trade in %
input double   InpMaxDailyLoss     = 5.0;             // Max daily loss in %
input double   InpMaxDrawdown      = 20.0;            // Max drawdown in %
input int      InpMaxTradesPerDay  = 5;               // Max trades per day
input int      InpMaxOpenTrades    = 3;               // Max open trades
input double   InpFixedLot         = 0.01;            // Fixed lot size if percent risk not used
input double   InpStopLossPips     = 20.0;            // SL in pips
input double   InpTakeProfit1Pips  = 30.0;            // TP1 in pips
input double   InpTakeProfit2Pips  = 60.0;            // TP2 in pips
input double   InpTakeProfit3Pips  = 100.0;           // TP3 in pips
input bool     InpCloseOpposite    = true;            // Close opposite positions
input bool     InpFridayClose      = false;           // Close all on Friday
input bool     InpTrailingEnabled  = false;           // Trailing stop
input bool     InpBreakevenEnabled = false;           // Breakeven
input bool     InpSessionLondon    = true;            // London session
input bool     InpSessionNewYork   = true;            // New York session
input int      InpSessionGMTOffset = 0;               // GMT offset
input bool     InpUsePercentRisk   = true;            // Use percent risk for lot size
input bool     InpUseFixedLot      = false;           // Use fixed lot size
input bool     InpEnableLogging    = true;            // Enable logging

///////////////////////
// GLOBAL VARIABLES
///////////////////////
CTrade trade;
int    hMA_H1 = INVALID_HANDLE;
int    hMA_H4 = INVALID_HANDLE;
datetime lastBarTime = 0;
int     tradeCountToday = 0;
double  dailyLoss = 0.0;
double  maxDrawdown = 0.0;
datetime lastResetDate = 0;

// Structure for trade information
struct TradeInfo
{
   ulong ticket;
   double entryPrice;
   double sl;
   double tp1;
   double tp2;
   double tp3;
   bool  partialClosed;
};
TradeInfo openTrades[];

// Helper function prototypes
double   CalculateLotSize();
bool     IsWithinSession();
bool     TradeAllowed();
void     ManageOpenTrades();
void     ResetDailyCounters();
double   GetCurrentATR();
double   GetCurrentSpread();

///////////////////////
// OnInit
///////////////////////
int OnInit()
{
   Print("BSDK BOT initializing...");

   // Set magic number and slippage
   trade.SetExpertMagicNumber(InpMagicNumber);
   trade.SetDeviationInPoints(InpSlippage);

   // Create indicator handles
   hMA_H1 = iMA(_Symbol, PERIOD_H1, 50, 0, MODE_EMA, PRICE_CLOSE);
   if(hMA_H1 == INVALID_HANDLE)
   {
      Print("Failed to create H1 MA handle");
      return(INIT_FAILED);
   }

   hMA_H4 = iMA(_Symbol, PERIOD_H4, 50, 0, MODE_EMA, PRICE_CLOSE);
   if(hMA_H4 == INVALID_HANDLE)
   {
      Print("Failed to create H4 MA handle");
      IndicatorRelease(hMA_H1);
      return(INIT_FAILED);
   }

   // Initialize arrays
   ArraySetAsSeries(openTrades, true);

   // Initialize daily counters
   lastResetDate = TimeCurrent();
   ResetDailyCounters();

   Print("BSDK BOT initialized successfully");
   return(INIT_SUCCEEDED);
}

///////////////////////
// OnDeinit
///////////////////////
void OnDeinit(const int reason)
{
   Print("BSDK BOT deinitializing...");

   if(hMA_H1 != INVALID_HANDLE)
      IndicatorRelease(hMA_H1);
   if(hMA_H4 != INVALID_HANDLE)
      IndicatorRelease(hMA_H4);

   Print("BSDK BOT deinitialized");
}

///////////////////////
// OnTick
///////////////////////
void OnTick()
{
   // Reset daily counters if date changed
   datetime currentDate = TimeCurrent();
   if(TimeDay(currentDate) != TimeDay(lastResetDate))
   {
      lastResetDate = currentDate;
      ResetDailyCounters();
   }

   // Check if new bar
   datetime currentBarTime = iTime(_Symbol, PERIOD_H1, 0);
   if(currentBarTime == lastBarTime)
      return; // No new bar

   lastBarTime = currentBarTime;

   // Session filter
   if(!IsWithinSession())
   {
      if(InpEnableLogging) Print("Outside trading session");
      return;
   }

   // Friday close check
   MqlDateTime dt;
   TimeToStruct(currentDate, dt);
   if(dt.day_of_week == 5 && InpFridayClose) // 5=Friday
   {
      if(InpEnableLogging) Print("Friday close: closing all positions");
      for(int i=PositionsTotal()-1; i>=0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(!PositionSelectByTicket(ticket)) continue;
         if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
         trade.PositionClose(ticket);
      }
      return;
   }

   // Manage existing trades
   ManageOpenTrades();

   // Check trade limits
   if(tradeCountToday >= InpMaxTradesPerDay)
   {
      if(InpEnableLogging) Print("Max trades per day reached");
      return;
   }
   if(openTrades.Total() >= InpMaxOpenTrades)
   {
      if(InpEnableLogging) Print("Max open trades reached");
      return;
   }

   // Read indicator values
   double maH1[], maH4[];
   ArraySetAsSeries(maH1, true);
   ArraySetAsSeries(maH4, true);

   if(CopyBuffer(hMA_H1, 0, 0, 2, maH1) <= 0 ||
      CopyBuffer(hMA_H4, 0, 0, 2, maH4) <= 0)
   {
      if(InpEnableLogging) Print("Failed to copy indicator buffers");
      return;
   }

   // Trend filter: both MAs must be in same direction
   bool trendUp = maH1[0] > maH1[1] && maH4[0] > maH4[1];
   bool trendDown = maH1[0] < maH1[1] && maH4[0] < maH4[1];

   // Spread check
   double spread = GetCurrentSpread();
   if(spread > 3 * SymbolInfoDouble(_Symbol, SYMBOL_POINT))
   {
      if(InpEnableLogging) Print("Spread too high: ", spread);
      return;
   }

   // Entry conditions
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   // Long entry
   if(trendUp && InpEnableLogging) Print("Long entry condition met");
   if(trendUp && tradeCountToday < InpMaxTradesPerDay && openTrades.Total() < InpMaxOpenTrades)
   {
      double lot = CalculateLotSize();
      double sl = ask - InpStopLossPips * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double tp1 = ask + InpTakeProfit1Pips * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double tp2 = ask + InpTakeProfit2Pips * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double tp3 = ask + InpTakeProfit3Pips * SymbolInfoDouble(_Symbol, SYMBOL_POINT);

      if(trade.Buy(lot, _Symbol, ask, sl, tp3, InpComment))
      {
         ulong ticket = trade.ResultRetInteger(TRADE_RESULT_TICKET);
         TradeInfo ti;
         ti.ticket = ticket;
         ti.entryPrice = ask;
         ti.sl = sl;
         ti.tp1 = tp1;
         ti.tp2 = tp2;
         ti.tp3 = tp3;
         ti.partialClosed = false;
         ArrayInsert(openTrades, 0, ti);
         tradeCountToday++;
         if(InpEnableLogging) Print("Opened BUY: Ticket ", ticket, " Lot ", lot);
      }
      else
      {
         if(InpEnableLogging) Print("Buy failed: ", trade.ResultRetError());
      }
   }

   // Short entry
   if(trendDown && InpEnableLogging) Print("Short entry condition met");
   if(trendDown && tradeCountToday < InpMaxTradesPerDay && openTrades.Total() < InpMaxOpenTrades)
   {
      double lot = CalculateLotSize();
      double sl = bid + InpStopLossPips * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double tp1 = bid - InpTakeProfit1Pips * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double tp2 = bid - InpTakeProfit2Pips * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double tp3 = bid - InpTakeProfit3Pips * SymbolInfoDouble(_Symbol, SYMBOL_POINT);

      if(trade.Sell(lot, _Symbol, bid, sl, tp3, InpComment))
      {
         ulong ticket = trade.ResultRetInteger(TRADE_RESULT_TICKET);
         TradeInfo ti;
         ti.ticket = ticket;
         ti.entryPrice = bid;
         ti.sl = sl;
         ti.tp1 = tp1;
         ti.tp2 = tp2;
         ti.tp3 = tp3;
         ti.partialClosed = false;
         ArrayInsert(openTrades, 0, ti);
         tradeCountToday++;
         if(InpEnableLogging) Print("Opened SELL: Ticket ", ticket, " Lot ", lot);
      }
      else
      {
         if(InpEnableLogging) Print("Sell failed: ", trade.ResultRetError());
      }
   }
}

///////////////////////
// Helper Functions
///////////////////////
double CalculateLotSize()
{
   double lot = InpFixedLot;
   if(InpUsePercentRisk)
   {
      double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      double riskAmount = accountBalance * InpRiskPerTrade / 100.0;
      double stopLossPoints = InpStopLossPips;
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double lotSize = riskAmount / (stopLossPoints * point * tickValue);
      lot = NormalizeDouble(lotSize, 2);
      if(lot < SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
         lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   }
   return lot;
}

bool IsWithinSession()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   int hour = dt.hour;
   // London: 08:00-16:00 GMT
   // New York: 13:00-21:00 GMT
   bool inLondon = InpSessionLondon && hour >= 8 && hour < 16;
   bool inNewYork = InpSessionNewYork && hour >= 13 && hour < 21;
   return inLondon || inNewYork;
}

bool TradeAllowed()
{
   // Placeholder for additional filters
   return true;
}

void ManageOpenTrades()
{
   for(int i=0; i<openTrades.Total(); i++)
   {
      TradeInfo &ti = openTrades[i];
      if(!PositionSelectByTicket(ti.ticket))
         continue;

      double currentPrice = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ?
                            SymbolInfoDouble(_Symbol, SYMBOL_BID) :
                            SymbolInfoDouble(_Symbol, SYMBOL_ASK);

      // Check for TP1 partial close
      if(!ti.partialClosed)
      {
         bool tp1Hit = false;
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
            tp1Hit = currentPrice >= ti.tp1;
         else
            tp1Hit = currentPrice <= ti.tp1;

         if(tp1Hit)
         {
            double partialLot = PositionGetDouble(POSITION_VOLUME) * 0.5;
            if(partialLot < SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
               partialLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);

            if(trade.PositionClosePartial(ti.ticket, partialLot))
            {
               ti.partialClosed = true;
               if(InpEnableLogging) Print("Partial close TP1 on ticket ", ti.ticket);
            }
            else
            {
               if(InpEnableLogging) Print("Partial close failed: ", trade.ResultRetError());
            }
         }
      }

      // Check for TP2 or TP3
      bool tpHit = false;
      if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
      {
         if(currentPrice >= ti.tp2) tpHit = true;
         else if(currentPrice >= ti.tp3) tpHit = true;
      }
      else
      {
         if(currentPrice <= ti.tp2) tpHit = true;
         else if(currentPrice <= ti.tp3) tpHit = true;
      }

      if(tpHit)
      {
         if(trade.PositionClose(ti.ticket))
         {
            if(InpEnableLogging) Print("Closed position at TP: Ticket ", ti.ticket);
            ArrayRemove(openTrades, i);
            i--; // adjust index after removal
         }
         else
         {
            if(InpEnableLogging) Print("Close failed: ", trade.ResultRetError());
         }
      }

      // Close opposite positions if enabled
      if(InpCloseOpposite)
      {
         for(int j=0; j<PositionsTotal(); j++)
         {
            ulong oppTicket = PositionGetTicket(j);
            if(oppTicket == ti.ticket) continue;
            if(!PositionSelectByTicket(oppTicket)) continue;
            if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
            if(PositionGetInteger(POSITION_TYPE) != PositionGetInteger(POSITION_TYPE))
            {
               if(trade.PositionClose(oppTicket))
               {
                  if(InpEnableLogging) Print("Closed opposite position: Ticket ", oppTicket);
               }
            }
         }
      }
   }
}

void ResetDailyCounters()
{
   tradeCountToday = 0;
   dailyLoss = 0.0;
   maxDrawdown = 0.0;
   if(InpEnableLogging) Print("Daily counters reset");
}

double GetCurrentATR()
{
   int hATR = iATR(_Symbol, PERIOD_H1, 14);
   if(hATR == INVALID_HANDLE) return 0.0;
   double atr[]; ArraySetAsSeries(atr, true);
   if(CopyBuffer(hATR, 0, 0, 2, atr) <= 0) return 0.0;
   return atr[0];
}

double GetCurrentSpread()
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   return (ask - bid) / SymbolInfoDouble(_Symbol, SYMBOL_POINT);
}