int OrderFlag = 0;
int Handle;
string File_Name = "Economic_Calendar.txt",
          Obj_Name,
          Currency,
          Str_DtTm,
          Importance,
          Actual,
          InfSymb;
datetime Dat_DtTm;
       
void init() {
   Alert("Время сейчас: ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES));
   
   Handle = FileOpen(File_Name,FILE_READ,";");
   if(Handle<0) {
      if(GetLastError()==4103)
         Alert("Нет файла с именем ",File_Name);
      else
         Alert("Ошибка при открытии файла ",File_Name);
      PlaySound("Bzrrr.wav");
      return;
   }
   
   while(FileIsEnding(Handle)==false) {
      Str_DtTm = FileReadString(Handle);
      Currency = FileReadString(Handle);
      Importance = FileReadString(Handle);
         
      Dat_DtTm = StrToTime(Str_DtTm);
      
      if(StringFind(Symbol(),Currency)==-1) {
            InfSymb="Не тот символ.";
      }
      else {
            InfSymb="Символ подходит.";
      }
      
      if(StringFind(Symbol(),Currency)==-1) {
            InfSymb="Не тот символ.";
      }
      else {
            
         if(TimeCurrent()<(Dat_DtTm-120)) {
         
            if((TimeCurrent()>(Dat_DtTm-10800))&&(OrderFlag==0)) { //Если текущее время в пределе от 3-ёх часов до 2 минут  до события 
                                                                      // и ордер не был поставлен
               Actual = "Актуально";
               AlertObject();
               
               OrderBuyStop();
               OrderSellStop();
               OrderFlag++;
            }
            
            else {
                     Actual = "Будет актуально";
                     AlertObject();
            }
         }
         
         else {
            Actual = "Устарело";
            AlertObject();
         }
      }
      if(FileIsEnding(Handle)==true)
         break;
   }
   PlaySound("bulk.wav");
   return;
}

void AlertObject() {
   Obj_Name = "News Line "+Str_DtTm+" "+Currency+" "+Importance+" "+InfSymb+" "+Actual;
   Alert(Obj_Name);
}

void OrderBuyStop() {

   int Dist_SL = 63;
   int Dist_TP = 210;
   double Prots = 0.02;
   string Symb = Symbol();
   double Win_Price = Ask+250*Point;
   
   while(true) {
      int Min_Dist = MarketInfo(Symb,MODE_STOPLEVEL);
      double Min_Lot = MarketInfo(Symb,MODE_MINLOT);
      double Free = AccountFreeMargin();
      double One_Lot = MarketInfo(Symb,MODE_MARGINREQUIRED);
      double Lot = MathFloor(Free*Prots/One_Lot/Min_Lot)*Min_Lot;
      
      double Price = Win_Price;
      if (NormalizeDouble(Price,Digits)<
         NormalizeDouble(Ask+Min_Dist*Point,Digits)) {
         Price = Ask+Min_Dist*Point;
         Alert("Изменена заявленая цена: Price = ", Price);
         }
         
      double SL = Price - Dist_SL*Point;
      if (Dist_SL<Min_Dist) {
         SL = Price - Min_Dist*Point;
         Alert("Увеличена дистанция SL = ",Min_Dist," pt"); 
      }
      
      double TP = Price + Dist_TP*Point;
      if (Dist_TP<Min_Dist) {
         TP = Price + Min_Dist*Point;
         Alert("Увеличена дистанция TP = ",Min_Dist," pt"); 
      }   
         
      Alert("Торговый приказ отправлен на сервер. Ожидание ответа..");
      int ticket = OrderSend(Symb, OP_BUYSTOP, Lot, Price, 0, SL, TP,NULL,0,TimeCurrent()+1800,clrYellow);
      
      if (ticket>0) {
         Alert ("Установлен ордер BuyStop",ticket);
         break;
      }
      
      int Error = GetLastError();
      
      switch(Error) {
         case 129:Alert("Неправильная цена. Пробуем ещё раз..");
            RefreshRates();
            continue;
         case 135:Alert("Цена изменилась. Пробуем ещё раз..");
            RefreshRates();
            continue;
         case 146:Alert("Подсистема торговли занята. Пробуем ещё..");
            Sleep(500);
            RefreshRates();
            continue;         
      }
      
      switch(Error) {
         case 2:Alert("Общая ошибка.");
            break;
         case 5:Alert("Старая версия клиентского терминала.");
            break;
         case 64:Alert("Счёт заблокирован.");
            break;
         case 133:Alert("Торговля запрещена");
            break;
         default: Alert("Возникла ошибка",Error);     
      }
      break;
   }
}

void OrderSellStop() {

   int Dist_SL = 63;
   int Dist_TP = 210;
   double Prots = 0.02;
   string Symb = Symbol();
   double Win_Price = Bid-250*Point;
   
   while(true) {
      int Min_Dist = MarketInfo(Symb,MODE_STOPLEVEL);
      double Min_Lot = MarketInfo(Symb,MODE_MINLOT);
      double Free = AccountFreeMargin();
      double One_Lot = MarketInfo(Symb,MODE_MARGINREQUIRED);
      double Lot = MathFloor(Free*Prots/One_Lot/Min_Lot)*Min_Lot;
      
      double Price = Win_Price;
      if (NormalizeDouble(Price,Digits)>
         NormalizeDouble(Bid-Min_Dist*Point,Digits)) {
         Price = Bid-Min_Dist*Point;
         Alert("Изменена заявленая цена: Price = ", Price);
         }
         
      double SL = Price + Dist_SL*Point;
      if (Dist_SL<Min_Dist) {
         SL = Price + Min_Dist*Point;
         Alert("Увеличена дистанция SL = ",Min_Dist," pt"); 
      }
      
      double TP = Price - Dist_TP*Point;
      if (Dist_TP<Min_Dist) {
         TP = Price - Min_Dist*Point;
         Alert("Увеличена дистанция TP = ",Min_Dist," pt"); 
      }   
         
      Alert("Торговый приказ отправлен на сервер. Ожидание ответа..");
      int ticket = OrderSend(Symb, OP_SELLSTOP, Lot, Price, 0, SL, TP,NULL,0,TimeCurrent()+1800,clrYellow);
      
      if (ticket>0) {
         Alert ("Установлен ордер SellStop",ticket);
         break;
      }
      
      int Error = GetLastError();
      
      switch(Error) {
         case 129:Alert("Неправильная цена. Пробуем ещё раз..");
            RefreshRates();
            continue;
         case 135:Alert("Цена изменилась. Пробуем ещё раз..");
            RefreshRates();
            continue;
         case 146:Alert("Подсистема торговли занята. Пробуем ещё..");
            Sleep(500);
            RefreshRates();
            continue;         
      }
      
      switch(Error) {
         case 2:Alert("Общая ошибка.");
            break;
         case 5:Alert("Старая версия клиентского терминала.");
            break;
         case 64:Alert("Счёт заблокирован.");
            break;
         case 133:Alert("Торговля запрещена");
            break;
         default: Alert("Возникла ошибка",Error);     
      }
      break;
   }
}