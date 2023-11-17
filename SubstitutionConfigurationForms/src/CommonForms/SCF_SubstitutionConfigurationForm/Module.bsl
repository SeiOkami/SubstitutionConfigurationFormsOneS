// @strict-types

#Region FormEventHandlers

&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	
	ParamsForOpen = StructureFromFormDataStructure(Parameters);
	
	Substitution = SessionParameters.SCF_ThisSubstitution; //CatalogRef.AdditionalReportsAndDataProcessors
	ObjectName = SCF_SubstitutionConfigurationForms.AttachSubstitution(Substitution);

	//@skip-check property-return-type, dynamic-access-method-not-found, statement-type-change - Error EDT
	FormForOpen = ExternalDataProcessors.Create(ObjectName).Metadata().DefaultForm.FullName(); //String
	
EndProcedure

&AtClient
Procedure OnOpen(Cancel)
	
	Cancel = True;
	
	StructParams = ParamsForOpen; //Structure
	OpenForm(FormForOpen, StructParams);
	
EndProcedure

#EndRegion

#Region Private

// Structure from form data structure.
// 
// Parameters:
//  FormDataStructure - FormDataStructure
// 
// Returns:
//  Structure
&AtServerNoContext
Function StructureFromFormDataStructure(FormDataStructure)
    
    Result = New Structure;
    
    XMLWriter = Новый XMLWriter;
    XMLWriter.SetString();
    XDTOSerializer.WriteXML(XMLWriter, FormDataStructure, XMLTypeAssignment.Explicit);
    StringXML = XMLWriter.Close();
    
    XMLReader = Новый XMLReader;
    XMLReader.SetString(StringXML);
    
    While XMLReader.Read() Do
        
        If XMLReader.Name = "structure"
            AND XMLReader.GetAttribute("name") = "parameters"
            AND XMLReader.NodeType = XMLNodeType.EndElement Then
            
            Break;
                        
        ElsIf XMLReader.Name = "field" Then
            
            ThisKey = XMLReader.GetAttribute("name");
			If ValueIsFilled(ThisKey) Then
                Result.Insert(ThisKey);
            EndIf;
            
        EndIf;
        
    EndDo;
    
    XMLReader.Close();
    
    FillPropertyValues(Result, FormDataStructure);
    
    Return Result;
    
EndFunction

#EndRegion
