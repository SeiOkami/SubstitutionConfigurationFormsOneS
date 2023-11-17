// @strict-types

#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	If Record.Substitution = Undefined Then
		CatalogName = SCF_SubstitutionConfigurationForms.AdditionalDataProcessorsNames().ObjectName;
		Record.Substitution = Catalogs[CatalogName].EmptyRef();
	EndIf;

EndProcedure

#EndRegion