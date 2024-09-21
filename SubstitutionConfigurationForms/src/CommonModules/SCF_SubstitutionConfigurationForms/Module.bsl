// @strict-types

#Region Internal

Procedure FormGetProcessingFormGetProcessing(
	Source, FormType, Parameters, SelectedForm, AdditionalInformation, StandardProcessing) Export

	SetPrivilegedMode(True);
	
	ClearThisSubstitution();
	
	MetadataSource = Metadata.FindByType(TypeOf(Source));
	If MetadataSource = Undefined Then
		Return;
	EndIf;
	
	FullNameForm = StrTemplate("%1.%2", MetadataSource.FullName(), FormType);
	Substitution = SubstitutionObject(FullNameForm);
	If Substitution.Ref = Undefined Then
		Return;
	EndIf;
	
	StandardProcessing = False;
	SelectedForm = "CommonForm.SCF_SubstitutionConfigurationForm";
	
	ObjectName = AttachSubstitution(Substitution.Ref);
	ExternalMetadata = ExternalDataProcessors.Create(ObjectName).Metadata();
	FormForOpen = MetadataObjectForm(ExternalMetadata, Substitution.FormName);
	If FormForOpen = Undefined Then
		Raise NStr("ru = 'Не удалось получить подменяющую форму!'; en = 'Failed to get a substitute form!'");
	EndIf;

	ThisSubstitution = NewThisSubstitution();
	ThisSubstitution.Ref = Substitution.Ref;
	ThisSubstitution.SubstitutionFormPath = FormForOpen.FullName();
	ThisSubstitution.SourceFormPath = FullNameForm;
	SetThisSubstitution(ThisSubstitution);
	
EndProcedure

// Substitution object.
// 
// Parameters:
//  FullNameForm - String
// 
// Returns:
//  Structure:
//  * Ref - Undefined, CatalogRef -
//  * FormName - String
Function SubstitutionObject(FullNameForm) Export

	Result = New Structure();
	Result.Insert("Ref", Undefined);
	Result.Insert("FormName", "");

	Query = New Query;
	Query.SetParameter("FullNameForm", FullNameForm);
	Query.Text = 
	"SELECT
	|	Substitutions.Substitution AS Ref,
	|	Substitutions.FormName
	|FROM
	|	InformationRegister.SCF_SubstitutionConfigurationForms AS Substitutions
	|WHERE
	|	Substitutions.FullNameForm = &FullNameForm";
	ResultQuery = Query.Execute();
	If Not ResultQuery.IsEmpty() Then
		Select = ResultQuery.Select();
		Select.Next();
		FillPropertyValues(Result, Select);
	EndIf;
	
	Return Result;

EndFunction

// Attach substitution.
// 
// Parameters:
//  Ref - CatalogRef
// 
// Returns:
//  String
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

// Clear this substitution.
Procedure ClearThisSubstitution() Export
	
	SetThisSubstitution();
	
EndProcedure

// Set this substitution.
// 
// Parameters:
//  Parameters - see NewThisSubstitution
// 
Procedure SetThisSubstitution(Val Parameters = Undefined) Export
	
	If Parameters = Undefined Then
		Parameters = NewThisSubstitution();
	EndIf;
	
	SessionParameters.SCF_ThisSubstitution = new FixedStructure(Parameters);
	
EndProcedure

// New this substitution.
// 
// Returns:
//  Structure:
// * Ref - Undefined, CatalogRef -
// * SubstitutionFormPath - String
// * SourceFormPath - String
Function NewThisSubstitution() Export
	
	Result = new Structure();
	Result.Insert("Ref", Undefined);
	Result.Insert("SubstitutionFormPath", "");
	Result.Insert("SourceFormPath", "");
	
	Return Result;
	
EndFunction

// This substitution.
// 
// Returns:
//  See NewThisSubstitution
Function ThisSubstitution() Export
	
	SetPrivilegedMode(True);
	
	Try
		Result = SessionParameterThisSubstitution();
	Except
		ClearThisSubstitution();
		Result = SessionParameterThisSubstitution();
	EndTry;
	
	//@skip-check constructor-function-return-section - Баг ЕДТ
	Return Result; //See NewThisSubstitution
	
EndFunction

// Substitute source form name.
// 
// Parameters:
//  FormPath - String
Procedure SubstituteSourceFormName(FormPath) Export
	
	Substitution = ThisSubstitution();
	If Upper(FormPath) = Upper(Substitution.SubstitutionFormPath) Then
		FormPath = Substitution.SourceFormPath;
	EndIf;
	
EndProcedure

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

Function MetadataObjectForm(MetadataObject, FormName = "")
	
	If IsBlankString(FormName) Then
		//@skip-check property-return-type, dynamic-access-method-not-found, statement-type-change - Error EDT
		FormForOpen = MetadataObject.DefaultForm; //MetadataObject
	Else
		//@skip-check property-return-type, dynamic-access-method-not-found, statement-type-change - Error EDT
		FormForOpen = MetadataObject.Forms.Find(FormName); //MetadataObject
	EndIf;
	
	Return FormForOpen;
	
EndFunction

Function SessionParameterThisSubstitution()
	
	Return SessionParameters.SCF_ThisSubstitution;
	
EndFunction

#EndRegion
