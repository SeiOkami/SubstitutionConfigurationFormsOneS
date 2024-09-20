
&Вместо("МенеджерОбъектаПоПолномуИмени")
Функция SCF_МенеджерОбъектаПоПолномуИмени(FullName) Экспорт
	
	NewFullName = FullName;
	SCF_SubstitutionConfigurationForms.SubstituteSourceFormName(NewFullName);
	Return ПродолжитьВызов(NewFullName);
	
КонецФункции
