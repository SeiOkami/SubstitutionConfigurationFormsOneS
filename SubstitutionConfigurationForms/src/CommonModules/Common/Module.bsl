
&Around("ObjectManagerByFullName")
Function SCF_ObjectManagerByFullName(FullName) Export
	
	NewFullName = FullName;
	SCF_SubstitutionConfigurationForms.SubstituteSourceFormName(NewFullName);
	Return ПродолжитьВызов(NewFullName);

EndFunction
