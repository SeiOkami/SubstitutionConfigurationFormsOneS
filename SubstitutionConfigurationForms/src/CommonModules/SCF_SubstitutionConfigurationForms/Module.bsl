// @strict-types

#Region Internal

Procedure FormGetProcessingFormGetProcessing(
	Source, FormType, Parameters, SelectedForm, AdditionalInformation, StandardProcessing) Export

	SetPrivilegedMode(True);
	
	MetadataSource = Metadata.FindByType(TypeOf(Source));
	If MetadataSource = Undefined Then
		Return;
	EndIf;
	
	FullNameForm = StrTemplate("%1.%2", MetadataSource.FullName(), FormType);
	SubstitutionObject = SubstitutionObject(FullNameForm);
	If SubstitutionObject = Undefined Then
		Return;
	EndIf;
	
	StandardProcessing = False;
	SessionParameters.SCF_ThisSubstitution = SubstitutionObject;
	SelectedForm = "CommonForm.SCF_SubstitutionConfigurationForm";
	
EndProcedure

// Substitution object.
// 
// Parameters:
//  FullNameForm - String
// 
// Returns:
//  CatalogRef
Function SubstitutionObject(FullNameForm) Export

	Query = New Query;
	Query.SetParameter("FullNameForm", FullNameForm);
	Query.Text = 
	"SELECT
	|	Substitutions.Substitution
	|FROM
	|	InformationRegister.SCF_SubstitutionConfigurationForms AS Substitutions
	|WHERE
	|	Substitutions.FullNameForm = &FullNameForm";
	ResultQuery = Query.Execute();
	If ResultQuery.IsEmpty() Then
		Return Undefined;
	Else
		Select = ResultQuery.Select();
		Select.Next();
		Return Select[0];
	EndIf;

EndFunction

// See AdditionalReportsAndDataProcessors.AttachExternalDataProcessor
Function AttachSubstitution(Ref) Export
	
	Names = AdditionalDataProcessorsNames();
	Code = StrTemplate("%1.%2(Ref)", Names.ObjectName, Names.MethodName);
	
	//@skip-check server-execution-safe-mode
	Return Eval(Code);
	
EndFunction

// Name of additional data processors module
//   
// Returns:
//  See NewSslObjectName
Function AdditionalDataProcessorsNames() Export

	SslParameters = SslParameters(); 
	
	For Each Element In SslParameters.AdditionalDataProcessorsNames Do

		If Metadata.CommonModules.Find(Element.ObjectName) <> Undefined Then
			//@skip-check constructor-function-return-section - Error EDT
			Return Element;
		EndIf;

	EndDo;

	Raise "Additional data processors not found!";

EndFunction

#EndRegion

#Region Private

// Ssl parameters.
// 
// Returns:
//  Structure:
// * AdditionalDataProcessorsNames - Array of See NewSslObjectName
Function SslParameters()
	
	Result = New Structure;
	Result.Insert("AdditionalDataProcessorsNames", New Array);
	
	AddSslObjectName(Result, "AdditionalReportsAndDataProcessors", "AttachExternalDataProcessor");
	AddSslObjectName(Result, "ДополнительныеОтчетыИОбработки", "ПодключитьВнешнююОбработку");
	
	Return Result;
	
EndFunction

// Add ssl object name.
// 
// Parameters:
//  SslParameters - See SslParameters
//  ObjectName - String
//  MethodName - String
Procedure AddSslObjectName(SslParameters, ObjectName, MethodName)
	
	NewElement = NewSslObjectName(ObjectName, MethodName);
	
	SslParameters.AdditionalDataProcessorsNames.Add(NewElement);
	
EndProcedure

// New ssl object name.
// 
// Parameters:
//  ObjectName - String
//  MethodName - String
// 
// Returns:
//  Structure:
// * ObjectName - String
// * MethodName - String
Function NewSslObjectName(ObjectName, MethodName)
	
	Result = New Structure;
	Result.Insert("ObjectName", ObjectName);
	Result.Insert("MethodName", MethodName);
	
	Return Result;
	
EndFunction

#EndRegion
