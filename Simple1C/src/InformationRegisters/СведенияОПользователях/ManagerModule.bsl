///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

// Для форм элементов справочников Пользователи и ВнешниеПользователи.
//
// Параметры:
//  Форма - ФормаКлиентскогоПриложения:
//    * Объект - СправочникОбъект.Пользователи
//             - СправочникОбъект.ВнешниеПользователи
//
Процедура ПрочитатьСведенияОПользователе(Форма) Экспорт
	
	Если ОбщегоНазначения.РазделениеВключено() Тогда
		Возврат;
	КонецЕсли;
	
	Пользователь = Форма.Объект.Ссылка;
	
	Если Не ЗначениеЗаполнено(Пользователь) Тогда
		Возврат;
	КонецЕсли;
	
	УровеньДоступа = ПользователиСлужебный.УровеньДоступаКСвойствамПользователя(Форма.Объект);
	
	НаборЗаписей = РегистрыСведений.СведенияОПользователях.СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Пользователь.Установить(Пользователь);
	НаборЗаписей.Прочитать();
	
	Форма.ПотребоватьСменуПароляПриВходе             = Ложь;
	Форма.СрокДействияНеОграничен                    = Ложь;
	Форма.СрокДействия                               = Неопределено;
	Форма.ПросрочкаРаботыВПрограммеДоЗапрещенияВхода = 0;
	
	Если НаборЗаписей.Количество() > 0 Тогда
		
		Если УровеньДоступа.УправлениеСписком
		 Или УровеньДоступа.ИзменениеТекущего Тогда
		
			ЗаполнитьЗначенияСвойств(Форма, НаборЗаписей[0],
				"ПотребоватьСменуПароляПриВходе,
				|СрокДействияНеОграничен,
				|СрокДействия,
				|ПросрочкаРаботыВПрограммеДоЗапрещенияВхода");
		Иначе
			Форма.ПотребоватьСменуПароляПриВходе = НаборЗаписей[0].ПотребоватьСменуПароляПриВходе;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

// Для форм элементов справочников Пользователи и ВнешниеПользователи.
//
// Параметры:
//  Форма - ФормаКлиентскогоПриложения
//  ТекущийОбъект - СправочникОбъект.Пользователи
//                - СправочникОбъект.ВнешниеПользователи
//
Процедура УстановитьСведенияОПользователе(Форма, ТекущийОбъект) Экспорт
	
	Если ОбщегоНазначения.РазделениеВключено() Тогда
		Возврат;
	КонецЕсли;
	
	СведенияОПользователе = Новый Структура(
		"ПотребоватьСменуПароляПриВходе,
		|СрокДействияНеОграничен,
		|СрокДействия,
		|ПросрочкаРаботыВПрограммеДоЗапрещенияВхода");
	
	ЗаполнитьЗначенияСвойств(СведенияОПользователе, Форма);
	
	ТекущийОбъект.ДополнительныеСвойства.Вставить("РасширенныеСвойстваПользователяИБ",
		СведенияОПользователе);
	
КонецПроцедуры

// Параметры:
//  ОписаниеПользователя - ПользовательИнформационнойБазы
//                       - УникальныйИдентификатор - идентификатор пользователя ИБ.
//
// Возвращаемое значение:
//  Структура:
//   * НетПрав - Булево
//   * НедостаточноПравДляВхода - Булево
//
Функция НаличиеПрав(ОписаниеПользователя) Экспорт
	
	Результат = Новый Структура;
	Результат.Вставить("НетПрав", Ложь);
	Результат.Вставить("НедостаточноПравДляВхода", Ложь);
	
	Если ТипЗнч(ОписаниеПользователя) = Тип("УникальныйИдентификатор") Тогда
		ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(
			ОписаниеПользователя);
		
		Если ПользовательИБ = Неопределено Тогда
			Возврат Результат;
		КонецЕсли;
	Иначе
		ПользовательИБ = ОписаниеПользователя;
	КонецЕсли;
	
	Для Каждого Роль Из ПользовательИБ.Роли Цикл
		Прервать;
	КонецЦикла;
	
	Результат.НетПрав = (Роль = Неопределено);
	
	Результат.НедостаточноПравДляВхода =
		Не Пользователи.ЕстьПраваДляВходаВПрограмму(ПользовательИБ, Ложь);
	
	Возврат Результат;
	
КонецФункции

// Параметры:
//  ПользовательОбъект - СправочникОбъект.Пользователи
//                     - СправочникОбъект.ВнешниеПользователи - или ДанныеФормыСтруктура этих объектов.
//
Функция ОтличаютсяСохраненныеСвойстваПользователяИБ(ПользовательОбъект) Экспорт
	
	Запрос = ЗапросСвойств(ПользовательОбъект.Ссылка);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Не Выборка.Следующий() Тогда
		Выборка = Неопределено;
	КонецЕсли;
	
	Свойства = НовыеСвойстваПользователя(ПользовательОбъект.Ссылка, Выборка, ПользовательОбъект);
	
	Возврат Свойства <> Неопределено;
	
КонецФункции

// Возвращаемое значение:
//  Булево
//
Функция ЗадатьВопросПроОтключениеOpenIDConnect(Признак = Null) Экспорт
	
	РешениеПринято = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"ОтключениеАутентификацииOpenIDConnectПослеОбновленияИБ", "РешениеПринято", Неопределено, , "");
	
	Возврат РешениеПринято = Признак;
	
КонецФункции

// Параметры:
//  Отключить - Булево
//
Процедура ОбработатьОтветПроОтключениеOpenIDConnect(Отключить) Экспорт
	
	Если Отключить Тогда
		СброситьАутентификациюOpenIDConnectУВсехПользователей();
	КонецЕсли;
	
	ОбщегоНазначения.ХранилищеОбщихНастроекСохранить(
		"ОтключениеАутентификацииOpenIDConnectПослеОбновленияИБ", "РешениеПринято", Отключить, , "");
	
КонецПроцедуры

// Процедура обновляет данные регистра при изменении свойств пользователя ИБ,
// связанного с элементом справочника Пользователи и ВнешниеПользователи.
//
// Параметры:
//  Пользователь - СправочникСсылка.Пользователи
//               - СправочникСсылка.ВнешниеПользователи
//               - Неопределено - для всех.
//
//  ЕстьИзменения - Булево - (возвращаемое значение) - если производилась запись,
//                  устанавливается Истина, иначе не изменяется.
//
Процедура ОбновитьДанныеРегистра(Пользователь = Неопределено, ЕстьИзменения = Неопределено) Экспорт
	
	Если Пользователь = Неопределено Тогда
		УдалитьСведенияОбУдаленныхПользователях(Пользователь, ЕстьИзменения);
	КонецЕсли;
	
	Запрос = ЗапросСвойств(Пользователь);
	Выборка = Запрос.Выполнить().Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Свойства = НовыеСвойстваПользователя(Выборка.Ссылка, Выборка);
		Если Свойства = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		// @skip-check query-in-loop - Порционная обработка данных в транзакции
		ОбновитьСведенияОПользователе(Выборка.Ссылка,,, ЕстьИзменения);
	КонецЦикла;
	
КонецПроцедуры

// Параметры:
//  Пользователь - СправочникСсылка.Пользователи
//               - СправочникСсылка.ВнешниеПользователи
//
//  Выборка - ВыборкаИзРезультатаЗапроса
//          - СтрокаТаблицыЗначений
//
//  ПользовательОбъект - СправочникОбъект.Пользователи
//                     - СправочникОбъект.ВнешниеПользователи
//                     - ДанныеФормыСтруктура
//                     - Неопределено
//
//  ПользовательИБ - ПользовательИнформационнойБазы
//                 - Неопределено
//
Функция НовыеСвойстваПользователя(Пользователь, Выборка,
			ПользовательОбъект = Неопределено, ПользовательИБ = Неопределено) Экспорт
	
	ТекущиеСвойства = Новый Структура;
	ТекущиеСвойства.Вставить("ПометкаУдаления", Ложь);
	ТекущиеСвойства.Вставить("ИдентификаторПользователяИБ",
		ОбщегоНазначенияКлиентСервер.ПустойУникальныйИдентификатор());
	
	ЭтоВнешнийПользователь = ТипЗнч(Пользователь) = Тип("СправочникСсылка.ВнешниеПользователи");
	Свойства = НовыеСвойства(ЭтоВнешнийПользователь);
	
	Если Выборка <> Неопределено И Выборка.СрокДействия <> Null Тогда
		ЗаполнитьЗначенияСвойств(Свойства, Выборка,
			"ПотребоватьСменуПароляПриВходе,
			|СрокДействияНеОграничен,
			|СрокДействия,
			|ПросрочкаРаботыВПрограммеДоЗапрещенияВхода");
	КонецЕсли;
	
	ИменаСвойствАутентификации =
	"АутентификацияСтандартная,
	|АутентификацияOpenID,
	|АутентификацияOpenIDConnect,
	|АутентификацияТокеномДоступа,
	|АутентификацияОС";
	
	Если ПользовательОбъект <> Неопределено Тогда
		Если ТипЗнч(ПользовательОбъект) <> Тип("ДанныеФормыСтруктура")
		   И ПользовательОбъект.ДополнительныеСвойства.Свойство("РасширенныеСвойстваПользователяИБ")
		   И ТипЗнч(ПользовательОбъект.ДополнительныеСвойства.РасширенныеСвойстваПользователяИБ) = Тип("Структура") Тогда
			
			РасширенныеСвойства = ПользовательОбъект.ДополнительныеСвойства.РасширенныеСвойстваПользователяИБ;
			УровеньДоступа = ПользователиСлужебный.УровеньДоступаКСвойствамПользователя(ПользовательОбъект);
			Если УровеньДоступа.НастройкиДляВхода Тогда
				ЗаполнитьЗначенияСвойств(Свойства, РасширенныеСвойства,
					"ПотребоватьСменуПароляПриВходе,
					|СрокДействияНеОграничен,
					|СрокДействия,
					|ПросрочкаРаботыВПрограммеДоЗапрещенияВхода");
			Иначе
				Свойства.ПотребоватьСменуПароляПриВходе =
					РасширенныеСвойства.ПотребоватьСменуПароляПриВходе;
			КонецЕсли;
		КонецЕсли;
		Если ТипЗнч(ПользовательОбъект) <> Тип("ДанныеФормыСтруктура")
		   И ПользовательОбъект.ДополнительныеСвойства.Свойство("ХранимыеСвойстваПользователяИБ")
		   И ТипЗнч(ПользовательОбъект.ДополнительныеСвойства.ХранимыеСвойстваПользователяИБ) = Тип("Структура") Тогда
			
			ХранимыеСвойства = ПользовательОбъект.ДополнительныеСвойства.ХранимыеСвойстваПользователяИБ;
			ПромежуточнаяСтруктура = Новый Структура(ИменаСвойствАутентификации);
			ЗаполнитьЗначенияСвойств(ПромежуточнаяСтруктура, Свойства);
			ЗаполнитьЗначенияСвойств(ПромежуточнаяСтруктура, ХранимыеСвойства);
			ЗаполнитьЗначенияСвойств(Свойства, ПромежуточнаяСтруктура);
		КонецЕсли;
		ЗаполнитьЗначенияСвойств(ТекущиеСвойства, ПользовательОбъект);
		
	ИначеЕсли Выборка <> Неопределено Тогда
		ЗаполнитьЗначенияСвойств(ТекущиеСвойства, Выборка);
	КонецЕсли;
	
	Если ПользовательИБ = Неопределено Тогда
		ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(
			ТекущиеСвойства.ИдентификаторПользователяИБ);
	КонецЕсли;
	
	Свойства.ВходВПрограммуОграничен = ЗначениеЗаполнено(Свойства.СрокДействия)
		Или ЗначениеЗаполнено(Свойства.ПросрочкаРаботыВПрограммеДоЗапрещенияВхода);
	
	Если ПользовательИБ <> Неопределено Тогда
		ВходВПрограммуРазрешен = Пользователи.ВходВПрограммуРазрешен(ПользовательИБ);
		ЗаполнитьЗначенияСвойств(Свойства, ПользовательИБ,,
			"Язык, ЗащитаОтОпасныхДействий" + ?(ВходВПрограммуРазрешен, "",
				"," + ИменаСвойствАутентификации));
		
		Если Не ВходВПрограммуРазрешен
		   И ХранимыеСвойства = Неопределено
		   И Выборка <> Неопределено Тогда
			
			ЗаполнитьЗначенияСвойств(Свойства, Выборка, ИменаСвойствАутентификации);
		КонецЕсли;
		
		Если ТипЗнч(ПользовательИБ.Язык) = Тип("ОбъектМетаданных") Тогда
			Свойства.Язык = ПользовательИБ.Язык.Имя;
		КонецЕсли;
		Свойства.ЗащитаОтОпасныхДействий =
			ПользовательИБ.ЗащитаОтОпасныхДействий.ПредупреждатьОбОпасныхДействиях;
		Свойства.ВходВПрограммуРазрешен = ВходВПрограммуРазрешен;
		НаличиеПрав = НаличиеПрав(ПользовательИБ);
		ЗаполнитьЗначенияСвойств(Свойства, НаличиеПрав);
	КонецЕсли;
	
	Если ТекущиеСвойства.ПометкаУдаления Тогда
		Свойства.НомерКартинкиСостояния = 1 + ?(ЭтоВнешнийПользователь, 6, 0);
		
	ИначеЕсли ПользовательИБ = Неопределено Тогда
		Свойства.НомерКартинкиСостояния = 15 + ?(ЭтоВнешнийПользователь, 3, 0);
		
	ИначеЕсли Не Свойства.ВходВПрограммуРазрешен
	      Или Свойства.НетПрав
	      Или Свойства.НедостаточноПравДляВхода Тогда
		
		Свойства.НомерКартинкиСостояния = 13 + ?(ЭтоВнешнийПользователь, 3, 0);
		
	ИначеЕсли Свойства.ВходВПрограммуОграничен Тогда
		Свойства.НомерКартинкиСостояния = 14 + ?(ЭтоВнешнийПользователь, 3, 0);
	Иначе
		Свойства.НомерКартинкиСостояния = 2 + ?(ЭтоВнешнийПользователь, 6, 0);
	КонецЕсли;
	
	Если Выборка = Неопределено Тогда
		Возврат Свойства;
	КонецЕсли;
	
	Для Каждого КлючИЗначение Из Свойства Цикл
		Если Выборка[КлючИЗначение.Ключ] <> Свойства[КлючИЗначение.Ключ] Тогда
			Возврат Свойства;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Неопределено;
	
КонецФункции

// Параметры:
//  Пользователь - СправочникСсылка.Пользователи
//               - СправочникСсылка.ВнешниеПользователи
//
//  ПользовательОбъект - СправочникОбъект.Пользователи
//                     - СправочникОбъект.ВнешниеПользователи
//                     - Неопределено
//
//  ПользовательИБ - ПользовательИнформационнойБазы
//                 - Неопределено
//
//  ЕстьИзменения - Булево - возвращаемое значение.
//
Процедура ОбновитьСведенияОПользователе(Пользователь, ПользовательОбъект = Неопределено,
			ПользовательИБ = Неопределено, ЕстьИзменения = Ложь) Экспорт
	
	Блокировка = Новый БлокировкаДанных;
	Если ТипЗнч(Пользователь) = Тип("СправочникСсылка.ВнешниеПользователи") Тогда
		ЭлементБлокировки = Блокировка.Добавить("Справочник.ВнешниеПользователи");
	Иначе
		ЭлементБлокировки = Блокировка.Добавить("Справочник.Пользователи");
	КонецЕсли;
	ЭлементБлокировки.УстановитьЗначение("Ссылка", Пользователь);
	ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.СведенияОПользователях");
	ЭлементБлокировки.УстановитьЗначение("Пользователь", Пользователь);
	
	Запрос = ЗапросСвойств(Пользователь);
	
	НачатьТранзакцию();
	Попытка
		Блокировка.Заблокировать();
		Выборка = Запрос.Выполнить().Выбрать();
		Если Не Выборка.Следующий() Тогда
			Выборка = Неопределено;
		КонецЕсли;
		Свойства = НовыеСвойстваПользователя(Пользователь, Выборка, ПользовательОбъект, ПользовательИБ);
		Если Свойства <> Неопределено Тогда
			НаборЗаписей = СлужебныйНаборЗаписей(РегистрыСведений.СведенияОПользователях);
			НаборЗаписей.Отбор.Пользователь.Установить(Пользователь);
			НаборЗаписей.Прочитать();
			Если НаборЗаписей.Количество() = 0 Тогда
				Запись = НаборЗаписей.Добавить();
				Запись.Пользователь = Пользователь;
			Иначе
				Запись = НаборЗаписей[0];
			КонецЕсли;
			ЗаполнитьЗначенияСвойств(Запись, Свойства);
			НаборЗаписей.Записать();
			ЕстьИзменения = Истина;
		КонецЕсли;
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

Функция НовыеСвойства(ЭтоВнешнийПользователь)
	
	Свойства = Новый Структура;
	Свойства.Вставить("НомерКартинкиСостояния", 0);
	
	Свойства.Вставить("ПотребоватьСменуПароляПриВходе", Ложь);
	Свойства.Вставить("СрокДействияНеОграничен", Ложь);
	Свойства.Вставить("СрокДействия", '00010101');
	Свойства.Вставить("ПросрочкаРаботыВПрограммеДоЗапрещенияВхода", 0);
	
	Свойства.Вставить("ВходВПрограммуРазрешен", Ложь);
	Свойства.Вставить("ВходВПрограммуОграничен", Ложь);
	Свойства.Вставить("НетПрав", Ложь);
	Свойства.Вставить("НедостаточноПравДляВхода", Ложь);
	Свойства.Вставить("Имя", "");
	Свойства.Вставить("АдресЭлектроннойПочты", "");
	Свойства.Вставить("АутентификацияСтандартная", Ложь);
	Свойства.Вставить("ЗапрещеноИзменятьПароль", Ложь);
	Свойства.Вставить("ЗапрещеноВосстанавливатьПароль", Ложь);
	Свойства.Вставить("ПоказыватьВСпискеВыбора", Ложь);
	Свойства.Вставить("АутентификацияOpenID", Ложь);
	Свойства.Вставить("АутентификацияOpenIDConnect", Ложь);
	Свойства.Вставить("АутентификацияТокеномДоступа", Ложь);
	Свойства.Вставить("АутентификацияОС", Ложь);
	Свойства.Вставить("ПользовательОС", "");
	Свойства.Вставить("Язык", "");
	Свойства.Вставить("ЗащитаОтОпасныхДействий", Ложь);
	
	Возврат Свойства;
	
КонецФункции

Функция ЗапросСвойств(Пользователь) Экспорт
	
	ТекстЗапроса =
	"ВЫБРАТЬ
	|	ЕСТЬNULL(Пользователи.Ссылка, СведенияОПользователях.Пользователь) КАК Ссылка,
	|	Пользователи.ИдентификаторПользователяИБ КАК ИдентификаторПользователяИБ,
	|	Пользователи.ПометкаУдаления КАК ПометкаУдаления,
	|	СведенияОПользователях.ПотребоватьСменуПароляПриВходе КАК ПотребоватьСменуПароляПриВходе,
	|	СведенияОПользователях.СрокДействияНеОграничен КАК СрокДействияНеОграничен,
	|	СведенияОПользователях.СрокДействия КАК СрокДействия,
	|	СведенияОПользователях.ПросрочкаРаботыВПрограммеДоЗапрещенияВхода КАК ПросрочкаРаботыВПрограммеДоЗапрещенияВхода,
	|	СведенияОПользователях.НомерКартинкиСостояния КАК НомерКартинкиСостояния,
	|	СведенияОПользователях.ВходВПрограммуРазрешен КАК ВходВПрограммуРазрешен,
	|	СведенияОПользователях.ВходВПрограммуОграничен КАК ВходВПрограммуОграничен,
	|	СведенияОПользователях.НетПрав КАК НетПрав,
	|	СведенияОПользователях.НедостаточноПравДляВхода КАК НедостаточноПравДляВхода,
	|	СведенияОПользователях.Имя КАК Имя,
	|	СведенияОПользователях.АдресЭлектроннойПочты КАК АдресЭлектроннойПочты,
	|	СведенияОПользователях.АутентификацияСтандартная КАК АутентификацияСтандартная,
	|	СведенияОПользователях.ЗапрещеноИзменятьПароль КАК ЗапрещеноИзменятьПароль,
	|	СведенияОПользователях.ЗапрещеноВосстанавливатьПароль КАК ЗапрещеноВосстанавливатьПароль,
	|	СведенияОПользователях.ПоказыватьВСпискеВыбора КАК ПоказыватьВСпискеВыбора,
	|	СведенияОПользователях.АутентификацияOpenID КАК АутентификацияOpenID,
	|	СведенияОПользователях.АутентификацияOpenIDConnect КАК АутентификацияOpenIDConnect,
	|	СведенияОПользователях.АутентификацияТокеномДоступа КАК АутентификацияТокеномДоступа,
	|	СведенияОПользователях.АутентификацияОС КАК АутентификацияОС,
	|	СведенияОПользователях.ПользовательОС КАК ПользовательОС,
	|	СведенияОПользователях.Язык КАК Язык,
	|	СведенияОПользователях.ЗащитаОтОпасныхДействий КАК ЗащитаОтОпасныхДействий
	|ИЗ
	|	Справочник.Пользователи КАК Пользователи
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СведенияОПользователях КАК СведенияОПользователях
	|		ПО (СведенияОПользователях.Пользователь = Пользователи.Ссылка)
	|ГДЕ
	|	&ОтборПоПользователю";
	
	Запрос = Новый Запрос;
	
	Если Пользователь = Неопределено Тогда
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ОтборПоПользователю", "ИСТИНА");
		Запрос.Текст = ТекстЗапроса + Символы.ПС + Символы.ПС
			+ "ОБЪЕДИНИТЬ ВСЕ" + Символы.ПС + Символы.ПС
			+ СтрЗаменить(ТекстЗапроса, "Справочник.Пользователи",
				"Справочник.ВнешниеПользователи");
	Иначе
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "ЛЕВОЕ СОЕДИНЕНИЕ", "ПОЛНОЕ СОЕДИНЕНИЕ");
		ТекстЗапроса = СтрЗаменить(ТекстЗапроса, "&ОтборПоПользователю",
				"Пользователи.Ссылка = &Пользователь
			|	ИЛИ СведенияОПользователях.Пользователь = &Пользователь");
		Запрос.УстановитьПараметр("Пользователь", Пользователь);
		Если ТипЗнч(Пользователь) = Тип("СправочникСсылка.Пользователи") Тогда
			Запрос.Текст = ТекстЗапроса;
		Иначе
			Запрос.Текст = СтрЗаменить(ТекстЗапроса, "Справочник.Пользователи",
				"Справочник.ВнешниеПользователи");
		КонецЕсли;
	КонецЕсли;
	
	Возврат Запрос;
	
КонецФункции

Процедура УдалитьСведенияОбУдаленныхПользователях(Пользователь, ЕстьИзменения = Ложь)
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СведенияОПользователях.Пользователь КАК Ссылка
	|ИЗ
	|	РегистрСведений.СведенияОПользователях КАК СведенияОПользователях
	|ГДЕ
	|	СведенияОПользователях.Пользователь.Ссылка ЕСТЬ NULL
	|	И &ОтборПоПользователю";
	
	Если Пользователь = Неопределено Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "&ОтборПоПользователю", "ИСТИНА");
	Иначе
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "&ОтборПоПользователю",
			"СведенияОПользователях.Пользователь = &Пользователь");
		Запрос.УстановитьПараметр("Пользователь", Пользователь);
	КонецЕсли;
	
	// АПК:1328-выкл - №648.1.1 блокировка данных не требуется при очистке избыточных записей.
	Выборка = Запрос.Выполнить().Выбрать();
	// АПК:1328-вкл
	Пока Выборка.Следующий() Цикл
		НаборЗаписей = РегистрыСведений.СведенияОПользователях.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.Пользователь.Установить(Выборка.Ссылка);
		НаборЗаписей.Записать();
		ЕстьИзменения = Истина;
	КонецЦикла;
	
КонецПроцедуры

// Создает служебный элемент справочника, который не участвует в подписках на события.
//
// Параметры:
//   Ссылка - СправочникСсылка
//
Функция СлужебныйЭлемент(Ссылка)
	
	ЭлементСправочника = Ссылка.ПолучитьОбъект();
	Если ЭлементСправочника = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ЭлементСправочника.ДополнительныеСвойства.Вставить("НеВыполнятьКонтрольУдаляемых");
	ЭлементСправочника.ДополнительныеСвойства.Вставить("ОтключитьМеханизмРегистрацииОбъектов");
	ЭлементСправочника.ОбменДанными.Получатели.АвтоЗаполнение = Ложь;
	ЭлементСправочника.ОбменДанными.Загрузка = Истина;
	
	Возврат ЭлементСправочника;
	
КонецФункции

// Создает набор записей служебного регистра, который не участвует в подписках на события.
Функция СлужебныйНаборЗаписей(МенеджерРегистра)
	
	НаборЗаписей = МенеджерРегистра.СоздатьНаборЗаписей();
	НаборЗаписей.ДополнительныеСвойства.Вставить("НеВыполнятьКонтрольУдаляемых");
	НаборЗаписей.ДополнительныеСвойства.Вставить("ОтключитьМеханизмРегистрацииОбъектов");
	НаборЗаписей.ОбменДанными.Получатели.АвтоЗаполнение = Ложь;
	НаборЗаписей.ОбменДанными.Загрузка = Истина;
	
	Возврат НаборЗаписей;
	
КонецФункции

Процедура ОбновитьСведенияОПользователяхИОтключитьАутентификацию() Экспорт
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Пользователи.Ссылка КАК Пользователь
	|ИЗ
	|	Справочник.Пользователи КАК Пользователи
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ВнешниеПользователи.Ссылка
	|ИЗ
	|	Справочник.ВнешниеПользователи КАК ВнешниеПользователи
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	СведенияОПользователях.Пользователь
	|ИЗ
	|	РегистрСведений.СведенияОПользователях КАК СведенияОПользователях
	|ГДЕ
	|	СведенияОПользователях.Пользователь.Ссылка ЕСТЬ NULL";
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	ТаблицаПользователей = РегистрыСведений.СведенияОПользователях.СоздатьНаборЗаписей().Выгрузить(, "Пользователь");
	ТаблицаПользователей.Добавить();
	
	Пока Выборка.Следующий() Цикл
		Пользователь = Выборка.Пользователь;
		
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.СведенияОПользователях");
		ЭлементБлокировки.УстановитьЗначение("Пользователь", Пользователь);
		Если ТипЗнч(Пользователь) = Тип("СправочникСсылка.Пользователи") Тогда
			ЭлементБлокировки = Блокировка.Добавить("Справочник.Пользователи");
		ИначеЕсли ТипЗнч(Пользователь) = Тип("СправочникСсылка.ВнешниеПользователи") Тогда
			ЭлементБлокировки = Блокировка.Добавить("Справочник.ВнешниеПользователи");
		Иначе
			Продолжить;
		КонецЕсли;
		ЭлементБлокировки.УстановитьЗначение("Ссылка", Пользователь);
		
		НачатьТранзакцию();
		Попытка
			Блокировка.Заблокировать();
			ЕстьИзменения = Ложь;
			// @skip-check query-in-loop - Порционная обработка данных в транзакции
			УдалитьСведенияОбУдаленныхПользователях(Пользователь, ЕстьИзменения);
			Если Не ЕстьИзменения Тогда
				ПользовательОбъект = СлужебныйЭлемент(Пользователь);
				Если ПользовательОбъект <> Неопределено Тогда
					СброситьАутентификациюНедействительногоПользователя(ПользовательОбъект);
					СброситьЛишнююАутентификациюOpenIDConnect(ПользовательОбъект);
					СтарыеСвойства = ПользовательОбъект.УдалитьСвойстваПользователяИБ.Получить();
					Если СтарыеСвойства <> Неопределено Тогда
						ПользовательОбъект.УдалитьСвойстваПользователяИБ = Новый ХранилищеЗначения(Неопределено);
						Если ТипЗнч(СтарыеСвойства) = Тип("Структура") Тогда
							ПользовательОбъект.ДополнительныеСвойства.Вставить("ХранимыеСвойстваПользователяИБ",
								ПользователиСлужебный.ХранимыеСвойстваПользователяИБ(СтарыеСвойства));
						КонецЕсли;
					КонецЕсли;
					// @skip-check query-in-loop - Порционная обработка данных в транзакции
					ОбновитьСведенияОПользователе(Пользователь, ПользовательОбъект);
					Если ПользовательОбъект.Модифицированность() Тогда
						// АПК:1363-выкл - служебная очистка хранимых свойств аутентификации, которые не участвует в обмене данными.
						ПользовательОбъект.Записать();
						// АПК:1363-вкл
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ВызватьИсключение;
		КонецПопытки;
		
	КонецЦикла;
	
	Если СтандартныеПодсистемыСервер.ЭтоБазоваяВерсияКонфигурации() Тогда
		СброситьАутентификациюOpenIDConnectУВсехПользователей();
		
	ИначеЕсли ЗадатьВопросПроОтключениеOpenIDConnect(Неопределено)
	        И ЕстьВключеннаяАутентификациюOpenIDConnect() Тогда
		
		ОбщегоНазначения.ХранилищеОбщихНастроекСохранить(
			"ОтключениеАутентификацииOpenIDConnectПослеОбновленияИБ", "РешениеПринято", Null, , "");
	КонецЕсли;
	
КонецПроцедуры

Процедура СброситьАутентификациюНедействительногоПользователя(ПользовательОбъект)
	
	Если Не ПользовательОбъект.Недействителен
	   И Не ПользовательОбъект.ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(
		ПользовательОбъект.ИдентификаторПользователяИБ);
	
	Если ПользовательИБ = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Записать = Ложь;
	Если ПользовательИБ.АутентификацияСтандартная Тогда
		ПользовательИБ.АутентификацияСтандартная = Ложь;
		Записать = Истина;
	КонецЕсли;
	
	Если ПользовательИБ.АутентификацияOpenID Тогда
		ПользовательИБ.АутентификацияOpenID = Ложь;
		Записать = Истина;
	КонецЕсли;
	
	Если ПользовательИБ.АутентификацияOpenIDConnect Тогда
		ПользовательИБ.АутентификацияOpenIDConnect = Ложь;
		Записать = Истина;
	КонецЕсли;
	
	Если ПользовательИБ.АутентификацияТокеномДоступа Тогда
		ПользовательИБ.АутентификацияТокеномДоступа = Ложь;
		Записать = Истина;
	КонецЕсли;
	
	Если ПользовательИБ.АутентификацияОС Тогда
		ПользовательИБ.АутентификацияОС = Ложь;
		Записать = Истина;
	КонецЕсли;
	
	Если Записать Тогда
		ПользовательИБ.Записать();
	КонецЕсли;
	
КонецПроцедуры

Процедура СброситьЛишнююАутентификациюOpenIDConnect(ПользовательОбъект)
	
	Если ПользовательОбъект.Недействителен
	 Или ПользовательОбъект.ПометкаУдаления Тогда
		Возврат;
	КонецЕсли;
	
	ПользовательИБ = ПользователиИнформационнойБазы.НайтиПоУникальномуИдентификатору(
		ПользовательОбъект.ИдентификаторПользователяИБ);
	
	Если ПользовательИБ = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Не ПользовательИБ.АутентификацияСтандартная
	   И Не ПользовательИБ.АутентификацияOpenID
	   И    ПользовательИБ.АутентификацияOpenIDConnect
	   И Не ПользовательИБ.АутентификацияТокеномДоступа
	   И Не ПользовательИБ.АутентификацияОС Тогда
		
		ПользовательИБ.АутентификацияOpenIDConnect = Ложь;
		ПользовательИБ.Записать();
	КонецЕсли;
	
КонецПроцедуры

Процедура СброситьАутентификациюOpenIDConnectУВсехПользователей()
	
	ВсеПользователиИБ = ПользователиИнформационнойБазы.ПолучитьПользователей();
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Пользователи.Ссылка КАК Ссылка,
	|	Пользователи.ИдентификаторПользователяИБ КАК ИдентификаторПользователяИБ
	|ИЗ
	|	Справочник.Пользователи КАК Пользователи
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ВнешниеПользователи.Ссылка,
	|	ВнешниеПользователи.ИдентификаторПользователяИБ
	|ИЗ
	|	Справочник.ВнешниеПользователи КАК ВнешниеПользователи";
	Выгрузка = Запрос.Выполнить().Выгрузить();
	
	Для Каждого ПользовательИБ Из ВсеПользователиИБ Цикл
		Если Не ПользовательИБ.АутентификацияOpenIDConnect Тогда
			Продолжить;
		КонецЕсли;
		ПользовательИБ.АутентификацияOpenIDConnect = Ложь;
		Строка = Выгрузка.Найти(ПользовательИБ.УникальныйИдентификатор, "ИдентификаторПользователяИБ");
		НачатьТранзакцию();
		Попытка
			ПользовательИБ.Записать();
			Если Строка <> Неопределено Тогда
				// @skip-check query-in-loop - Порционная обработка данных в транзакции
				ОбновитьСведенияОПользователе(Строка.Ссылка);
			КонецЕсли;
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ВызватьИсключение;
		КонецПопытки;
	КонецЦикла;
	
КонецПроцедуры

Функция ЕстьВключеннаяАутентификациюOpenIDConnect()
	
	ВсеПользователиИБ = ПользователиИнформационнойБазы.ПолучитьПользователей();
	
	Для Каждого ПользовательИБ Из ВсеПользователиИБ Цикл
		Если ПользовательИБ.АутентификацияOpenIDConnect Тогда
			Возврат Истина;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Ложь;
	
КонецФункции

#КонецОбласти

#КонецЕсли
